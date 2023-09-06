SELECT *
FROM PortfolioProject..covid_deaths$
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..covid_vaccinations$
--ORDER BY 3,4

--select data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..covid_deaths$
order by 1,2


--looking at total cases vs total deaths
--shows likehood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,CAST(total_deaths AS float) / CAST(total_cases AS float)*100 as DeathPercentage
FROM PortfolioProject..covid_deaths$
WHERE location like '%states%'
order by 1,2

--looking at total cases vs population
SELECT location,date,total_cases,total_deaths,population,CAST(total_cases AS float) / CAST(population AS float)*100 as PercentagePopulationInfected
FROM PortfolioProject..covid_deaths$
order by 1,2

--looking at countrues highest infection rate compareed to population''SELECT location,date,total_cases,total_deaths,CAST(total_deaths AS float) / CAST(total_cases AS float)*100 as DeathPercentage

SELECT location,population,MAX(total_cases)AS HighestInfectionCount,MAX(CAST(total_cases AS float) / CAST(population AS float))*100 as PercentagePopulationInfected
FROM PortfolioProject..covid_deaths$
group by location,population
order by PercentagePopulationInfected 

--Showing countries with death count per population
SELECT location,population,MAX(total_deaths) AS HIGHEST_DEATHS ,MAX(cast(total_deaths as float)) / population as HighestDeathPercentage
FROM PortfolioProject..covid_deaths$
--WHERE location like 'india'
where continent is not null
--use where instead of having above group by
group by location,population
order by HighestDeathPercentage DESC  


--lets break things down by continent
SELECT continent,MAX(total_deaths) AS HIGHEST_DEATHS 
FROM PortfolioProject..covid_deaths$
--WHERE location like 'india'
where continent is not null
group by continent



--showning the continent with highest death count per population
SELECT continent,location, population,max(total_deaths),max(cast(total_deaths as float))/population as HighestContinentalDeaths
FROM PortfolioProject..covid_deaths$
group  by continent,population, location

--GLOBAL NUMBERS 

SELECT sum(new_cases)as WorldCases,sum(cast(new_deaths as int)) as WorldDeaths --sum(CAST(new_deaths AS int) )/ sum(cast(new_cases as int))*100 as DeathPercentage
FROM PortfolioProject..covid_deaths$
--WHERE location like '%states%'
where continent is not null
--group by date
order by 1,2

-- looking total population vs vaccinations
SELECT dea.continent, dea.location,dea.population,total_vaccinations,cast(total_vaccinations as float)/population as vaccinationPercentage,sum(cast (vac.new_vaccinations as float)) over(partition by dea.location )
FROM PortfolioProject..covid_deaths$ dea
JOIN  PortfolioProject..covid_vaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1


--new vaccinations
SELECT dea.continent, dea.location,dea.population, new_vaccinations,sum(cast (vac.new_vaccinations as float)) over(partition by dea.location ) as RollingPeopleVaciinated
--,(RollingPeopleVaciinated/population)*100
FROM PortfolioProject..covid_deaths$ dea
JOIN  PortfolioProject..covid_vaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1



--USE CTE
WITH PopvsVac (Continent, Location,  Date,Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
    FROM PortfolioProject..covid_deaths$ dea
    JOIN PortfolioProject..covid_vaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT*,
    (CAST(RollingPeopleVaccinated AS FLOAT)) / (cast(Population as float))*100 as percentage
    FROM PopvsVac;



--temp tables
DROP TABLE IF EXISTS #percentpopulationVaccinated
create table #percentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationVaccinated
SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
    FROM PortfolioProject..covid_deaths$ dea
    JOIN PortfolioProject..covid_vaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL

	SELECT*,
    (CAST(RollingPeopleVaccinated AS FLOAT)) / (cast(Population as float))*100 as percentage
    FROM #percentpopulationVaccinated





	--creating a view to store data for later visualizations

	create view percentpopulationVaccinated as 
	SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
    FROM PortfolioProject..covid_deaths$ dea
    JOIN PortfolioProject..covid_vaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
	--order by 2,3
	

	select *
	from  percentpopulationVaccinated