***SET TIME SERIES AND LOAD DATA***
clear all

cd "C:\Users\Peter\OneDrive\My Own Projects\Bachelor"

use event_dataset

generate numdate = date(TIME_PERIOD, "YMDhms")

format numdate %td

tsset numdate

***GEN VARIABLES***
gen first_announcement = (numdate == mdy(9,12,2019))
gen two_day_first_announcement = (numdate == mdy(9,12,2019) | numdate == mdy(9,13,2019))
gen second_announcement = (numdate == mdy(3,18,2020))
gen two_day_second_announcement = (numdate == mdy(3,18,2020) | numdate == mdy(3,19,2020))
gen third_announcement = (numdate == mdy(6,4,2020))
gen two_day_third_announcement = (numdate == mdy(6,4,2020) | numdate == mdy(6,4,2020))
gen fourth_announcement = (numdate == mdy(12,10,2020))
gen two_day_fourth_announcement = (numdate == mdy(12,10,2020) | numdate == mdy(12,10,2020))

gen ln_DAX = ln(DAX)

gen delta_one = one_year - L1.one_year
gen delta_eight = eight_year - L1.eight_year
gen delta_twenty = twenty_year - L1.twenty_year
gen delta_dax = ln_DAX - L1.ln_DAX
*gen delta_CISS = CISS - L1.CISS
*gen delta_EONIA = EONIA - L1.EONIA

display mdy(9,12,2019)
display mdy(3,12,2020)
display mdy(6,4,2020)
display mdy(12,10,2020)
display mdy(2,20,2022)

***PLOT GRAPHS***
line one_year numdate if numdate <= td(20feb2022), xline(21804, lcolor(red)) xline(21986, lcolor(red)) xline(22070, lcolor(red)) xline(22259, lcolor(red)) tlabel(01jan2019(365)20feb2022) name(one_year) xtitle(Date) ytitle(Pct.) title(1-Year, size(medsmall)) lcolor(blue)

line eight_year numdate if numdate <= td(20feb2022), xline(21804, lcolor(red)) xline(21986, lcolor(red)) xline(22070, lcolor(red)) xline(22259, lcolor(red)) tlabel(01jan2019(365)20feb2022)  name(eight_year) xtitle(Date) ytitle(Pct.) title(8-Year, size(medsmall)) lcolor(blue)

line twenty_year numdate if numdate <= td(20feb2022), xline(21804, lcolor(red)) xline(21986, lcolor(red)) xline(22070, lcolor(red)) xline(22259, lcolor(red)) tlabel(01jan2019(365)20feb2022)  name(twenty_year) xtitle(Date) ytitle(Pct.) title(20-Year, size(medsmall)) lcolor(blue)

line ln_DAX numdate if numdate <= td(20feb2022), xline(21804, lcolor(red)) xline(21986, lcolor(red)) xline(22070, lcolor(red)) xline(22259, lcolor(red)) tlabel(01jan2019(365)20feb2022)  name(DAX) xtitle(Date) ytitle(Pct.) title(DAX, size(medsmall)) lcolor(blue)

graph combine one_year eight_year twenty_year DAX


***SINGLE DAY EVENT STUDY***
foreach var in "delta_one" "delta_eight" "delta_twenty" "delta_dax" {
	
	quietly regress `var' first_announcement second_announcement third_announcement fourth_announcement if numdate >= td(01jan2019) & numdate <= td(31dec2021), robust 
	predict `var'_pred, residuals
	
	
	margins, expression(_b[first_announcement] + _b[second_announcement] + _b[third_announcement] + _b[		fourth_announcement]) post
	mat r= r(table)
	
	eststo: quietly reg `var' first_announcement second_announcement third_announcement fourth_announcement if numdate >= td(01jan2019) & numdate <= td(31dec2021) 
	estadd local mystat "`= cond(r[4,1]<0.01,"`:di %5.3f `=r[1,1]''***", cond(r[4,1]<0.05,"`:di %5.3f `=r[1,1]''**", cond(r[4,1]<0.1,"`:di %5.3f `=r[1,1]''*",  "`:di %5.3f `=r[1,1]''")))'"
		
	
}

foreach var in "delta_one_pred" "delta_eight_pred" "delta_twenty_pred" "delta_dax_pred" {
	
histogram `var', name(`var')

}

graph combine delta_one_pred delta_eight_pred delta_twenty_pred delta_dax_pred


foreach var in "delta_one_pred" "delta_eight_pred" "delta_twenty_pred" "delta_dax_pred" {
	
qnorm `var', name(`var'1)

}

graph combine delta_one_pred1 delta_eight_pred1 delta_twenty_pred1 delta_dax_pred1


esttab using regression_tables1.tex, nogaps nobase scalar("mystat Sum") not starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("1-Year" "8-Years" "20-Years" "DAX") style(tex) legend replace

eststo clear

***TWO DAY EVENT STUDY***
foreach var in "delta_one" "delta_eight" "delta_twenty" "delta_dax" {
	
	quietly regress `var' two_day_first_announcement two_day_second_announcement two_day_third_announcement two_day_fourth_announcement if numdate >= td(01jan2019) & numdate <= td(31dec2021), robust 

	margins, expression(_b[two_day_first_announcement] + _b[two_day_second_announcement] + _b[two_day_fourth_announcement] + _b[two_day_fourth_announcement]) post
	mat r= r(table)
	
	eststo: quietly regress `var' two_day_first_announcement two_day_second_announcement two_day_third_announcement two_day_fourth_announcement if numdate >= td(01jan2019) & numdate <= td(31dec2021) 
	estadd local mystat "`= cond(r[4,1]<0.01,"`:di %5.3f `=r[1,1]''***", cond(r[4,1]<0.05,"`:di %5.3f `=r[1,1]''**", cond(r[4,1]<0.1,"`:di %5.3f `=r[1,1]''*",  "`:di %5.3f `=r[1,1]''")))'"
		
}

esttab using regression_tables2.tex, nogaps nobase scalar("mystat Sum") not starlevels(* 0.10 ** 0.05 *** 0.01) mlabels("1-Year" "8-Years" "20-Years" "DAX") style(tex) legend replace

eststo clear



