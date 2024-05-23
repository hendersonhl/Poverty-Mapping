*==========================================
* Program setup
*==========================================

* Set up
clear all
set more off
set matsize 8000
cap set processors 8

mata
	//Mata function for selection
	function mysel2(_bb, _se, _pval){
		thevars = tokens(st_local("_myhhvars"))
		zvals   = (_bb':/_se)[1..(rows(_se)-1)]
		zvals   = 2:*normal(-abs(zvals))
		if (colmax(zvals)>_pval){
			keepvar = thevars[selectindex(colmax(zvals):>zvals)]
			return(keepvar)	
		}	
		else{
			keepvar = "it's done"
			return(keepvar)
		}
	}

end

* Set globals
if (lower("`c(username)'")=="wb378870")    global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="paul corral") global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
if (lower("`c(username)'")=="hendersonhl") global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"

global inpath "$main/Data/"
global outpath "$main/Results/"

global thevar gis_arvimin gis_arvimax gis_arvimean gis_arvisum gis_arvistddev ///
gis_baeimin gis_baeimax gis_baeimean gis_baeisum gis_baeistddev gis_bimin ///
gis_bimax gis_bimean gis_bisum gis_bistddev gis_brbamin gis_brbamax gis_brbamean ///
gis_brbasum gis_brbastddev gis_bumin gis_bumax gis_bumean gis_busum gis_bustddev ///
gis_evimin gis_evimax gis_evimean gis_evisum gis_evistddev gis_ibimin gis_ibimax ///
gis_ibimean gis_ibisum gis_ibistddev gis_mndwimin gis_mndwimax gis_mndwimean ///
gis_mndwisum gis_mndwistddev gis_nbaimin gis_nbaimax gis_nbaimean gis_nbaisum ///
gis_nbaistddev gis_nbimin gis_nbimax gis_nbimean gis_nbisum gis_nbistddev gis_ndbimin ///
gis_ndbimax gis_ndbimean gis_ndbisum gis_ndbistddev gis_ndvimin gis_ndvimax gis_ndvimean ///
gis_ndvisum gis_ndvistddev gis_ndwimin gis_ndwimax gis_ndwimean gis_ndwisum ///
gis_ndwistddev gis_srmin gis_srmax gis_srmean gis_srsum gis_srstddev gis_uimin ///
gis_uimax gis_uimean gis_uisum gis_uistddev gis_ndsimin gis_ndsimax gis_ndsimean ///
gis_ndsisum gis_ndsistddev gis_varimin gis_varimax gis_varimean gis_varisum ///
gis_varistddev gis_savimin gis_savimax gis_savimean gis_savisum gis_savistddev ///
gis_osavimin gis_osavimax gis_osavimean gis_osavisum gis_osavistddev gis_ndmimin ///
gis_ndmimax gis_ndmimean gis_ndmisum gis_ndmistddev gis_mdeamin gis_mdeamax ///
gis_mdeamean gis_mdeasum gis_mdeastddev gis_mdepmin gis_mdepmax gis_mdepmean ///
gis_mdepsum gis_mdepstddev ///
 gis_ntl_min_2015 gis_ntl_max_2015 gis_ntl_std_2015 gis_ntl_mean_2015 gis_ntl_sum_2015 


*===============================================================================
// Version adds the GIS covariates!
*===============================================================================
cap use "$outpath\FH_results_mun_gis_ntl.dta", clear
if _rc{
	local start = 1
}
else{
	sum simul
	local start = r(max)+1
}
local start=1

