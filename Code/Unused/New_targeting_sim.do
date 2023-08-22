//Quick and dirty PMT sim
set more off
clear all

//Data
global dpath    "C:\Users\WB378870\GitHub\Poverty-Mapping\Data"
global models   "C:\Users\WB378870\OneDrive\WPS_2020\999.Survey Sim\0.data\simdata\models.dta"
global main     "C:\Users\\`c(username)'\GitHub\Poverty-Mapping\"
global inpath   "$main/Results"
global outpath  "$main/Manuscript"
global sae      "C:\Users\WB378870\GitHub\Poverty-Mapping\Results\eb.csv"
global direct   "C:\Users\WB378870\GitHub\Poverty-Mapping\Data\direct_mun.csv"
global true     "C:\Users\WB378870\GitHub\Poverty-Mapping\Data\true_mun.csv"

*SAE
import delimited using "$sae", clear
keep muni yhat_1

rename muni HID_mun
tempfile sae
save `sae'


*Direct
import delimited using "$direct", clear

rename muni HID_mun
keep if sim_sample==1

tempfile direct
save `direct'

*===============================================================================
// Simulate impact of SAE on PMT
//1. Get PMT
*===============================================================================
local iter=1
use "$models", clear
keep in 1
	
	forval z=1/1{
		local todo `todo' `=hhmodel[`z']' `=amodel[`z']'
		local todo : list uniq todo
	}
	global toimport `todo'
	local remove HID_age_hh HID_cellphone mun_age_hh mun_sewage_pub mun_television HID_hhsize HID_max_tertiary mun_share_elderly
	local todo: list todo - remove

	
	use "$dpath/census_trim.dta", clear
	keep hhid HID_mun HID hhsize $toimport poor gap gap2 e_y lny state
	
	tempfile censo
	save `censo'

use "$models", clear
global hhCmodel `todo'
	
*===============================================================================
// CREATE THE SURVEY!
*===============================================================================
	
use "$dpath/my_samples_pps_psu@.dta" if sim_sample==1, clear
	merge 1:1 hhid using `censo'
		keep if _m==3
		drop _m
cap gen popw = Whh*hhsize

tempfile survey
save `survey'
sort lny
cap gen popw = Whh*hhsize
gen rank = sum(popw)
sum popw
local dem = r(sum)
gen double bcy = invnorm(((rank - 0.5)/`dem'))

*===============================================================================
// PMT Formula
*===============================================================================
reg bcy $hhCmodel [aw=Whh],r
predict xb, xb
merge m:1 HID_mun using `direct'
	drop if _m==2
	drop _m
gen double mystate = int(HID_mun/1e4)
groupfunction [aw=popw], mean(dpoor) by(mystate)
tempfile cutoff
save `cutoff'
*================================================================================
//Bring in the census and get the recipients
*=================================================================================
use `censo', clear
predict xb, xb

gen double mystate = int(HID_mun/1e4)

	merge m:1 mystate using `cutoff'
		drop if _m==2
		drop _m

_pctile xb [aw=hhsize], p(25)

gen PMT_national = xb<r(r1)

gen reg_cutoff = 0
levelsof mystate, local(thestate)
foreach x of local thestate{
	sum dpoor if mystate==`x'
	_pctile xb if mystate==`x' [aw=hhsize], p(`=r(mean)*100')
	replace reg_cutoff = r(r1) if mystate==`x'
}

gen PMT_regional = xb < reg_cutoff

//Now use the poverty maps...
merge m:1 HID_mun using `sae'
	drop if _m==2
	drop _m


gen mun_cutoff = 0
levelsof HID_mun, local(mymun)
foreach x of local mymun{
	sum yhat_1 if HID_mun==`x'
	_pctile xb if HID_mun==`x' [aw=hhsize], p(`=r(mean)*100')
	replace mun_cutoff = r(r1) if HID_mun==`x'
}

gen PMT_mun = xb < mun_cutoff

xtile TenQ = lny [aw=hhsize], nq(10)

sp_groupfunction [aw=hhsize], coverage(PMT_*) by(TenQ)

export excel using "C:\Users\WB378870\Downloads\PMT_sim.xlsx", first(variables) replace








	


