--1 Find all teammate pairings (same constructor, same season)
with season_totals as (
  select driverId, constructorId, year, SUM(points) total_points
  from merged_df
  group by driverId, constructorId, year
)

select 
t1.driverId driver_1,
t2.driverId driver_2,
t1.constructorId,
t1.year,
t1.total_points driver_1_points,
t2.total_points driver_2_points
from
season_totals t1 JOIN season_totals t2
on t1.constructorId = t2.constructorId
AND t1.year = t2.year
AND t1.driverId < t2.driverId
order by 
t1.constructorId, t1.year;


--2 For each season, compare a driver’s points to their teammate's in the same car.
with season_totals as (
select 
driverId,
constructorId,
year,
CONCAT(first_name,' ', last_name) driver_name,
SUM(points) total_points
from merged_df
group by driverId, constructorId, year, first_name, last_name
),
driver_pairs as(
select 
t1.driverId driver_1_id,
t2.driverId driver_2_id,
t1.constructorId,
t1.year,
t1.driver_name driver_1,
t2.driver_name driver_2,
t1.total_points driver_1_points,
t2.total_points driver_2_points,
 ABS(t1.total_points - t2.total_points) point_gap,
case when t1.total_points > t2.total_points then t1.driver_name
else t2.driver_name
end better_driver
from season_totals t1
join season_totals t2
on t1.constructorId = t2.constructorId
AND t1.year = t2.year
AND t1.driverId < t2.driverId
)
select *
from driver_pairs
order by better_driver, year;


--3 Which constructors (teams) consistently scored the most points across seasons?
select year, constructorId, constructor_name, SUM(points) total_team_points
from merged_df
group by year, constructorId, constructor_name
order by total_team_points desc


--4 Which drivers scored the majority of their team's points in a season?
with team_totals as (
select constructor_name, year, SUM(points) team_points
from merged_df
group by constructor_name, year
),
driver_totals as (
select driverId, constructor_name,year, CONCAT(first_name, ' ', last_name) driver_name, SUM(points) driver_points
from merged_df
group by driverId, constructor_name, year, first_name, last_name
)
select d.year, d.constructor_name, d.driver_name, d.driver_points, t.team_points,
CAST(
case 
when t.team_points = 0 THEN NULL
else (d.driver_points * 100.0) / t.team_points
end as DECIMAL(5,2)) contribution_pct
from driver_totals d JOIN team_totals t
on d.constructor_name = t.constructor_name AND d.year = t.year
order by d.year, constructor_name, contribution_pct desc;



--5 How much do drivers improve or lose positions during a race?
select CONCAT(m.first_name,' ',m.last_name) as driver_name, m.grid, m.final_position, (m.grid - m.final_position) position_change
from merged_df m
where m.final_position is not null
order by m.final_position

--6 who are the top drivers?
select CONCAT(first_name,' ',last_name) as driver, driverId, SUM(points) total_points
from merged_df
group by CONCAT(first_name,' ',last_name), driverId
order by total_points desc


--7 senna dominance in mcLaren
with season_totals as (
select 
driverId,
constructorId,
year,
CONCAT(first_name,' ', last_name) driver_name,
SUM(points) total_points
from merged_df
group by driverId, constructorId, year, first_name, last_name
),
driver_pairs as(
select 
t1.driverId driver_1_id,
t2.driverId driver_2_id,
t1.constructorId,
t1.year,
t1.driver_name driver_1,
t2.driver_name driver_2,
t1.total_points driver_1_points,
t2.total_points driver_2_points,
 ABS(t1.total_points - t2.total_points) point_gap,
case when t1.total_points > t2.total_points then t1.driver_name
else t2.driver_name
end better_driver
from season_totals t1
join season_totals t2
on t1.constructorId = t2.constructorId
AND t1.year = t2.year
AND t1.driverId < t2.driverId
)
select driver_1, driver_1_points, driver_2, driver_2_points
from driver_pairs
where driver_1 = 'Ayrton Senna' or driver_2 = 'Ayrton Senna'
order by better_driver, year;




select sum(points) from merged_df

select * from merged_df;




