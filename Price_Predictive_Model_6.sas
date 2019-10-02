*SAMPLING FOR ANALYSIS; proc surveyselect data=proj.craigslistvehicles_clean 
method=srs 
n=300000
out=SampleSRS;
run;

/*We used the above sample data during our model building
and analysis but have used the total dataset in the below*/


DATA proj.craigslistvehicles_clean;
set proj.craigslistvehicles_clean;
format condition condition_ord.;
format size size_ord.;
format cylinder cyl_ord.;
run;

proc contents data=proj.craigslistvehicles_temp;
run;

/*PREDICTIVE LINEAR MODEL USING ALL FEATURES*/

ods output ParameterEstimates = para_table;
proc glmselect data=proj.craigslistvehicles_clean plots=all;
partition fraction(test=0.25 validate=0.15);

class make 	
		year(param=ref ref='2000') 
		manufacturer(param=ref ref='honda')  
		condition(param=ordinal ref='salvage') 
		cylinders(param=ordinal ref='other') 
		fuel (param=ref ref='gas')
		title_status(param=ref ref='clean') 
		transmission 
		drive(param=ref ref='rwd') 
		size(param=ordinal ref='sub-compact') 
		type(param=ref ref='sedan') 
		paint_color(param=ref ref='black') 
		state_fips(param=ref ref='99');

model price = year make manufacturer drive odometer fuel odometer fuel cylinders state_fips
type condition title_status vin_flag transmission paint_color size
		/ selection=stepwise showpvalues ;

run;

/*PREDICTIVE LINEAR MODEL USING ONLY EFFICIENT FEATURES*/

ods output ParameterEstimates = para_table;
proc glmselect data=proj.craigslistvehicles_clean plots=all;
partition fraction(test=0.25 validate=0.15);

class   make 	
		year(param=ref ref='2000') 
		manufacturer(param=ref ref='honda')  
		fuel (param=ref ref='gas')
		drive(param=ref ref='rwd') ;

model price = year make manufacturer drive odometer fuel 
		/ selection=stepwise showpvalues ;

run;

proc sql outobs=10;
select * from para_table where effect like '%manufacturer%'
order by estimate desc;

proc sql outobs=10;
select * from para_table where effect like '%year%'
order by estimate desc;
