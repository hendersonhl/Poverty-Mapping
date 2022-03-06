*==========================================
* Program setup
*==========================================

* Install gtools for faster sorting
* ssc install gtools

* Set up
clear all
set more off

* Set globals
if (lower("`c(username)'")=="paul corral") global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
if (lower("`c(username)'")=="hendersonhl") global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"

global inpath "$main/Data/"
global outpath "$main/Results/"

*=========================================================================
//Bring in the data for "ideal transfer"
*=========================================================================
* Open census data and create select variables
use "$inpath/census_trim.dta", clear
	rename HID_mun muni
	label var muni "Municipality identifier"
	//Poverty line is the 25th percentile
	sum e_y [aw=hhsize], d
	global pline = r(p25)
	rename e_y incpc
	label var incpc "Income per capita (pre-transfer)" 
keep muni incpc hhsize 

	//Gen poverty rates and gaps
	forval a=0/2{
		gen fgt`a' = (incpc<$pline)*(1 - incpc/$pline)^`a'
	}

	sum fgt1 [aw=hhsize]
	global budget = `r(mean)'*$pline*`r(sum_w)'
	sum fgt0 [aw=hhsize]
	global transfer_pc = $budget/r(sum) 

tempfile pretrans
save `pretrans'

//Leave data at muni level	
groupfunction [aw=hhsize], mean(fgt0 fgt1 fgt2 incpc) rawsum(hhsize) by(muni)
rename hhsize pop

	//Alrighty begin the transfer
	gsort -fgt0
	gen double transfer = pop*$transfer_pc
	gen double cummul=sum(transfer)
	//Indicate over budget
	gen double overbudget= cummul>$budget & cummul!=.
	replace transfer=0 if overbudget==1
	gen double budgetleft= ($budget-cummul)*(($budget-cummul)>0)
	//Places the transfer budget for the municipality at the margin
	replace transfer=budgetleft[_n-1] if budgetleft==0 & budgetleft[_n-1]>0
	replace transfer = transfer/pop
	lab var transfer "transfer per capita for the municipality"
tempfile idealtrans
save `idealtrans'
*=========================================================================
//Bring in the transfer to the Census population and get new poverty rates
*=========================================================================
use `pretrans', clear
	merge m:1 muni using `idealtrans', keepusing(transfer)
		drop if _m==2
		drop _m
		
	egen double incpc_trans = rsum(incpc transfer)
	
gen pline = $pline
gen all=1
sp_groupfunction [aw=hhsize], poverty(incpc_trans incpc) povertyline(pline) by(all)

//Best output
list
tempfile idealresult
save `idealresult'

*=========================================================================
//Ok, now to the model based estimates...
*=========================================================================
import delimited "$outpath/hyperopt_census_mun.csv", clear 
	//include population
	merge 1:1 muni using `idealtrans', keepusing(pop)
		drop if _m==2
		drop _m
	forval z=1/500{
		qui{
		gsort -yhat_`z'
		gen double transfer = pop*$transfer_pc
		gen double cummul=sum(transfer)
		//Indicate over budget
		gen double overbudget= cummul>$budget & cummul!=.
		replace transfer=0 if overbudget==1
		gen double budgetleft= ($budget-cummul)*(($budget-cummul)>0)
		//Places the transfer budget for the municipality at the margin
		replace transfer=budgetleft[_n-1] if budgetleft==0 & budgetleft[_n-1]>0
		replace transfer = transfer/pop
		replace yhat_`z' = transfer
		drop transfer cummul overbudget budgetleft
		}
	}
	
tempfile xgboost
save `xgboost'
*=========================================================================
//Bring in the transfer to the Census population and get new poverty rates
*=========================================================================
use `pretrans', clear
	merge m:1 muni using `xgboost', keepusing(yhat*)
		drop if _m==2
		drop _m
		
	forval z = 1/500{
		qui:replace yhat_`z' = yhat_`z' + incpc
	}
	
gen pline = $pline
gen all=1
keep hhsize yhat_*

putmata Y = (yhat_*), replace
putmata wt = hhsize, replace
local pline = $pline
count 
local top = r(N)
clear
mata:
wt = wt/quadsum(wt)
Y  = (1:-(Y:/`pline'))
fgt0 = quadcolsum((Y:>0):*wt)
fgt1 = quadcolsum(Y:*(Y:>0):*wt)
fgt2 = quadcolsum(Y:*Y:*(Y:>0):*wt)

//Poverty
mean((fgt0\fgt1\fgt2)')

end




