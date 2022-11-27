*==========================================
* Figures for Manuscript
*==========================================

* Set up
clear all
if (lower("`c(username)'")=="wb378870" | lower("`c(username)'")=="paul corral")     global main "C:\Users\\`c(username)'\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="hendersonhl")  global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"
if (lower("`c(username)'")=="lupin" | lower("`c(username)'")=="paul corral" ) global main "C:\Users\\`c(username)'\Documents\GitHub\Poverty-Mapping\"
global inpath  "$main/Results"
global outpath "$main/Manuscript"


* Basic R-squared plot
import delimited "$inpath/results_rsquared.csv", clear
keep sim_sample gb_census_mun_direct gb_census_mun_true gb_census_psu_direct gb_census_psu_true 
tabstat gb_census_mun_true-gb_census_psu_direct, stat(p50)
rename *_true True_*
rename *_direct Direct_*
reshape long True Direct, i(sim_sample) j(model) string
replace model = "Municipality" if model=="_gb_census_mun"
replace model = "PSU" if model=="_gb_census_psu"
gen order = 1 if model=="PSU" 
replace order = 2 if model=="Municipality" 

graph box Direct True, ytitle("R-squared") over(model, sort(order)) ///
   /* nooutside note("")*/ graphregion(color(white)) scheme(s1mono)
	
graph export "$outpath/Figure-1a.png", as(png) replace
graph export "$outpath/Figure-1a.pdf", as(pdf) replace

* Model-selection experiment (true vs. direct)
import delimited "$inpath/results_rsquared.csv", clear
keep sim_sample gb_census_mun_true gb_census_mun_direct gb_census_psu_true gb_census_psu_direct
gen select_muni_true = (gb_census_mun_true > gb_census_psu_true)
gen select_muni_direct = (gb_census_mun_direct > gb_census_psu_direct)
tab select_muni_direct select_muni_true

* Constrained versus unconstrained R-squared plot
import delimited "$inpath/results_rsquared.csv", clear
keep sim_sample gb_census_mun_true gb_census_mun_constrain gb_census_psu_true gb_census_psu_constrain
rename *_true Unconstrained_*
rename *_constrain Constrained_*
reshape long Unconstrained Constrained, i(sim_sample) j(model) string
replace model = "Municipality" if model=="_gb_census_mun"
replace model = "PSU" if model=="_gb_census_psu"
gen order = 1 if model=="PSU" 
replace order = 2 if model=="Municipality" 
graph box Unconstrained Constrained, ytitle("R-squared") over(model, sort(order)) ///
    nooutside note("") graphregion(color(white)) scheme(s1mono)
graph export "$outpath/Figure-1b.pdf", as(pdf) replace
graph export "$outpath/Figure-1b.png", as(png) replace
	
* Model-selection experiment (unconstrained vs. contrained)
import delimited "$inpath/results_rsquared.csv", clear
keep sim_sample gb_census_mun_true gb_census_mun_constrain gb_census_psu_true gb_census_psu_constrain
gen select_muni_true = (gb_census_mun_true > gb_census_psu_true)
gen select_muni_constrain = (gb_census_mun_constrain > gb_census_psu_constrain)
tab select_muni_true select_muni_constrain
	
* MSE vs. R-squared scatterplot
import delimited "$main/Data/true_mun.csv", clear   // Import true poverty rates
keep mimun poor
rename poor true
tempfile true
save `true'
import delimited "$main/Data/svydata_mun.csv", clear  // Import sampling information
keep sim_sample mimun poor
merge m:1 mimun using `true'
drop _merge
by sim_sample, sort: egen variance = sd(true)  // Get variance of true rates by sample
replace variance = variance^2
collapse variance, by(sim_sample)
tempfile variance
save `variance'
import delimited "$inpath/results_rsquared.csv", clear
merge 1:1 sim_sample using `variance'    // Merge variances with R-squared values
keep sim_sample gb_census_mun_true gb_census_psu_true variance
gen mse_mun = (1 - gb_census_mun_true)*variance
gen mse_psu = (1 - gb_census_psu_true)*variance
twoway (scatter mse_mun gb_census_mun_true), xtitle("R-squared") ytitle("Empirical MSE") scheme(s1mono)
twoway (scatter mse_psu gb_census_psu_true), xtitle("R-squared") ytitle("Emprical MSE") scheme(s1mono)

