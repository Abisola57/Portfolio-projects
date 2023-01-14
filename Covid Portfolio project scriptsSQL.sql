
SELECT *
FROM ['owid-covid- deaths']

--SELECT *
--FROM ['covid- vaccination']
--Order by date;

SELECT Location,date,total_cases,new_cases,total_deaths, population
FROM ['owid-covid- deaths']
order by 1,2

--TOTAL CASES vs TOTAL DEATHS
--Show the likelihood of dying if you contract Covid
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM ['owid-covid- deaths']
Where location= 'Africa'
order by 1,2

-- Total cases VS population
--Shows what percentage of population got covid

SELECT Location,date,total_cases,population,(total_cases/population)*100 AS Deathpercentage
FROM ['owid-covid- deaths']
Where location= 'Africa'
order by 1,2

--Countries with highest infection rate compared to population

--Sected DESC
SELECT Location,population, MAX(total_cases) AS Highestinfection,MAX((total_cases/population))*100 AS percentagepopulationinfected
FROM ['owid-covid- deaths']
--Where location= 'Africa'
Group by population,location
order by percentagepopulationinfected


-- Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS Totaldeathcount
FROM ['owid-covid- deaths']
--Where location= 'Africa'
where continent IS NOT null
Group by location
order by  Totaldeathcount DESC

-- BY CONTINENT
---- Continent with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) AS Totaldeathcount
FROM ['owid-covid- deaths']
--Where location= 'Africa'
where continent IS NOT null
Group by continent
order by  Totaldeathcount DESC


--GLOBAL NUMBERS
SELECT date,SUM(new_cases) AS new_cases, SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Deathpercentage
FROM ['owid-covid- deaths']
--Where location= 'Africa'
Where continent IS NOT null
Group by date
order by 1,2

--- Totals around the world
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Deathpercentage
FROM ['owid-covid- deaths']
--Where location= 'Africa'
Where continent IS NOT null
--Group by date
order by 1,2


SELECT *
FROM ['owid-covid- deaths'] dea
JOIN ['covid- vaccination'] vac
    ON dea.location = vac.location
	and dea.date = vac.date

	--Total population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM ['owid-covid- deaths'] dea
JOIN ['covid- vaccination'] vac
    ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3

---Total population vs Vaccination By Partition.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location
,dea.date) as RollingpeopleVaccinated
FROM ['owid-covid- deaths'] dea
JOIN ['covid- vaccination'] vac
    ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3


---In order to use the the new column created for calculations(rollingpeoplevaccination) , use a CTE
With popvsVac(continent,Location,Date,Population,New_vaccinations,rollingpeoplevaccinated)
as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location
,dea.date) as RollingpeopleVaccinated
FROM ['owid-covid- deaths'] dea
JOIN ['covid- vaccination'] vac
    ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3
)
select *, (RollingpeopleVaccinated/population)*100 
from popvsVac

--TEMP TABLE

DROP Table if exists #PercentpopulationVaccinated
Create Table #percentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)


Insert into #percentpopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location
,dea.date) as RollingpeopleVaccinated
FROM ['owid-covid- deaths'] dea
JOIN ['covid- vaccination'] vac
    ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3

Select *, (RollingpeopleVaccinated/Population)*100 
From #percentpopulationVaccinated











---Creating view to store data for later visualization

Create View PercentpopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location
,dea.date) as RollingpeopleVaccinated
FROM ['owid-covid- deaths'] dea
JOIN ['covid- vaccination'] vac
    ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3


select *
from PercentpopulationVaccinated