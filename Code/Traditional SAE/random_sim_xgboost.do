clear 
*===============================================================================
// Simulation pre-amble
*===============================================================================
local iter     		= $zed
local simnum        = $sim
local sample        = $sample
if ($bcox==1){
	local transform bcox
	local transformell eta(nonnormal) epsilon(nonnormal)
}
else if ($bcox==2){
	local transform lnskew
	local transformell eta(nonnormal) epsilon(nonnormal)
}
else if ($bcox==999){
	local transform oqnorm
}
else{
	local transform
	local transformell eta(normal) epsilon(normal)
}

local simhere /*direct twofold twofoldS h3eb h3ebc ellold elloldA h3area twofoldA twofoldAS */ h3cbeb h3no uceb

*===============================================================================
// Model fit for every sample! this differs from other fits.
*===============================================================================

use "$simdata\models.dta", clear

if (`iter'==1){
	count
	local mm=r(N)
	
	forval z=1/`mm'{
		local todo `todo' `=hhmodel[`z']' `=amodel[`z']'
		local todo : list uniq todo
	}
	global toimport `todo'
	
	use "$dpath/census_trim.dta", clear
	keep hhid HID_mun HID hhsize $toimport poor gap gap2 e_y lny
	save "$dpath/census_`simnum'.dta", replace
}
use "$simdata\models.dta", clear
global hhCmodel `=hhmodel[`sample']'
global amodel   `=amodel[`sample']'



*===============================================================================
// CREATE THE SURVEY!
*===============================================================================
	
use "$thesamples" if sim_sample==`sample', clear
	merge 1:1 hhid using "$dpath/census_`simnum'.dta"
		keep if _m==3
		drop _m
cap gen popw = Whh*hhsize

save "$simdata\svy`simnum'.dta", replace
	
	
*===============================================================================
// Direct estimates
*===============================================================================
	gen observations=1
	groupfunction [aw=popw],mean(poor gap gap2 e_y) rawsum(observations) by(HID_mun)
	gen nsim = `iter'
	gen nsample = `sample'
	
	if (`iter'==1) save "$simdata\direct`simnum'.dta", replace
	else{
		append using "$simdata\direct`simnum'.dta"
		save "$simdata\direct`simnum'.dta", replace
	}
		

	//Bring in the census
	if (`iter'==1){
		sae data import, datain("$dpath/census_trim.dta") varlist($toimport) ///
		area(HID_mun) uniqid(hhid) dataout("$dpath\censo_`simnum'")
	}


	//Seed stage for simulations, changes after every iteration!
	local seedstage `c(rngstate)'
	

*===============================================================================
//H3-CBEB
*===============================================================================
use "$simdata\svy`simnum'.dta", clear
sort lny
cap gen popw = Whh*hhsize
gen rank = sum(popw)
sum popw
local dem = r(sum)
gen double bcy = invnorm(((rank - 0.5)/`dem'))

local povline = invnormal(.25)

capture noisily sae sim lmm bcy $hhCmodel [aw=Whh], area(HID_mun) psu(HID) varest(h3) ebest eta(normal) ///
epsilon(normal) matin("$dpath\censo_`simnum'") seed(`seedstage') rep(100) ///
pwcensus(hhsize) indicators(FGT0) aggids(0) uniq(hhid) plines(`povline') allmata
	if _rc==0{
		gen nsim = `iter'
		gen nsample = `sample'
		
		rename avg_fgt0 avg_fgt0
		drop se_fgt0
		
		if (`iter'==1) save "$simdata\h3cbeb`simnum'.dta", replace
		else{
			append using "$simdata\h3cbeb`simnum'.dta"
			save "$simdata\h3cbeb`simnum'.dta", replace
		}
		global redo = 0
	}
	else{
		dis as error "h3cbeb failed"
		global redo = 1
		
		foreach x of local simhere{
			use "$simdata\\`x'`simnum'.dta", clear
			drop if nsim==`iter'
			save "$simdata\\`x'`simnum'.dta", replace
			
		}
	}

if ($redo==0){
		
use "$simdata\svy`simnum'.dta", clear

sort lny
cap gen popw = Whh*hhsize
gen rank = sum(popw)
sum popw
local dem = r(sum)
gen double bcy = invnorm(((rank - 0.5)/`dem'))

local povline = invnormal(.25)
		
		cap noisily sae sim h3 bcy $hhCmodel [aw=Whh],  area(HID_mun)  ///
		mcrep(50) bsrep(0) matin("$dpath\censo_`simnum'") seed(`seedstage') ///
		pwcensus(hhsize) indicators(FGT0) aggids(0) uniq(hhid) plines(`povline')
		if _rc==0{
			gen nsim = `iter'
			gen nsample = `sample'
			
			if (`iter'==1) save "$simdata\h3no`simnum'.dta", replace
			else{
				append using "$simdata\h3no`simnum'.dta"
				save "$simdata\h3no`simnum'.dta", replace
			}
			global redo = 0
		}
		else{
			global redo = 1
			dis as error "CeB failed"
			foreach x of local simhere{
				cap use "$simdata\\`x'`simnum'.dta", clear
				if _rc==0{
					drop if nsim==`iter'
					save "$simdata\\`x'`simnum'.dta", replace
				}				
			}
		}
	}
	
if ($redo==0){
		
use "$simdata\svy`simnum'.dta", clear

sort lny
cap gen popw = Whh*hhsize
gen rank = sum(popw)
sum popw
local dem = r(sum)
gen double bcy = invnorm(((rank - 0.5)/`dem'))

local povline = invnormal(.25)
		
		cap noisily sae sim h3 bcy $amodel [aw=Whh],  area(HID_mun)  ///
		mcrep(50) bsrep(0) matin("$dpath\censo_`simnum'") seed(`seedstage') ///
		pwcensus(hhsize) indicators(FGT0) aggids(0) uniq(hhid) plines(`povline')
		if _rc==0{
			gen nsim = `iter'
			gen nsample = `sample'
			
			if (`iter'==1) save "$simdata\uceb`simnum'.dta", replace
			else{
				append using "$simdata\uceb`simnum'.dta"
				save "$simdata\uceb`simnum'.dta", replace
			}
			global redo = 0
		}
		else{
			global redo = 1
			dis as error "UC failed"
			foreach x of local simhere{
				cap use "$simdata\\`x'`simnum'.dta", clear
				if _rc==0{
					drop if nsim==`iter'
					save "$simdata\\`x'`simnum'.dta", replace
				}				
			}
		}
	}


