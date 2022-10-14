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

import delimited "$dpath/true_mun.csv", clear
gen negpoor = - poor
	_ebin negpoor, nq(50) gen(pov_rank)
	rename mimun muni	
tempfile thetruth
save `thetruth'

//bring in pop size
use "$dpath/h3no19.dta" if nsim==1, clear
	rename Unit muni
tempfile thepop
save `thepop'


import delimited "$inpath/results_bias.csv", clear
	merge 1:1 muni using `thetruth', keepusing(pov_rank poor)
		drop if _m!=3
		drop _m
	merge 1:1 muni using `thepop', keepusing(nIndi)
		drop if _m!=3
		drop _m
		
sp_groupfunction [aw=nIndi], mean(bias_*) by(muni pov_rank poor)

gen epoor = poor+value 

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
replace level = "HH level" if regexm(variable,"eb")|regexm(variable,"uc")
replace measure = "Bias"

gen true_npoor = poor*_population
gen e_npoor    = epoor*_population

//we use each methods ranking of their expected mun value
egen ranking = rank(epoor), by(variable)
egen true_rank = rank(poor), by(variable)

//Create the cummulative share of poor according to the method's ranking but using
//the true ranking
//The problem is that the rankings are different, and this is what leads to the 
//weird transfer results...

//---> You get the spatial concentration coefficient from the original transfer
// ---> compare the proportion of the funds going to where the poorest live.

groupfunction, sum(true_npoor e_npoor _pop) by(variable) merge

gen double share  = true_npoor/sum_true_npoor
gen double eshare = e_npoor/sum_e_npoor

sort variable ranking

bysort variable: gen true_cumul = sum(share)

sort variable ranking
bysort variable: gen est_cumul = sum(eshare)

sort variable ranking
bysort variable: gen pop_share = sum(_population)


