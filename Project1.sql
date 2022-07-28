use Portfolio;

select *
from coviddeaths
order by location, date;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by location, date;


-- Shows likelihood of dying if you got covid in United States
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths
where location like '%states%'
order by location, date;


-- Shows likelihood of dying if you got covid in South Korea
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths
where location like '%korea%'
order by location, date;


-- What percentage of populatgion got covid
select location, date, population, total_cases, (total_cases/population)*100 as Infected_Percentage
from coviddeaths
order by location, date;


-- Highest infection rate compared to population
select location, population, max(total_cases) as Highest_Infection, Max((total_cases/population))*100 as Infected_Percentage
from coviddeaths
group by location, population
order by Infected_Percentage desc;


ALTER TABLE coviddeaths MODIFY total_deaths text DEFAULT NULL;
ALTER TABLE coviddeaths MODIFY continent TEXT DEFAULT NULL;
UPDATE `Portfolio`.`coviddeaths`
SET `continent` = null
WHERE continent = '';


-- Continents with highest death conut per population
select continent, sum(new_deaths) as Total_Deathcount
from coviddeaths
where continent is not null
group by continent
order by Total_Deathcount desc;


-- Global Death Percentage
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as signed int)) as Total_Deaths, sum(cast(new_deaths as float))/sum(new_cases)*100 as Death_Percentage
from coviddeaths
where continent is not null
order by date, sum(new_cases);


-- Total population vs Vccinations
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(vac.new_vaccinations, signed int)) over (partition by death.location order by death.location, death.date) as People_Vaccinated
from coviddeaths as death
join covidvaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by death.location, death.date;


-- CTE
with Pop_Vac (continent, location, date, population, new_vaccinations, People_Vaccinated) as
(Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(vac.new_vaccinations, signed int)) over (partition by death.location order by death.location, death.date) as People_Vaccinated
from coviddeaths as death
join covidvaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null)
-- order by death.location, death.date

select *, (People_Vaccinated/population)*100
from Pop_vac;


-- Temp table
UPDATE `Portfolio`.`covidvaccinations`
SET `new_vaccinations` = null
WHERE new_vaccinations = '';

Drop table if exists percentpopulationvaccinated;
create TEMPORARY table percentpopulationvaccinated (
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
People_Vaccinated numeric
);

Insert into percentpopulationvaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(vac.new_vaccinations, signed int)) over (partition by death.location order by death.location, death.date) as People_Vaccinated
from coviddeaths as death
join covidvaccinations as vac
	on death.location = vac.location
	and death.date = vac.date;

select *, (People_Vaccinated/population)*100
from percentpopulationvaccinated;


-- View to store data for later visualizations

create view percentpopulationvaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(vac.new_vaccinations, signed int)) over (partition by death.location order by death.location, death.date) as People_Vaccinated
from coviddeaths as death
join covidvaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by death.location, death.date;

select *
from percentpopulationvaccinated;
