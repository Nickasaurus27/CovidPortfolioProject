SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT location, cal_date, total_cases, 
new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Cases vs. Total Deaths
SELECT location, cal_date, total_cases, total_deaths, 
ROUND((total_deaths / total_cases)*100,2) death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Cases. vs. Population (Canada)
SELECT location, cal_date, population, total_cases, 
ROUND((total_cases / population)*100,2) percent_pop_infected
FROM covid_deaths
WHERE location = 'Canada'
AND continent IS NOT NULL
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population
--Removing NULL values from 'percent_pop_infected' column
SELECT location, population, MAX(total_cases) highest_infection_count,
MAX(ROUND((total_cases / population)*100,2)) percent_pop_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1,2
HAVING MAX(ROUND((total_cases / population)*100,2)) IS NOT NULL
ORDER BY 4 DESC;

--Showing countries with the highest death count per population
SELECT location, MAX(total_deaths) total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

--Showing the highest death counts by continent
SELECT continent, MAX(total_deaths) total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

--Global numbers
SELECT cal_date, 
SUM(new_deaths) new_deaths, SUM(new_cases) new_cases,
ROUND((SUM(new_deaths) / SUM(new_cases))*100,2) new_death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 1;

--Joining 'Covid Deaths' and 'Covid Vaccinations'
--Looking at total population vs. vaccinations 
SELECT cd.continent, cd.location, cd.cal_date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.cal_date) rolling_people_vaccinated
FROM covid_deaths cd
JOIN covid_vaccinations cv ON 
cd.location = cv.location AND
cd.cal_date = cv.cal_date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

--USE CTE
WITH pop_vs_vac (Continent, Location, Cal_Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS (
	SELECT cd.continent, cd.location, cd.cal_date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.cal_date) rolling_people_vaccinated
	FROM covid_deaths cd
	JOIN covid_vaccinations cv ON 
	cd.location = cv.location AND
	cd.cal_date = cv.cal_date
	WHERE cd.continent IS NOT NULL
)
SELECT *, ROUND((Rolling_People_Vaccinated / Population) * 100,2) Percent_pop_vaccinated
FROM pop_vs_vac;

--Temp Table (Creating for good measure)
DROP TABLE IF EXISTS Percent_Population_Vaccinated;
CREATE TABLE Percent_Population_Vaccinated
(
Continent VARCHAR(250),
Location VARCHAR(250),
Cal_Date DATE,
Population NUMERIC,
New_Vaccinations NUMERIC,
Rolling_People_Vaccinated NUMERIC);

INSERT INTO Percent_Population_Vaccinated
(SELECT cd.continent, cd.location, cd.cal_date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.cal_date) rolling_people_vaccinated
	FROM covid_deaths cd
	JOIN covid_vaccinations cv ON 
	cd.location = cv.location AND
	cd.cal_date = cv.cal_date
	WHERE cd.continent IS NOT NULL);

SELECT *, ROUND((Rolling_People_Vaccinated / Population) * 100,2) Percent_pop_vaccinated
FROM Percent_Population_Vaccinated;

--Creating View - Storing data for Tableau

--View #1 - Percent of Population Vaccinated
CREATE VIEW PercentPopulationVaccinated AS (
SELECT cd.continent, cd.location, cd.cal_date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.cal_date) rolling_people_vaccinated
	FROM covid_deaths cd
	JOIN covid_vaccinations cv ON 
	cd.location = cv.location AND
	cd.cal_date = cv.cal_date
	WHERE cd.continent IS NOT NULL);
	
--View #2 - Total Deaths
CREATE VIEW Total_Deaths AS (
SELECT location, cal_date, total_cases, total_deaths, 
ROUND((total_deaths / total_cases)*100,2) death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL);

--View #3 - Population Infected
CREATE VIEW Population_Infected AS (
SELECT location, cal_date, population, total_cases, 
ROUND((total_cases / population)*100,2) percent_pop_infected
FROM covid_deaths
WHERE continent IS NOT NULL);
ORDER BY 1,2;