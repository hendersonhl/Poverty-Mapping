*==========================================
* Figures for Manuscript
*==========================================

* Set up
clear all
set more off
if (lower("`c(username)'")=="wb378870")        global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="hendersonhl")	   global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"
global inpath  "$main/Results"
global outpath "$main/Results"
global dpath   "$main/Data"


*===============================================================================
// Prep data for Tableau
*===============================================================================
import delimited "$inpath/results_rsquared.csv", clear

sp_groupfunction, mean(gb_census_mun_true gb_census_mun_direct gb_gis_mun_true gb_gis_mun_direct gb_all_mun_true gb_all_mun_direct gb_census_psu_true gb_census_psu_direct bart_census_mun_true bart_census_mun_direct bart_gis_mun_true bart_gis_mun_direct bart_all_mun_true bart_all_mun_direct bart_census_psu_true bart_census_psu_direct rf_census_mun_true rf_census_mun_direct rf_gis_mun_true rf_gis_mun_direct rf_all_mun_true rf_all_mun_direct rf_census_psu_true rf_census_psu_direct lasso_census_mun_true lasso_census_mun_direct lasso_gis_mun_true lasso_gis_mun_direct lasso_all_mun_true lasso_all_mun_direct lasso_census_psu_true lasso_census_psu_direct ols_census_mun_true ols_census_mun_direct ols_gis_mun_true ols_gis_mun_direct ols_all_mun_true ols_all_mun_direct ols_census_psu_true ols_census_psu_direct eb_true eb_direct uc_true uc_direct) by(sim_sample)

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
	replace model_t = "``m''" if regexm(variable,"`m'")
}

gen dtype = ""
foreach d of local types{
	replace dtype = "``d''" if regexm(variable,"_`d'_")
}
replace dtype = "Census microdata" if missing(dtype)

gen level = "PSU" if regexm(variable,"psu")
replace level = "Municipality" if regexm(variable,"mun")
replace level = "HH level" if missing(level)

gen true = "True" if regexm(variable,"true")
replace true = "Direct" if missing(true)

export delimited using "$outpath/results_for_tableau_R2.csv", replace 

*===============================================================================
// Prep data for Tableau
*===============================================================================
import delimited "$dpath/true_mun.csv", clear
gen negpoor = - poor
	_ebin negpoor, nq(50) gen(pov_rank)
	rename mimun muni
tempfile thetruth
save `thetruth'

//bring in pop size
use "$dpath/h3no19.dta" if nsim==1, clear
	_ebin nIndi, nq(50) gen(pop_rank)
	rename Unit muni
tempfile thepop
save `thepop'

import delimited "$inpath/results_mse.csv", clear
	merge 1:1 muni using `thetruth', keepusing(pov_rank)
		drop if _m!=3
		drop _m
	merge 1:1 muni using `thepop', keepusing(pop_rank)
		drop if _m!=3
		drop _m

sp_groupfunction, mean(mse_*) by(muni pov_rank pop_rank) 

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
local types census gis all census_wc

gen model_t = ""
foreach m of local models{
	replace model_t = "``m''" if regexm(variable,"`m'")
}

gen dtype = ""
foreach d of local types{
	replace dtype = "``d''" if regexm(variable,"_`d'")
}
replace dtype = "Census microdata" if missing(dtype) & regexm(variable,"eb")
replace dtype = "Census agg." if missing(dtype)

gen level = "PSU" if regexm(variable,"psu")
replace level = "Municipality" if regexm(variable,"mun")|regexm(variable,"all")|regexm(variable,"gis")|regexm(variable,"census")
replace level = "HH level" if regexm(variable,"eb")|regexm(variable,"uc")|regexm(variable,"hh")

replace level = "PSU & Mun" if variable=="mse_gb_psu_wc"



replace measure = "MSE"

egen min = min(value), by(muni)
gen gap = value - min

tempfile mse
save `mse'

import delimited "$inpath/results_bias.csv", clear
	merge 1:1 muni using `thetruth', keepusing(pov_rank)
		drop if _m!=3
		drop _m
	merge 1:1 muni using `thepop', keepusing(pop_rank)
		drop if _m!=3
		drop _m


sp_groupfunction, mean(bias_*) by(muni pov_rank pop_rank) //higher pov rank = poorer

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
	replace model_t = "``m''" if regexm(variable,"`m'")
}

gen dtype = ""
foreach d of local types{
	replace dtype = "``d''" if regexm(variable,"_`d'")
}
replace dtype = "Census microdata" if missing(dtype) & regexm(variable,"eb")
replace dtype = "Census agg." if missing(dtype)

gen level = "PSU" if regexm(variable,"psu")
replace level = "Municipality" if regexm(variable,"mun")|regexm(variable,"all")|regexm(variable,"gis")|regexm(variable,"census")
replace level = "HH level" if regexm(variable,"eb")|regexm(variable,"uc")|regexm(variable,"hh")

replace level = "PSU & Mun" if variable=="mse_gb_psu_wc"

replace measure = "Bias"

append using `mse', force

export delimited using "$outpath/results_for_tableau_mse_bias.csv", replace 






