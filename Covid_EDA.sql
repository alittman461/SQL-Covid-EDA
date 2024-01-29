-- EDA DEATHS

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths as Death_Percentage

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM covid_deaths
ORDER BY 1,2

-- Shows what percentage of population has tested positive for Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as Cases_Percentage
FROM covid_deaths
--WHERE location like '%States%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
FROM covid_deaths
-- WHERE location like '%States%'
Group by Location, Population
ORDER BY Percent_Population_Infected desc

-- Showing Countries with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM covid_deaths
-- WHERE location like '%States%'
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Death_Count desc

-- Total Death Count by Continent

SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM covid_deaths
-- WHERE location like '%States%'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM covid_deaths
--WHERE location like '%States%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- EDA VACCINATIONS

SELECT * FROM covid_vaccinations

-- JOIN TABLES ON LOCATION AND DATE

SELECT * FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations
--, (Total_Vaccinations/Population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, total_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations
--, (Total_Vaccinations/Population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (Total_Vaccinations/population)*100
FROM pop_vs_vac

-- TEMP TABLE

DROP TABLE if exists Percent_Population_Vaccinated;
CREATE TEMPORARY TABLE Percent_Population_Vaccinated
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
);

INSERT INTO Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations
--, (Total_Vaccinations/Population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3
;

SELECT *, (Total_Vaccinations/population)*100
FROM Percent_Population_Vaccinated

-- CREATING VIEW TO STORE DATA FOR VISUALIZATIONS

CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations
--, (Total_Vaccinations/Population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM Percent_Population_Vaccinated