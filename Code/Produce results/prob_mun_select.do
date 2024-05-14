set more off
clear all

#delimit;
local modelos gb_census_mun gb_gis_mun gb_all_mun gb_census_psu  
         bart_census_mun bart_gis_mun bart_all_mun bart_census_psu 
         rf_census_mun rf_gis_mun rf_all_mun rf_census_psu 
         lasso_census_mun lasso_gis_mun lasso_all_mun lasso_census_psu 
         ols_census_mun ols_gis_mun ols_all_mun ols_census_psu gb_census_hhid_demo 
		 gb_census_psu_wc ;
#delimit cr

if (lower("`c(username)'")=="wb378870")    global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="paul corral") global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
if (lower("`c(username)'")=="hendersonhl") global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"

global inpath "$main/Data/"
global outpath "$main/Results/"
global outpath1 "$main/Manuscript"

*=========================================================================
use "$inpath/accumulate_results.dta", clear

keep fgt0_mse fgt0_bias_reg HID method_des

rename HID muni
rename (fgt0_mse fgt0_bias_reg) (mse bias)

drop if regexm(lower(method),"cbeb")

replace method_des = "Unit-context" if regexm(lower(method),"u-c")
replace method_des = "Unit-level" if regexm(lower(method),"censuseb")

tempfile main
save `main'



*=========================================================================
//Prep FH results
*=========================================================================
use "$outpath\FH_results_mun.dta", clear

rename fh_fgt0 yhat_

drop fh_fgt0_se fh_fgt0_cv fh_fgt0_gamma

reshape wide yhat_, i(HID_mun) j(simul)

rename HID_mun muni

tempfile FH
save `FH'

use "$outpath\FH_results.dta", clear

rename estimate yhat_
rename area HID_mun

drop mse weight

reshape wide yhat_, i(HID_mun) j(simul)

rename HID_mun muni

tempfile FHpsu
save `FHpsu'

use "$outpath\FH_results_mun_gis.dta", clear

rename fh_fgt0 yhat_

drop fh_fgt0_se fh_fgt0_cv fh_fgt0_gamma

reshape wide yhat_, i(HID_mun) j(simul)

rename HID_mun muni

tempfile FHgis
save `FHgis'

use "$outpath\FH_results_mun_gis_ntl.dta", clear

rename fh_fgt0 yhat_

drop fh_fgt0_se fh_fgt0_cv fh_fgt0_gamma

reshape wide yhat_, i(HID_mun) j(simul)

rename HID_mun muni

tempfile FHgis_ntl
save `FHgis_ntl'




local fhs FHgis FHpsu FH FHgis_ntl
local FHgis1 "Area-level (GIS)"    
local FHpsu1  "Area-level (CEN-PSU)"
local FH1 "Area-level (CEN)"   
local FHgis_ntl1 "Area-level (GIS-NTL)"


*=========================================================================
//Prepare sample - probability of selection per municipality
*=========================================================================
use "$inpath\my_samples_pps_psu@.dta" if sim_sample<=500, clear
	gen double muni = int(HID/1e3)
	duplicates drop muni sim_sample, force
	egen double prob=count(muni),by(muni)
	
	replace prob= prob/500
duplicates drop muni, force

xtile psel_qtile = prob, nq(5)
xtile psel_ctile = prob, nq(50)


tempfile psel
save `psel'


*=========================================================================
//Prepare true results
*=========================================================================
import delimited "$inpath\true_mun.csv", clear
	rename mimun muni
	keep muni poor
