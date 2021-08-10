select *
	from PortfolioProject..CovidDeaths$
	order by 3,4    --order with respect to columns 3 and 4

select *
	from PortfolioProject..CovidDeaths$
	where continent is null              -- to get all cells where location is a continent
	order by 3,4    --order with respect to columns 3 and 4

select *
	from PortfolioProject..CovidDeaths$
	where continent is not null              -- to get only cells where location is a country(not a continent)
	order by 3,4    --order with respect to columns 3 and 4


--select *
	--from PortfolioProject..CovidVaccination$
	--order by 3,4      --order with respect to columns 3 and 4

-- Select the Data we are going to be using

select  Location, date, total_cases, new_cases, total_deaths, population
	from PortfolioProject..CovidDeaths$
	where continent is not null
	order by 1,2           --order with respect to columns 1 and 2    


-- Looking at Total Cases vs Total Deaths
 
   --In general, what's the % of people who died and who actually get infected )

select  Location, date, total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage    -- convert total_deaths and total_cases into numerical values as they are taken as nvarchar
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2  

  --Shows likelihood of dying if you contract covid in this country

   --In united states: 

select  Location, date, total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage    -- convert total_deaths and total_cases into numerical values as they are taken as nvarchar
from PortfolioProject..CovidDeaths$
where location like '%states%'
		and continent is not null	
order by 1,2 

   --In Cameroon:

select  Location, date, total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage    -- convert total_deaths and total_cases into numerical values as they are taken as nvarchar
from PortfolioProject..CovidDeaths$
where location like '%cameroon%' 
		and continent is not null
order by 1,2 

  --In France:

select  Location, date, total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage    -- convert total_deaths and total_cases into numerical values as they are taken as nvarchar
from PortfolioProject..CovidDeaths$
where location like '%france%'
		and continent is not null
order by 1,2 


-- Looking at the Total Cases vs Population
-- shows what percentage of population got Covid

select  Location, date, Population, total_cases, (convert(float,total_deaths)/convert(float,population))*100 as DeathPercentage    -- convert total_deaths and total_cases into numerical values as they are taken as nvarchar
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2 

 --In united states: 

select  Location, date, Population, total_cases, (convert(float,total_deaths)/convert(float,population))*100 as DeathPercentage    -- convert total_deaths and total_cases into numerical values as they are taken as nvarchar
from PortfolioProject..CovidDeaths$
where location like '%states%'
		and continent is not null
order by 1,2 

-- Looking at countries with highest Infection Rate compared to Population
select  Location, Population, Max(total_cases) as HighestInfectionCount, Max((convert(float,total_deaths)/convert(float,population))*100) as PercentPopulationInfected    -- convert total_deaths and Population into numerical values as they are taken as nvarchar
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- showing the Countries with Highest Death Count per location
select  Location, Max(cast(total_deaths as float)) as TotalDeathCount  
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing the continents with the highest death count per population

select  continent, Max(cast(total_deaths as float)) as TotalDeathCount  
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, 
  SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage    -- convert total_deaths and total_cases into numerical values as they are taken as nvarchar
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--by date
select date, SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, 
  SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage    -- convert total_deaths and total_cases into numerical values as they are taken as nvarchar
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by date
order by 1,2 



-- Looking at Total Population vs Vaccinations
--Let's join the 2 tables and check it

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

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

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualisation

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea
join  PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated

