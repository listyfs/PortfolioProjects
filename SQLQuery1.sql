select Location, date, total_cases, new_cases, total_deaths, population 
	from master..CovidDeaths
	order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	from master..CovidDeaths
	--where location like '%Indonesia%'
	order by 1,2

-- Looking at Total Cases vs Population
-- Shows How likely people will get Covid in the country
select Location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
	from master..CovidDeaths
	--where location like '%Indonesia%'
	order by 1,2

--What country have the highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
	from master..CovidDeaths
	-- where location like '%Indonesia%'
	group by Location, Population
	order by PercentPopulationInfected desc

--What country have the highest infection rate compared to population
select Location, population, date, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
	from master..CovidDeaths
	-- where location like '%Indonesia%'
	group by Location, Population, date
	order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count
select Location, max(cast(total_deaths as int)) as TotalDeathCount
	from master..CovidDeaths
	where continent is not null
	group by Location
	order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
select Location, max(cast(total_deaths as int)) as TotalDeathCount
	from master..CovidDeaths
	where continent is null
	and Location not in ('World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'International', 'European Union')
	group by Location
	order by TotalDeathCount desc

--Global numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath, 
Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
	from master..CovidDeaths
	where continent is not null
	--group by date
	order by 1,2


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CumVac
From master..CovidVaccinations vac
Join master..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (CumVac/Population)*100
From PopvsVac

--TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumVac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CumVac
From master..CovidVaccinations vac
Join master..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (CumVac/Population)*100
From #PercentPopulationVaccinated




--CREATE VIEW to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CumVac
From master..CovidVaccinations vac
Join master..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated