SELECT * FROM public."CovidDeaths";

SELECT * FROM public."CovidVaccinations";

--Select data we are using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM public."CovidDeaths"
ORDER BY location, date;

-- Total Cases vs. Total Deaths
-- Shows likelihood of dying if you get covid in your specific country
SELECT location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 AS death_percentage
FROM public."CovidDeaths"
WHERE location = 'United States'
ORDER BY location, date;

--Total Cases vs. Population
--Shows how much of the population has gotten covid
SELECT location, date, total_cases, population, (total_cases*1.0/population)*100 AS population_percent_infected
FROM public."CovidDeaths"
WHERE location = 'United States'
ORDER BY location, date;

--Countries with Highest Infection Rate compared to Population
SELECT location, MAX(total_cases) AS highest_infection_count, population, 
MAX(total_cases*1.0/population)*100 AS population_percent_infected
FROM public."CovidDeaths"
GROUP BY location, population
ORDER BY MAX(total_cases*1.0/population)*100 DESC;

--Countries with the Highest Death count per Population
SELECT location, MAX(total_deaths) AS total_death_count
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MAX(total_deaths) DESC;


-- Breaking it down by CONTINENT --
--Continents with the Highest Death count
SELECT continent, MAX(total_deaths) AS total_death_count
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAX(total_deaths) DESC;

-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, 
SUM(new_deaths) AS total_deaths, 
((SUM(new_deaths)*1.0)/SUM(new_cases))*100 AS death_percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) != 0
ORDER BY date;

--Global Numbers - total
SELECT SUM(new_cases) AS total_cases, 
SUM(new_deaths) AS total_deaths, 
((SUM(new_deaths)*1.0)/SUM(new_cases))*100 AS death_percentage
FROM public."CovidDeaths"
WHERE continent IS NOT NULL;

-- Total Population vs. Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) 
OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS rolling_people_vax
FROM public."CovidDeaths" AS cd
JOIN public."CovidVaccinations" AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

--Incorporating CTE to perform calculation on partition by in previous query
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vax)
AS 
(
	SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) 
	OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS rolling_people_vax
	FROM public."CovidDeaths" AS cd
	JOIN public."CovidVaccinations" AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
)
SELECT *, (Rolling_People_Vax/Population)*100 AS vaccinated_percentage
FROM PopvsVac;

-- Creating View to store data for visualizations
CREATE VIEW Percent_Population_Vaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) 
OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS rolling_people_vax
FROM public."CovidDeaths" AS cd
JOIN public."CovidVaccinations" AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;


SELECT * FROM public.percent_population_vaccinated;

