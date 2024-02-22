SELECT * 
FROM dbo.CovidDeaths$
Where continent is not null
order by 3,4

--SELECT * 
--FROM dbo.CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population From
dbo.CovidDeaths$
order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of Dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From
dbo.CovidDeaths$
WHERE location like '%nepal%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date,  population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From
dbo.CovidDeaths$
--WHERE location like '%india%'
order by 1,2

--Looking countries  at the highest infection rate Compared to Population

Select location,  population, MAX( total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From
dbo.CovidDeaths$
--WHERE location like '%india%'
GROUP BY location, population
order by PercentagePopulationInfected desc


-- Showing the countries with the highest death count per population

Select location,  MAX(cast( total_deaths as int)) as TotalDeathCount 
From
dbo.CovidDeaths$
--WHERE location like '%india%'
Where continent is not null
GROUP BY location
order by TotalDeathCount  desc


--Lets break things down by continent


--Showing Continent with the highest death count per population

Select continent,  MAX(cast( total_deaths as int)) as TotalDeathCount 
From
dbo.CovidDeaths$
--WHERE location like '%india%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount  desc



--Global Numbers

Select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
FROM
dbo.CovidDeaths$
--WHERE location like '%nepal%'
Where continent is not null
--Group By date
order by 1,2



--- Looking at Total Population Vs Vaccinaation
-- USE CTE 
with PopvsVac (Continent, Location, Date , Population,new_vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidVaccinations$ vac
Join dbo.CovidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--TEMP TABLE
DROP Table if exists #PercentPopulationvaccinated
Create Table #PercentPopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationvaccinated
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidVaccinations$ vac
Join dbo.CovidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationvaccinated





--Creating View to store for future visualization

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidVaccinations$ vac
Join dbo.CovidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

SELECT *
 FROM PercentPopulationVaccinated






