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


*=========================================================================
* Figure 1a
*=========================================================================

* Bring in area-level results
use "$inpath/fh_mun_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh_mun
rename area muni
tempfile FH
save `FH'

* Merge 
import delimited "$inpath/results_mse.csv", clear
merge 1:1 muni using `FH', keepusing(mse_fh_mun)
drop if _m==2
drop _m

* Label and plot
keep mse_gb_gis_ntl mse_uc mse_fh_mun mse_eb	
label var mse_gb_gis_ntl "Gradient Boosting (GIS)"
label var mse_eb "Unit-level (CEN)"  
label var mse_uc "Unit-context (CEN)" 
label var mse_fh_mun "Area-level (CEN)"    	
graph hbox mse_gb_gis_ntl mse_eb  mse_fh_mun mse_uc, ytitle(Mean Squared Error) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray))
graph export "$outpath/Figure-1a.png", as(png) replace

* Select descriptive statistics
sum, detail


*=========================================================================
* Figure 1b
*=========================================================================

* Import and reshape
import delimited "$inpath/results_transfer.csv", clear
keep variable sim fgt0
order sim variable fgt0
reshape wide fgt0, i(sim) j(variable) string
rename fgt0* *
keep gb_gis_mun_ntl eb uc fh_mun

* Poverty rates in percentage terms
foreach x of varlist gb_gis_mun_ntl eb uc fh_mun {
	replace `x' = `x'*100
}

* Label and plot
label var gb_gis_mun_ntl "Gradient Boosting (GIS)"
label var eb "Unit-level (CEN)"      
label var uc "Unit-context (CEN)"
label var fh_mun "Area-level (CEN)"  
graph hbox gb_gis_mun_ntl eb fh_mun uc, ytitle(Poverty Rate) ///
    scheme(s1mono) legend(off) showyvars nooutside note("") ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray))
graph export "$outpath/Figure-1b.png", as(png) replace

* Select descriptive statistics
sum, detail


*=========================================================================
* Figure 2a
*=========================================================================

* Bring in area-level results w/ GIS covariates
use "$inpath/fh_mun_gis_ntl_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh_mun_gis_ntl
rename area muni
tempfile FH_GIS
save `FH_GIS'

* Import and label
import delimited "$inpath/results_mse.csv", clear
merge 1:1 muni using `FH_GIS', keepusing(mse_fh_mun_gis)
keep mse_gb_gis_ntl mse_bart_gis mse_rf_gis mse_fh_mun_gis_ntl
label var mse_gb_gis "Gradient Boosting (GIS)"
label var mse_bart_gis "BART (GIS)"
label var mse_rf_gis "Random Forest (GIS)"
label var mse_fh_mun_gis_ntl "Area-level (GIS)"  

* Plot   	
graph hbox mse_gb_gis_ntl mse_rf_gis mse_bart_gis mse_fh_mun_gis_ntl, ///
    ytitle(Mean Squared Error) scheme(s1mono) legend(off) nooutside note("") ///
	showyvars box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) ///
	box(4, color(gray))
graph export "$outpath/Figure-2a.png", as(png) replace

* Select descriptive statistics
sum, detail

*=========================================================================
* Figure 2b
*=========================================================================

* Import and reshape
import delimited "$inpath/results_transfer.csv", clear
keep variable sim fgt0
order sim variable fgt0
reshape wide fgt0, i(sim) j(variable) string
rename fgt0* *
keep gb_gis_mun_ntl rf_gis_mun bart_gis_mun fh_mun_gis_ntl

* Poverty rates in percentage terms
foreach x of varlist gb_gis_mun_ntl rf_gis_mun bart_gis_mun fh_mun_gis_ntl {
	replace `x' = `x'*100
}

* Label and plot
label var gb_gis_mun_ntl "Gradient Boosting (GIS)"
label var bart_gis_mun "BART (GIS)"
label var rf_gis_mun "Random Forest (GIS)"
label var fh_mun_gis_ntl "Area-level (GIS)"   
graph hbox gb_gis_mun_ntl rf_gis_mun bart_gis_mun fh_mun_gis_ntl, ytitle(Poverty Rate) ///
    scheme(s1mono) legend(off) showyvars nooutside note("") ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray))
