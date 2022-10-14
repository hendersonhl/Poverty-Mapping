set more off
clear all
cap set processors 8


*===============================================================================
global main "C:\Users\\`c(username)'\OneDrive\WPS_2020\999.Survey Sim\"
global dpath   "$main\0.data"
global simdata "$dpath\simdata\"
global thedo   "$main\1.dofiles\"
local losmodelos h3cbeb h3no uceb
*===============================================================================

use "$dpath\\true_census_trim", clear
gen HID_mun = int(HID/1e3)
gen hh_num = 1
groupfunction [aw=hhsize], mean(poor_40) rawsum(hhsize hh_num) by(HID_mun) norestore
	clonevar nHH = hhsize
	
	rename HID_mun HID
	sort HID
	
xtile Q_poor = -poor_40, nq(50)
xtile Q_pop  = hhsize, nq(50)
	
tempfile censo
save `censo'

import delimited "C:\Users\WB378870\OneDrive\WPS_2020\999.Survey Sim\5.xgboost\gb_census_psu.csv", clear
reshape long yhat_, i(muni) j(nsim)

rename muni HID
rename yhat fgt0

merge m:1 HID using `censo', keepusing(poor_40 hhsize)
	drop if _m!=3
	drop _m
	
gen bias = (fgt0 - poor_40)
gen mse  = bias^2

gen x = -poor_40
sort nsim x
bysort nsim: gen rank=_n
drop x
gen x = -fgt0
sort nsim x
bysort nsim: gen rank_est=_n

export delimited "C:\Users\WB378870\OneDrive\WPS_2020\999.Survey Sim\5.xgboost\heat_xgboost.csv", replace



local spcorr = 0
forval z=1/500{
	qui:spearman fgt0 poor_40 if nsim==`z'
	local spcorr=`spcorr'+r(rho)
}
dis as error "xgboost: `spcorr'"
local xgboost = `spcorr'/500

groupfunction, mean(bias mse hhsize) by(HID)
gen model = "xgboost"


tempfile final
save `final'


foreach elmod of local losmodelos{
	use "$simdata\\`elmod'40.dta", clear
	rename  avg_fgt0 fgt0
	rename Unit HID
	merge m:1 HID using `censo', keepusing(poor_40 hhsize)
		drop if _m!=3
		drop _m
		
	gen bias = (fgt0 - poor_40)
	gen mse  = bias^2
	
	gen x = -poor_40
	sort nsim x
	bysort nsim: gen rank=_n
	drop x
	gen x = -fgt0
	sort nsim x
	bysort nsim: gen rank_est=_n
	
	
	local spcorr = 0
	forval z=1/500{
		qui:spearman fgt0 poor_40 if nsim==`z'
		local spcorr=`spcorr'+r(rho)
	}
	dis as error "`elmod': `spcorr'"
	local `elmod' = `spcorr'/500
	
	groupfunction, mean(bias mse hhsize) by(HID)
	gen model = "`elmod'"
	cap append using `final'
	tempfile final
	save `final'
}

foreach x in `losmodelos' xgboost{
	char _dta[`x'] = ``x''
}

merge m:1 HID using `censo', keepusing(poor_40 hhsize Q_*)
	drop if _m!=3
	drop _m
	
gen level = "HH level" if inlist(model,"h3no","uceb","h3cbeb")
replace level = "PSU" if inlist(model,"xgboost")
gen dtype = "Census microdata" if inlist(model,"h3no","h3cbeb")
replace dtype = "Census agg." if inlist(model,"xgboost", "uceb")
gen model_t = "CensusEB" if inlist(model,"h3no")
replace model_t = "H3-CBEB" if inlist(model,"h3cbeb")
replace model_t = "Unit-Context" if inlist(model,"uceb")
replace model_t = "XGboost" if inlist(model,"xgboost")
	
export delimited "C:\Users\WB378870\OneDrive\WPS_2020\999.Survey Sim\5.xgboost\results40.csv", replace


save "$simdata\results40.dta", replace

