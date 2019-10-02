*ANALYSIS;proc corr data=proj.craigslistvehicles_clean; *Pearson correlation; 
var price odometer;
run;


/* create a format to group missing and nonmissing */
proc format;
 value $missfmt ' '='Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;
 
proc freq data=proj.craigslistvehicles_clean; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;

*TABLE AND PLOTS FOR EDA;proc sql;
create table year as
select year,avg(price) as average_price from proj.craigslistvehicles_clean
group by year
order by average_price desc;
run;

proc sgplot data=year;
  title "Relationship between year and average price";
	scatter y=average_price x=year;
run;

proc univariate data=proj.craigslistvehicles_clean;
var year;
histogram;
run;

proc sgplot data=proj.craigslistvehicles_clean;
  title "Relationship between condition and Number of Cars listed for each condition";
	*scatter y=Number_Of_Cars x=condition;
	*dot dataskin = crisp;
  	yaxis label='Number of Cars'; 
	xaxis label='Condition of car';
	vbar condition  / group=condition stat=freq;
run;

proc sgplot data=proj.craigslistvehicles_clean;
  title "Relationship between size and Number of Cars listed for each size";
	*scatter y=Number_Of_Cars x=condition;
	*dot dataskin = crisp;
  	yaxis label='Number of Cars'; 
	xaxis label='size of car';
	vbar size  / group=size stat=freq;
run;

*TABLE AND PLOTS FOR EDA;proc sql;
create table paint as
select paint_color  from proj.craigslistvehicles_clean
where paint_color not like '%unkno%';
run;

proc sgplot data=paint;
  title "Relationship between Paint Color and Number of Cars listed";
	*scatter y=Number_Of_Cars x=condition;
	*dot dataskin = crisp;
  	yaxis label='Number of Cars'; 
	xaxis label='Paint Color of car';
	vbar paint_color  / group=paint_color stat=freq;
run;

proc sql;
create table Type as
select Type,avg(price) as average_price,count(price) as ct
from proj.craigslistvehicles_clean
group by Type
order by average_price desc;
run;

proc sgplot data=Type;
scatter x=Type y=average_price / markerattrs=(symbol=trianglefilled color=red) ;
series x=Type y=average_price / curvelabel='Average Price'
 lineattrs=(color=red pattern=dash) ;
xaxis display=(nolabel);
yaxis min=0 label='Average Price' values=(0 to 18000 by 2000);
run;

proc sql;
create table paint_color as
select paint_color,avg(price) as average_price,count(price) as paint_color_ct
from proj.craigslistvehicles_clean
group by paint_color
order by average_price desc;
run;
proc print data=paint_color (obs=5);
run;

proc sgplot data=paint_color;
scatter x=paint_color y=average_price / markerattrs=(symbol=trianglefilled color=red) ;
scatter x=paint_color y=paint_color_ct / y2axis
 markerattrs=(symbol=circlefilled color=blue);
series x=paint_color y=average_price / curvelabel='Average Price'
 lineattrs=(color=red pattern=dash) ;
series x=paint_color y=paint_color_ct / curvelabel='Count of Paint Color'
 Y2axis
 lineattrs=(color=blue ) ;
xaxis display=(nolabel);
yaxis min=0 label='Average Price' values=(0 to 14000 by 2000);
y2axis min=0 label='Count of Paint Color' values=(0 to 700000 by 10000);
run;

proc sql;
create table title_status as
select title_status,avg(price) as average_price,count(price) as ct
from proj.craigslistvehicles_clean
group by title_status
order by average_price desc;
run;

proc sgplot data=title_status;
scatter x=title_status y=average_price / markerattrs=(symbol=trianglefilled color=red) ;
series x=title_status y=average_price / curvelabel='Average Price'
 lineattrs=(color=red pattern=dash) ;
xaxis display=(nolabel);
yaxis min=0 label='Average Price' values=(0 to 18000 by 2000);
run;

proc sql;
create table vin_flag as
select vin_flag,avg(price) as average_price,count(price) as ct
from proj.craigslistvehicles_clean
group by vin_flag
order by vin_flag desc;
run;

proc print data=vin_flag;
run;


proc means data=proj.craigslistvehicles_clean;
var price;
run;

*TEST FOR RELATIONSHIP;proc glm data=proj.craigslistvehicles_clean;
class size;
model price = size;
run;

proc logistic data=proj.craigslistvehicles_clean;
class drive;
model drive = price;
run;
