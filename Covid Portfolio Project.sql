Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to be using 

Select 
	location
	, date
	, total_cases
	, new_cases
	, total_deaths
	, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs total Deaths
-- Shows likelihood of dying if you contract covid in your country 
Select 
	location
	, date
	, total_cases
	, total_deaths
	, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select 
	location
	, date
	, total_cases
	, Population
	, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select 
	location
	, Population
	, MAX(total_cases) as HighestInfectionCount
	, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent, Population
order by PercentPopulationInfected desc


-- Showing Countries with the Highest Death Count per Population


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population 

Select 
	continent
	, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers


SELECT	
	  Sum(new_cases) as total_cases
	, Sum(new_deaths) as total_deaths
	, SUM(new_deaths)/Sum(nullif(new_cases,0))*100 as DeathPercentatge
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations


--USE CTE

With PopvsVac (Continent, Locatoin, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select 
	   dea.continent
	 , dea.location
	 , dea.date
	 , dea.population
	 , vac.new_vaccinations
	 , SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,
	(RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	  Continent nvarchar(255)
	, Location nvarchar(255)
	, Date datetime
	, Population numeric
	, New_vaccinations numeric
	, RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select 
	   dea.continent
	 , dea.location
	 , dea.date
	 , dea.population
	 , vac.new_vaccinations
	 , SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *,
	(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select 
	   dea.continent
	 , dea.location
	 , dea.date
	 , dea.population
	 , vac.new_vaccinations
	 , SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
