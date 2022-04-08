*==========================================
* Figures for Manuscript
*==========================================

* Set up
clear all
global inpath "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results"
global outpath "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Manuscript"

*==========================================
* Section 5: The Standard Implementation
*==========================================

* R-squared plot
import delimited "$inpath/results_rsquared.csv", clear
keep sim_sample eb_true eb_direct uc_true uc_direct gb_gis_mun_true gb_gis_mun_direct
rename *_true True_*
rename *_direct Direct_*
reshape long True Direct, i(sim_sample) j(model) string
replace model = "Empirical Best" if model=="_eb"
replace model = "Gradient Boosting" if model=="_gb_gis_mun"
replace model = "Unit-Context" if model=="_uc"
gen order = 1 if model=="Empirical Best" 
replace order = 2 if model=="Unit-Context" 
replace order = 3 if model=="Gradient Boosting" 
graph hbox True Direct, ytitle({it:R}{sup: 2}) scheme(s1mono) over(model, sort(order)) ///
    nooutside note("")
graph export "$outpath/s5_rsquared.pdf", as(pdf) replace

* MSE plot
import delimited "$inpath/results_mse.csv", clear
keep mse_gb_gis mse_eb mse_uc
label var mse_gb_gis "Gradient Boosting"
label var mse_eb "Empirical Best"
label var mse_uc "Unit-Context"
graph hbox mse_eb mse_uc mse_gb_gis, ytitle(Mean Squared Error) scheme(s1mono) ///
    box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) legend(off) ///
	showyvars nooutside note("")
graph export "$outpath/s5_mse.pdf", as(pdf) replace

* Bias plot
import delimited "$inpath/results_bias.csv", clear
keep bias_gb_gis bias_eb bias_uc
label var bias_gb_gis "Gradient Boosting"
label var bias_eb "Empirical Best"
label var bias_uc "Unit-Context"
graph hbox bias_eb bias_uc bias_gb_gis, ytitle(Bias) scheme(s1mono) ///
    box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) legend(off) ///
	showyvars nooutside note("")
graph export "$outpath/s5_bias.pdf", as(pdf) replace

* Poverty reduction
import delimited "$inpath/results_targeting.csv", clear
keep gb_gis_mun eb uc
replace gb_gis_mun = gb_gis_mun*100  // Put values in percentage terms
replace eb = eb*100  
replace uc = uc*100  
label var gb_gis_mun "Gradient Boosting"
label var eb "Empirical Best"
label var uc "Unit-Context"
graph hbox eb uc gb_gis_mun, ytitle(Poverty Rate) scheme(s1mono) ///
    box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) legend(off) ///
	showyvars nooutside note("")
graph export "$outpath/s5_poverty.pdf", as(pdf) replace

*==========================================
* Section 6: Alternative Covariates
*==========================================

* R-squared plot
import delimited "$inpath/results_rsquared.csv", clear
keep gb_census_mun_true gb_gis_mun_true gb_all_mun_true
label var gb_census_mun_true "Census"
label var gb_gis_mun_true "GIS"
label var gb_all_mun_true "All"
graph hbox gb_census_mun_true gb_gis_mun_true gb_all_mun_true, ytitle({it:R}{sup: 2}) ///
    scheme(s1mono) box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) ///
	legend(off) showyvars nooutside note("")
graph export "$outpath/s6_rsquared.pdf", as(pdf) replace

* MSE plot
import delimited "$inpath/results_mse.csv", clear
keep mse_gb_census mse_gb_gis mse_gb_all
label var mse_gb_census "Census"
label var mse_gb_gis "GIS"
label var mse_gb_all "All"
graph hbox mse_gb_census mse_gb_gis mse_gb_all, ytitle(Mean Squared Error) ///
    scheme(s1mono) box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) ///
	legend(off) showyvars nooutside note("")
graph export "$outpath/s6_mse.pdf", as(pdf) replace

* Bias plot
import delimited "$inpath/results_bias.csv", clear
keep bias_gb_census bias_gb_gis bias_gb_all
label var bias_gb_census "Census"
label var bias_gb_gis "GIS"
label var bias_gb_all "All"
graph hbox bias_gb_census bias_gb_gis bias_gb_all, ytitle(Bias) ///
    scheme(s1mono) box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) ///
	legend(off) showyvars nooutside note("")
graph export "$outpath/s6_bias.pdf", as(pdf) replace

