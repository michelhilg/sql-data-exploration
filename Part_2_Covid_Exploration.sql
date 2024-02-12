-- PART 2

-- In the second part of the COVID data exploration, we will address some questions about the covid in the world.
 
-- QUESTION 1 - What are the countries with the highest infection rate by population?

SELECT
    location,
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
    population,
    location
ORDER BY
    InfectionRate DESC 

-- QUESTION 2 - What are the countries with the highest death count?
    
SELECT
    location,
    population,
    MAX(cast (total_deaths as int)) as TotalDeathCount
FROM
    covid_database.public.coviddeaths
WHERE
    total_deaths IS NOT NULL
    AND population IS NOT NULL
    AND continent IS NOT NULL
GROUP BY
    population,
    location
ORDER BY
    TotalDeathCount DESC 

-- QUESTION 3 - What are the countries with the highest death rate by population?
    
SELECT
    location,
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
    population,
    location
ORDER BY
    DeathRate DESC 
        
-- QUESTION 4 - Which continent has the highest death count?

SELECT
    location,
    MAX(cast (total_deaths as int)) as TotalDeathCount
FROM
    covid_database.public.coviddeaths
WHERE
    continent IS NULL 
    AND location LIKE 'Europe' OR location LIKE '%America' OR location LIKE 'Asia' 
    OR location LIKE 'Africa' OR location LIKE 'Oceania'
GROUP BY
    location
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