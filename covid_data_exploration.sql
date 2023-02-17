SELECT *
FROM Covid_data_exploration.dbo.CovidVaccinations$
ORDER BY 3,4;

SELECT *
FROM Covid_data_exploration.dbo.CovidDeaths$
ORDER BY 3,4; 


SELECT location, date, total_cases,new_cases,total_deaths,new_deaths,population
FROM Covid_data_exploration.dbo.CovidDeaths$
ORDER BY 1,2;

-- start: 01.01.2020 End: 30.04.2021
-- Looking at total deaths vs total cases in each country

SELECT location , MAX(CAST(total_cases as bigint)) as total_cases,SUM(CAST(new_cases as bigint)) as total_cases , Max(CAST(total_deaths as bigint)) as total_deaths, SUM(CAST(new_deaths as bigint)) as total_deaths
FROM Covid_data_exploration.dbo.CovidDeaths$
GROUP BY location
ORDER BY 1;

-- Percentage of death relative to the total cases per country
with CTEDeathTable(location,death,cases)
as (
SELECT location, Max(CAST(total_deaths as float)) as death , MAX(CAST(total_cases as float)) as cases
FROM Covid_data_exploration.dbo.CovidDeaths$
GROUP BY location
)
SELECT location, ROUND(death/cases,3)*100 as DeathPercentage
FROM CTEDeathTable
ORDER by 1;


--Percentage rate of Infection for each country compared to the population
SELECT location,population,MAX(total_cases ) as Total_cases, ROUND((MAX(total_cases )/population)*100,3) as InfectionRate
FROM Covid_data_exploration.dbo.CovidDeaths$
GROUP BY location,population
ORDER BY 1

--Showing countries with highest Death Count per population
SELECT location , population, MAX(CAST(total_deaths as bigint)) as Total_deaths , ROUND((MAX(CAST(total_deaths as bigint))/population)*100,3) as DEATHRate
FROM Covid_data_exploration.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 1


--TotalDeath per continent using view
CREATE VIEW TotalDeath as
SELECT location, population, MAX(CAST(total_deaths as bigint)) as Total_deaths, ROUND((MAX(CAST(total_deaths as bigint))/population)*100,3) as DeathRate
FROM Covid_data_exploration.dbo.CovidDeaths$
WHERE continent IS  NULL
GROUP BY location,population

SELECT *
FROM TotalDeath
Order by 1



--Looking at total Population vs Vaccinations using CTE

WITH CTE_VaccinationRate (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations as BIGINT)) over (PARTITION BY d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM Covid_data_exploration.dbo.CovidDeaths$ d
JOIN Covid_data_exploration.dbo.CovidVaccinations$ v
ON d.location=v.location
AND d.date= v.date
WHERE d.continent IS NOT NULL
)
SELECT *,RollingPeopleVaccinated/population*100
FROM CTE_VaccinationRate
ORDER BY 2,3

--Looking at total Population vs Vaccinations using TEMP Table   

DROP TABLE IF EXISTS #VaccinationRate
CREATE TABLE #VaccinationRate(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated nvarchar(255)
)

INSERT INTO #VaccinationRate 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations as BIGINT)) over (PARTITION BY d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM Covid_data_exploration.dbo.CovidDeaths$ d
JOIN Covid_data_exploration.dbo.CovidVaccinations$ v
ON d.location=v.location
AND d.date= v.date
WHERE d.continent IS NOT NULL

SELECT * ,RollingPeopleVaccinated/population*100 as VaccinationRate
FROM #VaccinationRate 
WHERE location ='Albania'
ORDER BY 2,3


