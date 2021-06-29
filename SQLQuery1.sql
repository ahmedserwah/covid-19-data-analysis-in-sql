select *
from [first database]..[covid death]
where continent is not null
order by 3,4

--select *
--from [first database]..['covid vaccine$']
--order by 3,4

--selct data that we are using 
select continent,location ,date,total_cases,new_cases,total_deaths,population 
	from [first database]..[covid death]
	order by 1,2
-- looking at total cases vs total deaths 
select  continent, location ,date,total_cases,total_deaths,population,(total_deaths/total_cases)*100 as death_percatnage
	from [first database]..[covid death]
	where location like '%states%'
	order by 1,2

	-- looking at the total cases vs population
	-- 
	select continent,location ,date,population, total_cases,(total_cases/population)*100 as covid_percentage
	from [first database]..[covid death]
	--where location like '%states%'
	order by 1,2

-- higher infection rate 

select continent,location ,population, max(total_cases) as highest_infection,max((total_cases/population))*100 as covid_percentage
	from [first database]..[covid death]
	group by population ,location
	order by covid_percentage desc

	--how many people dead 
	select continent ,location , max( cast (total_deaths as int)) as dead 
	from [first database]..[covid death]
	where continent is not null

	group by location
	order by dead desc

-- showing the conteient with highest death count
select continent , max( cast (total_deaths as int)) as dead 
	from [first database]..[covid death]
	where continent is not null
	group by continent
	order by dead desc

-- entier the world 

select sum(new_cases) as total_Cases,sum(cast (new_deaths as int)) as tota_deaths,sum(cast (new_deaths as int))/sum(new_cases) as  death_percentage--,total_deaths,population,(total_deaths/total_cases)*100 as death_percatnage
	from [first database]..[covid death]
	where continent is not null 
	--group by date
	order by 1,2

	-- total population vs vac
	
	select death.continent ,death.location,death.date,death.population,vac.new_vaccinations
	,sum(convert (int, vac.new_vaccinations )) over (partition by death.location order by death.location ,death.date )as people_vac
    from [first database]..[covid death] death
	join[first database]..['covid vaccine$'] vac
	on death.date=vac.date  
	and death.location=vac.location
	where death.continent is not null
	order by 2,3
 


 --use cte 
 with popvsvac(contient,location,date,population,new_vaccinations,people_vac)
 as 
 (
 	select death.continent ,death.location,death.date,death.population,vac.new_vaccinations
	,sum(convert (int, vac.new_vaccinations )) over (partition by death.location order by death.location ,death.date )as people_vac
    from [first database]..[covid death] death
	join[first database]..['covid vaccine$'] vac
	on death.date=vac.date  
	and death.location=vac.location
	where death.continent is not null
	--order by 2,3
 )
select *,(people_vac/population)*100
from popvsvac

-- temp  tabel 
drop table if exists #percent_pop
create table #percent_pop
( 
contient nvarchar(255),
location nvarchar(255),
date datetime,
population numeric ,
people_vac numeric 
)
insert into #percent_pop
select death.continent ,death.location,death.date,death.population,vac.new_vaccinations
	,sum(convert (int, vac.new_vaccinations )) over (partition by death.location order by death.location ,death.date )as people_vac
    from [first database]..[covid death] death
	join[first database]..['covid vaccine$'] vac
	on death.date=vac.date  
	and death.location=vac.location
	--where death.continent is not null
	--order by 2,3
select *,(people_vac/population)*100
from #percent_pop


--creating view for 
create view percent_pop as
select death.continent ,death.location,death.date,death.population,vac.new_vaccinations
	,sum(convert (int, vac.new_vaccinations )) over (partition by death.location order by death.location ,death.date )as people_vac
    from [first database]..[covid death] death
	join[first database]..['covid vaccine$'] vac
	on death.date=vac.date  
	and death.location=vac.location
	where death.continent is not null
	--order by 2,3




