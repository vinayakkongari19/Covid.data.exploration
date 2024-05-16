--use [Data Exploration]
--select * from CovidDeaths;
----select * from CovidVaccinations;


--select data that we are going to be using

Select Location ,date ,total_cases,new_cases,total_deaths,population
from [Data Exploration]..Coviddeaths
order by 1,2

--total cases vs total deaths

Select Location ,date ,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [Data Exploration]..Coviddeaths
where location like '%states%'
order by 1,2

--total cases vs population 
--shows what percentage of population got covid

select Location ,date ,total_cases,population,(total_cases/population)*100 as percentpopulationinfected
from [Data Exploration]..Coviddeaths
where location like '%states%'
order by 1,2

--country with highest infection rate compared to population

select Location ,population ,max(total_cases)as highinfectioncount,max(total_cases/population)*100 as percentpopulationinfected
from [Data Exploration]..Coviddeaths
--where location like '%states%'
group by location, population
order by percentpopulationinfected desc

--country with highest death count per population

select Location ,max(total_deaths)as totaldeathcount
from [Data Exploration]..Coviddeaths
--where location like '%states%'
group by location
order by totaldeathcount desc

--continents  with the highest death count per population

select continent ,max(cast(total_deaths as int))as totaldeathcount
from [Data Exploration]..Coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers

Select Location ,date ,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [Data Exploration]..Coviddeaths
where location like '%states%'
and continent is not null
order by 1,2

--total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Exploration]..CovidDeaths dea
Join [Data Exploration]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--use cte
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Exploration]..CovidDeaths dea
Join [Data Exploration]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Exploration]..CovidDeaths dea
Join [Data Exploration]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Exploration]..CovidDeaths dea
Join [Data Exploration]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 