*==========================================
* Program setup
*==========================================

* Set up
clear all
set more off

* Set globals
if (lower("`c(username)'")=="wb378870")    global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="paul corral"){
	global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
	set processors 8
}
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
	global budget = `r(mean)'*$pline*`r(sum_w)'
	sum fgt0 [aw=hhsize]
	global transfer_pc = $budget/r(sum) 

tempfile pretrans
save `pretrans'

//Leave data at muni level	
groupfunction [aw=hhsize], mean(fgt0 fgt1 fgt2 incpc) rawsum(hhsize) by(muni)

//Determine proportion of poor
sum fgt0 [aw=hhsize]
local num_poor = r(sum)

gen double prop_poor = fgt0*hhsize/`num_poor'
sum prop_poor
di r(sum)

renam hhsize pop
/*
The targtetting exercise will be as follows:
- We give priority to poorest communities...then we devote funds by the prop of poor
*/


gsort -fgt0
gen double transfer = ${budget}*prop_poor/pop

tempfile latran
save `latran'

//Bring it back to the census
use `pretrans', clear
	merge m:1 muni using `latran', keepusing(transfer)
		drop if _m==2
		drop _m
	egen double incpc_trans = rsum(incpc transfer)
	drop transfer

gen pline = $pline
gen all=1
sp_groupfunction [aw=hhsize], poverty(incpc_trans  incpc) povertyline(pline) by(all)

list
save "$outpath/True_result_prop.dta", replace

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
	
	use "$outpath\FH_results.dta", clear
	keep area estimate simul
	rename area muni
	rename estimate yhat
	rename simul sim_sample
	order muni sim_sample yhat
	sort muni sim_sample
	reshape wide yhat, i(muni) j(sim_sample)
	rename yhat* yhat_*
	outsheet using "$outpath/fh.csv", comma replace
	
	use "$outpath\FH_results_mun.dta", clear
	rename HID_mun area 
	rename fh_fgt0 estimate
	keep area estimate simul
	rename area muni
	rename estimate yhat
	rename simul sim_sample
	order muni sim_sample yhat
	sort muni sim_sample
	reshape wide yhat, i(muni) j(sim_sample)
	rename yhat* yhat_*
	outsheet using "$outpath/fh_mun.csv", comma replace
	
	use "$outpath\FH_results_mun_gis.dta", clear
	rename HID_mun area 
	rename fh_fgt0 estimate
	keep area estimate simul
	rename area muni
	rename estimate yhat
	rename simul sim_sample
	order muni sim_sample yhat
	sort muni sim_sample
	reshape wide yhat, i(muni) j(sim_sample)
	rename yhat* yhat_*
	outsheet using "$outpath/fh_mun_gis.csv", comma replace
	
	use "$outpath\FH_results_mun_gis_ntl.dta", clear
	rename HID_mun area 
	rename fh_fgt0 estimate
	keep area estimate simul
	rename area muni
	rename estimate yhat
	rename simul sim_sample
	order muni sim_sample yhat
	sort muni sim_sample
	reshape wide yhat, i(muni) j(sim_sample)
	rename yhat* yhat_*
	outsheet using "$outpath/fh_mun_gis_ntl.csv", comma replace
	
restore

*=========================================================================
//Ok, now to the model based estimates...
*=========================================================================
local themodels gb_census_mun gb_gis_mun gb_all_mun gb_census_psu ///
    bart_census_mun bart_gis_mun bart_all_mun bart_census_psu ///
	rf_census_mun rf_gis_mun rf_all_mun rf_census_psu ///
	lasso_census_mun lasso_gis_mun lasso_all_mun lasso_census_psu ///
	ols_census_mun ols_gis_mun ols_all_mun ols_census_psu eb uc ///
	hyperopt_census_mun gb_census_hhid_demo fh fh_mun fh_mun_gis ///
	fh_mun_gis_ntl gb_all_mun_ntl gb_gis_mun_ntl
	//gb_census_hh -> XGboost household level poverty classification

//For a subset
local themodels gb_census_mun gb_gis_mun gb_gis_mun_ntl gb_all_mun_ntl gb_all_mun gb_census_psu eb uc fh fh_mun fh_mun_gis fh_mun_gis_ntl bart_gis_mun rf_gis_mun



foreach model of local themodels{
	import delimited "$outpath/`model'.csv", clear
	merge 1:1 muni using `latran', keepusing(pop)
		drop if _m==2
		drop _m
	forval z = 1/500{
		sum yhat_`z' [aw=pop]
		gen double prop = yhat_`z'*pop/r(sum)
		drop yhat_`z'
		gen double yhat_`z' = prop*${budget}/pop
		drop prop
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

	cap append using `all'
	tempfile all
	save `all'	
}

use `all', clear
rename model variable
local bart BART
local eb CensusEB
local uc Unit-Context
local rf Random forest
local gb XGboost
local lasso lasso
local ols OLS
local hyperopt HyperOpt
local fh Fay-Herriot
local fh_mun Fay-Herriot

local census Census agg.
local gis GIS
local all Mixed
local ntl GIS-NTL

local models bart eb uc rf gb lasso ols hyperopt fh
local types census gis all ntl

gen model_t = ""
foreach m of local models{
	replace model_t = "``m''" if regexm(variable,"`m'")
}

gen dtype = ""
foreach d of local types{
	replace dtype = "``d''" if regexm(variable,"_`d'")
}
replace dtype = "Census microdata" if missing(dtype) & (regexm(variable,"eb")|regexm(variable,"hhid"))
replace dtype = "Census microdata" if regexm(variable,"hhid")
replace dtype = "Census agg." if missing(dtype)

gen level = "PSU" if regexm(variable,"psu")|variable=="fh"
replace level = "Municipality" if variable=="fh_mun"|regexm(variable,"mun")|regexm(variable,"all")|regexm(variable,"gis")|(regexm(variable,"census")&!regexm(variable,"hhid"))
replace level = "HH level" if regexm(variable,"eb")|regexm(variable,"uc")|regexm(variable,"hhid")

replace level = "PSU & Mun" if variable=="mse_gb_psu_wc"

save "$outpath/Results_transfer_share.dta", replace

export delimited using "$outpath/results_transfer_share.csv", replace 


