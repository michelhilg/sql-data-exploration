/*
Covid 19 Dataset for Data Exploration using SQL

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Get an overview of the data that we are working with

-- Table 1 - CovidDeaths: Describe the evolution of the number of cases and deaths over time.

SELECT
    *
FROM
    covid_database.public.coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY
    1,
    2

-- Table 2 - CovidVaccinations: Describe the evolution of the number of new tests and vaccines over time.

SELECT
    *
FROM
    covid_database.public.covidvaccinations
WHERE
    continent IS NOT NULL
ORDER BY
    1,
    2
    





