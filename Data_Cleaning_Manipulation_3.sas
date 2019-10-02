/* create a format to group missing and nonmissing */
*MISSING VALUES INFO;proc format;
 value $missfmt ' '='Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;
 
*MISSING VALUES INFO;proc freq data=proj.craigslistvehiclesfull; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;

*ANALYSIS;proc corr data=proj.craigslistvehiclesfull; *Pearson correlation; 
run;

*DROP VARIABLES; data proj.craigslistvehiclesfull(drop= url image_url lat long weather state_name state_code county_name county_fips);
set proj.craigslistvehiclesfull;
run;
*Taking a copy of dataset to work;
data proj.craigslistvehicles_use;
set proj.craigslistvehiclesfull;
run;
*DATA FLAGS AND CORRECTION; data proj.craigslistvehicles_use;
set proj.craigslistvehicles_use;
if (odometer <=1 or odometer >= 750000)  then odometer_flag = 0; else odometer_flag =1; 
	clean_id=_n_;
	run;
*ANALYSIS;proc corr data=proj.craigslistvehiclesfull; *Pearson correlation; 
run;

*ODOMETER PREDICTION - HANDLING MISSING VALUES;proc sql;
create table odometer_sample as
select clean_id,odometer,odometer_flag,price,year,city,type from proj.craigslistvehicles_use;
run;

proc glmselect data = odometer_sample(where=(odometer_flag=1)) plots=all;
partition fraction(test=0.25 validate=0.15);
class type year city;
model odometer = price year type city/ showpvalues;
score data=odometer_sample(where=(odometer_flag=0)) out = results p r;
run;

proc glmselect data = odometer_sample(where=(odometer_flag=1)) plots=all;
partition fraction(test=0.25 validate=0.15);
class type year;
model odometer = price year type/ showpvalues;
score data=odometer_sample(where=(odometer_flag=0)) out = results p r;
run;

data proj.craigslistvehicles_use;
merge proj.craigslistvehicles_use results(keep=clean_id p_odometer);
by clean_id;
run;
data proj.craigslistvehicles_use;
set proj.craigslistvehicles_use;
if odometer_flag = 0 then odometer=p_odometer;
run;

*DRIVE-HANDLE NULL VALUES;proc sql outobs=10;
select count(*) as missing_count from proj.craigslistvehicles_use
where drive is null
;
proc sql outobs=10;
select make,drive from proj.craigslistvehicles_use
where drive is not null
and make is not null
;

proc sql outobs=10;
create table make_drive (
make varchar(50),
wd4 int 8,
fwd int 8,
rwd int 8
);

proc sql;
insert into make_drive (make, wd4)
select distinct make,count(*) as wd4 from proj.craigslistvehicles_use
where drive like '%4wd%'
and make in (select distinct make from proj.craigslistvehicles_use where drive is null and make is not null)
and drive is not null
group by make;
proc sql;
insert into make_drive (make, fwd)
select distinct make,count(*) as fwd from proj.craigslistvehicles_use
where drive like '%fwd%'
and make in (select distinct make from proj.craigslistvehicles_use where drive is null and make is not null)
and drive is not null
group by make;
proc sql;
insert into make_drive (make, rwd)
select distinct make,count(*) as rwd from proj.craigslistvehicles_use
where drive like '%rwd%'
and make in (select distinct make from proj.craigslistvehicles_use where drive is null and make is not null)
and drive is not null
group by make;

proc sql;
create table make_drive2 as
select make,max(wd4) as wd4,max(fwd) as fwd,max(rwd) as rwd from make_drive
group by make
;

data make_drive2;
set make_drive2;
array v wd4 fwd rwd;
   maxvalue = max(of v(*));
   length maxdrive $32.;
   maxdrive = vname(v[whichn(maxvalue, of v(*))]);
run;

data make_drive;
set make_drive2;
   if maxdrive = 'wd4' then maxdrive = '4wd';
   run;

proc sql outobs = 10;
select make,max(wd4),max(fwd),max(rwd) from make_drive
group by make
;

proc sql outobs = 5;
select * from proj.craigslistvehicles_use a join make_drive b 
on a.make=b.make;
proc sort data=make_drive;
by make;
run;
proc sort data=proj.craigslistvehicles_use;
by make;
run;

data proj.craigslistvehicles_use;
set proj.craigslistvehicles_use;
merge proj.craigslistvehicles_use make_drive(keep=make maxdrive);
by make;
run;
proc sql outobs=10;
select count(*) from proj.craigslistvehicles_use
where drive is null
and make in (select make from make_drive)
;

data proj.craigslistvehicles_use;
set proj.craigslistvehicles_use;
if drive = '' then drive=maxdrive;
run;
proc sql outobs=10;
select make,drive,maxdrive from proj.craigslistvehicles_use
where drive is not null
and make is not null
;
proc sql outobs=10;
select count(*) as missing_count from proj.craigslistvehicles_use
where drive is null
;

