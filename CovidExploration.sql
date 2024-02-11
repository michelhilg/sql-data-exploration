-- Select the data that we want to work with
SELECT
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_database.public.coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY
    1,
    2 -- Looking at total cases and total deaths

-- Shows the likelihood of dying if you contract COVID in your country until 2021
SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 as DeathPerccentage
FROM
    covid_database.public.coviddeaths
WHERE
    Location LIKE '%Brazil%'
    AND continent IS NOT NULL
ORDER BY
    1,
    2 -- Looking at total cases against the population

-- Shows the percentage of the population that got COVID
SELECT
    Location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 as InfectionRate
FROM
    covid_database.public.coviddeaths
WHERE
    Location like '%Brazil%'
    AND continent IS NOT NULL
ORDER BY
    1,
    2 

-- Looking at countries with the highest infection rate by population
SELECT
    Location,
    population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / population)) * 100 as InfectionRate
FROM
    covid_database.public.coviddeaths
WHERE
    total_cases IS NOT NULL
    AND population IS NOT NULL
    AND continent IS NOT NULL
GROUP BY
    Population,
    Location
ORDER BY
    InfectionRate DESC 
    
-- Looking at countries with the highest death count
SELECT
    Location,
    population,
    MAX(cast (total_deaths as int)) as TotalDeathCount
FROM
    covid_database.public.coviddeaths
WHERE
    total_deaths IS NOT NULL
    AND population IS NOT NULL
    AND continent IS NOT NULL
GROUP BY
    Population,
    Location
ORDER BY
    TotalDeathCount DESC 
    
-- Breaking the numbers down by world region
SELECT
    Location,
    MAX(cast (total_deaths as int)) as TotalDeathCount
FROM
    covid_database.public.coviddeaths
WHERE
    Continent IS NULL
GROUP BY
    Location
ORDER BY
    TotalDeathCount DESC ------------------------------
    
-- Looking at the global numbers
    
-- Death percentage over infect cases by day
SELECT
    date,
    SUM(new_cases) as Total_Cases,
    SUM(new_deaths) as Total_Deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 as DeathPercentage
FROM
    covid_database.public.coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    1,
    2 

-- Global death percentage over infect cases
SELECT
    SUM(new_cases) as Total_Cases,
    SUM(new_deaths) as Total_Deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 as DeathPercentage
FROM
    covid_database.public.coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY
    1,
    2 
    
-- Join the two main tables of the database
-- Looking total population vs total vaccination

SELECT
    dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition BY dae.location ORDER BY dae.location, dae.date) as PeopleVaccinated,
    (PeopleVaccinated/dae.population)*100 as PercentageVaccinated
FROM
    covid_database.public.coviddeaths dae
JOIN 
    covid_database.public.covidvaccinations vac
    ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL
ORDER BY
    2,
    3

-- OBS.: The code above work due to some under the hood functionally of Snowflake
-- Using CTE to grab the number of vaccinated people over the total population by location in a standard SQL code

WITH
    PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS
(
SELECT
    dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition BY dae.location ORDER BY dae.location, dae.date) as PeopleVaccinated
FROM
    covid_database.public.coviddeaths dae
JOIN 
    covid_database.public.covidvaccinations vac
    ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL
)
SELECT
    *, (PeopleVaccinated/population)*100 as PercentageVaccinated
FROM PopvsVac

-- Using a TempTable to grab the number of vaccinated people over the total population by location in a standard SQL code

DROP TABLE IF EXISTS PercentageVaccinatedTable;

CREATE TABLE PercentageVaccinatedTable
    (
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    PeopleVaccinated numeric
    );

INSERT INTO PercentageVaccinatedTable
SELECT
    dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition BY dae.location ORDER BY dae.location, dae.date) as PeopleVaccinated
FROM
    covid_database.public.coviddeaths dae
JOIN 
    covid_database.public.covidvaccinations vac
    ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL
ORDER BY
    2,
    3
;   
SELECT
    *, (PeopleVaccinated/population)*100 as PercentageVaccinated
FROM PercentageVaccinatedTable

-- Create a view

CREATE VIEW PercentageVaccinated AS
SELECT
    dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition BY dae.location ORDER BY dae.location, dae.date) as PeopleVaccinated,
    (PeopleVaccinated/dae.population)*100 as PercentageVaccinated
FROM
    covid_database.public.coviddeaths dae
JOIN 
    covid_database.public.covidvaccinations vac
    ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL

-- Querying the view

SELECT *
FROM covid_database.public.percentagevaccinated