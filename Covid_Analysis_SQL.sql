--Select *
--from PersonalProjecet.dbo.CovidDeaths
--order by 3,4

--- Deaths table -------

Select location, date, total_cases, new_cases, total_deaths, population
from PersonalProjecet.dbo.CovidDeaths
order by 1,2


----ANALYSING DATA BY COUNTRIES

--- Total cases vs Total Deaths in Canada -- Mortality_Rate (Likelihood of Death in Canada)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Mortality_Rate
from PersonalProjecet.dbo.CovidDeaths
where location like 'Canada'
order by 1,2


--- Total Cases VS Population -- (Infection Rate for the population)
Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from PersonalProjecet.dbo.CovidDeaths
--where location like 'Canada'
order by 1,2


-- Countries with highest infection rate for their population
Select location as Country,  MAX(total_cases) as MaximumInfectionCount, population, MAX((total_cases/population))*100 as InfectionRate
from PersonalProjecet.dbo.CovidDeaths
--where location like 'Canada'
group by location, Population
order by InfectionRate desc

---- Countries with highest count per population
Select location as Country,  MAX(cast(total_deaths as int)) as TotalDeaths
from PersonalProjecet.dbo.CovidDeaths		
--where location like 'Canada'
where continent is not null
group by location
order by TotalDeaths desc


------- ANALYSING DATA BY CONTINENT



--Select location ,  MAX(cast(total_deaths as int)) as TotalDeaths
--from PersonalProjecet.dbo.CovidDeaths		
----where location like 'Canada'
--where continent is null
--group by location
--order by TotalDeaths desc

------ Continents with Highest Death counts
Select continent ,  MAX(cast(total_deaths as int)) as TotalDeaths
from PersonalProjecet.dbo.CovidDeaths		
where continent is not null
group by continent
order by TotalDeaths desc


------ GLOBAL DATA -- Death Percentage

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(New_cases))*100 as DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as Mortality_Rate
from PersonalProjecet.dbo.CovidDeaths
where continent is not null
order by 1,2


---- Total Population  Vs Vaccincation using rolling count ------

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, cd.date) as VaccincationRollingCount
from PersonalProjecet.dbo.CovidDeaths cd
JOIN PersonalProjecet.dbo.CovidVaccinations cv
	on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3

---USING CTE
With PopVsVac(Continent, Location, Date, Population, New_Vaccinations, VaccincationRollingCount)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as bigint)) OVER (partition by cd.location order by cd.location, cd.date) as VaccincationRollingCount
from PersonalProjecet.dbo.CovidDeaths cd
JOIN PersonalProjecet.dbo.CovidVaccinations cv
	on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
-- order by 2,3
)
select *, (VaccincationRollingCount/Population)*100 
from PopVsVac


--- Using Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
VaccincationRollingCount numeric
)



Insert Into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as bigint)) OVER (partition by cd.location order by cd.location, cd.date) as VaccincationRollingCount
from PersonalProjecet.dbo.CovidDeaths cd
JOIN PersonalProjecet.dbo.CovidVaccinations cv
	on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
-- order by 2,3

select *, (VaccincationRollingCount/Population)*100 
from #PercentPopulationVaccinated
order by 2,3



----- VIEWS to store data for visualisation

Create View PercentPopulationVaccinated as 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as bigint)) OVER (partition by cd.location order by cd.location, cd.date) as VaccincationRollingCount
from PersonalProjecet.dbo.CovidDeaths cd
JOIN PersonalProjecet.dbo.CovidVaccinations cv
	on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
--order by 2,3
