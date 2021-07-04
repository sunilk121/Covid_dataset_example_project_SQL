select * from PortfolioProject..CovidDeaths 
order by 3,4

select * from PortfolioProject..CovidVaccinations 
order by 3,4

--Selecting Data that I am going to be using

select location,total_cases, new_cases, total_deaths,population from PortfolioProject..CovidDeaths 
order by 1,2

-- looking at total cases vs total deaths
select location,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location like '%states%'
order by 1,2

-- Total cases vs Population
select location, date,total_cases, Population ,(total_cases/population)*100 as TotalInfected
from PortfolioProject..CovidDeaths 
where location like '%Nepal%'
order by 1,2

--countries with Highest infection rate compared with population 
select location, max(total_cases)as HighestInfectionCount, Population ,max((total_cases/population)*100) as HighestInfectedpopulation
from PortfolioProject..CovidDeaths 
--where location like '%Nepal%'
group by location,population
order by HighestInfectedpopulation desc

-- countries with maximum  cases and maximum infected population
select location, max(total_cases)as HighestInfectionCount, Population ,max((total_cases/population)*100) as HighestInfectedpopulation
from PortfolioProject..CovidDeaths 
--where location like '%Nepal%'
group by location,population
order by HighestInfectedpopulation desc

-- Countries with highest Death count per population
select location, max(cast(total_deaths as int))as TotalDeathCont 
from PortfolioProject..CovidDeaths 
--where location like '%Nepal%'
where continent is not null 
group by location,population
order by TotalDeathCont desc


select * from PortfolioProject..CovidDeaths 
where continent is not null 
order by 3,4



select location, max(cast(total_deaths as int))as TotalDeathCont 
from PortfolioProject..CovidDeaths 
--where location like '%Nepal%'
where continent is null 
group by location
order by TotalDeathCont desc

-- Dividing thigs by cointinent
-- Showing the continent with highest death count
select continent, max(cast(total_deaths as int))as TotalDeathCont 
from PortfolioProject..CovidDeaths 
--where location like '%Nepal%'
where continent is  not null 
group by continent
order by TotalDeathCont desc


-- global numbers
select Sum(new_cases) as total_cases,Sum(cast(new_deaths as int)) as Total_deaths,
Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
-- where location like '%states%'
where continent is not null
--group by date
order by 1,2



--using vaccination table
-- joinig two tables on location and date
select * 
from PortfolioProject..CovidDeaths dea 
join
 PortfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 1,2


-- looking at total population vs vaccination
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths dea 
join
 PortfolioProject..CovidVaccinations vac
   on dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
order by 2,3

-- adiing vaccination details by date and locations 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations )) Over 
(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join
 PortfolioProject..CovidVaccinations vac
   on dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
order by 2,3


-- Using CTE
with PopvsVac(Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations )) Over 
(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join
 PortfolioProject..CovidVaccinations vac
   on dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations )) Over 
(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join
 PortfolioProject..CovidVaccinations vac
   on dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- creating a view to store datas for visualizations 
create view PercentPopulationVacinated as 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations )) Over 
(Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join
 PortfolioProject..CovidVaccinations vac
   on dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVacinated