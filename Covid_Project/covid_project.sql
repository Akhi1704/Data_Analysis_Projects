/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM covid_project.coviddeaths 
WHERE continent is not null
order by 3,4;

-- Selecting Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_project.coviddeaths
Where continent is not null
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid_project.coviddeaths
Where location like "%India%"
and continent is not null
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covid_project.coviddeaths
-- Where location like '%India%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_Cases/population) as PercentPopulationInfected
From covid_project.coviddeaths
Group by Location, population
order by PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as signed)) as TotalDeathCount
From covid_project.coviddeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as signed)) as TotalDeathCount
From covid_project.coviddeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;

-- GLOBAL NUMBERS(depicting the total cases and the death percentage on whole)

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(CAST(new_deaths as signed))/SUM(new_cases)*100 as DeathPercentage
From covid_project.coviddeaths
where continent is not null
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From covid_project.coviddeaths dea
JOIN covid_project.covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
-- We look at the data of Population vs Vaccinated people by naming the CTE Pop vs Vac
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(vac.new_vaccinations, signed)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid_project.coviddeaths dea
JOIN covid_project.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

USE covid_project;

-- Drop the temporary table if it exists
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the temporary table with corrected data types
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population DECIMAL(20, 0),
    New_vaccinations DECIMAL(20, 0),
    RollingPeopleVaccinated DECIMAL(20, 0)
);

-- Insert data into the temporary table with robust handling of invalid values
INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    STR_TO_DATE(dea.date, '%d-%m-%Y') AS date,  -- Convert date format to 'YYYY-MM-DD'
    dea.population,
    -- Replace empty strings with '0' for new_vaccinations
    CASE
        WHEN vac.new_vaccinations = '' THEN 0
        ELSE vac.new_vaccinations
    END AS new_vaccinations,
    SUM(
        CAST(
            CASE
                WHEN vac.new_vaccinations = '' THEN '0'  -- Replace empty string with '0'
                WHEN vac.new_vaccinations IS NULL THEN '0' -- Replace NULL with '0'
                WHEN vac.new_vaccinations NOT REGEXP '^[0-9]+$' THEN '0' -- Replace non-numeric values with '0'
                ELSE vac.new_vaccinations
            END AS SIGNED
        )
    ) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    covid_project.coviddeaths dea
JOIN 
    covid_project.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;
-- where dea.continent is not null 
-- order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;

-- Creating View to store data for visualizations

Create View PercentagePeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM covid_project.coviddeaths dea
JOIN covid_project.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
where dea.continent is not null 
