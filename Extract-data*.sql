Extract ad cost data
==========================
#### Descriptions: 
* Extract the date of week, hour and the channel(network) kantar ad cost data.
* Group the data by hour
* Calculating the average cost in that hour
* Limit 1500000, which covers data from approximately two month

#### SQL code:
---------------------- selecting data ----------------------------
select
  date_trunc('hour',ad_time_est) as time,
  avg(ad_cost),
  master_n,
  date_part('quarter', date_trunc('hour',ad_time_est)) as quarter_No,
  date_part(dow,date_trunc('hour',ad_time_est)) as date,
  date_part('hour', date_trunc('hour',ad_time_est)) as hour
from dw.f_kantar_ads
group by date_trunc('hour',ad_time_est),master_n
order by date_trunc('hour',ad_time_est)
limit 150000

### Brief understanding of data 
---------------- Check the delay days kantar report --------------
select
  date_trunc('day',ad_time_est) as days,
  avg(ad_cost)
from dw.f_kantar_ads
group by date_trunc('day',ad_time_est)
order by date_trunc('day',ad_time_est) DESC
limit 100

---------------- show top 10 most expensive ad ----------------------
select
  avg(ad_cost) as average_cost,
  program
from dw.f_kantar_ads
group by program
order by average_cost DESC
limit 10

--------------- show graph ----------------------
select
  avg(ad_cost),
  master_n
from dw.f_kantar_ads
group by master_n
order by avg(ad_cost)
;

select
  avg(ad_cost),
  program_type
from dw.f_kantar_ads
where ad_time_est between
          (select DATEADD(mm, -6, MAX(ad_time_est))from dw.f_kantar_ads where ad_cost > 0)
      and (select max(ad_time_est) from dw.f_kantar_ads where ad_cost > 0)
group by program_type
order by avg(ad_cost)
;

---------------- Average cost by Kevin ------------------------------
--------------------------------------------------------------------------------
--[MEDDLE:PG] {?FileName} - Initialize cost data storage
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS {?SchemaName}.CostByNetworkDayHour CASCADE;
CREATE TABLE {?SchemaName}.CostByNetworkDayHour
(
    StationCallSign varchar,
    EffectiveDate date,
    DayOfWeek int,
    HourOfDay int,
    NumSpots int,
    AverageCost double precision
);

--------------------------------------------------------------------------------
--[MEDDLE:PG] {?FileName} - Build estimated cost data
--------------------------------------------------------------------------------
INSERT INTO {?SchemaName}.CostByNetworkDayHour (
    StationCallSign, EffectiveDate, DayOfWeek, HourOfDay, NumSpots, AverageCost)
SELECT StationCallSign, EffectiveDate, DayOfWeek, HourOfDay, COUNT(*), AVG(Cost)
FROM (
    SELECT A.StationCallSign, C.EffectiveDate,
        EXTRACT(DOW FROM A.AirDateTime) AS DayOfWeek,
        EXTRACT(HOUR FROM A.AirDateTime) AS HourOfDay,
        A.Cost
    FROM NationalAd A
    INNER JOIN (
        SELECT StationCallSign, MAX(AirDateTime)::date AS EffectiveDate
        FROM NationalAd
        WHERE Cost IS NOT NULL AND Cost>0
        GROUP BY StationCallSign
    ) C ON C.StationCallSign=A.StationCallSign
        AND A.AirDateTime BETWEEN C.EffectiveDate-'6 months'::interval AND C.EffectiveDate
    WHERE A.Cost IS NOT NULL AND A.Cost>0
) X
GROUP BY StationCallSign, EffectiveDate, DayOfWeek, HourOfDay;

--------------------------------------------------------------------------------
--[MEDDLE:PG] {?FileName} - Update missing cost data with averages
--------------------------------------------------------------------------------
UPDATE NationalAd A SET Cost=C.AverageCost
FROM {?SchemaName}.CostByNetworkDayHour C
WHERE (A.Cost IS NULL OR A.Cost=0)
AND A.AirDateTime>=C.EffectiveDate AND C.NumSpots>=100
AND A.StationCallSign=C.StationCallSign
AND C.DayOfWeek=EXTRACT(DOW FROM AirDateTime)
AND C.HourOfDay=EXTRACT(HOUR FROM AirDateTime);
