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

		use "$dpath/census_trim.dta", clear
		
		sum e_y [aw=hhsize],d
		global pline = r(p25)		
		
		use "$thesamples" if sim_sample==`sample', clear
			merge 1:1 hhid using "$dpath/census_trim.dta"
				keep if _m==3
				drop _m
				
		cap drop *automobile*
				
		if ($bcox==1) bcskew0 bcy = lny
		else if ($bcox==2) lnskew0 bcy = exp(lny)
		else if ($bcox==999){
			sort lny
			gen popw = Whh*hhsize
			gen rank = sum(popw)
			sum popw
			local dem = r(sum)
			gen double bcy = invnorm(((rank - 0.5)/`dem'))
		}
		else clonevar bcy = lny
		rename HID_mun theMUN
		
		lassoregress bcy HID_* mun_* state_* [aw=Whh], lambda1se epsilon(1e-10) numfolds(20)
		local hhvars0p = e(varlist_nonzero)
		local hhvars `hhvars0p'
		
		rename theMUN HID_mun 
		
		//sae model h3 bcy `hhvars0p', area(HID_mun)
		
		forval z= 0.5(-0.05)0.05{
			sae model h3 bcy `hhvars' [aw=Whh], area(HID_mun) 
			mata: bb=st_matrix("e(b_gls)")
			mata: se=sqrt(diagonal(st_matrix("e(V_gls)")))
			mata: zvals = bb':/se
			mata: st_matrix("min",min(abs(zvals)))
			local zv = (-min[1,1])
			if (2*normal(`zv')<`z') exit
		
			foreach x of varlist `hhvars'{
				local hhvars1
				qui: sae model h3 bcy `hhvars' [aw=Whh], area(HID_mun)
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

		forval z= 0.05(-0.0005)0.0005{
			sae model h3 bcy `hhvars' [aw=Whh], area(HID_mun) 
			mata: bb=st_matrix("e(b_gls)")
			mata: se=sqrt(diagonal(st_matrix("e(V_gls)")))
			mata: zvals = bb':/se
			mata: st_matrix("min",min(abs(zvals)))
			local zv = (-min[1,1])
			if (2*normal(`zv')<`z') exit
		
			foreach x of varlist `hhvars'{
				local hhvars1
				qui: sae model h3 bcy `hhvars' [aw=Whh], area(HID_mun)
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
		
		reg bcy `hhvars' [aw=Whh]
		gen touse = e(sample)
		
		mata: ds = _f_stepvif("`hhvars'","Whh",3,"touse")
	
		local hhvars `vifvar'

		
		global amodel `hhvars'
		
		rename HID_mun theMUN
		
		lassoregress bcy  rural  hhsize age_hh male_hh  piped_water no_piped_water no_sewage sewage_pub sewage_priv electricity telephone cellphone internet computer washmachine fridge television share_under15 share_elderly share_adult max_tertiary max_secondary HID_* mun_* state_* [aw=Whh], lambda1se epsilon(1e-10) numfolds(20)
		local hhvars0p = e(varlist_nonzero)
		local hhvars `hhvars0p'
		//sae model h3 bcy `hhvars0p', area(HID_mun)
		
		rename theMUN HID_mun
		
		forval z= 0.5(-0.05)0.05{
			qui:sae model h3 bcy `hhvars' [aw=Whh], area(HID_mun) 
			mata: bb=st_matrix("e(b_gls)")
			mata: se=sqrt(diagonal(st_matrix("e(V_gls)")))
			mata: zvals = bb':/se
			mata: st_matrix("min",min(abs(zvals)))
			local zv = (-min[1,1])
			if (2*normal(`zv')<`z') exit
		
			foreach x of varlist `hhvars'{
				local hhvars1
				qui: sae model h3 bcy `hhvars' [aw=Whh], area(HID_mun)
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

		forval z= 0.05(-0.0005)0.0005{
			qui:sae model h3 bcy `hhvars' [aw=Whh], area(HID_mun) 
			mata: bb=st_matrix("e(b_gls)")
			mata: se=sqrt(diagonal(st_matrix("e(V_gls)")))
			mata: zvals = bb':/se
			mata: st_matrix("min",min(abs(zvals)))
			local zv = (-min[1,1])
			if (2*normal(`zv')<`z') exit
		
			foreach x of varlist `hhvars'{
				local hhvars1
				qui: sae model h3 bcy `hhvars' [aw=Whh], area(HID_mun)
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
		
		reg bcy `hhvars' [aw=Whh]
		replace touse = e(sample)
		
		
		mata: ds = _f_stepvif("`hhvars'","Whh",3,"touse")
	
		local hhvars `vifvar'
			
		sae model h3 bcy `hhvars' [aw=Whh], area(HID_mun)
		global hhCmodel `hhvars'			
		
		local unico $hhCmodel $amodel hhsize	
		local unico: list uniq unico
		global toimport `unico'		
	cap gen popw = Whh*hhsize	
	
	if (`iter'==1) save "$simdata\svy`simnum'.dta", replace	
		
	clear 
	set obs 1
	gen hhmodel = "$hhCmodel"
	gen amodel  = "$amodel"
	gen sample  = `sample'
	
	if (`sample'==1) save "$simdata\models.dta", replace
	else{
		append using "$simdata\models.dta"
		save "$simdata\models.dta", replace
	}
