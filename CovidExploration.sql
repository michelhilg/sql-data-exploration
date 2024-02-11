/*
Covid 19 Dataset for Data Exploration using SQL

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Get an overview of the data that we are working with

SELECT
    *
FROM
    covid_database.public.coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY
    1,
    2

SELECT
    *
FROM
    covid_database.public.covidvaccinations
WHERE
    continent IS NOT NULL
ORDER BY
    1,
    2
    

-- PART 1

-- In the first part of the COVID data exploration, we will address some questions about the covid in Brazil.

-- QUESTION 1 - How has the likelihood of contracting COVID in Brazil evolved?

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

-- QUESTION 2 - After contracting COVID, how has the likelihood of death evolved in Brazil?

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
    2 
    
-- QUESTION 3 - How has the number of vaccinations evolved in Brazil?

SELECT
    dae.location,
    dae.date,
    dae.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        Partition BY dae.location
        ORDER BY
            dae.location,
            dae.date
    ) as TotalVaccinations
FROM
    covid_database.public.coviddeaths dae
    JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.location LIKE '%Brazil%'
ORDER BY
    2,
    3 

-- QUESTION 4 - Does vaccination impact the number of deaths per 100 cases?

CREATE VIEW 
    DeathsVsVaccinations 
AS
    SELECT
        dae.location,
        dae.date,
        dae.population,
        dae.total_cases,
        dae.total_deaths,
        (dae.total_deaths / dae.total_cases) * 100 as DeathPerccentage,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (
            Partition BY dae.location
            ORDER BY
                dae.location,
                dae.date
        ) as TotalVaccinations
    FROM
        covid_database.public.coviddeaths dae
        JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
        AND dae.date = vac.date
    WHERE
        dae.location LIKE '%Brazil%'
    ORDER BY
        2,
        3

-- QUESTION 5 - Does vaccination impact the number of new cases reported?

SELECT
    dae.location,
    dae.date,
    dae.population,
    dae.new_deaths,
    dae.new_cases,
    vac.new_vaccinations
FROM
    covid_database.public.coviddeaths dae
    JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.location LIKE '%Brazil%'
ORDER BY
    2,
    3 

-- PART 2

-- In the second part of the COVID data exploration, we will address some questions about the covid in the world.
 
-- QUESTION 1 - What are the countries with the highest infection rate by population?

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

-- QUESTION 2 - What are the countries with the highest death count?
    
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

-- QUESTION 3 - What are the countries with the highest death rate by population?
    
SELECT
    Location,
    population,
    --MAX(cast (total_deaths as int)) as TotalDeathCount
    MAX(cast (total_deaths as int) / population) * 100 as DeathRate
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
    DeathRate DESC 
        
-- QUESTION 4 - Which continent has the highest death count?

SELECT
    Location,
    MAX(cast (total_deaths as int)) as TotalDeathCount
FROM
    covid_database.public.coviddeaths
WHERE
    Continent IS NULL 
    AND Location LIKE 'Europe' OR Location LIKE '%America' OR Location LIKE 'Asia' 
    OR Location LIKE 'Africa' OR Location LIKE 'Oceania'
GROUP BY
    Location
ORDER BY
    TotalDeathCount DESC 

-- QUESTION 5 - What is the global death percentage over infect cases since beginning?

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

-- PART 3

-- In the third part of the COVID data exploration, we will address some questions about the vaccination in the world.

-- QUESTION 1 - How the new vaccines are concentrated over the pandemic period?

SELECT
    dae.location,
    dae.date,
    dae.population,
    vac.new_vaccinations
FROM
    covid_database.public.coviddeaths dae
    JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.location LIKE 'World'
ORDER BY
    2,
    3 

-- QUESTION 2 - How the vaccination numbers evolved in the world?

SELECT
    dae.location,
    dae.date,
    dae.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        Partition BY dae.location
        ORDER BY
            dae.location,
            dae.date
    ) as TotalVaccinations
FROM
    covid_database.public.coviddeaths dae
    JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.location LIKE 'World'
ORDER BY
    2,
    3 
 
-- QUESTION 3 - Which countries have the highest number of vaccines applied per capita?


-- Using CTE to grab the number of vaccinated people over the total population by location in a standard SQL code
-- Using CTE to grab the number of vaccinated people over the total population by location in standard SQL code
WITH PopvsVac (
    continent,
    location,
    date,
    population,
    PeopleVaccinated
) AS (
    SELECT
        dae.continent,
        dae.location,
        dae.date,
        dae.population,
        SUM(vac.new_vaccinations) OVER (
            PARTITION BY dae.location
            ORDER BY dae.location, dae.date
        ) as PeopleVaccinated
    FROM
        covid_database.public.coviddeaths dae
    JOIN covid_database.public.covidvaccinations vac
        ON dae.location = vac.location AND dae.date = vac.date
    WHERE
        dae.continent IS NOT NULL
)
SELECT
    location,
    SUM(population) as TotalPopulation,
    SUM(PeopleVaccinated) as TotalPeopleVaccinated,
    (SUM(PeopleVaccinated) / SUM(population)) as VaccinesPerCapita
FROM
    PopvsVac 
GROUP BY
    location
ORDER BY
    VaccinesPerCapita DESC

    
-- Snowflake test
SELECT
    continent,
    location,
    population,
    PeopleVaccinated,
    (PeopleVaccinated / population) as VaccinesPerCapita
FROM (
    SELECT
        dae.continent,
        dae.location,
        dae.population,
        SUM(vac.new_vaccinations) OVER (
            PARTITION BY dae.location
            ORDER BY dae.location
        ) as PeopleVaccinated
    FROM
        covid_database.public.coviddeaths dae
        JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
            AND dae.date = vac.date
    WHERE
        dae.continent IS NOT NULL
    GROUP BY
        dae.location, dae.continent, dae.population
) AS subquery
ORDER BY
    VaccinesPerCapita


    
-- Join the two main tables of the database

-- Looking total population vs total vaccination
SELECT
    dae.continent,
    dae.location,
    dae.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        Partition BY dae.location
        ORDER BY
            dae.location
    ) as PeopleVaccinated,
    (PeopleVaccinated / dae.population) as PercentageVaccinated
FROM
    covid_database.public.coviddeaths dae
    JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL
ORDER BY
    2,
    3 
-- OBS.: The code above work due to some under the hood functionally of Snowflake
    
-- Using CTE to grab the number of vaccinated people over the total population by location in a standard SQL code
WITH PopvsVac (
    continent,
    location,
    date,
    population,
    new_vaccinations,
    PeopleVaccinated
    ) AS (
        SELECT
            dae.continent,
            dae.location,
            dae.date,
            dae.population,
            vac.new_vaccinations,
            SUM(vac.new_vaccinations) OVER (
                Partition BY dae.location
                ORDER BY
                    dae.location,
                    dae.date
            ) as PeopleVaccinated
        FROM
            covid_database.public.coviddeaths dae
            JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
            AND dae.date = vac.date
        WHERE
            dae.continent IS NOT NULL
    )
SELECT
    *,
    (PeopleVaccinated / population) * 100 as PercentageVaccinated
FROM
    PopvsVac 
    
-- Using a TempTable to grab the number of vaccinated people over the total population by location in a standard SQL code
    DROP TABLE IF EXISTS PercentageVaccinatedTable;
CREATE TABLE PercentageVaccinatedTable (
        continent nvarchar(255),
        location nvarchar(255),
        date datetime,
        population numeric,
        new_vaccinations numeric,
        PeopleVaccinated numeric
    );
INSERT INTO
    PercentageVaccinatedTable
SELECT
    dae.continent,
    dae.location,
    dae.date,
    dae.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        Partition BY dae.location
        ORDER BY
            dae.location,
            dae.date
    ) as PeopleVaccinated
FROM
    covid_database.public.coviddeaths dae
    JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL
ORDER BY
    2,
    3;
SELECT
    *,
    (PeopleVaccinated / population) * 100 as PercentageVaccinated
FROM
    PercentageVaccinatedTable 
    
-- Create a view
    CREATE VIEW PercentageVaccinated AS
SELECT
    dae.continent,
    dae.location,
    dae.date,
    dae.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        Partition BY dae.location
        ORDER BY
            dae.location,
            dae.date
    ) as PeopleVaccinated,
    (PeopleVaccinated / dae.population) * 100 as PercentageVaccinated
FROM
    covid_database.public.coviddeaths dae
    JOIN covid_database.public.covidvaccinations vac ON dae.location = vac.location
    AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL -- Querying the view
SELECT
    *
FROM
    covid_database.public.percentagevaccinated