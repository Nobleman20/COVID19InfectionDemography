Select *
from CovidDeaths
Order by 3,4

Select *
from CovidVaccinations


--SELECT DATA WE ARE GOIN TO BE USING

Select location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'Nigeria'
Order by 1,2


--LOOKING AT TOTAL CASE vS total death

Select location, date, total_cases, new_cases, population, (total_cases/population)*100 as CasePercentage
from CovidDeaths
where location like 'Nigeria'
Order by 1,2


--LOOKING AT TOTAL CASES vs POPULATION (by country)

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
where continent is not null
Group by Location, Population
Order by PercentagePopulationInfected desc


--LOOKING AT TOTAL CASES vs POPULATION (by continent)

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMNERS

Select Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
Order by 1,2


--JOIN TABLES

Select *
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date


--Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeaoleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeaoleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeaoleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated


--CREATING VIEW TO STORE DATA FOR DATA VISUALIZATION

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeaoleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3
