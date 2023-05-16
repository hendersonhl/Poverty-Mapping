*==========================================
* Figures for Blog
*==========================================

* Set up
clear all
if (lower("`c(username)'")=="wb378870" | lower("`c(username)'")=="paul corral")     global main "C:\Users\\`c(username)'\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="hendersonhl")  global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"
if (lower("`c(username)'")=="lupin" | lower("`c(username)'")=="paul corral" ) global main "C:\Users\\`c(username)'\Documents\GitHub\Poverty-Mapping\"
global inpath  "$main/Results"
global outpath "$main/Manuscript"


cap erase mse.gph
cap erase bias.gph

* Basic MSE plot
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
	
keep mse_gb_census mse_gb_gis mse_gb_all mse_gb_psu mse_eb mse_uc mse_fh*
tabstat mse_gb_census-mse_fh_mun, stat(p50)
label var mse_gb_census "Gradient Boosting (CEN-MUN)"
label var mse_gb_gis    "Gradient Boosting (GIS-MUN)"         
label var mse_gb_all    "Gradient Boosting (ALL-MUN)"            
label var mse_eb        "Unit-level (CensusEB)"                           
label var mse_fh_mun        "Area-level (CEN-MUN)"  
label var mse_fh_mun_gis        "Area-level (GIS-MUN)"                    
graph hbox mse_gb_census mse_gb_gis mse_gb_all mse_eb mse_fh_mun mse_fh_mun_gis, ytitle(Empirical MSE) ///
  legend(off) nooutside note("") graphregion(color(white)) ///
  box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
  box(5, color(gray)) box(6, color(gray)) saving(mse) xsize(3.5) ysize(5) fxsize(45)

  
* Basic bias plot
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

use "$inpath/fh_mun_mse_bias.dta", clear
keep if variable == "bias_fh"
rename value bias_fh_mun_gis
rename area muni
tempfile tres
save `tres'

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

keep bias_gb_gis bias_gb_census bias_gb_all bias_gb_psu bias_eb bias_uc bias_fh*
tabstat bias_gb_census-bias_fh_mun, stat(p50 min max N)
label var bias_gb_census "Gradient Boosting (CEN-MUN)"
label var bias_gb_gis "Gradient Boosting (GIS-MUN)"
label var bias_gb_all "Gradient Boosting (ALL-MUN)"
label var bias_gb_psu "Gradient Boosting (CEN-PSU)"
label var bias_eb   "Unit-level (CensusEB)"      
label var bias_uc   "Unit-context"
label var bias_fh        "Area-level (CEN-PSU)"
label var bias_fh_mun        "Area-level (CEN-MUN)"  
label var bias_fh_mun_gis        "Area-level (GIS-MUN)"  
  
graph hbox  bias_gb_census bias_gb_gis bias_gb_all bias_eb bias_fh_mun bias_fh_mun_gis, ytitle(Empirical Bias) ///
    legend(off) nooutside note("") graphregion(color(white)) showyvars ///
  box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
  box(5, color(gray)) box(6, color(gray)) saving(bias) ysize(5) xsize(6)
  
  
gr combine bias.gph mse.gph , graphregion(color(white))  imargin(0 0 0 0)  graphregion(margin(l=2 r=5)) 
//ysize(5) xsize(9.5)

* Poverty targeting
import delimited "$inpath/results_transfer.csv", clear
keep variable sim fgt0
order sim variable fgt0
replace fgt0 = 100*(0.25-fgt0) if regexm(variable, "fh") | regexm(variable,"gb_census_hhid_demo")

reshape wide fgt0, i(sim) j(variable) string
rename fgt0* *
keep gb_gis_mun gb_census_mun gb_all_mun gb_census_psu eb uc fh fh_mun fh_mun_gis gb_census_hhid_demo
replace gb_gis_mun = (0.25-gb_gis_mun)*100  // Put values in percentage terms
replace gb_census_mun = (0.25-gb_census_mun)*100
replace gb_all_mun = (0.25-gb_all_mun)*100
replace gb_census_psu = (0.25-gb_census_psu)*100
replace eb = (0.25-eb)*100
replace uc = (0.25-uc)*100
tabstat eb-uc, stat(p50)
label var gb_census_mun "Gradient Boosting (CEN-MUN)"
label var gb_gis_mun    "Gradient Boosting (GIS-MUN)"         
label var gb_all_mun    "Gradient Boosting (ALL-MUN)"            
label var gb_census_psu    "Gradient Boosting (CEN-PSU)"
label var eb        "Unit-level (CensusEB)"                              
label var uc        "Unit-context"  
label var fh        "Area-level (CEN-PSU)"
label var fh_mun        "Area-level (CEN-MUN)"   
label var fh_mun_gis        "Area-level (GIS-MUN)"  
label var gb_census_hhid_demo "Gradient Boosting (CEN-HH)"

graph hbox gb_census_mun gb_gis_mun  gb_all_mun eb fh_mun fh_mun_gis /*gb_census_hhid_demo*/, ytitle(Poverty reduction (% points)) ///
    legend(off) nooutside note("") graphregion(color(white)) showyvars ///
  box(1, color(gray)) box(2, color(gray)) box(3, color(gray)) box(4, color(gray)) ///
  box(5, color(gray)) box(6, color(gray))