* Basic MSE plot
use "$inpath\fh_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh
rename area muni
tempfile uno
save `uno'

use "$inpath\fh_mun_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh_mun
rename area muni
tempfile dos
save `dos'

import delimited "$inpath/results_mse.csv", clear
merge 1:1 muni using `uno', keepusing(mse_fh)
	drop if _m==2
	drop _m
merge 1:1 muni using `dos', keepusing(mse_fh_mun)
	drop if _m==2
	drop _m
	
keep mse_gb_census mse_gb_gis mse_gb_all mse_gb_psu mse_eb mse_uc mse_fh*
tabstat mse_gb_census-mse_fh_mun, stat(p50)
label var mse_gb_census "Gradient Boosting (Census agg. mun)"
label var mse_gb_gis    "Gradient Boosting (GIS mun)"         
label var mse_gb_all    "Gradient Boosting (All mun)"            
label var mse_gb_psu    "Gradient Boosting (Census agg. PSU)"
label var mse_eb        "CensusEB"                              
label var mse_uc        "Unit-context"      
label var mse_fh        "Fay-Herriot (Census agg. PSU)"
label var mse_fh_mun        "Fay-Herriot (Census agg. mun)"                    
graph hbox mse_gb_gis mse_gb_census mse_gb_all mse_gb_psu mse_eb mse_uc mse_fh mse_fh_mun, ytitle(Empirical MSE) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) box(6, color(gray)) box(7, color(gray)) box(8, color(gray))
graph export "$outpath/Figure-2a.pdf", as(pdf) replace
graph export "$outpath/Figure-2a.png", as(png) replace

* Basic bias plot
use "$inpath\fh_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh
rename area muni
tempfile uno
save `uno'

use "$inpath\fh_mun_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun
rename area muni
tempfile dos
save `dos'


import delimited "$inpath/results_bias.csv", clear
merge 1:1 muni using `uno', keepusing(bias_fh)
	drop if _m==2
	drop _m
merge 1:1 muni using `dos', keepusing(bias_fh)
	drop if _m==2
	drop _m	

keep bias_gb_gis bias_gb_census bias_gb_all bias_gb_psu bias_eb bias_uc bias_fh*
tabstat bias_gb_census-bias_fh_mun, stat(p50 min max N)
label var bias_gb_census "Gradient Boosting (Census agg. mun)"
label var bias_gb_gis "Gradient Boosting (GIS mun)"
label var bias_gb_all "Gradient Boosting (All mun)"
label var bias_gb_psu "Gradient Boosting (Census agg. PSU)"
label var bias_eb   "CensusEB"       
label var bias_uc   "Unit-context"
label var bias_fh        "Fay-Herriot (Census agg. PSU)"
label var bias_fh_mun        "Fay-Herriot (Census agg. mun)"  
  
graph hbox bias_gb_gis bias_gb_census bias_gb_all bias_gb_psu bias_eb bias_uc bias_fh bias_fh_mun, ytitle(Bias) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) box(6, color(gray)) box(7, color(gray)) box(8, color(gray))
graph export "$outpath/Figure-2b.pdf", as(pdf) replace
graph export "$outpath/Figure-2b.png", as(png) replace

