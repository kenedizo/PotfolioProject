
--SELECT *
--FROM Portfolioproject..Covid_vaccinations
--ORDER BY 3, 4

SELECT *
FROM Portfolioproject..Covid_death
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- data that I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject..Covid_death
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total cases v total deaths
-- likely hood of dying form covid in kenya

SELECT location, date, total_cases, total_deaths, 
(CAST(total_deaths as float) /CAST(total_cases as float)) *100  AS Percentage_death
FROM Portfolioproject..Covid_death
WHERE continent IS NOT NULL
--AND location LIKE '%Kenya%'
ORDER BY total_cases DESC

-- Total cases V population
-- the percentage of people that got covid

SELECT location, date, total_cases, population,
	(CAST(total_cases AS float)/CAST(population AS float)) * 100 AS Percentage_of_Population
FROM Portfolioproject..Covid_death
WHERE continent IS NOT NULL
--AND location LIKE '%Kenya%'

ORDER BY 1, 2


--countries with highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
	MAX(CAST(total_cases AS float)/CAST(population AS float)) * 100 AS Percentage_of_Population_Infected
FROM Portfolioproject..Covid_death
WHERE continent IS NOT NULL
--AND location LIKE '%Kenya%'
GROUP BY location, population
ORDER BY Percentage_of_Population_Infected DESC


-- COuntries with highest death count per population
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM Portfolioproject..Covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Continents with highest continent count

SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM Portfolioproject..Covid_death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Global numbers

SELECT SUM(CAST(new_cases AS int)) AS Total_cases,
	(SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float))) * 100 AS DeathPercentage
FROM Portfolioproject..Covid_death
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1

-- looking for total population vs vaccination

WITH popVSvac( continent, location, date, population, new_vaccinations, RollingVaccination)
AS

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccination
FROM Portfolioproject..Covid_death dea
JOIN Portfolioproject..Covid_vaccinations vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL

--ORDER BY 2, 3
)
--CTE function
SELECT  *, (RollingVaccination/population) * 100
from popVSvac