graph export "$outpath/Figure-2b.png", as(png) replace

* Select descriptive statistics
sum, detail

*=========================================================================
* Figure 3a
*=========================================================================

* Bring in area-level results w/ census covariates
use "$inpath/fh_mun_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh_mun
rename area muni
tempfile FH_CEN
save `FH_CEN'

* Bring in area-level results w/ GIS covariates
use "$inpath/fh_mun_gis_ntl_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh_mun_gis_ntl
rename area muni
tempfile FH_GIS
save `FH_GIS'

* Merge 
import delimited "$inpath/results_mse.csv", clear
merge 1:1 muni using `FH_CEN', keepusing(mse_fh_mun)
drop if _m==2
drop _m
merge 1:1 muni using `FH_GIS', keepusing(mse_fh_mun_gis)
drop if _m==2
drop _m	

* Label and plot
keep mse_gb_gis_ntl mse_gb_census mse_fh_mun_gis_ntl mse_fh_mun 
label var mse_gb_gis_ntl "Gradient Boosting (GIS)"
label var mse_gb_census "Gradient Boosting (CEN)"
label var mse_fh_mun_gis_ntl "Area-level (GIS)"   	
label var mse_fh_mun "Area-level (CEN)"   
graph hbox mse_gb_gis_ntl mse_gb_census mse_fh_mun_gis_ntl mse_fh_mun, ytitle(Mean Squared Error) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray))
graph export "$outpath/Figure-3a.png", as(png) replace

* Select descriptive statistics
sum, detail


*=========================================================================
* Figure 3b
*=========================================================================

* Import and reshape
import delimited "$inpath/results_transfer.csv", clear
keep variable sim fgt0
order sim variable fgt0
reshape wide fgt0, i(sim) j(variable) string
rename fgt0* *
keep gb_gis_mun_ntl gb_census_mun fh_mun_gis_ntl fh_mun 

* Poverty rates in percentage terms
foreach x of varlist gb_gis_mun_ntl gb_census_mun fh_mun_gis_ntl fh_mun {
	replace `x' = `x'*100
}

* Label and plot
label var gb_gis_mun_ntl "Gradient Boosting (GIS)"
label var gb_census_mun "Gradient Boosting (CEN)"
label var fh_mun_gis_ntl "Area-level (GIS)"   	
label var fh_mun "Area-level (CEN)"  
graph hbox gb_gis_mun_ntl gb_census_mun fh_mun_gis_ntl fh_mun, ytitle(Poverty Rate) ///
    scheme(s1mono) legend(off) showyvars nooutside note("") ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray))
graph export "$outpath/Figure-3b.png", as(png) replace

* Select descriptive statistics
sum, detail


*===============================================================================
* Figure 4
*===============================================================================

* Import and keep top 20
import delimited "$inpath/gb_importance_all_mun_ntl.csv", clear
egen imp = rowmean(imp*)
gsort -imp
drop if _n >20

* Label and plot
replace variable = "Cellphone ownership (CEN)" if variable == "census_cellphone"
replace variable = "Television ownership (CEN)" if variable == "census_television"
replace variable = "Computer ownership (CEN)" if variable == "census_computer"
replace variable = "Washing machine ownership (CEN)" if variable == "census_washmachine"
replace variable = "Access to internet (CEN)" if variable == "census_internet"
replace variable = "Adult population share (CEN)" if variable == "census_share_adult"
replace variable = "Refrigerator ownership (CEN)" if variable == "census_fridge"
replace variable = "No sewage access (CEN)" if variable == "census_no_sewage"
replace variable = "Male household share (CEN)" if variable == "census_male_hh"
replace variable = "Household size (CEN)" if variable == "census_hhsize"
replace variable = "Night-time lights std. dev. (GIS)" if variable == "gis_ntl_std_2015"
replace variable = "Mean slope from digital model (GIS)" if variable == "gis_mdepmean"
replace variable = "Secondary education share (CEN)" if variable == "census_max_secondary"
replace variable = "Elderly population share (CEN)" if variable == "census_share_elderly"
replace variable = "Age of household head (CEN)" if variable == "census_age_hh"
replace variable = "Simple ratio std. dev. (GIS)" if variable == "gis_srstddev"
replace variable = "Max. night-time lights (GIS)" if variable == "gis_ntl_max_2015"
replace variable = "Max. built-up index (GIS)" if variable == "gis_bumax"
replace variable = "Mean night-time lights (GIS)" if variable == "gis_ntl_mean_2015"
replace variable = "Under 15 population share (CEN)" if variable == "census_share_under15"
graph hbar (asis) imp, over(variables, sort(1) descending) scheme(s1mono) ///
    ytitle(Feature Importance) xsize(8)
graph export "$outpath/Figure-4.png", as(png) replace


*===============================================================================
* Figure 5a
*===============================================================================

* Bring in area-level bias results w/ census covariates
use "$inpath/fh_mun_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun
rename area muni
tempfile FH_CEN_bias
save `FH_CEN_bias'

* Bring in area-level bias results w/ GIS covariates
use "$inpath/fh_mun_gis_ntl_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun_gis_ntl
rename area muni
tempfile FH_GIS_bias
save `FH_GIS_bias'

* Bring in bias results
import delimited "$inpath/results_bias.csv", clear
keep muni bias_gb_gis_ntl bias_gb_census bias_eb bias_uc
merge 1:1 muni using `FH_CEN_bias', keepusing(bias_fh_mun)
drop if _m==2
drop _m
merge 1:1 muni using `FH_GIS_bias', keepusing(bias_fh_mun_gis_ntl)
drop if _m==2
drop _m

* Bias plot 
label var bias_gb_gis_ntl "Gradient Boosting (GIS)"
label var bias_gb_census "Gradient Boosting (CEN)"
label var bias_fh_mun_gis_ntl "Area-level (GIS)"   	
label var bias_fh_mun "Area-level (CEN)"   
graph hbox bias_gb_gis_ntl bias_gb_census bias_fh_mun_gis_ntl bias_fh_mun, ytitle(Bias) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray))
graph export "$outpath/Figure-5a.png", as(png) replace


*===============================================================================
* Figure 5b
*===============================================================================

* Bring in area-level bias results w/ GIS covariates
use "$inpath/fh_mun_gis_ntl_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun_gis_ntl
rename area muni
tempfile FH_GIS
save `FH_GIS'

* Bring in area-level bias results w/ census covariates
use "$inpath/fh_mun_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun
rename area muni
tempfile FH_CEN
save `FH_CEN'

* Bring in truth
import delimited "$main/Data/true_mun.csv", clear
keep mimun poor
rename mimun muni
tempfile true
save `true'

* Merge 
import delimited "$inpath/results_bias.csv", clear
merge 1:1 muni using `true'
drop _merge
merge 1:1 muni using `FH_GIS', keepusing(bias_fh_mun_gis_ntl)
drop if _m==2
drop _m
merge 1:1 muni using `FH_CEN', keepusing(bias_fh_mun)
drop if _m==2
drop _m

* Collapse and plot	
xtile pov_rank = poor, nq(50)
replace pov_rank = 51 - pov_rank  // Reverse order
collapse bias*, by(pov_rank)
twoway (line bias_gb_gis_ntl pov_rank, lpattern(solid) lcolor(black)) ///
    (line bias_gb_census pov_rank, lpattern(shortdash) lcolor(black)) ///
    (line bias_fh_mun_gis_ntl pov_rank, lpattern(solid) lcolor(gray)) ///
    (line bias_fh_mun pov_rank, lpattern(dash) lcolor(gray)), ///
	ytitle(Average Bias) xtitle(Poverty Quantile (Poorest to Richest)) scheme(s1mono) ///
	legend(label(1 "Gradient Boosting (GIS)") label(2 "Gradient Boosting (CEN)") ///
	label(3 "Area-level (GIS)") label(4 "Area-level (CEN)") ///
    symxsize(*0.7) size(*.88)) 
graph export "$outpath/Figure-5b.png", as(png) replace




*===============================================================================
* Old stuff below
*===============================================================================

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

*=========================================================================
* Basic MSE plot
*=========================================================================
use "$inpath/fh_mse_bias.dta", clear
	keep if variable == "mse_fh"
	rename value mse_fh
	rename area muni
tempfile uno
save `uno'

use "$inpath/fh_mun_mse_bias.dta", clear
	keep if variable == "mse_fh"
	rename value mse_fh_mun
	rename area muni
tempfile dos
save `dos'

use "$inpath/fh_mun_gis_mse_bias.dta", clear
	keep if variable == "mse_fh"
	rename value mse_fh_mun_gis
	rename area muni
tempfile tres
save `tres'

use "$inpath/fh_mun_gis_ntl_mse_bias.dta", clear
	keep if variable == "mse_fh"
	rename value mse_fh_mun_gis_ntl
	rename area muni
tempfile cuatro
save `cuatro'

import delimited "$inpath/results_mse.csv", clear
	merge 1:1 muni using `uno', keepusing(mse_fh)
		drop if _m==2
		drop _m
	merge 1:1 muni using `dos', keepusing(mse_fh_mun)
		drop if _m==2
		drop _m
	merge 1:1 muni using `tres', keepusing(mse_fh_mun_gis)
		drop if _m==2
		drop _m	
	merge 1:1 muni using `cuatro', keepusing(mse_fh_mun_gis)
		drop if _m==2
		drop _m	
		
	keep mse_gb_census mse_gb_gis mse_gb_all mse_gb_psu mse_eb mse_uc mse_fh* mse_gb_gis_ntl mse_gb_all_ntl
	tabstat mse_gb_census-mse_fh_mun, stat(p50)
	label var mse_gb_census "Gradient Boosting (CEN)"
	label var mse_gb_gis    "Gradient Boosting (GIS)"         
	label var mse_gb_all    "Gradient Boosting (ALL)"            
	label var mse_gb_psu    "Gradient Boosting (CEN-PSU)"
	label var mse_eb        "Unit-level"                           
	label var mse_uc        "Unit-context (CEN)"      
	label var mse_fh        "Area-level (CEN-PSU)"
	label var mse_fh_mun        "Area-level (CEN)"  
	label var mse_fh_mun_gis        "Area-level (GIS)"  
	label var mse_fh_mun_gis_ntl       "Area-level (GIS-NTL)" 
	label var mse_gb_gis_ntl "Gradient Boosting (GIS-NTL)"
	label var mse_gb_all_ntl "Gradient Boosting (ALL-NTL)"
                  
graph hbox mse_gb_gis mse_gb_gis_ntl mse_fh_mun_gis mse_fh_mun_gis_ntl mse_uc mse_fh_mun mse_gb_all_ntl mse_gb_all mse_gb_census mse_eb, ytitle(Mean Squared Error) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) box(6, color(gray)) box(7, color(gray)) box(8, color(gray))
graph export "$outpath/Figure-2a.pdf", as(pdf) replace
graph export "$outpath/Figure-2a.png", as(png) replace

*=========================================================================
* Basic bias plot
*=========================================================================

use "$inpath/fh_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh
rename area muni
tempfile uno
save `uno'

use "$inpath/fh_mun_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun
rename area muni
tempfile dos
save `dos'

use "$inpath/fh_mun_gis_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun_gis
rename area muni
tempfile tres
save `tres'

use "$inpath/fh_mun_gis_ntl_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun_gis_ntl
rename area muni
tempfile cuatro
save `cuatro'

import delimited "$inpath/results_bias.csv", clear
merge 1:1 muni using `uno', keepusing(bias_fh)
	drop if _m==2
	drop _m
merge 1:1 muni using `dos', keepusing(bias_fh)
	drop if _m==2
	drop _m	
merge 1:1 muni using `tres', keepusing(bias_fh)
	drop if _m==2
	drop _m	
merge 1:1 muni using `cuatro', keepusing(bias_fh)
	drop if _m==2
	drop _m		


keep bias_gb_gis bias_gb_census bias_gb_all bias_gb_psu bias_eb bias_uc bias_fh* bias_gb_gis_ntl bias_gb_all_ntl
tabstat bias_gb_census-bias_fh_mun, stat(p50 min max N)
label var bias_gb_census "Gradient Boosting (CEN)"
label var bias_gb_gis    "Gradient Boosting (GIS)"
label var bias_gb_all    "Gradient Boosting (ALL)"
label var bias_gb_psu    "Gradient Boosting (CEN-PSU)"
label var bias_eb   "Unit-level"      
label var bias_uc   "Unit-context (CEN)"
label var bias_fh                "Area-level (CEN-PSU)"
label var bias_fh_mun            "Area-level (CEN)"  
label var bias_fh_mun_gis        "Area-level (GIS)"  
label var bias_gb_gis_ntl "Gradient Boosting (GIS-NTL)"
label var bias_gb_all_ntl "Gradient Boosting (ALL-NTL)"
label var bias_fh_mun_gis_ntl       "Area-level (GIS-NTL-MUN)" 
	
  
graph hbox bias_gb_gis bias_gb_gis_ntl bias_fh_mun_gis bias_fh_mun_gis_ntl bias_uc bias_fh_mun bias_gb_all_ntl bias_gb_all bias_gb_census bias_eb, ytitle(Bias) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) box(6, color(gray)) box(7, color(gray)) box(8, color(gray))
graph export "$outpath/Figure-2b.pdf", as(pdf) replace
graph export "$outpath/Figure-2b.png", as(png) replace

*===============================================================================
* Variable importance
*===============================================================================
import delimited "$inpath/gb_importance_all_mun_ntl.csv", clear
egen imp = rowmean(imp*)
gsort -imp
drop if _n >20
replace variable = "Cellphone ownership (CEN)" if variable == "census_cellphone"
replace variable = "Television ownership (CEN)" if variable == "census_television"
replace variable = "Computer ownership (CEN)" if variable == "census_computer"
replace variable = "Access to internet (CEN)" if variable == "census_internet"
replace variable = "Washing machine ownership (CEN)" if variable == "census_washmachine"
replace variable = "Adult population share (CEN)" if variable == "census_share_adult"
replace variable = "Refrigerator ownership (CEN)" if variable == "census_fridge"
replace variable = "Male household share (CEN)" if variable == "census_male_hh"
replace variable = "Household size (CEN)" if variable == "census_hhsize"
replace variable = "No sewage access (CEN)" if variable == "census_no_sewage"
replace variable = "Under 15 population share (CEN)" if variable == "census_share_under15"
replace variable = "Elderly population share (CEN)" if variable == "census_share_elderly"
replace variable = "Mean normalized difference water index (GIS)" if variable == "gis_ndwimean"
replace variable = "Age of household head (CEN)" if variable == "census_age_hh"
replace variable = "Simple ratio standard deviation (GIS)" if variable == "gis_srstddev"
replace variable = "Secondary education share (CEN)" if variable == "census_max_secondary"
replace variable = "Maximum built up index (GIS)" if variable == "gis_bumax"
replace variable = "Maximum urban index (GIS)" if variable == "gis_uimax"
replace variable = "Tertiary education share (CEN)" if variable == "census_max_tertiary"
replace variable = "Mean slope from digital model (GIS)" if variable == "gis_mdepmean"
graph hbar (asis) imp, over(variables, sort(1) descending) scheme(s1mono) ///
    ytitle(Feature Importance)
graph export "$outpath/Figure-3.pdf", as(pdf) replace
graph export "$outpath/Figure-3.png", as(png) replace

*===============================================================================
* MSE by poverty quantiles
*===============================================================================
use "$inpath/fh_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh
rename area muni
tempfile uno
save `uno'

use "$inpath/fh_mun_mse_bias.dta", clear
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
	ytitle(Average Mean Squared Error) xtitle(Poverty Quantile) scheme(s1mono) ///
	legend(label(1 "Gradient Boosting (GIS-MUN)") label(2 "Unit-level") ///
	label(3 "Gradient Boosting (CEN-MUN)") label(4 "Unit-context") ///
	label(5 "Area-level (CEN-PSU)") label(6 "Area-level (CEN-MUN)") symxsize(*0.7) size(*.88))
graph export "$outpath/Figure-4a.pdf", as(pdf) replace
graph export "$outpath/Figure-4a.png", as(png) replace

*===============================================================================
* Bias by poverty quantiles
*===============================================================================
use "$inpath/fh_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh
rename area muni
tempfile uno
save `uno'

use "$inpath/fh_mun_mse_bias.dta", clear
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
	ytitle(Average Bias) xtitle(Poverty Quantile) scheme(s1mono) ///
	legend(label(1 "Gradient Boosting (GIS-MUN)") label(2 "Unit-level") ///
	label(3 "Gradient Boosting (CEN-MUN)") label(4 "Unit-context") ///
	label(5 "Area-level (CEN-PSU)") label(6 "Area-level (CEN-MUN)") symxsize(*0.7) size(*.88))
graph export "$outpath/Figure-4b.pdf", as(pdf) replace
graph export "$outpath/Figure-4b.png", as(png) replace

*===============================================================================
* Model comparisons w/ GIS covariates (MSE)
*===============================================================================
import delimited "$inpath/results_mse.csv", clear
keep mse_gb_gis mse_bart_gis mse_rf_gis mse_lasso_gis
label var mse_gb_gis "Gradient Boosting"
label var mse_bart_gis "BART"
label var mse_rf_gis "Random Forest"
label var mse_lasso_gis "Lasso"
graph hbox mse_gb_gis mse_bart_gis mse_rf_gis mse_lasso_gis, ///
    ytitle(Mean Squared Error) scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) 
graph export "$outpath/Figure-5a.pdf", as(pdf) replace
graph export "$outpath/Figure-5a.png", as(png) replace

*===============================================================================
* Model comparisons w/ GIS covariates (Bias)
*===============================================================================
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

*===============================================================================	
* Poverty targeting
*===============================================================================
import delimited "$inpath/results_transfer.csv", clear
keep variable sim fgt0
order sim variable fgt0

reshape wide fgt0, i(sim) j(variable) string
rename fgt0* *
keep gb_census_mun gb_gis_mun gb_all_mun gb_census_psu eb uc fh fh_mun fh_mun_gis gb_gis_mun_ntl gb_all_mun_ntl fh_mun_gis_ntl

foreach x of varlist gb_census_mun gb_gis_mun gb_all_mun gb_census_psu eb uc fh fh_mun fh_mun_gis gb_gis_mun_ntl gb_all_mun_ntl fh_mun_gis_ntl{
	replace `x' = `x'*100
}


label var gb_census_mun "Gradient Boosting (CEN)"
label var gb_gis_mun "Gradient Boosting (GIS)"
label var gb_all_mun "Gradient Boosting (ALL)"
label var eb   "Unit-level"      
label var uc   "Unit-context (CEN)"
label var fh_mun        "Area-level (CEN)"  
label var fh_mun_gis        "Area-level (GIS)"  
label var gb_gis_mun_ntl "Gradient Boosting (GIS-NTL)"
label var gb_all_mun_ntl "Gradient Boosting (ALL)"
label var fh_mun_gis_ntl       "Area-level (GIS-NTL)" 


graph hbox gb_gis_mun gb_gis_mun_ntl fh_mun_gis fh_mun_gis_ntl ///
uc fh_mun gb_all_mun_ntl gb_all_mun gb_census_mun eb, ytitle(Poverty Rate) ///
    scheme(s1mono) legend(off) showyvars nooutside note("") ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) box(6, color(gray)) box(7, color(gray)) box(8, color(gray)) ///
	box(9, color(gray))
graph export "$outpath/Figure-6.pdf", as(pdf) replace
graph export "$outpath/Figure-6.png", as(png) replace





