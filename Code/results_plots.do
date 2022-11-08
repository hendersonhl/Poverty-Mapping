*==========================================
* Figures for Manuscript
*==========================================

* Set up
clear all
if (lower("`c(username)'")=="wb378870")     global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="hendersonhl")  global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"
global inpath  "$main/Results"
global outpath "$main/Manuscript"

* Basic R-squared plot
import delimited "$inpath/results_rsquared.csv", clear
keep sim_sample gb_census_mun_direct gb_census_mun_true gb_census_psu_direct gb_census_psu_true 
rename *_true True_*
rename *_direct Direct_*
reshape long True Direct, i(sim_sample) j(model) string
replace model = "Municipality" if model=="_gb_census_mun"
replace model = "PSU" if model=="_gb_census_psu"
gen order = 1 if model=="PSU" 
replace order = 2 if model=="Municipality" 
graph box Direct True, ytitle("R-squared") scheme(s1mono) over(model, sort(order)) ///
    nooutside note("")
graph export "$outpath/R-squared.pdf", as(pdf) replace

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
graph box Unconstrained Constrained, ytitle("R-squared") scheme(s1mono) over(model, sort(order)) ///
    nooutside note("")
graph export "$outpath/Constrained.pdf", as(pdf) replace
	
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
import delimited "$inpath/results_mse.csv", clear
keep mse_gb_census mse_gb_gis mse_gb_all mse_gb_psu mse_eb mse_uc
label var mse_gb_census "Gradient Boosting (Census)"
label var mse_gb_gis "Gradient Boosting (GIS)"
label var mse_gb_all "Gradient Boosting (All)"
label var mse_gb_psu "Gradient Boosting (PSU)"
label var mse_eb "Traditional (EB)"
label var mse_uc "Traditional (UC)"
graph hbox mse_gb_gis mse_gb_census mse_gb_all mse_gb_psu mse_eb mse_uc, ytitle(Empirical MSE) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) box(6, color(gray))
graph export "$outpath/MSE.pdf", as(pdf) replace
	
* Basic bias plot
import delimited "$inpath/results_bias.csv", clear
keep bias_gb_gis bias_gb_census bias_gb_all bias_gb_psu bias_eb bias_uc
label var bias_gb_census "Gradient Boosting (Census)"
label var bias_gb_gis "Gradient Boosting (GIS)"
label var bias_gb_all "Gradient Boosting (All)"
label var bias_gb_psu "Gradient Boosting (PSU)"
label var bias_eb "Traditional (EB)"
label var bias_uc "Traditional (UC)"
graph hbox bias_gb_census bias_gb_gis bias_gb_all bias_gb_psu bias_eb bias_uc, ytitle(Bias) ///
    scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) box(6, color(gray))
graph export "$outpath/Bias.pdf", as(pdf) replace
	
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
    ytitle(Variable Importance)
graph export "$outpath/Importance.pdf", as(pdf) replace

* MSE by poverty quantiles
import delimited "$main/Data/true_mun.csv", clear
keep mimun poor
rename mimun muni
tempfile true
save `true'
import delimited "$inpath/results_mse.csv", clear
merge 1:1 muni using `true'
drop _merge
xtile pov_rank = poor, nq(50)
replace pov_rank = 51 - pov_rank  // Reverse order
collapse mse*, by(pov_rank)
twoway (line mse_gb_gis pov_rank, lpattern(solid) lcolor(black)) ///
    (line mse_eb pov_rank, lpattern(shortdash) lcolor(black)) ///
    (line mse_gb_census pov_rank, lpattern(solid) lcolor(gray)) ///
    (line mse_uc pov_rank, lpattern(shortdash) lcolor(gray)),  ///
	ytitle(Average MSE) xtitle(Poverty Quantile) scheme(s1mono) ///
	legend(label(1 "Gradient Boosting (GIS)") label(2 "Traditional (EB)") ///
	label(3 "Gradient Boosting (Census)") label(4 "Traditional (UC)"))
graph export "$outpath/Quantiles(MSE).pdf", as(pdf) replace

* Bias by poverty quantiles
import delimited "$main/Data/true_mun.csv", clear
keep mimun poor
rename mimun muni
tempfile true
save `true'
import delimited "$inpath/results_bias.csv", clear
merge 1:1 muni using `true'
drop _merge
xtile pov_rank = poor, nq(50)
replace pov_rank = 51 - pov_rank  // Reverse order
collapse bias*, by(pov_rank)
twoway (line bias_gb_gis pov_rank, lpattern(solid) lcolor(black)) ///
    (line bias_eb pov_rank, lpattern(shortdash) lcolor(black)) ///
    (line bias_gb_census pov_rank, lpattern(solid) lcolor(gray)) ///
    (line bias_uc pov_rank, lpattern(shortdash) lcolor(gray)),  ///
	ytitle(Average Bias) xtitle(Poverty Quantile) scheme(s1mono) ///
	legend(label(1 "Gradient Boosting (GIS)") label(2 "Traditional (EB)") ///
	label(3 "Gradient Boosting (Census)") label(4 "Traditional (UC)"))
graph export "$outpath/Quantiles(Bias).pdf", as(pdf) replace

* Model comparisons w/ census covariates
import delimited "$inpath/results_mse.csv", clear
keep mse_gb_census mse_bart_census mse_rf_census mse_lasso_census
label var mse_gb_census "Gradient Boosting"
label var mse_bart_census "BART"
label var mse_rf_census "Random Forest"
label var mse_lasso_census "Lasso"
graph hbox mse_gb_census mse_bart_census mse_rf_census mse_lasso_census, ///
    ytitle(Empirical MSE) scheme(s1mono) legend(off) nooutside note("") showyvars ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) 
graph export "$outpath/Models(Census).pdf", as(pdf) replace
	
* Model comparisons w/ GIS covariates
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
graph export "$outpath/Models(GIS).pdf", as(pdf) replace
	
* Poverty targeting
import delimited "$inpath/results_targeting.csv", clear
keep gb_census_mun gb_gis_mun gb_all_mun gb_census_psu eb uc
replace gb_census_mun = gb_census_mun*100  // Put values in percentage terms
replace gb_gis_mun = gb_gis_mun*100 
replace gb_all_mun = gb_all_mun*100 
replace gb_census_psu = gb_census_psu*100 
replace eb = eb*100
replace uc = uc*100
label var gb_census_mun "Gradient Boosting (Census)"
label var gb_gis_mun "Gradient Boosting (GIS)"
label var gb_all_mun "Gradient Boosting (All)"
label var gb_census_psu "Gradient Boosting (PSU)"
label var eb "Traditional (EB)"
label var uc "Traditional (UC)"
graph hbox gb_gis_mun gb_census_mun gb_all_mun gb_census_psu eb uc, ytitle(Poverty Rate) ///
    scheme(s1mono) legend(off) showyvars nooutside note("") ///
	box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
	box(5, color(gray)) box(6, color(gray))
graph export "$outpath/Targeting.pdf", as(pdf) replace