* Poverty reduction
import delimited "$inpath/results_targeting.csv", clear
keep gb_census_mun gb_gis_mun gb_all_mun 
replace gb_census_mun = gb_census_mun*100  // Put values in percentage terms
replace gb_gis_mun = gb_gis_mun*100 
replace gb_all_mun = gb_all_mun*100 
label var gb_census_mun "Census"
label var gb_gis_mun "GIS"
label var gb_all_mun "All"
graph hbox gb_census_mun gb_gis_mun gb_all_mun , ytitle(Poverty Rate) ///
    scheme(s1mono) box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) ///
	legend(off) showyvars nooutside note("")
graph export "$outpath/s6_poverty.pdf", as(pdf) replace

* Variable importance
import delimited "$inpath/gb_importance_all_mun.csv", clear
egen imp = rowmean(imp*)
gsort -imp
drop if _n >25
graph hbar (asis) imp, over(variables, sort(1) descending) scheme(s1mono) ///
    ytitle(Variable Importance)
graph export "$outpath/s6_importance.pdf", as(pdf) replace

*==========================================
* Section 7: Alternative Models
*==========================================

* R-squared plot
import delimited "$inpath/results_rsquared.csv", clear
keep gb_all_mun_true bart_all_mun_true rf_all_mun_true lasso_all_mun_true ols_all_mun_true
label var gb_all_mun_true "Gradient Boosting"
label var bart_all_mun_true "BART"
label var rf_all_mun_true "Random Forest"
label var lasso_all_mun_true "Lasso"
label var ols_all_mun_true "OLS"
graph hbox gb_all_mun_true rf_all_mun_true bart_all_mun_true lasso_all_mun_true ///
    ols_all_mun_true, ytitle({it:R}{sup: 2}) scheme(s1mono) box(1, color(gray)) ///
	box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) box(5, color(gray)) ///
	legend(off) showyvars nooutside note("")
graph export "$outpath/s7_rsquared.pdf", as(pdf) replace

* MSE plot
import delimited "$inpath/results_mse.csv", clear
keep mse_gb_all mse_bart_all mse_rf_all mse_lasso_all mse_ols_all
label var mse_gb_all "Gradient Boosting"
label var mse_bart_all "BART"
label var mse_rf_all "Random Forest"
label var mse_lasso_all "Lasso"
label var mse_ols_all "OLS"
graph hbox mse_gb_all mse_rf_all mse_bart_all mse_lasso_all mse_ols_all, ///
    ytitle(Mean Squared Error) scheme(s1mono) box(1, color(gray)) ///
	box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) box(5, color(gray)) ///
	legend(off) showyvars nooutside note("")
graph export "$outpath/s7_mse.pdf", as(pdf) replace

* Bias plot
import delimited "$inpath/results_bias.csv", clear
keep bias_gb_all bias_bart_all bias_rf_all bias_lasso_all bias_ols_all
label var bias_gb_all "Gradient Boosting"
label var bias_bart_all "BART"
label var bias_rf_all "Random Forest"
label var bias_lasso_all "Lasso"
label var bias_ols_all "OLS"
graph hbox bias_gb_all bias_rf_all bias_bart_all bias_lasso_all bias_ols_all, ///
    ytitle(Bias) scheme(s1mono) box(1, color(gray)) ///
	box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) box(5, color(gray)) ///
	legend(off) showyvars nooutside note("")
graph export "$outpath/s7_bias.pdf", as(pdf) replace

* Poverty reduction
import delimited "$inpath/results_targeting.csv", clear
keep gb_all_mun bart_all_mun rf_all_mun lasso_all_mun ols_all_mun
replace gb_all_mun = gb_all_mun*100  // Put values in percentage terms
replace bart_all_mun = bart_all_mun*100 
replace rf_all_mun = rf_all_mun*100 
replace lasso_all_mun = lasso_all_mun*100 
replace ols_all_mun = ols_all_mun*100 
label var gb_all_mun "Gradient Boosting"
label var bart_all_mun "BART"
label var rf_all_mun "Random Forest"
label var lasso_all_mun "Lasso"
label var ols_all_mun "OLS"
graph hbox gb_all_mun rf_all_mun bart_all_mun lasso_all_mun ols_all_mun, ///
    ytitle(Poverty Rate) scheme(s1mono) box(1, color(gray)) ///
	box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) box(5, color(gray)) ///
	legend(off) showyvars nooutside note("")
graph export "$outpath/s7_poverty.pdf", as(pdf) replace




