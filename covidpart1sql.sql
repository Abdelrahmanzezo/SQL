--select * from protofolio..CovidVaccinations;
--select * from protofolio..CovidDeaths;

-- looking at total_cases vs total deaths
-- show
select location,date,total_cases,new_cases,total_deaths,(total_deaths /total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%gyp%'
order by 1,2;

-- looking at population vs total_cases
-- what is the percentage population got covid

select location,date,total_cases,population,(total_cases /population)*100 as popupercentage
from CovidDeaths
where location like '%gyp%'
order by 1,2;

-- looking at the country with the highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectedCount,max((total_cases /population))*100 as populationpercentage
from CovidDeaths
group by location,population
order by populationpercentage desc;

-- showing countries with the highest death count per population
select location,population,max(total_deaths) AS Totaldeathcount,max((total_deaths /population))*100 as DeathPercentage
from CovidDeaths
group by location,population
order by Totaldeathcount DESC;

select location,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc;

-- lets break things down by its continent
select location,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
where continent is null
group by location
order by totaldeathcount desc;

-- global numbers

select date ,sum(new_cases) as sum_of_new_cases,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths
where continent is not null
group by date
order by sum_of_new_cases desc;


with popvsvac(continent,location,date,population,new_vaccination,rolling_people_vaccinated)
as

(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int )) over(partition by dea.location order by dea.location , dea.date) as rolling_people_vaccinated
from protofolio..CovidVaccinations vac
join  protofolio..CovidDeaths dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null
--order by 2,3
)
select *,
(rolling_people_vaccinated/ population)* 100
from popvsvac

-- Temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated(
continent nvarchar(255)
,location nvarchar(255),
date datetime,
population numeric
,new_vaccination numeric
,rolling_people_vaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int )) over(partition by dea.location order by dea.location , dea.date) as rolling_people_vaccinated
from protofolio..CovidVaccinations vac
join  protofolio..CovidDeaths dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null
--order by 2,3