*MANUFACTURER - COLLECT FROM MAKE, REPLACE MISSING; data proj.craigslistvehicles_clean;
set proj.craigslistvehicles_use;
if find(make,'mazd','i') ge 1 and manufacturer ='' then manufacturer = 'mazda';
if find(make,'ford','i') ge 1 and manufacturer ='' then manufacturer = 'ford';
if find(make,'chev','i') ge 1 and manufacturer ='' then manufacturer = 'chevrolet';
if find(make,'toyot','i') ge 1 and manufacturer ='' then manufacturer = 'toyota';
if find(make,'merc','i') ge 1 and manufacturer ='' then manufacturer = 'mercedes-benz';
if find(make,'hond','i') ge 1 and manufacturer ='' then manufacturer = 'honda';
if find(make,'vw','i') ge 1 and manufacturer ='' then manufacturer = 'volkswagen';
if find(make,'volk','i') ge 1 and manufacturer ='' then manufacturer = 'volkswagen';
if find(make,'audi','i') ge 1 and manufacturer ='' then manufacturer = 'audi';
if find(make,'bmw','i') ge 1 and manufacturer ='' then manufacturer = 'bmw';
if find(make,'alfa','i') ge 1 and manufacturer ='' then manufacturer = 'alfa-romeo';
if find(make,'aston','i') ge 1 and manufacturer ='' then manufacturer = 'aston-martin';
if find(make,'cadill','i') ge 1 and manufacturer ='' then manufacturer = 'cadillac';
if find(make,'dodge','i') ge 1 and manufacturer ='' then manufacturer = 'dodge';
if find(make,'ferra','i') ge 1 and manufacturer ='' then manufacturer = 'ferrari';
if find(make,'acura','i') ge 1 and manufacturer ='' then manufacturer = 'acura';
if find(make,'buick','i') ge 1 and manufacturer ='' then manufacturer = 'buick';
if find(make,'chrysl','i') ge 1 and manufacturer ='' then manufacturer = 'chrysler';
if find(make,'datsun','i') ge 1 and manufacturer ='' then manufacturer = 'datsun';
if find(make,'fiat','i') ge 1 and manufacturer ='' then manufacturer = 'fiat';
if find(make,'gmc','i') ge 1 and manufacturer ='' then manufacturer = 'gmc';
if find(make,'harley','i') ge 1 and manufacturer ='' then manufacturer = 'harley-davidson';
if find(make,'henness','i') ge 1 and manufacturer ='' then manufacturer = 'hennessey';
if find(make,'hyund','i') ge 1 and manufacturer ='' then manufacturer = 'hyundai';
if find(make,'infinit','i') ge 1 and manufacturer ='' then manufacturer = 'infiniti';
if find(make,'jaguar','i') ge 1 and manufacturer ='' then manufacturer = 'jaguar';
if find(make,'jeep','i') ge 1 and manufacturer ='' then manufacturer = 'jeep';
if find(make,'kia','i') ge 1 and manufacturer ='' then manufacturer = 'kia';
if find(make,'rover','i') ge 1 and manufacturer ='' then manufacturer = 'landrover';
if find(make,'lexu','i') ge 1 and manufacturer ='' then manufacturer = 'lexus';
if find(make,'linco','i') ge 1 and manufacturer ='' then manufacturer = 'lincoln';
if find(make,'benz','i') ge 1 and manufacturer ='' then manufacturer = 'mercedes-benz';
if find(make,'mercury','i') ge 1 and manufacturer ='' then manufacturer = 'mercury';
if find(make,'mini','i') ge 1 and manufacturer ='' then manufacturer = 'mini';
if find(make,'mitsubis','i') ge 1 and manufacturer ='' then manufacturer = 'mitsubishi';
if find(make,'morgan','i') ge 1 and manufacturer ='' then manufacturer = 'morgan';
if find(make,'nissan','i') ge 1 and manufacturer ='' then manufacturer = 'nissan';
if find(make,'volvo','i') ge 1 and manufacturer ='' then manufacturer = 'volvo';
if find(make,'subaru','i') ge 1 and manufacturer ='' then manufacturer = 'subaru';
if find(make,'noble','i') ge 1 and manufacturer ='' then manufacturer = 'noble';
if find(make,'pontiac','i') ge 1 and manufacturer ='' then manufacturer = 'pontiac';
if find(make,'porch','i') ge 1 and manufacturer ='' then manufacturer = 'porche';
if find(make,'ram','i') ge 1 and manufacturer ='' then manufacturer = 'ram';
if find(make,'saturn','i') ge 1 and manufacturer ='' then manufacturer = 'saturn';

run;
