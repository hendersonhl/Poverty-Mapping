*==========================================
* Program setup
*==========================================

* Set up
clear all
set more off
set matsize 8000
set processors 8

version 14


* Set globals
if (lower("`c(username)'")=="wb378870")    global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="paul corral") global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
if (lower("`c(username)'")=="hendersonhl") global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"

global inpath "$main/Data/"
global outpath "$main/Results/"

global thevar_hid HID_hhsize HID_age_hh HID_male_hh HID_piped_water ///
HID_no_piped_water HID_no_sewage HID_sewage_pub HID_sewage_priv ///
HID_electricity HID_telephone HID_cellphone HID_internet ///
HID_computer HID_washmachine HID_fridge HID_television HID_share_under15 ///
HID_share_elderly HID_share_adult HID_max_tertiary HID_max_secondary ///
HID_share_female

global thevar mun_hhsize mun_age_hh mun_male_hh mun_piped_water ///
mun_no_piped_water mun_no_sewage mun_sewage_pub mun_sewage_priv ///
mun_electricity mun_telephone mun_cellphone mun_internet ///
mun_computer mun_washmachine mun_fridge mun_television mun_share_under15 ///
mun_share_elderly mun_share_adult mun_max_tertiary mun_max_secondary ///
mun_share_female


*===============================================================================

*===============================================================================
forval sim=34/500{
use "$inpath\my_samples_pps_psu@.dta" if sim_sample==`sim', clear

merge 1:1 hhid using "$inpath\census_trim", keepusing(hhsize poor $thevar $thevar_hid HID)

replace poor = . if _m!=3


gen popw = Whh*hhsize
qui:proportion poor if _m==3 [pw = popw], over(HID)
mata: fgt0     = st_matrix("e(b)")
mata: fgt0     = fgt0[(cols(fgt0)/2+1)..cols(fgt0)]'
mata: fgt0_var = st_matrix("e(V)")
mata: fgt0_var = diagonal(fgt0_var)[(cols(fgt0_var)/2+1)..cols(fgt0_var)]

	// the census. Leave data at the municipality level.
	groupfunction, first($thevar $thevar_hid) rawsum(hhsize) max(_m) by(HID) 
	sort HID //ordered to match proportion output
	putmata HID if _m==3
	//Pull proportion's results
	getmata dir_fgt0 = fgt0 dir_fgt0_var = fgt0_var, id(HID)
	replace dir_fgt0_var = . if dir_fgt0_var==0
	replace dir_fgt0     = . if missing(dir_fgt0_var)
	
*=============================================================================
// Model fit and selection
*=============================================================================
	
	local hhvars $thevar $thevar_hid
	local hhvars1 
	
	//Removal of non-significant variables
	forval z= 0.8(-0.05)0.0001{
		qui:fhsae dir_fgt0 `hhvars', revar(dir_fgt0_var) method(fh) 
		mata: bb=st_matrix("e(b)")
		mata: se=sqrt(diagonal(st_matrix("e(V)")))
		mata: zvals = bb':/se
		mata: st_matrix("min",min(abs(zvals)))
		local zv = (-min[1,1])
		if (2*normal(`zv')>=`z'){
			foreach x of varlist `hhvars'{
				local hhvars1
				qui: fhsae dir_fgt0 `hhvars', revar(dir_fgt0_var) method(fh) 
				qui: test `x' 
				if (r(p)>`z'){
					local hhvars1
					foreach yy of local hhvars{
						if ("`yy'"=="`x'") dis ""
						else local hhvars1 `hhvars1' `yy'
					}
				}
				else local hhvars1 `hhvars'
				local hhvars `hhvars1'		
			}
		}
	}	

	//Global with non-significant variables removed
	global postsign `hhvars'

	//Check VIF
	reg dir_fgt0 $postsign, r
	gen touse = e(sample)
	gen weight = 1
	mata: ds = _f_stepvif("$postsign","weight",5,"touse") 
	global postvif `vifvar'
	
	local hhvars $postvif
	local hhvars1 
	
	//One final removal of non-significant covariates
	forval z= 0.8(-0.05)0.0001{
		qui:fhsae dir_fgt0 `hhvars', revar(dir_fgt0_var) method(fh) 
		mata: bb=st_matrix("e(b)")
		mata: se=sqrt(diagonal(st_matrix("e(V)")))
		mata: zvals = bb':/se
		mata: st_matrix("min",min(abs(zvals)))
		local zv = (-min[1,1])
		if (2*normal(`zv')>=`z'){	
			foreach x of varlist `hhvars'{
				local hhvars1
				qui: fhsae dir_fgt0 `hhvars', revar(dir_fgt0_var) method(fh) 
				qui: test `x' 
				if (r(p)>`z'){
					local hhvars1
					foreach yy of local hhvars{
						if ("`yy'"=="`x'") dis ""
						else local hhvars1 `hhvars1' `yy'
					}
				}
				else local hhvars1 `hhvars'
				local hhvars `hhvars1'		
			}
		}
	}	
	
	global last `hhvars'
	
	gen double HID_mun = int(HID/1e3)
	//Obtain SAE-FH-estimates	
	fhsae dir_fgt0 $last, revar(dir_fgt0_var) method(reml) fh(fh_fgt0) ///
	fhse(fh_fgt0_se) fhcv(fh_fgt0_cv) gamma(fh_fgt0_gamma) out  ///
	aggarea(HID_mun) censuspop(hhsize) force

	gen simul = `sim'
	if (`sim'==1) save "$outpath\FH_results.dta", replace
	else{
		cap drop weight
		append using "$outpath\FH_results.dta"
		save "$outpath\FH_results.dta", replace
	}
	clear mata

dis as error "`sim'"
}



