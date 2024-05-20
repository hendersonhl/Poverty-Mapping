*==========================================
* Program setup
*==========================================

* Set up
clear all
set more off
set matsize 8000
cap set processors 8
if _rc set processors 4

version 14


* Set globals
if (lower("`c(username)'")=="wb378870")    global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="paul corral") global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
if (lower("`c(username)'")=="hendersonhl") global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"

global inpath "$main/Data/"
global outpath "$main/Results/"

*===============================================================================
// Bring in the NTL data
*===============================================================================

forval z=2014/2022{
	cap	import delimited using "$inpath\MX_VNL_v21_npp_`z'_AVG.csv", clear
	if (_rc==0){
		gen estado = real(substr(adm2_pcode,3,2))
		gen municipio = real(substr(adm2_pcode,5,3))
		local keepers
		foreach x in range mean std median pct90{
			rename `x' gis_ntl_`x'_`z'
			local keepers `keepers' gis_ntl_`x'_`z'
		}
		keep estado municipi `keepers'
		
		tempfile _`z'
		save `_`z''
	}	
}

*===============================================================================
// Merge the NTL to the linking file
*===============================================================================

use "$inpath\for_ntl_link.dta", clear

forval z = 2014/2022{
	cap merge 1:1 estado municipio using `_`z''
	if (_rc==0){
		drop if _m==2
		drop _m
	} 
}

rename HID_mun mimun
tempfile ntl
save `ntl'

*===============================================================================
// Merge the NTL to the main data for the models.
*===============================================================================


import delimited using "$inpath\xmatrix_mun.csv", clear

	merge 1:1 mimun using `ntl'
		drop if _m==2
		drop _m
		
	rename mimun MiMun
		
export delimited using "$inpath\xmatrix_mun_ntl.csv", replace
save "$inpath\xmatrix_mun_ntl.dta", replace
