-- PART 1

-- In the first part of the COVID data exploration, we will address some questions about the covid in Brazil.

-- QUESTION 1 - How has the likelihood of contracting COVID in Brazil evolved?

SELECT
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 as InfectionRate
FROM
    covid_database.public.coviddeaths
WHERE
    location like '%Brazil%'
    AND continent IS NOT NULL
ORDER BY
    1,
    2 

-- QUESTION 2 - After contracting COVID, how has the likelihood of death evolved in Brazil?

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 as DeathPerccentage
FROM
    covid_database.public.coviddeaths
WHERE
    location LIKE '%Brazil%'
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