forval sim= `start'/500{
	
	use "$inpath\my_samples_pps_psu@.dta" if sim_sample==`sim', clear
	dis as error "Starting Simulation number : `sim'"
	
	merge 1:1 hhid using "$inpath\census_trim", keepusing(hhsize poor HID)
	gen double HID_mun = int(HID/1e3)
	replace poor = . if _m!=3
	
	
	gen popw = Whh*hhsize
	qui:proportion poor if _m==3 [pw = popw], over(HID_mun)
	mata: fgt0     = st_matrix("e(b)")
	mata: fgt0     = fgt0[(cols(fgt0)/2+1)..cols(fgt0)]'
	mata: fgt0_var = st_matrix("e(V)")
	mata: fgt0_var = diagonal(fgt0_var)[(cols(fgt0_var)/2+1)..cols(fgt0_var)]

	// the census. Leave data at the municipality level.
	groupfunction,  rawsum(hhsize) max(_m) by(HID_mun) 
	cap clonevar MiMun = HID_mun
	merge 1:1 MiMun using "$inpath\xmatrix_mun_ntl.dta", keepusing(gis_*) gen(match)
		drop if match!=3
		drop match MiMun
		

	
	sort HID_mun //ordered to match proportion output
	putmata HID_mun if _m==3, replace
	//Pull proportion's results
	getmata dir_fgt0 = fgt0 dir_fgt0_var = fgt0_var, id(HID_mun)
	replace dir_fgt0_var = . if dir_fgt0_var==0
	replace dir_fgt0     = . if missing(dir_fgt0_var)
	
*=============================================================================
// Model fit and selection
*=============================================================================
	local hhvars $thevar
	local hhvars1 
	
	local a = 1
	local hhvarsOO
	foreach x of local hhvars{
		rename `x' gis_`a'
		lab var gis_`a' "`x'"
		local hhvarsOO `hhvarsOO' gis_`a'
		local a= `a'+1
	} 
	
	local hhvars `hhvarsOO'
	cap:_rmcoll `hhvars', forcedrop
	if (_rc==0) 	local hhvars `r(varlist)'
	else{
		_rmcoll `hhvarsOO', forcedrop
		local hhvars `r(varlist)'
	}
	

	local hhvars : list clean hhvars
	dis as error "Sim : `sim' first removal"
	//Removal of non-significant variables
	forval z= 0.8(-0.05)0.01{
		local regreso 
		while ("`regreso'"!="it's done"){
			fhsae dir_fgt0 `hhvars', revar(dir_fgt0_var) method(fh) 
			mata: bb=st_matrix("e(b)")
			mata: se=sqrt(diagonal(st_matrix("e(V)")))
			local _myhhvars : colnames(e(b))
			mata: st_local("regreso", invtokens(mysel2(bb, se, `z')))	
			if ("`regreso'"!="it's done") local hhvars `regreso'
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
	
	local hhvars
	local hhvars1 
	
	foreach x of global postvif{
		cap confirm variable `x'
		if (_rc==0) local hhvars `hhvars' `x'
	}
	
	dis as error "Sim : `sim' final removal"
	//One final removal of non-significant covariates
	forval z= 0.8(-0.05)0.01{
		local regreso 
		while ("`regreso'"!="it's done"){
			fhsae dir_fgt0 `hhvars', revar(dir_fgt0_var) method(fh) 
			mata: bb=st_matrix("e(b)")
			mata: se=sqrt(diagonal(st_matrix("e(V)")))
			local _myhhvars : colnames(e(b))
			mata: st_local("regreso", invtokens(mysel2(bb, se, `z')))	
			if ("`regreso'"!="it's done") local hhvars `regreso'
		}	
	}	
	
	global last `hhvars'
	
	
	//Obtain SAE-FH-estimates	
	fhsae dir_fgt0 $last, revar(dir_fgt0_var) method(reml) fh(fh_fgt0) ///
	fhse(fh_fgt0_se) fhcv(fh_fgt0_cv) gamma(fh_fgt0_gamma) out  ///
	
	keep fh_* HID_mun

	gen simul = `sim'
	if (`sim'==1) save "$outpath\FH_results_mun_gis_ntl.dta", replace
	else{
		cap drop weight
		append using "$outpath\FH_results_mun_gis_ntl.dta"
		save "$outpath\FH_results_mun_gis_ntl.dta", replace
	}
	//clear mata

dis as error "`sim'"
}



