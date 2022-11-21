clear all

cd "C:\Users\Peter\OneDrive\My Own Projects\Bachelor\Github kode\STATA code"

use collected_dataset

rename X INDUSTRIAL
rename y QUARTERLY_GDP
rename y_hat MONTHLY_GDP


**# Set time
gen month = ym(INDEX, grain)
format %tm month

tsset month


**# Gen variables
gen log_MONTHLY_GDP = log(MONTHLY_GDP)
gen log_ASSETS = log(ASSETS)
gen log_HICP = log(HICP)
gen EONIA_MRO_SPREAD = EONIA - MRO

gen ASSETS_new = log_ASSETS*100
gen CISS_new = CISS*100
gen EONIA_new = EONIA_MRO_SPREAD*100 
gen HICP_new = log_HICP*100 
gen GDP_new = log_MONTHLY_GDP*100 
gen MRO_new = MRO*100

gen corona_dummy1 = (month == tm(2020m4))
gen corona_dummy2 = (month == tm(2020m5))
gen corona_dummy3 = (month == tm(2020m6))

global start_year 2015m1

global end_year 2021m12

gen yoy_GDP = log_MONTHLY_GDP-l12.log_MONTHLY_GDP
gen yoy_ASSETS = log_ASSETS-l12.log_ASSETS

twoway (bar yoy_ASSETS month if month >= tm($start_year) & month <= tm($end_year), yaxis(1) xlabel(#4) color(emidblue) ytitle(Yoy. percentage change)) (line yoy_GDP month if month >= tm($start_year) & month <= tm($end_year), yaxis(2) xlabel(#4) color(dkorange))



**# Draw line graphs
graph drop _all
local variables "log_ASSETS CISS EONIA_MRO_SPREAD log_HICP log_MONTHLY_GDP MRO"
line log_ASSETS month if month >= tm($start_year) & month <= tm($end_year), name(log_ASSETS) xlabel(#4) lcolor(blue) title(Log of Total Assets, size(medsmall)) ytitle(log(Assets)) xtitle(Date)
line CISS month if month >= tm($start_year) & month <= tm($end_year), name(CISS) xlabel(#4) lcolor(blue) title(CISS, size(medsmall)) ytitle(pPt.) xtitle(Date)
line EONIA_MRO_SPREAD month if month >= tm($start_year) & month <= tm($end_year), name(EONIA_MRO_SPREAD) xlabel(#4) lcolor(blue) title(EONIA-MRO-spread, size(medsmall)) ytitle(Pct.) xtitle(Date)
line log_HICP month if month >= tm($start_year) & month <= tm($end_year), name(log_HICP) xlabel(#4) lcolor(blue) title(Log of HICP, size(medsmall)) ytitle(log(HICP)) xtitle(Date)
line log_MONTHLY_GDP month if month >= tm($start_year) & month <= tm($end_year), name(log_MONTHLY_GDP) xlabel(#4) lcolor(blue) title(Log of monthly GDP, size(medsmall)) ytitle(log(GDP)) xtitle(Date)
line MRO month if month >= tm($start_year) & month <= tm($end_year), name(MRO) xlabel(#4) lcolor(blue) title(MRO, size(medsmall)) ytitle(Pct.) xtitle(Date)
graph combine `variables'


**# Dickey-fuller test
local variables "log_ASSETS CISS EONIA_MRO_SPREAD log_HICP log_MONTHLY_GDP MRO"
foreach var in `variables' { 
	dfuller `var' if month >= tm($start_year) & month <= tm($end_year)
}


**# VAR model
local variables "ASSETS_new CISS_new EONIA_new HICP_new GDP_new MRO_new"
var `variables'  if month >= tm($start_year) & month <= tm($end_year), exog(corona_dummy1) lag(1/2) 


varstable
varsoc

irf create var, set(var2.irf) replace step(30) 

irf cgraph (var ASSETS_new ASSETS_new irf) (var ASSETS_new CISS_new irf) (var ASSETS_new EONIA_new irf) (var ASSETS_new HICP_new irf) (var ASSETS_new GDP_new irf, ysize(3)) (var ASSETS_new MRO_new irf), rows(3) fxsize(60)  level(95)

*graph drop _all
*foreach var in `variables' { 
*	irf graph irf, yline(0,lcolor(black)) impulse(log_ASSETS) response(`var') name(`var') 
*}
*graph combine `variables'


**# SVAR model
local variables "GDP_new CISS_new ASSETS_new EONIA_new HICP_new  MRO_new"
var `variables' if month>=tm($start_year)  & month <= tm($end_year), exog(corona_dummy1) lags(1/2) 

varstable
varsoc

irf create svar, set(var2.irf) replace step(10)

irf cgraph (svar ASSETS_new GDP_new oirf ) (svar ASSETS_new CISS_new oirf ) (svar ASSETS_new ASSETS_new oirf ) (svar ASSETS_new EONIA_new oirf ) (svar ASSETS_new HICP_new oirf)  (svar ASSETS_new MRO_new oirf), rows(3) fxsize(50)


*graph drop _all
*foreach var in `variables' { 
*	irf graph oirf, yline(0,lcolor(black)) impulse(log_ASSETS) response(`var') name(`var') 
*}
*graph combine `variables'
