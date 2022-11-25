Select * From [dbo].[CovidDeaths]
Where continent is not null
Order by 1,2


--Looking at Total Cases vs Total Deaths
-- Shows likelihood of daying if you have a confirmed Covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where continent is not null
Order by 1,2 desc


--Lookin at Total Cases vs Population
--Show what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
From [dbo].[CovidDeaths]
Where continent is not null
Order by 1,2 desc


--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentageOfPopulationInfected
From [dbo].[CovidDeaths]
Where continent is not null
Group by location, population
Order by PercentageOfPopulationInfected desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continents with the highest count per Population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

--Total cases, deaths and death percentage by day
Select date, Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as Int)) as TotalDeaths, Sum(Cast(new_deaths as Int))/Sum(New_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where continent is not null
Group by date
Order by 1 desc


--Total cases, deaths and death percentage averall across the World
Select Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as Int)) as TotalDeaths, Sum(Cast(new_deaths as Int))/Sum(New_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where continent is not null


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, Sum(Convert(Int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations]  vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null 
order by 2,3


--Use CTE
With PopvsVac as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations]  vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercent
From PopvsVac

--Temp Table
Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
loacation nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations]  vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercent
From #PercentPopulationVaccinated


--Creating View to store data for later visualisation
/*Alter */ Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations]  vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null

Select * 
From PercentPopulationVaccinated