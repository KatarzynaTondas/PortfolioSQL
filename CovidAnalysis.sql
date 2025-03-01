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
Select continent, max(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths]
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Continent-Level Vaccination Rollout
SELECT dea.continent,
       SUM(vac.new_vaccinations) AS TotalVaccinations,
       (SUM(vac.new_vaccinations)) / MAX(dea.population) * 100 AS PercentageVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent
ORDER BY PercentageVaccinated DESC;


--GLOBAL NUMBERS

--Total cases, deaths and death percentage by day
Select date, Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, Sum(new_deaths)/Sum(New_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where continent is not null
Group by date
Order by 1 desc

--Total cases, deaths and death percentage averall across the World
Select Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, Sum(new_deaths)/Sum(New_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where continent is not null

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, Sum(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations]  vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null 
order by 2,3

--Global Death Percentage Change (Day-to-Day)
Select dea.date, 
       Sum(dea.new_cases) as TotalCases, 
       Sum(dea.new_deaths) as TotalDeaths,
       (Sum(dea.new_deaths)/Sum(dea.new_cases))*100 as DeathPercentage,
       Lag((Sum(dea.new_deaths)/Sum(dea.new_cases))*100) OVER (ORDER BY dea.date) as PreviousWeekDeathPercentage,
       ((Sum(dea.new_deaths)/Sum(dea.new_cases))*100) - Lag((Sum(dea.new_deaths)/Sum(dea.new_cases))*100) OVER (ORDER BY dea.date) as DeathPercentageChange
From [dbo].[CovidDeaths] dea
Where dea.continent is not null
Group by dea.date
Order by dea.date desc;

-- Global Death Percentage Change (Week-to-Week)
WITH WeeklyData AS (
    SELECT 
        DATEPART(YEAR, dea.date) AS Year,
        DATEPART(WEEK, dea.date) AS Week,
        SUM(dea.new_cases) AS TotalCases,
        SUM(dea.new_deaths) AS TotalDeaths
    FROM [dbo].[CovidDeaths] dea
    WHERE dea.continent IS NOT NULL
    GROUP BY DATEPART(YEAR, dea.date), DATEPART(WEEK, dea.date)
)
SELECT 
    Year,
    Week,
    TotalCases,
    TotalDeaths,
    (TotalDeaths / TotalCases) * 100 AS DeathPercentage,
    LAG((TotalDeaths / TotalCases) * 100) OVER (ORDER BY Year, Week) AS PreviousWeekDeathPercentage,
    ((TotalDeaths / TotalCases) * 100) - LAG((TotalDeaths / TotalCases) * 100) OVER (ORDER BY Year, Week) AS DeathPercentageChange
FROM WeeklyData
ORDER BY Year DESC, Week DESC;

-- Global Death Percentage Change (Month-to-Month)
WITH MonthlyData AS (
    SELECT 
        DATEPART(YEAR, dea.date) AS Year,
        DATEPART(MONTH, dea.date) AS Month,
        SUM(dea.new_cases) AS TotalCases,
        SUM(dea.new_deaths) AS TotalDeaths
    FROM [dbo].[CovidDeaths] dea
    WHERE dea.continent IS NOT NULL
    GROUP BY DATEPART(YEAR, dea.date), DATEPART(MONTH, dea.date)
)
SELECT 
    Year,
    Month,
    TotalCases,
    TotalDeaths,
    (TotalDeaths / TotalCases) * 100 AS DeathPercentage,
    LAG((TotalDeaths / TotalCases) * 100) OVER (ORDER BY Year, Month) AS PreviousMonthDeathPercentage,
    ((TotalDeaths / TotalCases) * 100) - LAG((TotalDeaths / TotalCases) * 100) OVER (ORDER BY Year, Month) AS DeathPercentageChange
FROM MonthlyData
ORDER BY Year DESC, Month DESC;

-- Global Death Percentage Change (Quarter-to-Quarter)
WITH QuarterlyData AS (
    SELECT 
        DATEPART(YEAR, dea.date) AS Year,
        DATEPART(QUARTER, dea.date) AS Quarter,
        SUM(dea.new_cases) AS TotalCases,
        SUM(dea.new_deaths) AS TotalDeaths
    FROM [dbo].[CovidDeaths] dea
    WHERE dea.continent IS NOT NULL
    GROUP BY DATEPART(YEAR, dea.date), DATEPART(QUARTER, dea.date)
)
SELECT 
    Year,
    Quarter,
    TotalCases,
    TotalDeaths,
    (TotalDeaths / TotalCases) * 100 AS DeathPercentage,
    LAG((TotalDeaths / TotalCases) * 100) OVER (ORDER BY Year, Quarter) AS PreviousQuarterDeathPercentage,
    ((TotalDeaths / TotalCases) * 100) - LAG((TotalDeaths / TotalCases) * 100) OVER (ORDER BY Year, Quarter) AS DeathPercentageChange
FROM QuarterlyData
ORDER BY Year DESC, Quarter DESC;

-- Global Death Percentage Change (Year-to-Year)
WITH YearlyData AS (
    SELECT 
        DATEPART(YEAR, dea.date) AS Year,
        SUM(dea.new_cases) AS TotalCases,
        SUM(CAST(dea.new_deaths AS INT)) AS TotalDeaths
    FROM [dbo].[CovidDeaths] dea
    WHERE dea.continent IS NOT NULL
    GROUP BY DATEPART(YEAR, dea.date)
)
SELECT 
    Year,
    TotalCases,
    TotalDeaths,
    (TotalDeaths / TotalCases) * 100 AS DeathPercentage,
    LAG((TotalDeaths / TotalCases) * 100) OVER (ORDER BY Year) AS PreviousYearDeathPercentage,
    ((TotalDeaths / TotalCases) * 100) - LAG((TotalDeaths / TotalCases) * 100) OVER (ORDER BY Year) AS DeathPercentageChange
FROM YearlyData
ORDER BY Year DESC;


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
       Sum(dea.new_deaths) as TotalDeaths,
       (Sum(dea.new_deaths)/dea.population)*100000 as DeathsPer100k
From [dbo].[CovidDeaths] dea
Where dea.continent is not null
Group by dea.location, dea.population
Order by DeathsPer100k desc;

--Locations with the Most Days of Increases in Total Cases
Select dea1.location, 
       count(*) as DaysWithIncreaseInCases
From [dbo].[CovidDeaths] dea1
Where dea1.continent is not null
  and dea1.total_cases > (Select dea2.total_cases 
                          From [dbo].[CovidDeaths] dea2 
                          Where dea1.location = dea2.location 
                            and dea1.date = dateadd(day, 1, dea2.date))
Group by dea1.location
Order by DaysWithIncreaseInCases desc;

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