* Variable importance
import delimited "$inpath/gb_importance_all_mun.csv", clear
egen imp = rowmean(imp*)
gsort -imp
drop if _n >20
replace variable = "Cellphone ownership (census)" if variable == "census_cellphone"
replace variable = "Television ownership (census)" if variable == "census_television"
replace variable = "Computer ownership (census)" if variable == "census_computer"
replace variable = "Access to internet (census)" if variable == "census_internet"
replace variable = "Washing machine ownership (census)" if variable == "census_washmachine"
replace variable = "Adult population share (census)" if variable == "census_share_adult"
replace variable = "Refrigerator ownership (census)" if variable == "census_fridge"
replace variable = "Male household share (census)" if variable == "census_male_hh"
replace variable = "Household size (census)" if variable == "census_hhsize"
replace variable = "No sewage access (census)" if variable == "census_no_sewage"
replace variable = "Under 15 population share (census)" if variable == "census_share_under15"
replace variable = "Elderly population share (census)" if variable == "census_share_elderly"
replace variable = "Normalized difference water index (GIS)" if variable == "gis_ndwimean"
replace variable = "Age of household head (census)" if variable == "census_age_hh"
replace variable = "Simple ratio standard deviation (GIS)" if variable == "gis_srstddev"
replace variable = "Secondary education share (census)" if variable == "census_max_secondary"
replace variable = "Maximum built up index (GIS)" if variable == "gis_bumax"
replace variable = "Maximum urban index (GIS)" if variable == "gis_uimax"
replace variable = "Tertiary education share (census)" if variable == "census_max_tertiary"
replace variable = "Mean slope from digital model (GIS)" if variable == "gis_mdepmean"
graph hbar (asis) imp, over(variables, sort(1) descending) scheme(s1mono) ///
    ytitle(Feature Importance)
graph export "$outpath/Figure-3.pdf", as(pdf) replace
graph export "$outpath/Figure-3.png", as(png) replace
	
* MSE by poverty quantiles
use "$inpath\fh_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh
rename area muni
tempfile uno
save `uno'

use "$inpath\fh_mun_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh_mun
rename area muni
tempfile dos
save `dos'

import delimited "$main/Data/true_mun.csv", clear
keep mimun poor
rename mimun muni
tempfile true
save `true'
import delimited "$inpath/results_mse.csv", clear
merge 1:1 muni using `true'
drop _merge

merge 1:1 muni using `uno', keepusing(mse_fh)
	drop if _m==2
	drop _m
merge 1:1 muni using `dos', keepusing(mse_fh)
	drop if _m==2
	drop _m
	

xtile pov_rank = poor, nq(50)
replace pov_rank = 51 - pov_rank  // Reverse order
collapse mse*, by(pov_rank)
twoway (line mse_gb_gis pov_rank, lpattern(solid) lcolor(black)) ///
    (line mse_eb pov_rank, lpattern(shortdash) lcolor(black)) ///
    (line mse_gb_census pov_rank, lpattern(solid) lcolor(gray)) ///
    (line mse_uc pov_rank, lpattern(dash) lcolor(gray)) ///
	(line mse_fh pov_rank, lpatter(shortdash_dot) lcolor(gs7)) ///
	(line mse_fh_mun pov_rank, lpatter(dot) lcolor(black)),  ///
	ytitle(Average MSE) xtitle(Poverty Quantile) scheme(s1mono) ///
	legend(label(1 "Gradient Boosting (GIS mun)") label(2 "CensusEB") ///
	label(3 "Gradient Boosting (Census agg. mun)") label(4 "Unit-context") ///
	label(5 "Fay-Herriot (Census agg. PSU)") label(6 "Fay-Herriot (Census agg. mun)") symxsize(*0.7) size(*.88))
graph export "$outpath/Figure-4a.pdf", as(pdf) replace
graph export "$outpath/Figure-4a.png", as(png) replace

* Bias by poverty quantiles
use "$inpath\fh_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh
rename area muni
tempfile uno
save `uno'

use "$inpath\fh_mun_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun
rename area muni
tempfile dos
save `dos'

import delimited "$main/Data/true_mun.csv", clear
keep mimun poor
rename mimun muni
tempfile true
save `true'
import delimited "$inpath/results_bias.csv", clear
merge 1:1 muni using `true'
drop _merge

merge 1:1 muni using `uno', keepusing(bias_fh)
	drop if _m==2
	drop _m
	
merge 1:1 muni using `dos', keepusing(bias_fh)
	drop if _m==2
	drop _m
	
