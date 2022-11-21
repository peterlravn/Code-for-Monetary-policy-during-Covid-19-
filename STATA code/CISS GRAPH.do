clear all

cd "C:\Users\Peter\OneDrive\My Own Projects\Bachelor\Final model"

use collected_dataset

rename X INDUSTRIAL
rename y QUARTERLY_GDP
rename y_hat MONTHLY_GDP


**# Set time
gen month = ym(INDEX, grain)
format %tm month

tsset month


**# Gen variables
gen log_ASSETS = log(ASSETS)
gen log_HICP = log(HICP)

gen dlog_ASSETS = log_ASSETS*100-L12.log_ASSETS*100

gen corona_dummy = (month == tm(2020m4))

global start_year 2015m01

global end_year 2021m12

twoway (bar dlog_ASSETS month if month >= tm($start_year) & month <= tm($end_year), yaxis(1) xlabel(#4) color(emidblue) ytitle(Pct.) ) (line CISS month if month >= tm($start_year) & month <= tm($end_year), yaxis(2) xlabel(#4) color(green) ytitle("", axis(2))),  legend(label(1 "Yoy. percentage change (lhs.)") label(2 "CISS (rhs.)"))
