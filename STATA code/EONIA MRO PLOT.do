clear all

cd "C:\Users\Peter\OneDrive\My Own Projects\Bachelor\Final model"

use MRO_DATA

rename OBS_VALUE MRO

gen date = date(TIME_PERIOD, "YMD")
format %td date

**# Draw line graphs
graph drop _all
twoway (line MRO date, lcolor(blue) ) (line DEPOSIT date, lcolor(navy) ytitle(Pct.)) (line LENDING date, lcolor(eltblue)) (line EONIA date, lcolor(red))
