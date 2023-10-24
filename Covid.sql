
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Lets select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 -- makes this orderd by  location and date

-- Lets start with a super simple calculation and get total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as Float)/CAST(total_cases as float)) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' and continent is not null
ORDER BY 1,2

-- Looking at the total cases vs the population
-- As of 9-6-2023 the U.S.A has a 30.58%
SELECT location, date, total_cases, population, (CAST(total_cases as Float)/CAST(population as float)) * 100 as PercentofGettingCovid
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%united states' and continent is not null
ORDER BY 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(CAST(total_cases as float)) as HighestInfectionCount, MAX((CAST(total_cases as Float))/CAST(population as float)) * 100 as HighestInfectionPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 desc

-- Looking for highest death count per population
-- We can see the USA has the highest total death count
SELECT location, population, MAX(CAST(total_deaths as float)) as Highest_total_death_count, MAX((CAST(total_deaths as float))/CAST(population as float)) * 100 as Highest_percent_in_country
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 3 desc

-- Lets find the total deaths for each continent
-- Looks like the first query is more accuarte but shows extra information
SELECT location, MAX(CAST(total_deaths as float)) as Total_Deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 2 desc

SELECT continent, MAX(CAST(total_deaths as float)) as Total_Deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 desc


-- showing global death percentage for the world

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths) / SUM(new_cases)) *100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 desc


-- this was us joining the two tables together
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- Looking at total population vs vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.date, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- so that previous query shows the new vaccinations per day but now our goal is to 
-- create a rolling count. So to add the new vaccinations as they happen 
-- so this query shows the TOTAL vaccinations for a country at all times in the left most column and that is because
-- we only partioned by location. Next query will show different
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as float) as new_vac,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location) as rolling_count
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- if we want the count to add as new vaccinations come as in a true rolling count
-- then we also need to put order by date and location in our partition statement

SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as float) as new_vac,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_count_vaccinations
FROM PortfolioProject..CovidDeaths dea
--(rolling_count_vaccinations / population) *100 gets us an error
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- now our goal is going to be getting rolling count vaccinations / by population
-- we can not divide with a column we just made, it causes an error, so we have two ways to go about this

--1) using CTE

with PopvsVac
as(
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as float) as new_vac,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_count_vaccinations
FROM PortfolioProject..CovidDeaths dea
--(rolling_count_vaccinations / population) *100 gets us an error
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rolling_count_vaccinations/population) *100 as vaccination_percentage
FROM PopvsVac
WHERE location LIKE '%albania%'
ORDER BY date

-- Using a Temp table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
continent VARCHAR(200),
location VARCHAR(200),
date datetime,
population float,
new_vaccinations float,
rolling_count_vaccinations float,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as float) as new_vac,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_count_vaccinations
FROM PortfolioProject..CovidDeaths dea
--(rolling_count_vaccinations / population) *100 gets us an error
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

-- that creates our temp table now lets use it
-- if we need to edit the temp table we will need to delete it or use 
-- Drop table if exists

SELECT *, (rolling_count_vaccinations/population) *100 as vaccination_percentage
FROM #PercentPopulationVaccinated

-- Lastly lets make #PercentPopulationVaccinated a view 

USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as float) as new_vac,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_count_vaccinations
FROM PortfolioProject..CovidDeaths dea
--(rolling_count_vaccinations / population) *100 gets us an error
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

DROP VIEW PercentPopulationVaccinated

--------------------------------------------------------

-- Here are the Tableau Queries

-- 1.
-- showing global death percentage for the world

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths) / SUM(new_cases)) *100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 desc



--2.
SELECT location, SUM(new_deaths) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is null and location not in ('World', 'European Union', 'International', 'High Income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY Total_Death_Count desc



--3.
SELECT location, population, MAX(CAST(total_cases as FLOAT)) as highest_infected_count, MAX(CAST(total_cases as FLOAT)/population) * 100 as Percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Percent_population_infected desc




--4.
SELECT location, population, date, MAX(CAST(total_cases as FLOAT)) as highest_infected_count, MAX(CAST(total_cases as FLOAT)/population) * 100 as Percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY Percent_population_infected desc