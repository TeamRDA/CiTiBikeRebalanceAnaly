

create table 201609_merge_v1 AS SELECT 201609_wea_v3.newtime, 201609_wea_v3.wtype, station_20160901_07_new.start_time, station_20160901_07_new.end_time, station_20160901_07_new.delta
   FROM  station_20160901_07_new
   JOIN  201609_wea_v3 WHERE newtime<= end_time
           AND newtime>= start_time;


CREATE TABLE 201609_wea_full_v1 AS SELECT from_unixtime(unix_timestamp(CONCAT(CONCAT(date,time),"00"),'yyyyMMddHHmmss')) as newtime, wtype, temp FROM 201609_wea;

create table 201609_merge_v3 AS SELECT 201609_wea_full_v1.newtime, 201609_wea_full_v1.wtype, station_20160901_full.start_time, station_20160901_full.end_time, station_20160901_full.delta
FROM  station_20160901_07_new
   JOIN  201609_wea WHERE newtime<= end_time
           AND newtime>= start_time;

create table 201609_merge_v4 AS SELECT * from 201609_merge_v3 where length(wtype)>=2;

SELECT AVG(abs(delta)) FROM 201609_merge_v3;
SELECT AVG(abs(201609_merge_v4.delta)) FROM 201609_merge_v4 where array_contains(split(wtype,' '),'+RA');;


create table 201601_merge_v1 AS SELECT 201601_wea_v3.newtime, 201601_wea_v3.wtype, 201601_wea_v3.temp,
   station_diff_201601.start_time, station_diff_201601.end_time, station_diff_201601.delta
    FROM  station_diff_201601
    JOIN  201601_wea_v3 WHERE newtime<= end_time
            AND newtime>= start_time;

  SELECT AVG(abs(delta)) FROM 201601_merge_v1;
  SELECT AVG(abs(201601_merge_v1.delta)) FROM 201601_merge_v1 WHERE (array_contains(split(wtype,' '),'+SN')OR(array_contains(split(wtype,' '),'-SN')));

  create external table 201602_wea_v1 (data1 string, date string, time string, data4 string, data5 string,
  data6 string, data7 string, data8 string, wtype string, data10 string, temp int,
  data12 string, data13 string, data14 string, data15 string,
  data16 string, data17 string, data18 string, data19 string, data20 string,
  data21 string, data22 string, data23 string, data24 string, data25 string,
  data26 string, data27 string, data28 string, data29 string, data30 string,
  data31 string, data32 string, data33 string, data34 string, data35 string,
  data36 string, data37 string, data38 string, data39 string, data40 string,
  data41 string, data42 string, data43 string, data44 string
) row format delimited fields terminated by ',' location '/user/iwl210/201602';

CREATE TABLE 201602_wea_v2 AS SELECT date, time, wtype, temp FROM 201602_wea_v1;
CREATE TABLE 201602_wea_v4 AS SELECT from_unixtime(unix_timestamp(CONCAT(CONCAT(date,time),"00"),'yyyyMMddHHmmss'))
as newtime, wtype, temp FROM 201602_wea_v2;


create table station_diff_201602 as select * from station_diff_201601to03 where
  (start_time >= unix_timestamp("20160201000000",'yyyyMMddHHmmss'))
  and (start_time < unix_timestamp("20160301000000",'yyyyMMddHHmmss'));


create table 201602_merge_v1 AS SELECT 201602_wea_v4.newtime, 201602_wea_v4.wtype, 201602_wea_v4.temp,
  station_diff_201602.start_time, station_diff_201602.end_time, station_diff_201602.delta
   FROM  station_diff_201602
   JOIN  201602_wea_v4 WHERE newtime<= end_time
           AND newtime>= start_time;

// stop here to wait for the correct table

CREATE TABLE triptable_v4 AS SELECT tripduration, starttime, stoptime, startstationid, endstationid FROM triptable_v3;

CREATE TABLE triptable_v5 AS SELECT * FROM triptable_v4 SORT BY starttime ASC;


CREATE TABLE  201609_wea_full_v3 AS SELECT from_unixtime(unix_timestamp(newtime,'yyyy-MM-dd HH:mm:ss'))
AS time, wtype, temp from 201609_wea_full_v1;

CREATE TABLE  201609_wea_full_v4 AS SELECT cast(newtime AS timestamp)
AS time, wtype, temp from 201609_wea_full_v1;

CREATE TABLE triptable_v8 AS SELECT
cast(tripduration AS int) AS tripd,
cast(from_unixtime(unix_timestamp(starttime,'M-d-yyyy HH:mm:ss')) AS timestamp) AS startt,
cast(from_unixtime(unix_timestamp(stoptime,'M-d-yyyy HH:mm:ss')) AS timestamp) AS stopt,
startstationid, endstationid FROM triptable_v5;

CREATE TABLE triptable_v9 AS SELECT ROW_NUMBER() OVER() as row_num, *
from triptable_v8;

create table tripwea09_v4 AS SELECT a.tripd, a.startt, a.stopt,
b.time, b.wtype, b.temp
   FROM  triptable_v8 a
   JOIN 201609_wea_full_v4 b
   WHERE b.time  >= a.startt
    AND  b.time  <= a.stopt;

create table tripwea09_v5 AS SELECT a.row_num, a.tripd, a.startt, a.stopt,
    b.time, b.wtype, b.temp
       FROM  triptable_v9 a
       JOIN 201609_wea_full_v4 b
       WHERE b.time  >= a.startt
        AND  b.time  <= a.stopt;

CREATE TABLE tripwea09_v6 AS SELECT * FROM tripwea09_v5 where array_contains(split(wtype,' '),'-RA');

CREATE TABLE tripwea09_v7 AS SELECT row_num, tripd, COUNT(distinct time) AS counter
FROM tripwea09_v6
GROUP BY row_num,tripd;

SELECT AVG(tripd) FROM tripwea09_v7
  WHERE counter == 1;  // 1067.574699544136   (9652)

SELECT AVG(tripd) FROM tripwea09_v7
  WHERE counter == 2; // 7877.977272727273    (1100)

SELECT AVG(tripd) FROM tripwea09_v7
    WHERE counter >=3; // 147795.94814814813  (270)

SELECT AVG(tripd) FROM tripwea09_v7 WHERE tripd < 4500;  //  1018.7260881880842#10591
SELECT AVG(tripd) FROM tripwea09_v7;                     //  5341.581564144439


CREATE TABLE tripwea09_v8 AS SELECT * FROM tripwea09_v5 where array_contains(split(wtype,' '),'+RA');

CREATE TABLE tripwea09_v9 AS SELECT row_num, tripd, COUNT(distinct time) AS counter
FROM tripwea09_v8
GROUP BY row_num,tripd;



SELECT AVG(tripd) FROM tripwea09_v9 WHERE tripd < 4500;
SELECT AVG(tripd) FROM tripwea09_v9;

SELECT AVG(tripd) FROM tripwea09_v5 WHERE tripd < 4500;

// Repeat this for every month

CREATE TABLE trip1015_0916_v2 AS SELECT
cast(tripduration AS int) AS tripd,
cast(from_unixtime(unix_timestamp(starttime,'M-d-yyyy HH:mm:ss')) AS timestamp) AS startt,
cast(from_unixtime(unix_timestamp(stoptime,'M-d-yyyy HH:mm:ss')) AS timestamp) AS stopt,
startstationid, endstationid FROM trip1015_0916;









"20160201000000",'yyyyMMddHHmmss'
