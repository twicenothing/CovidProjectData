SELECT * FROM Portfolioproject..CovidDeaths;
--SELECT * FROM Portfolioproject..CovidVaccinations;

--Select data we're going to be using

select  continent ,location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..CovidDeaths
order by 1,2 ;


-- Looking at total deaths vs total cases

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
order by 1,2

-- Looking at the total cases vs population
Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population ), 0)) * 100 AS InfectionPercentage
from PortfolioProject..covidDeaths
order by 1,2


-- Countries with the highest infection rate by population
Select location, MAX(CONVERT(float,total_cases)) as HighestCount ,population, 
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population ), 0)) * 100 AS InfectionPercentage
from PortfolioProject..covidDeaths
GROUP BY location, population
order by InfectionPercentage desc;


-- Countries with the highest death count
Select location, MAX(cast(total_deaths as int)) as HighestCount
from PortfolioProject..covidDeaths
where location not in ('World','High-income countries','Upper-middle-income countries','Europe','North America','Asia','South America','European Union (27)')
GROUP BY location
order by HighestCount desc

-- Breaking it down by continent
Select continent, MAX(cast(total_deaths as int)) as HighestCount
from PortfolioProject..covidDeaths
GROUP BY continent
order by HighestCount desc





with PopvsVac (continent, location, population, new_vaccinations, RollingSum)

as (
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingSum
FROM Portfolioproject..CovidDeaths dea
INNER JOIN Portfolioproject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

)

SELECT *, (RollingSum/population) * 100 as perc FROM PopvsVac;

--Creating VIEW to store data for later visualisation

CREATE VIEW PercentagePopulationVaccinated as 
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingSum
FROM Portfolioproject..CovidDeaths dea
INNER JOIN Portfolioproject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date



SELECT SUM(CONVERT(float, new_cases)) as total_cases, SUM(CONVERT(float, new_deaths )) as total_deaths, SUM(CONVERT(float, new_deaths ))/SUM(CONVERT(float, new_cases))* 100 as death_percentage
FROM Portfolioproject..CovidDeaths
where continent is not null
order by 1,2


-- This query basically only removes international and world and european uniion since it's part of europe for more correct continent specific data
SELECT location, SUM(CONVERT(float, new_deaths)) as total_deaths
FROM Portfolioproject..CovidDeaths
where location  in (  'Europe', 'North America', 'Asia', 'South America', 'Africa', 'Oceania')
Group by location
order by total_deaths desc


SELECT Location, population, date, MAX(CONVERT(float, total_cases)) as max_cases,MAX(CONVERT(float, total_cases))/(CONVERT(float, population))*100 as percent_population_infected
FROM Portfolioproject..CovidDeaths
Group by location, population,date
order by percent_population_infected desc
