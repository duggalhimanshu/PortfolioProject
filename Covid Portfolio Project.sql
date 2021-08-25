select * 
from PortfolioProject..[covid deaths]
order by 3,4 


select * 
from PortfolioProject..[covid vaccinations]
order by 3,4 


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..[covid deaths]
order by 1,2 


-- looking at total cases vs total deaths


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[covid deaths]
where location like '%india%'
order by 1,2 


-- looking at the total cases vs population
-- shows what percentage of population got covid


select location, date,population, total_cases , (total_cases/population)*100 as DeathPercentage
from PortfolioProject..[covid deaths]
--where location like '%india%'
order by 1,2 


--looking at countries with highest infection rate compared to population

select location,population, MAX(total_cases) as HighestInfectionCount , MAX(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..[covid deaths]
group by location, population 
order by PercentagePopulationInfected desc


-- showing countries with highest death count per population

select location, MAX(cast(total_deaths as int) ) as TotalDeathCount
from PortfolioProject..[covid deaths]
where continent is not null
group by location 
order by TotalDeathCount desc


--let's break things down by continent

select continent, MAX(cast(total_deaths as int) ) as TotalDeathCount
from PortfolioProject..[covid deaths]
where continent is not null
group by continent 
order by TotalDeathCount desc


-- Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..[covid deaths]
--where location like '%india%'
where continent is not null
--group by date
order by 1,2 



-- looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccination
  --,( RollingPeopleVaccination/population)*100
from PortfolioProject..[covid deaths] dea
join PortfolioProject..[covid vaccinations] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE


with PopVsVac (continent, location,date, population,new_vaccinations, RollingPeopleVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccination
  --,( RollingPeopleVaccination/population)*100
from PortfolioProject..[covid deaths] dea
join PortfolioProject..[covid vaccinations] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccination/population)*100
from PopVsVac


-- TEMP TABLE


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccination
  --,( RollingPeopleVaccination/population)*100
from PortfolioProject..[covid deaths] dea
join PortfolioProject..[covid vaccinations] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccination/population)*100
from #PercentPopulationVaccinated


--creating view


CREATE VIEW PercentPopulationVaccinated 
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccination
  --,( RollingPeopleVaccination/population)*100
from PortfolioProject..[covid deaths] dea
join PortfolioProject..[covid vaccinations] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * 
from PercentPopulationVaccinated
