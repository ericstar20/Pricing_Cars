dm 'clear log';
dm 'clear output';

/* clear log and output */
libname proj "C:\sxp180046_Suhas\Project_CraiglistCars";
*DATA IMPORT; proc import out=proj.craigslistVehiclesFull 
datafile="H:\Project_CraiglistCars\craigslist-carstrucks-data\craigslistVehiclesFull.csv" 
		dbms=csv replace;
	GETNAMES=YES;
	datarow=2;
run;

*CORRECTING THE DATATYPE OF VARIABLES;data PROJ.CRAIGSLISTVEHICLESFULL;
	%let _EFIERR_ = 0;

	/* set the ERROR detection macro variable */
	infile 'H:\Project_CraiglistCars\craigslist-carstrucks-data/craigslistVehiclesFull.csv' 
		delimiter= ',' MISSOVER DSD lrecl=32767 firstobs=2;
	informat url $89.;
	informat city $14.;
	informat price best32.;
	informat year best32.;
	informat manufacturer $15.;
	informat make $34.;
	informat condition $11.;
	informat cylinders $14.;
	informat fuel $10.;
	informat odometer best32.;
	informat title_status $9.;
	informat transmission $11.;
	informat vin $19.;
	informat drive $5.;
	informat size $13.;
	informat type $13.;
	informat paint_color $8.;
	informat image_url $61.;
	informat lat best32.;
	informat long best32.;
	informat county_fips best32.;
	informat county_name $16.;
	informat state_fips best32.;
	informat state_code $4.;
	informat state_name $15.;
	informat weather best32.;
	format url $89.;
	format city $14.;
	format price best12.;
	format year best12.;
	format manufacturer $15.;
	format make $34.;
	format condition $11.;
	format cylinders $14.;
	format fuel $10.;
	format odometer best12.;
	format title_status $9.;
	format transmission $11.;
	format vin $19.;
	format drive $5.;
	format size $13.;
	format type $13.;
	format paint_color $8.;
	format image_url $61.;
	format lat best12.;
	format long best12.;
	format county_fips best12.;
	format county_name $16.;
	format state_fips best12.;
	format state_code $4.;
	format state_name $15.;
	format weather best12.;
					input url  $
                         city  $
                         price year manufacturer  $
                         make  $
                         condition  $
                         cylinders  $
                         fuel  $
                         odometer title_status  $
                         transmission  $
                         vin  $
                         drive  $
                         size  $
                         type  $
                         paint_color  $
                         image_url  $
                         lat long county_fips 
						 county_name  $
                         state_fips state_code  $
                         state_name  $
                         weather;

	if _ERROR_ then
		call symputx('_EFIERR_', 1);

	/* set ERROR detection macro variable */
run;
*ASSIGN ORDER LEVELS FOR ORDINAL DATA;
proc format;
	value condition_ord
	1='salvage'
	2='fair'
	3='good'
	4='excellent'
	5='like new'
	6='new'
	other='unknown_condition';

	value size_ord
	1='sub-compact'
	2='compact'
	3='mid-size '
	4='full-size'
	other='unknown_size ';

	value cyl_ord
	1 = 'other'
	2='3 cylinders' 
	3='4 cylinders' 
	4='5 cylinders' 
	5='6 cylinders' 
	6='8 cylinders' 
	7='10 cylinders' 
	8='12 cylinders' 
	other = 'unknown_cylinder';

run;

proc contents DATA=proj.craigslistvehiclesfull;
run;
