set more off 
clear all

* Set globals
if (lower("`c(username)'")=="wb378870")    global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="paul corral") global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
if (lower("`c(username)'")=="hendersonhl") global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"

global inpath "$main/Data/"
global outpath "$main/Results/"

use "$outpath\FH_results_mun.dta", clear
gen GIS = "Census"
append using "$outpath\FH_results_mun_gis_ntl.dta"
replace GIS = "GIS" if missing(GIS)
//gen test = dir_fgt0 * (1-fh_fgt0_gamma) + xb*(fh_fgt0_gamma ) // illustrates how the weight works!

//If we want to include the out-of sample
replace  fh_fgt0_gamma = 1 if missing(fh_fgt0_gamma)


//we want to show as the proper formula
replace  fh_fgt0_gamma = 1 - fh_fgt0_gamma


groupfunction, by(HID_mun GIS) mean(fh_fgt0_gamma fh_fgt0_se)

reshape wide fh_fgt0_*, j(GIS) i(HID_mun) string


sort fh_fgt0_gammaCensus
gen rank = _n



lab var fh_fgt0_gammaCensus "Census covariate based FH"
lab var fh_fgt0_gammaGIS "GIS covariate based FH"
twoway (scatter fh_fgt0_gammaCensus rank) (scatter fh_fgt0_gammaGIS rank), xtitle(Municipality sorted by shrinkage parameter (census))