tempfile thetruth
save `thetruth'

*=========================================================================
//Prepare results of interest...
*=========================================================================


local modelos gb_census_mun gb_gis_mun gb_all_mun gb_census_psu gb_gis_mun_ntl gb_all_mun_ntl
local gb_census_mun "Gradient Boosting (CEN)"
local gb_gis_mun "Gradient Boosting (GIS)"  
local gb_all_mun "Gradient Boosting (ALL)"
local gb_all_mun_ntl  "Gradient Boosting (ALL-NTL)"
local gb_gis_mun_ntl "Gradient Boosting (GIS-NTL)"

foreach modelo of local modelos{
	import delimited using "$outpath\\`modelo'", clear
	
		merge 1:1 muni using `thetruth'
			drop if _m==2
			drop _m
		
	egen double bias = rmean(yhat_*)
	replace bias = bias - poor
	
	gen double mse = 0
	forval z=1/500{
		qui:replace mse = mse + (yhat_`z' - poor)^2
	}
	replace mse = mse/500
	
	keep muni bias mse
	gen method_des = "``modelo''"
	
	cap: append using `xgb'
	tempfile xgb
	save `xgb'
}

foreach fh of local fhs{
	use ``fh'', clear
	
		merge 1:1 muni using `thetruth'
			drop if _m==2
			drop _m
		
	egen double bias = rmean(yhat_*)
	replace bias = bias - poor
	
	gen double mse = 0
	forval z=1/500{
		qui:replace mse = mse + (yhat_`z' - poor)^2
	}
	replace mse = mse/500
	
	keep muni bias mse
	gen method_des = "``fh'1'" 
	
	cap: append using `losfh'
	tempfile losfh
	save `losfh'
}

append using `main'
append using `xgb'

merge m:1 muni using `psel'

  
drop if method=="Direct"

replace method = "Unit-context (CEN)" if method=="Unit-context"


	gen     order = 1  if method=="Gradient Boosting (GIS)"
	replace order = 2  if method=="Gradient Boosting (GIS-NTL)"         
	replace order = 3  if method=="Area-level (GIS)"
	replace order = 4  if method=="Area-level (GIS-NTL)"
	replace order = 5  if method=="Unit-context (CEN)"                    
	replace order = 6  if method=="Area-level (CEN)"       
	replace order = 7  if method=="Gradient Boosting (ALL-NTL)"
	replace order = 8  if method=="Gradient Boosting (ALL)"
	replace order = 9  if method=="Gradient Boosting (CEN)"
	replace order = 10 if method=="Unit-level"

graph hbox mse if psel_qtile==1 & !missing(order), over(method, sort(order)) scheme(s1mono) legend(off) nooutside note("")
graph export "$outpath1/Figure-3_1a.png", as(png) replace
graph hbox mse if psel_qtile==5 & !missing(order), over(method, sort(order)) scheme(s1mono) legend(off) nooutside note("")
graph export "$outpath1/Figure-3_1b.png", as(png) replace

graph hbox bias if psel_qtile==1 & !missing(order), over(method, sort(order)) scheme(s1mono) legend(off) nooutside note("")
graph export "$outpath1/Figure-3_2a.png", as(png) replace
graph hbox bias if psel_qtile==5 & !missing(order), over(method, sort(order)) scheme(s1mono) legend(off) nooutside note("")
graph export "$outpath1/Figure-3_2b.png", as(png) replace

preserve
	groupfunction, mean(mse bias) by(method psel_qtile)
	reshape wide mse bias, i(method_des) j(psel_qtile)
	
gen order = 5 if method=="Unit-level"
replace order= 1 if method=="Gradient Boosting (GIS mun)"
replace order= 2 if method=="Gradient Boosting (Census agg. mun)"
replace order= 4 if method=="Gradient Boosting (Census agg. PSU)"
replace order= 3 if method=="Gradient Boosting (All mun)"
replace order= 7 if method=="Fay-Herriot (Census agg. PSU)"
replace order= 8 if method=="Fay-Herriot (Census agg. mun)"
replace order= 6 if method=="Unit-context"
sort order
	list method mse1 mse2 mse3 mse4 mse5
	list method bias1 bias2 bias3 bias4 bias5
restore

//graph hbox mse if psel_qtile==5, over(method) noout
preserve
	groupfunction, mean(mse bias) by(method psel_ctile)
	twoway (line mse psel_ctile if regexm(method, "U-C")) (line mse psel_ctile if regexm(method, "Fay")) (line mse psel_ctile if regexm(method, "XG"))
restore






























	
