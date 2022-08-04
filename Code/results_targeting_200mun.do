*==========================================
* Program setup
*==========================================

* Set up
clear all
set more off

* Set globals
if (lower("`c(username)'")=="wb378870")    global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="paul corral") global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
if (lower("`c(username)'")=="hendersonhl") global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"

global inpath "$main/Data/"
global outpath "$main/Results/"

*=========================================================================
//Bring in the data for "ideal transfer"
*=========================================================================
* Open census data and create select variables
if (lower("`c(username)'")=="wb378870") use "C:\Users\WB378870\OneDrive\WPS_2020\999.Survey Sim\0.data\census_trim.dta", clear
else use "$inpath/census_trim.dta", clear
	rename HID_mun muni
	label var muni "Municipality identifier"
	//Poverty line is the 25th percentile
	sum e_y [aw=hhsize], d
	global pline = r(p25)
	rename e_y incpc
	label var incpc "Income per capita (pre-transfer)" 
keep muni incpc hhsize 

	//Gen poverty rates and gaps
	forval a=0/2{
		gen fgt`a' = (incpc<$pline)*(1 - incpc/$pline)^`a'
	}

	sum fgt1 [aw=hhsize]
	local gap = r(mean)
	global budget = `gap'*$pline*`r(sum_w)'
	sum fgt0 [aw=hhsize]
	global transfer_pc = $budget/r(sum) 
	//global transfer_pc_gap = `gap'*$pline
tempfile pretrans
save `pretrans'

********************************************************************************
// Modified transfer: give priority to the 50/100 poorest municipalities
// Give everyone in them the poverty gap
*===============================================================================
local ene = 250
//Leave data at muni level	
groupfunction [aw=hhsize], mean(fgt0 fgt1 fgt2 incpc) rawsum(hhsize) by(muni)
rename hhsize pop

preserve
	//Alrighty begin the transfer
	gsort -fgt0
	gen double transfer = pop*$transfer_pc if _n<=`ene'
	gen double cummul=sum(transfer)
	sum cummul
	//Indicate over budget
	replace transfer = $transfer_pc if _n<=`ene'
	lab var transfer "transfer per capita for the municipality"
tempfile idealtrans
save `idealtrans'
restore


*=========================================================================
//Bring in the transfer to the Census population and get new poverty rates
*=========================================================================
use `pretrans', clear
	merge m:1 muni using `idealtrans', keepusing(transfer)
		drop if _m==2
		drop _m
		
	egen double incpc_trans = rsum(incpc transfer)
	drop transfer
	
gen pline = $pline
gen all=1
sp_groupfunction [aw=hhsize], poverty(incpc_trans incpc) povertyline(pline) by(all)

//Best output
list
save "$outpath/True_result_`ene'.dta", replace

*=========================================================================
//prep results for traditional
*=========================================================================
* Prep results from traditional estimators
preserve
use "$inpath/h3no19.dta", clear   // EB results
keep Unit avg_fgt0_* nsim
rename Unit muni
rename avg_fgt0_* yhat
rename nsim sim_sample
order muni sim_sample yhat
sort muni sim_sample
reshape wide yhat, i(muni) j(sim_sample)
rename yhat* yhat_*
outsheet using "$outpath/eb.csv", comma replace
use "$inpath/uceb19.dta", clear   // Unit-context results
keep Unit avg_fgt0_* nsim
rename Unit muni
rename avg_fgt0_* yhat
rename nsim sim_sample
order muni sim_sample yhat
sort muni sim_sample
reshape wide yhat, i(muni) j(sim_sample)
rename yhat* yhat_*
outsheet using "$outpath/uc.csv", comma replace
restore
*=========================================================================
//Ok, now to the model based estimates...
*=========================================================================
local themodels gb_census_mun gb_gis_mun gb_all_mun gb_census_psu ///
    bart_census_mun bart_gis_mun bart_all_mun bart_census_psu ///
	rf_census_mun rf_gis_mun rf_all_mun rf_census_psu ///
	lasso_census_mun lasso_gis_mun lasso_all_mun lasso_census_psu ///
	ols_census_mun ols_gis_mun ols_all_mun ols_census_psu eb uc hyperopt_census_mun
	
local themodels eb uc gb_census_psu 
	
foreach model of local themodels{
	import delimited "$outpath/`model'.csv", clear 
	//include population
	merge 1:1 muni using `idealtrans', keepusing(pop)
		drop if _m==2
		drop _m
	forval z=1/500{
		qui{
		gsort -yhat_`z'
		
		replace yhat_`z' = $transfer_pc if _n<=`ene'
		
		}
	}
	
	tempfile `model'
	save ``model''
}
*=========================================================================
//Bring in the transfer to the Census population and get new poverty rates
*=========================================================================

foreach model of local themodels{	
	use `pretrans', clear
		merge m:1 muni using ``model'', keepusing(yhat*)
			drop if _m==2
			drop _m
		
		forval z = 1/500{
			qui:replace yhat_`z' = 1-(yhat_`z' + incpc)/${pline}
		}
		
	
	keep hhsize yhat_*
	
	unab myhat:yhat_*
	mata: st_view(Y=.,.,tokens("`myhat'"))
	putmata wt = hhsize, replace
	
	mata: fgt0 = mean((Y:>0),wt)'
	mata: fgt1 = mean((Y:*(Y:>0)),wt)'
	mata: fgt2 = mean((Y:*Y:*(Y:>0)),wt)'
	clear
	set obs 500
	gen model = "`model'"
	gen sim = _n
	getmata fgt0 = fgt0 fgt1 = fgt1 fgt2 = fgt2  
	mata: matadrop fgt0 fgt1 fgt2
	cap append using `all'
	tempfile all
	save `all'	
}

use `all', clear
use "$outpath/Results_transfer.dta", clear
drop  model_t dtype level
local bart BART
local eb CensusEB
local uc Unit-Context
local rf Random forest
local gb XGboost
local lasso lasso
local ols OLS
local hyperopt HyperOpt

local census Census agg.
local gis GIS
local all Mixed

local models bart eb uc rf gb lasso ols hyperopt
local types census gis all

gen model_t = ""
foreach m of local models{
	replace model_t = "``m''" if regexm(model,"`m'")
}

gen dtype = ""
foreach d of local types{
	replace dtype = "``d''" if regexm(model,"_`d'_")
}
replace dtype = "Census microdata" if missing(dtype)

gen level = "PSU" if regexm(model,"psu")
replace level = "Municipality" if regexm(model,"mun")
replace level = "HH level" if missing(level)

save "$outpath/Results_transfer.dta", replace

export delimited using "$outpath/results_transfer.csv", replace 




