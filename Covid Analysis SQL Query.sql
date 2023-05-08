--- Covid 19 Data Exploration 
--- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
--WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccination
--ORDER BY 3,4

-- Select the data to start with 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2 -- order by 1st and 2nd column


--Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location='United States'
ORDER BY 1,2 

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as PopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location='United States'
ORDER BY 1,2 

-- Looking at Countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount ,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location='United States'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--showing the countries with the highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='Malaysia'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 


SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='Malaysia'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- Showing the continents with the highest death rate 


SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='Malaysia'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS TO SHOW TOTAL CASES VS TOTAL DEATHS 

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='United States'
WHERE continent is not null 
--GROUP BY date
--ORDER BY 1,2 


-- Looking at Total Population vs Vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccination as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccination as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND dea.location='Malaysia'
ORDER BY 2,3 


-- Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccination as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--AND dea.location='Albania'
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopVac
FROM PopvsVac





-- Temp Table 
DROP TABLE if exists #PercentTotalVaccinated 
CREATE TABLE #PercentTotalVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentTotalVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccination as vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null 
--AND dea.location='Malaysia'
ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopVac
FROM #PercentTotalVaccinated

-- Creating View to store data for later visualizations

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccination as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

Create View PercentageDeath as
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location='United States' 
WHERE continent is not null

SELECT location,DeathPercentage
FROM PercentageDeath



