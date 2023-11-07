Select iso_code, location
from CovDie
where continent is null

Select location, date, total_cases, new_cases, total_deaths, population
from CovDie
order by 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from CovDie
where location like '%states%'
order by 1,2

-- Total Cases vs Population

Select location, date, population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopInfected
from CovDie
where location like '%States%'
order by 1,2

--Countries With Highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopInfected
from CovDie
--where location like '%States%'
group by location, population
order by PercentPopInfected desc

--Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as bigint)) as TotalDealthCount
from CovDie
where continent is not null
group by location
order by TotalDealthCount desc

--Continents with Highest Death Count

Select location, Max(cast(total_deaths as bigint)) as TotalDealthCount
from CovDie
where continent is null and location not like '%income%'
group by location
order by TotalDealthCount desc

-- Global Numbers

Select date,  MAX(total_cases) as Total_Cases, MAX(total_deaths) as Total_Deaths, Max(convert(float,total_deaths))/Max(convert(float, total_cases))*100 as DeathPercentage
from CovDie
where continent is not null
group by date
order by 1,2


--Total Population vs Vaccination

Select  CovDie.continent, CovDie.location, CovDie.date, CovDie.population, CovVac.new_vaccinations
, sum(cast(CovVac.new_vaccinations as bigint)) over (partition by CovDie.location order by covdie.location, covdie.date) as RollingVaccineCount
from CovDie
join CovVac
	on CovDie.location = CovVac.location
	and CovDie.date = CovVac.date
where covdie.continent is not null and covdie.location not like '%income%'
order by 2,3

with PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccineCount)
as
(
Select  CovDie.continent, CovDie.location, CovDie.date, CovDie.population, CovVac.new_vaccinations
, sum(cast(CovVac.new_vaccinations as bigint)) over (partition by CovDie.location order by covdie.location, covdie.date) as RollingVaccineCount
from CovDie
join CovVac
	on CovDie.location = CovVac.location
	and CovDie.date = CovVac.date
where covdie.continent is not null and covdie.location not like '%income%'
)
select *, (RollingVaccineCount/population)*100
from PopvsVac

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingVaccineCount numeric
)

insert into #PercentPopulationVaccinated
Select CovDie.continent, CovDie.location, CovDie.date, CovDie.population, CovVac.new_vaccinations
, sum(cast(CovVac.new_vaccinations as bigint)) over (partition by CovDie.location order by covdie.location, covdie.date) as RollingVaccineCount
from CovDie
join CovVac
	on CovDie.location = CovVac.location
	and CovDie.date = CovVac.date
where covdie.continent is not null and covdie.location not like '%income%'

select *, (RollingVaccineCount/population)*100
from #PercentPopulationVaccinated

--Creating View for Visualizations

Create View PercentPopulationVaccinated as
Select CovDie.continent, CovDie.location, CovDie.date, CovDie.population, CovVac.new_vaccinations
, sum(cast(CovVac.new_vaccinations as bigint)) over (partition by CovDie.location order by covdie.location, covdie.date) as RollingVaccineCount
from CovDie
join CovVac
	on CovDie.location = CovVac.location
	and CovDie.date = CovVac.date
where covdie.continent is not null and covdie.location not like '%income%'


select *
from PercentPopulationVaccinated