xtile pov_rank = poor, nq(50)
replace pov_rank = 51 - pov_rank  // Reverse order
collapse bias*, by(pov_rank)
twoway (line bias_gb_gis pov_rank, lpattern(solid) lcolor(black)) ///
    (line bias_eb pov_rank, lpattern(shortdash) lcolor(black)) ///
    (line bias_gb_census pov_rank, lpattern(solid) lcolor(gray)) ///
    (line bias_uc pov_rank, lpattern(dash) lcolor(gray)) ///
	(line bias_fh pov_rank, lpatter(shortdash_dot) lcolor(gs7)) ///
	(line bias_fh_mun pov_rank, lpatter(dot) lcolor(black)),  ///
	ytitle(Average MSE) xtitle(Poverty Quantile) scheme(s1mono) ///
	legend(label(1 "Gradient Boosting (GIS mun)") label(2 "CensusEB") ///
	label(3 "Gradient Boosting (Census agg. mun)") label(4 "Unit-context") ///
	label(5 "Fay-Herriot (Census agg. PSU)") label(6 "Fay-Herriot (Census agg. mun)") symxsize(*0.7) size(*.88))
graph export "$outpath/Figure-4b.pdf", as(pdf) replace
graph export "$outpath/Figure-4b.png", as(png) replace

* Model comparisons w/ GIS covariates (MSE)
import delimited "$inpath/results_mse.csv", clear
keep mse_gb_gis mse_bart_gis mse_rf_gis mse_lasso_gis
label var mse_gb_gis "Gradient Boosting"
label var mse_bart_gis "BART"
label var mse_rf_gis "Random Forest"
label var mse_lasso_gis "Lasso"
graph hbox mse_gb_gis mse_bart_gis mse_rf_gis mse_lasso_gis, ///
    ytitle(Empirical MSE) scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) 
graph export "$outpath/Figure-5a.pdf", as(pdf) replace
graph export "$outpath/Figure-5a.png", as(png) replace

* Model comparisons w/ GIS covariates (Bias)
import delimited "$inpath/results_bias.csv", clear
keep bias_gb_gis bias_bart_gis bias_rf_gis bias_lasso_gis
label var bias_gb_gis "Gradient Boosting"
label var bias_bart_gis "BART"
label var bias_rf_gis "Random Forest"
label var bias_lasso_gis "Lasso"
graph hbox bias_gb_gis bias_bart_gis bias_rf_gis bias_lasso_gis, ///
    ytitle(Bias) scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) 
graph export "$outpath/Figure-5b.pdf", as(pdf) replace
graph export "$outpath/Figure-5b.png", as(png) replace
	
* Poverty targeting
import delimited "$inpath/results_transfer.csv", clear
keep variable sim fgt0
order sim variable fgt0
replace fgt0 = 100*fgt0 if regexm(variable, "fh")

reshape wide fgt0, i(sim) j(variable) string
rename fgt0* *
keep gb_gis_mun gb_census_mun gb_all_mun gb_census_psu eb uc fh fh_mun
replace gb_gis_mun = gb_gis_mun*100  // Put values in percentage terms
replace gb_census_mun = gb_census_mun*100
replace gb_all_mun = gb_all_mun*100
replace gb_census_psu = gb_census_psu*100
replace eb = eb*100
replace uc = uc*100
tabstat eb-uc, stat(p50)
label var gb_census_mun "Gradient Boosting (Census agg. mun)"
label var gb_gis_mun    "Gradient Boosting (GIS mun)"         
label var gb_all_mun    "Gradient Boosting (All mun)"            
label var gb_census_psu    "Gradient Boosting (Census agg. PSU)"
label var eb        "CensusEB"                              
label var uc        "Unit-context"  
label var fh        "Fay-Herriot (Census agg. PSU)"
label var fh_mun        "Fay-Herriot (Census agg. mun)"   

graph hbox gb_gis_mun gb_census_mun gb_all_mun gb_census_psu eb uc fh fh_mun, ytitle(Poverty Rate) ///
    scheme(s1mono) legend(off) showyvars nooutside note("") ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) box(6, color(gray)) box(7, color(gray)) box(8, color(gray))
graph export "$outpath/Figure-6.pdf", as(pdf) replace
graph export "$outpath/Figure-6.png", as(png) replace






