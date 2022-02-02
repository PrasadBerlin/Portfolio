SELECT * FROM portfolio..covidvaccinations

SELECT * FROM portfolio..coviddeads
where continent is not null


SELECT Location, date, total_cases, new_cases , total_deaths,population
from portfolio ..coviddeads
where continent is not null

--Looking at total cases vs total deaths
--shows likehood of dying  if you contract covid

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolio ..coviddeads
where location like '%states%'
and continent is not null



-- Looking at total cases vs total population 
-- shows  what percentage of population  got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as percentPopulationInfected from portfolio ..coviddeads
--where location like '%states%'



--lOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED AT POPULATIONN
 SELECT Location, population, max(total_cases) as HighestinfectionCount,  max(total_cases/population)*100 as percentPopulationInfected
from portfolio ..coviddeads
--where location like '%states%'
group by population, location
order by percentPopulationInfected desc


--let's break things down by continent



--showing countries with highest death count per population 
SELECT continent, max(cast(total_deaths as int)) as totalDeathCount
from portfolio ..coviddeads
--where location like '%states%'
where continent is not null
group by  continent
order by totalDeathCount desc

--showing with  continents with the highest death count per population
SELECT location, max(cast(total_deaths as int)) as totalDeathCount
from portfolio ..coviddeads
--where location like '%states%'
where continent is  null
group by  location
order by totalDeathCount desc


--Global Numbers
SELECT   sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolio ..coviddeads
--where location like '%states%'
where continent is not null
group by date

select * from portfolio..covidvaccinations

--Lookin at Total population vs Vaccinations

/*select dea.continent, dea.location ,dea.date ,dea.population ,vac.new_vaccinations
, sum(CONVERT(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
from portfolio..coviddeads dea
join portfolio..covidvaccinations vac
on  dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null*/



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..coviddeads dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..coviddeads dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..Coviddeads dea
Join Portfolio..CovidVaccinations vac
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
From Portfolio..coviddeads dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

