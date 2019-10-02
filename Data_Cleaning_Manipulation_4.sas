*DATA CLEANING; data proj.craigslistvehicles_clean;
set proj.craigslistvehicles_use;

*NULL VALUES;	

	if transmission = '' or transmission = 'other' then transmission = 'automatic';
	if title_status = '' then title_status = 'clean';
	if fuel = '' then fuel = 'gas';

	if make ='' then make = 'unknown_make';
	if manufacturer ='' then manufacturer = 'unknown_manufacturer';
	if size ='' then size = 'unknown_size';
	if type ='' then type = 'unknown_type';
	if cylinders = '' then cylinders = 'unknown_cylinders';
	if condition = '' then condition = 'unknown_condition';
	if paint_color = '' then paint_color = 'unknown_color';

	if state_fips = . then state_fips=99;

	if price >= 200000 or price < 50  then delete;
	if price <= .Z then delete; /* cuts out where the price is non-numeric */
	if price <= 1 then delete; /* cuts out where the price is invalid */
	*cuts out where the odometer value is invalid:  https://www.autotrader.com/car-news/these-are-the-7-highest-mileage-cars-listed-on-autotrader-256616;
	*if (odometer <=1 or odometer >= 750000)  then odometer_flag = 0; else odometer_flag =1; 
	if odometer = . then odometer=mean(odometer); /* replacing with the mean */
	if year <= .Z then delete; /* cuts out where the year is non-numeric */
	if year <= 1884 then year = 1884; /* https://www.clunkers4charity.org/facts-about/11-oldest-cars-world/ */

run;

*DATA FLAGS AND CORRECTION; data proj.craigslistvehicles_clean;
set proj.craigslistvehicles_clean;

	vin = compress(vin, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', 'k');
	if vin = '' then vin_flag = 0;
	else vin_flag = 1;	
	if length(vin) ~= 17 then vin_flag = 0; *https://driving-tests.org/vin-decoder/;

	if manufacturer = 'alfa' then manufacturer = 'alfa-romeo';
	if manufacturer = 'aston' then manufacturer = 'aston-martin';
	if manufacturer = 'chev' or manufacturer = 'chevy' then manufacturer = 'chevrolet';
	if manufacturer = 'harley' then manufacturer = 'harley-davidson';
	if manufacturer = 'infinity' then manufacturer = 'infiniti';
	if manufacturer = 'land rover' then manufacturer = 'landrover'; 
	if manufacturer = 'rover' then manufacturer = 'landrover';
	if manufacturer = 'mercedes' then manufacturer = 'mercedes-benz';
	if manufacturer = 'mercedesbenz' then manufacturer = 'mercedes-benz';
	if manufacturer = 'vw' then manufacturer = 'volkswagen';

	if make='1500' then make = 'silverado 1500';
	if make = '1500 silverado' then make = 'silverado 1500';
	if make='f150' then make = 'f-150';


run;

proc sql ;
create table make_tbl as
select make,count(make) as freq from proj.craigslistvehicles_clean
group by make
order by freq desc
;
proc sql noprint;
create table proj.craigslistvehicles_t as
select * from proj.craigslistvehicles_clean p join make_tbl m
on p.make=m.make
;
data proj.craigslistvehicles_clean;
set proj.craigslistvehicles_t;
if freq < 100 then make = 'other';
run;
