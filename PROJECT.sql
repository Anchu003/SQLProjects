use covids;

select *
FROM covids..CovidDeaths
where population is null;

SELECT * 
FROM CovidVaccinationss;

-- select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths,population
from covids..CovidDeaths
order by 1,2

-- look at the total_cases and total_deaths
-- shows likelihood of dying if you contract covid in your coutry 
select location, 
	date, 
	total_cases, 
	total_deaths, 
	round((total_deaths/total_cases)*100,2) as deathpersentage 
from covids..CovidDeaths
order by 1,2

-- look at the total_cases and population 
-- shows persentage of population got total_case
select location, date, total_cases, population, (total_cases/population)*100 as percentagepopulationinfacted 
from covids..CovidDeaths
order by 1,2

--look at the country with the highest infection rate compared to population 

select location, population, max(total_cases) as highestcount, max((total_cases/population))*100 as percentagepopulationinfacted 
from covids..CovidDeaths
group by  location , population
order by percentagepopulationinfacted desc

--showing coutries with highest death count per population 

select location, max(cast(total_deaths as int )) as highestdeath
from covids..CovidDeaths
where continent is not null
group by  location 
order by highestdeath desc;

select continent, max(cast(total_deaths as int )) as highestdeath
from covids..CovidDeaths
where continent is not null
group by  continent 
order by highestdeath desc;

-- persentage of new_cases and new_death

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int )) as total_death,
	(SUM(cast(new_deaths as int ))/SUM(new_cases))*100 as deathpersentage
FROM covids..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 DESC;

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int )) as total_death,
	(SUM(cast(new_deaths as int ))/SUM(new_cases))*100 as deathpersentage
FROM covids..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 DESC;


-- join with covidVaccinationss
select dea.continent, dea.date, dea.location, vac.total_vaccinations, vac.people_vaccinated
from covids..CovidDeaths dea
	join covids..CovidVaccinationss vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 1
	;

select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations
from covids..CovidDeaths dea
	join covids..CovidVaccinationss vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3
	;

	
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date) as totalvaccionday
from covids..CovidDeaths dea
	join covids..CovidVaccinationss vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3;


with popvsvacc(continent,location,date, population, new_vaccinations,totalvaccionday) as
(
	select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date) as totalvaccionday
from covids..CovidDeaths dea
	join covids..CovidVaccinationss vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)

select *, ((totalvaccionday/population))*100 as vaccination_rate
from popvsvacc


-- temporary table 

drop table if exists #percenpopulationvacc
create table #percenpopulationvacc
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population int,
	new_vaccinations numeric,
	totalvaccionday numeric
)

insert into #percenpopulationvacc
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date) as totalvaccionday
from covids..CovidDeaths dea
	join covids..CovidVaccinationss vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

select * ,((totalvaccionday/population))*100 as vaccination_rate
from #percenpopulationvacc


create view percenpopulationvacc as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.date) as totalvaccionday
from covids..CovidDeaths dea
	join covids..CovidVaccinationss vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3