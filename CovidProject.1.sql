Select * 
From [PortfolioProject.1]..CovidDeaths
WHERE continent is not null
order by 3,4

Select * 
From [PortfolioProject.1]..CovidVax
WHERE continent is not null
order by 3,4

--Select Data we are using

Select location, date, total_cases, new_cases, total_deaths, population
From [PortfolioProject.1]..CovidDeaths
order by 3,4

-- Looking at total cases vs total deaths
-- Shows likelyhood of death
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as "DeathRate"
From [PortfolioProject.1]..CovidDeaths
Where location like '%states%'
order by 1,2




-- Looking at total cases vs population
Select location, date, population, total_cases,  (total_cases/population)*100 as "InfectionRate"
From [PortfolioProject.1]..CovidDeaths
Where location like '%states%'
order by 1,2


Select location, population, MAX(total_cases) as InfectionHigh,  Max((total_cases/population))*100 as "InfectionRate"
From [PortfolioProject.1]..CovidDeaths
--Where location like '%states%'
Group by population, location
order by "InfectionRate" desc

--Shows highest infection rate

--LETS BREAK DOWN BY CONTINENT
Select LOCATION, MAX(Cast(total_deaths as int)) as MortalityHigh,  Max((total_cases/population))*100 as "InfectionRate"
From [PortfolioProject.1]..CovidDeaths
WHERE continent is null
Group by LOCATION
order by "MortalityHigh" desc

Select location, population, MAX(Cast(total_deaths as int)) as MortalityHigh,  Max((total_cases/population))*100 as "InfectionRate"
From [PortfolioProject.1]..CovidDeaths
WHERE continent is not null
Group by population, location
order by "MortalityHigh" desc

-- shows highest death count

Select continent, MAX(Cast(total_deaths as int)) as MortalityHigh,  Max((total_cases/population))*100 as "InfectionRate"
From [PortfolioProject.1]..CovidDeaths
WHERE continent is NOT null
Group by continent
order by "MortalityHigh" desc



-- GLOBAL NUMBERS

Select date, SUM(NEW_CASES)as total_cases, SUM(CAST(NEW_deaths AS int)) as total_deaths,SUM(CAST(NEW_deaths AS int))/sum(NEW_cases)*100
From [PortfolioProject.1]..CovidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY DATE
order by 1,2

--Total Pop vs Vax

Select dea.continent, dea.location, dea.date, dea.population,vax.new_vaccinations
From [PortfolioProject.1]..CovidDeaths dea
Join [PortfolioProject.1]..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
WHERE dea.CONTINENT IS NOT NULL
order by 2,3

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population,vax.new_vaccinations,
SUM(CONVERT(INT,vax.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPPLVaxed,

From [PortfolioProject.1]..CovidDeaths dea
Join [PortfolioProject.1]..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
WHERE dea.CONTINENT IS NOT NULL
order by 2,3



-- USE CTE

With PopvsVax (Continent,location,date, population,new_vaccinations,RollingPeopleVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vax.new_vaccinations,
SUM(CONVERT(INT,vax.new_vaccinations)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinations

From [PortfolioProject.1]..CovidDeaths dea
Join [PortfolioProject.1]..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
WHERE dea.CONTINENT IS NOT NULL
)
Select *,(RollingPeopleVaccinations/population)*100
From PopvsVax


--TEMP Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vax.new_vaccinations,
SUM(cast(vax.new_vaccinations as BIGINT)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPPLVaxed
From [PortfolioProject.1]..CovidDeaths dea
Join [PortfolioProject.1]..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
WHERE dea.CONTINENT IS NOT NULL
Select *,(RollingPeopleVaccinations/population)*100
From #PercentPopulationVaccinated




--Create Views

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vax.new_vaccinations,
SUM(cast(vax.new_vaccinations as BIGINT)) over (partition by dea.location ORDER BY dea.location, dea.date) as RollingPPLVaxed
From [PortfolioProject.1]..CovidDeaths dea
Join [PortfolioProject.1]..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
WHERE dea.CONTINENT IS NOT NULL


Select *
From PercentPopulationVaccinated
