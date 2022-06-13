--Data from April 2021
--BASIC SQL DATA EXPLORATION
Select *
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

--QUERIES USED FOR TABLEAU

-- 1. --Looking at Total Cases, Total Deaths, and creating Death Percentage 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 
order by 1,2


-- 2. --TOTAL DEATH COUNT BY CONTINENT

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. FINDING THE HIGHEST PERCENT OF POPULATION INFECTED IN EACH COUNTRY BY USING AGGREGATE FUNCTION MAX ON TOTAL CASES

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. FINDING HIGHEST PERCENT OF INFECTED POPULATION AND GROUPING BY LOCATION, POPULATION AND DATE


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- 5. FINDING DEATH PERCENTAGE OF PEOPLE WHO WERE INFECTED BY COVID 19 ORDERING BY DATE DESC

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'United States'
order by date

--EXTRA QUERIES
--Looking at Total Cases vs Population
--Showing what percentage of population got Covid
SELECT location, date, population, (total_cases/population)*100 AS Percent_Of_Population_Infected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'United States'
order by 1,2

--Looking at countries with Highest Infection Rate compared to population
SELECT location, continent, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Group by location,population
order by PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount DESC


--BREAKING THINGS DOWN BY CONTINENT 
--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount DESC


--GLOBAL NUMBERS GROUPED BY DATE IN DESC ORDER

SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2

--TOTAL GLOBAL NUMBERS
SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--JOINING OUR 2 DATASETS
SELECT *
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON dea.location = vac.location
	and dea.date = vac.date

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
-- USING CTE
With PopVsVAC (Continent, Location, Date, Population, new_vaccinations, Rolling_CNT_People_Vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) AS Rolling_CNT_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
SELECT *, (Rolling_CNT_People_Vaccinated/Population)*100
FROM PopVsVAC


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_CNT_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) AS Rolling_CNT_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT *, (Rolling_CNT_People_Vaccinated/Population)*100 
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) AS Rolling_CNT_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ DEA
JOIN PortfolioProject..CovidVaccinations$ VAC
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- FINDING IF THERE IS CORRELATION BETWEEN MEDIAN AGE AND TOTAL DEATHS
SELECT location, MAX(convert(int,total_deaths)) as Total_Deaths, MAX(CONVERT(INT,median_age)) AS MedianAge
FROM PortfolioProject..CovidDeaths$
where total_deaths is not null and continent is not null
group by location
order by MedianAge DESC

