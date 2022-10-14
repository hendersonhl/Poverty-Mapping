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
global figs    "$main/Figures"


import delimited using "$outpath/results_for_tableau_R2.csv", clear

tempfile r2
save `r2'

import delimited using "$outpath/results_for_tableau_mse_bias.csv", clear

tempfile mse_bias
save `mse_bias'
*===============================================================================
// FIG compare R2
*===============================================================================
use `r2', clear
graph hbox value if regexm(variable, "gb_census_psu_")==1, over(true) graphregion(color(white))
/*
note: Figure illustrates R2 values for 500 sets of estimates based on 500 samples. Where an individual R2 value is obtained by regressing true/direct estimates against the model based estimates.
*/
//graph hbox value if regexm(variable, "eb_")==1, over(true) graphregion(color(white))
graph export "$figs/r2_gb_census_psu.png", as(png) replace








