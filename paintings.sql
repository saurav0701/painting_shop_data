create database painting;
use painting;
select * from artist;
select * from image_link;
select * from museum;
select * from museum_hours;
select * from product_size;
select * from canvas_size;
select * from subject;
select * from work;


#1) Fetch all the paintings wand their  museums in which they are displayed?

select w.work_id, w.name, m.name as Museum_Displayed, m.address, m.city, m.phone from 
work as w join museum as m 
on w.museum_id = m.museum_id;


#2) How many paintings have an asking price of more than their regular price? 

select count(work_id) from 
product_size 
where sale_price>regular_price;

#3) Identify the paintings whose asking price is less than 50% of its regular price
select work_id from 
(select work_id from product_size where sale_price< (regular_price/2)) as x;

#4) Which canva size costs the most?
select cs.size_id, cs.label , ps.regular_price from 
canvas_size as cs join product_size as ps
on cs.size_id = ps.size_id
where ps.regular_price = (select max(ps.regular_price) from canvas_size as cs join product_size as ps
on cs.size_id = ps.size_id);

#5) Delete duplicate records from work, product_size, subject and image_link tables
with clean_work as (
select * ,
row_number() over (partition by name) as rn
from work )
select * from clean_work 
where rn = 1
;

#6) Identify the museums with invalid city information in the given datase
select * from museum
where city in ('2', '29000', '38000', '45128', '6731 AW Otterlo', '75001');

#7) Fetch the top 10 most famous painting subject
select subject, count(subject) as No_of_Paintings from subject
group by subject
order by No_of_Paintings  desc
limit 10 ;

#8) Identify the museums which are open on both Sunday and Monday. Display museum name, city.
with sun_mon as(
select * ,
lead(day) over() as ld
from museum_hours
where day in ('Sunday', 'Monday'))
select m.name, m.city from sun_mon as sm join museum as m 
on sm.museum_id = m.museum_id
where sm.ld in ('Monday');

#9) How many museums are open every single day?
with open_all as (select museum_id, count(museum_id) as cnt
from museum_hours
group by museum_id
HAVING cnt = 7)
select count(museum_id) as Museums from open_all
;

#10 Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
with top5_work as (with ld_work as (with rn_work as (select * ,
row_number() over( partition by artist_id ) as rn
from work)
select * , lead(rn) over () as ld from rn_work)
select * from ld_work where ld =1 or (artist_id = 920 and rn = 24)
order by rn desc
limit 5)
select a.full_name from artist as a join top5_work as t5
on a.artist_id = t5.artist_id
;
#11 Identify the artists whose paintings are displayed in multiple countrie
with ans as (with ovr as (with arr as (with countr as (select w.artist_id, m.country from work as w join museum as m
on w.museum_id = m.museum_id)
select a.full_name, c.country from artist as a join countr as c on c.artist_id = a.artist_id)
select full_name, country, 
lag(country) over (partition by full_name) as rnk from arr)
select * from ovr 
where rnk<>country)
select distinct full_name from ans;

#12 Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
with count as (with art as (with port_ as (
  select s.work_id, s.subject, w.artist_id, w.museum_id from subject as s join work as w on s.work_id = w.work_id)
  select p.work_id, p.subject, p.artist_id, p.museum_id, m.country from port_ as p join museum as m on p.museum_id = m.museum_id
  where p.subject in ("Portraits") and m.country not in ("USA"))
  select a.artist_id, a.full_name, a.nationality , ar.work_id, ar.subject, ar.museum_id, ar.country from artist as a join art as ar on a.artist_id = ar.artist_id)
  select full_name, count(full_name) , nationality from count group by full_name order by count(full_name) desc  limit 1;


#13 Display the 3 least popular canva sizes
with pop as (with siz as (
  select cs.size_id, cs.height, cs.width,cs.label , ps.work_id from canvas_size as cs join product_size as ps on cs.size_id = ps.size_id)
  select size_id, label , count(size_id) from siz group by size_id order by count(size_id) asc ) 
  select size_id, label from pop limit 3;

#14 Which museum has the most no of most popular painting style?
select style, count(style) from work group by style order by count(style) desc;
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
with cte2 as (with cte as (select m.name as museum_name, m.country, m.phone, w.work_id, w.name, w.style from work as w join museum as m on w.museum_id = m.museum_id where w.style in ("Baroque", "Rococo", "Impressionism"))
select museum_name, country , phone, style, row_number() over(partition by museum_name) as rn 
from cte)
select * , count(style) from cte2 group by style, museum_name
order by count(style) desc
;













