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

-- Using CTE to perform this qeury

WITH VaccinesPerCapitaCTE (
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
    MAX(population) as population,
    MAX(PeopleVaccinated) as PeopleVaccinated,
    (MAX(PeopleVaccinated) / MAX(population)) as VaccinesPerCapita
FROM
    VaccinesPerCapitaCTE
WHERE
    PeopleVaccinated IS NOT NULL
GROUP BY
    location
ORDER BY
    VaccinesPerCapita DESC

-- Using CTE to perform this qeury
    
DROP TABLE IF EXISTS VaccinesPerCapitaTable;
CREATE TABLE VaccinesPerCapitaTable (
        continent nvarchar(255),
        location nvarchar(255),
        --date datetime,
        population numeric,
        new_vaccinations numeric,
        PeopleVaccinated numeric
    );
INSERT INTO
    VaccinesPerCapitaTable
SELECT
    dae.continent,
    dae.location,
    --dae.date,
    dae.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        PARTITION BY dae.location
        ORDER BY
            dae.location, dae.date
    ) as PeopleVaccinated
FROM
    covid_database.public.coviddeaths dae
JOIN covid_database.public.covidvaccinations vac 
    ON dae.location = vac.location AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL;
SELECT
    location,
    MAX(population) as population,
    MAX(PeopleVaccinated) as PeopleVaccinated,
    (MAX(PeopleVaccinated) / MAX(population)) as VaccinesPerCapita
FROM
    VaccinesPerCapitaTable
WHERE
    PeopleVaccinated IS NOT NULL
GROUP BY
    location
ORDER BY
    VaccinesPerCapita DESC