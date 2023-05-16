
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

/*
START WORKING ON CovidDeaths: 
*/

Select *
From PortfolioProject..CovidDeaths
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

 --Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)))*100 as [DeathPercentage]
from PortfolioProject..coviddeaths
Where location like '%states%'
order by 1,2

--Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases, CONVERT(DECIMAL(18, 2),  ( CONVERT(DECIMAL(18, 2),total_cases) /  CONVERT(DECIMAL(18, 2),population)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select location,population,max(total_cases) as HighestInfectionCount, CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2),max((total_cases / CONVERT(DECIMAL(18, 2),population))))))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths

group by location,population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, CONVERT(DECIMAL(18, 2),MAX(Total_deaths )) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, (CONVERT(DECIMAL(18, 2),MAX(Total_deaths )))  as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS :2 cases (group by date and no using group by function)

--SELECT 
--    CONVERT(DECIMAL(18, 2), new_cases)
--from PortfolioProject..coviddeaths

--Select date,SUM(CONVERT(DECIMAL(18, 2) , new_cases)),SUM(CONVERT(DECIMAL(18, 2) , new_deaths))
--from PortfolioProject..coviddeaths
--GROUP BY date


declare @new_cases int;
         declare @new_deaths int;
		 set @new_cases = 255;
		 set @new_deaths = 255;
Select date ,SUM(CONVERT(DECIMAL(18, 2) , new_cases)) as Total_Cases,SUM(CONVERT(DECIMAL(18, 2) , new_deaths))as Total_Deaths,SUM(CONVERT(DECIMAL(18, 2) , new_cases)) / NULLIF (SUM(CONVERT(DECIMAL(18, 2) , new_deaths)),0)*100 as DeathPercentage
from PortfolioProject..coviddeaths
GROUP BY date
order by 1,2


declare @new_cases int;
         declare @new_deaths int;
		 set @new_cases = 255;
		 set @new_deaths = 255;
Select SUM(CONVERT(DECIMAL(18, 2) , new_cases)) as Total_Cases,SUM(CONVERT(DECIMAL(18, 2) , new_deaths))as Total_Deaths,SUM(CONVERT(DECIMAL(18, 2) , new_cases)) / NULLIF (SUM(CONVERT(DECIMAL(18, 2) , new_deaths)),0)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--GROUP BY date
order by 1,2

/*
NOW: WORKING ON CovidVaccinations by JOIN 2 tables: 
*/

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select *
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(DECIMAL(18, 2) ,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(DECIMAL(18, 2) ,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(DECIMAL(18, 2) ,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated