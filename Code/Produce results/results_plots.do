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
* Table 1
*=========================================================================

* True headcounts
import delimited "$main/Data/true_mun.csv", clear
sum
import delimited "$main/Data/true_psu.csv", clear
sum

* Observations per sample
use "$main/Data/my_samples_pps_psu@.dta", clear
drop if sim_sample>500
collapse (count) hhid, by(sim_sample)

* Municipalities per sample
import delimited "$main/Data/direct_mun.csv", clear
collapse (count) muni, by(sim_sample)
sum
tempfile muni
save `muni'

* PSU per sample
import delimited "$main/Data/direct_psu.csv", clear
collapse (count) hid, by(sim_sample)
sum

* PSU-to-municipality ratio
merge 1:1 sim_sample using `muni'
gen ratio = hid/muni
sum ratio


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
* Figure 5a and 5b
*===============================================================================

* Bring in bias results
import delimited "$inpath/results_bias.csv", clear
keep muni bias_gb_gis_ntl bias_gb_census
tempfile bias
save `bias'

* Bring in area-level MSE results w/ census covariates
use "$inpath/fh_mun_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh_mun
rename area muni
tempfile FH_CEN_mse
save `FH_CEN_mse'

* Bring in area-level bias results w/ census covariates
use "$inpath/fh_mun_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun
rename area muni
tempfile FH_CEN_bias
save `FH_CEN_bias'

* Bring in area-level MSE results w/ GIS covariates
use "$inpath/fh_mun_gis_ntl_mse_bias.dta", clear
keep if variable == "mse_fh"
rename value mse_fh_mun_gis_ntl
rename area muni
tempfile FH_GIS_mse
save `FH_GIS_mse'

* Bring in area-level bias results w/ GIS covariates
use "$inpath/fh_mun_gis_ntl_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun_gis_ntl_ntl
rename area muni
tempfile FH_GIS_bias
save `FH_GIS_bias'

* Merge 
import delimited "$inpath/results_mse.csv", clear
keep muni mse_gb_gis_ntl mse_gb_census
merge 1:1 muni using `FH_CEN_mse', keepusing(mse_fh_mun)
drop if _m==2
drop _m
merge 1:1 muni using `FH_GIS_mse', keepusing(mse_fh_mun_gis_ntl)
drop if _m==2
drop _m	
merge 1:1 muni using `bias'
drop if _m==2
drop _m
merge 1:1 muni using `FH_CEN_bias', keepusing(bias_fh_mun)
drop if _m==2
drop _m
merge 1:1 muni using `FH_GIS_bias', keepusing(bias_fh_mun_gis_ntl)
drop if _m==2
drop _m	

* Calculate variance for each model
gen var_gb_census = mse_gb_census - bias_gb_census^2
gen var_gb_gis_ntl = mse_gb_gis_ntl - bias_gb_gis_ntl^2
gen var_fh_mun = mse_fh_mun - bias_fh_mun^2
gen var_fh_mun_gis_ntl = mse_fh_mun_gis_ntl - bias_fh_mun_gis_ntl^2

* Variance plot
label var var_gb_gis_ntl "Gradient Boosting (GIS)"
label var var_gb_census "Gradient Boosting (CEN)"
label var var_fh_mun_gis_ntl "Area-level (GIS)"   	
label var var_fh_mun "Area-level (CEN)"   
graph hbox var_gb_gis_ntl var_gb_census var_fh_mun_gis_ntl var_fh_mun, ytitle(Variance) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray))
graph export "$outpath/Figure-5a.png", as(png) replace

* Bias plot
label var bias_gb_gis_ntl "Gradient Boosting (GIS)"
label var bias_gb_census "Gradient Boosting (CEN)"
label var bias_fh_mun_gis_ntl "Area-level (GIS)"   	
label var bias_fh_mun "Area-level (CEN)" 
graph hbox bias_gb_gis_ntl bias_gb_census bias_fh_mun_gis_ntl bias_fh_mun, ytitle(Bias) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray))
graph export "$outpath/Figure-5b.png", as(png) replace
	
* Select descriptive statistics
sum var*, detail
	
	
*===============================================================================
* Figure 6a
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

* Create plot
twoway (lowess bias_gb_gis_ntl poor, lpattern(solid) lcolor(black)) ///
    (lowess bias_gb_census poor, lpattern(shortdash) lcolor(black)) ///
    (lowess bias_fh_mun_gis_ntl poor, lpattern(solid) lcolor(gray)) ///
    (lowess bias_fh_mun poor, lpattern(dash) lcolor(gray)), ///
	scheme(s1mono) xtitle("Poverty Rate") ytitle("Bias") ///
	legend(label(1 "Gradient Boosting (GIS)") label(2 "Gradient Boosting (CEN)") ///
	label(3 "Area-level (GIS)") label(4 "Area-level (CEN)"))
graph export "$outpath/Figure-6a.png", as(png) replace


*===============================================================================
* Figure 6b
*===============================================================================

* Import survey information
import delimited "$main/Data/svydata_mun.csv", clear
collapse (count) sim_sample, by(mimun)
rename sim_sample coverage 
replace coverage = coverage/500
rename mimun muni
tempfile coverage
save `coverage'

* Import true poverty rates and calculate ranks
import delimited "$main/Data/true_mun.csv", clear
xtile pov_rank = poor, nq(50)
replace pov_rank = 51 - pov_rank  // Reverse order
keep mimun pov_rank
rename mimun muni
tempfile ranks
save `ranks'

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

* Merge 
import delimited "$inpath/results_bias.csv", clear
merge 1:1 muni using `FH_GIS', keepusing(bias_fh_mun_gis_ntl)
drop _m
merge 1:1 muni using `FH_CEN', keepusing(bias_fh_mun)
drop _m
merge 1:1 muni using `ranks'
drop _merge
merge 1:1 muni using `coverage'
drop _merge

* Create plot
twoway (lowess bias_gb_gis_ntl coverage, lpattern(solid) lcolor(black)) ///
    (lowess bias_gb_census coverage, lpattern(shortdash) lcolor(black)) ///
    (lowess bias_fh_mun_gis_ntl coverage, lpattern(solid) lcolor(gray)) ///
    (lowess bias_fh_mun coverage, lpattern(dash) lcolor(gray)) ///
    if pov_rank<=10, scheme(s1mono) xtitle(Sampling Frequency) ytitle(Bias) ///
    legend(label(1 "Gradient Boosting (GIS)") label(2 "Gradient Boosting (CEN)") ///
    label(3 "Area-level (GIS)") label(4 "Area-level (CEN)"))
    graph export "$outpath/Figure-6b.png", as(png) replace


