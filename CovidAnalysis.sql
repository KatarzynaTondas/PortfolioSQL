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

--Global Death Percentage Change (Week-to-Week)
Select dea.date, 
       Sum(dea.new_cases) as TotalCases, 
       Sum(Cast(dea.new_deaths as Int)) as TotalDeaths,
       (Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100 as DeathPercentage,
       Lag((Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100) OVER (ORDER BY dea.date) as PreviousWeekDeathPercentage,
       ((Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100) - Lag((Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100) OVER (ORDER BY dea.date)) as DeathPercentageChange
From [dbo].[CovidDeaths] dea
Where dea.continent is not null
Group by dea.date
Order by dea.date desc;

--Continent-Level Vaccination Rollout
Select dea.continent,
       Sum(vac.new_vaccinations) as TotalVaccinations,
       Sum(vac.new_vaccinations)/Max(dea.population)*100 as PercentageVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
Group by dea.continent
Order by PercentageVaccinated desc;


--LET'S BREAK THINGS DOWN BY COUNTRY

--Trend of Total Cases and Deaths Over Time
Select dea.location, dea.date, Sum(dea.total_cases) as TotalCases, Sum(dea.total_deaths) as TotalDeaths
From [dbo].[CovidDeaths] dea
Where dea.continent is not null
Group by dea.location, dea.date
Order by dea.date asc, dea.location;

--Countries with Highest Deaths per 100k People
Select dea.location, 
       dea.population,
       Sum(Cast(dea.new_deaths as Int)) as TotalDeaths,
       (Sum(Cast(dea.new_deaths as Int))/dea.population)*100000 as DeathsPer100k
From [dbo].[CovidDeaths] dea
Where dea.continent is not null
Group by dea.location, dea.population
Order by DeathsPer100k desc;

--Locations with the Most Days of Increases in Total Cases
Select dea.location, 
       count(*) as DaysWithIncreaseInCases
From [dbo].[CovidDeaths] dea1
Where dea1.continent is not null
  and dea1.total_cases > (Select dea2.total_cases 
                          From [dbo].[CovidDeaths] dea2 
                          Where dea1.location = dea2.location 
                            and dea1.date = dateadd(day, 1, dea2.date))
Group by dea1.location
Order by DaysWithIncreaseInCases desc;

--Locations with the Most Drastic Daily Change in Death Percentage
Select dea.location, dea.date,
       (Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100 as DeathPercentage,
       Lag((Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100) OVER (Partition by dea.location ORDER BY dea.date) as PreviousDeathPercentage,
       Abs((Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100 - Lag((Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100) OVER (Partition by dea.location ORDER BY dea.date)) as DeathPercentageChange
From [dbo].[CovidDeaths] dea
Where dea.continent is not null
Group by dea.location, dea.date
Having Abs((Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100 - Lag((Sum(Cast(dea.new_deaths as Int))/Sum(dea.new_cases))*100) OVER (Partition by dea.location ORDER BY dea.date)) > 5
Order by DeathPercentageChange desc;

--Total Cases vs. Vaccinations: Countries with the Most Vaccinated but Low Case Counts
Select dea.location, 
       dea.population, 
       Sum(vac.new_vaccinations) as TotalVaccinations,
       Sum(vac.new_vaccinations)/dea.population*100 as VaccinationRate,
       Sum(dea.total_cases) as TotalCases
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
    On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
Group by dea.location, dea.population
Having Sum(dea.total_cases) < (Select avg(dea2.total_cases) From [dbo].[CovidDeaths] dea2)
Order by VaccinationRate desc;


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
