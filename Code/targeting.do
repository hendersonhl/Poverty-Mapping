*==========================================
* Program setup
*==========================================

* Set up
clear all
set more off

* Set globals
global inpath "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data/"
global outpath "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results/"
global pline = 715

* Define function to distribute transfers
* Note: The arguments for the function are: the muncipality identifier, 
* municipality poverty rates, household sizes, the transfer amount, the 
* number of people that can be treated for a given budget, and the populaion
* for each municipality. 
capture program drop distribute
program define distribute
    version 17.0
    args muni prate hhsize transfer people pop
	
	* Initial distribution 
	* Note: Here we sort municipalities by poverty rates and distribute 
	* to the poorest municipalities, ignoring that some HHs in the marginal
	* municipality will receive a transfer and some will not.
	gsort -`prate' `muni'     
	gen cumsum = sum(`hhsize')  
	gen amount = hhsize * `transfer' if cumsum <= `people'
	
	* Adjustment to marginal municipality
	* Note: Here we redistribute any transfers given to the marginal 
	* municipality to be shared equally among all HHs in that municipality.
	* The marginal municipality will be the one with only a fraction of HHs
	* receiving transfers.
	bysort `muni': egen treated = count(amount)
    bysort `muni': replace treated = treated/_N
    bysort `muni': egen cumamt = total(amount)
    replace amount = `hhsize' * (cumamt/`pop') if treated > 0 & treated < 1

	* Update income per capita
	replace amount = 0 if amount==.
    gen incpc_new = incpc + amount/`hhsize'
	drop cumsum treated cumamt amount

end

*==========================================
* Lowest achievable poverty rate
*==========================================

* Open census data and create select variables
use $inpath/census_trim.dta, clear
rename HID_mun muni
label var muni "Municipality identifier"
gen incpc = hhinc/hhsize  
label var incpc "Income per capita (pre-transfer)"   
bysort muni: egen pop = total(hhsize)  
label var pop "Municipality population"
order muni incpc hhsize pop poor
keep muni-pop

* Calculate budget and transfer amount
* Note: The budget is the total amount of money needed to eradicate income
* poverty. The transfer is the budget divided by the number of poor people.
* Finally, people is the total number of people that can be given transfers
* while staying within the budget.
gen fgt = ($pline - incpc)/$pline  
replace fgt = 0 if fgt < 0
qui sum fgt [aw = hhsize]      // Calculate poverty gap
global budget = `r(mean)' * $pline * `r(sum_w)'
replace fgt = 1 if fgt > 0         
qui sum fgt [aw = hhsize]     // Calculate poverty headcount
global prate_pre = `r(mean)'   // Pre-transfer poverty rate
global transfer = $budget/($prate_pre * `r(sum_w)')
global people = $budget/$transfer

* Lowest achievable poverty rate based on uniform transfer amount
replace fgt = fgt * hhsize
bysort muni: egen num_poor = total(fgt)
gen prate = num_poor/pop   // Municipality-level poverty rates
drop fgt num_poor
distribute muni prate hhsize $transfer $people pop  // Distribute transfers
gen poor = (incpc_new <= $pline)   // Calculate post-transfer poverty
qui sum poor [aw = hhsize]
global prate_low = `r(mean)'   // Lowest achievable poverty rate
drop prate poor incpc_new

*==========================================
* Poverty reductions based on xgboost
*==========================================

* Merge in xgboost estimates
* Note: This part is illustrative and only uses the xgboost results based
* on municipality-level data with the census covariates.
preserve      // Prepare for merging in xgboost estimates
import delimited "$outpath/hyperopt_census_mun.csv", clear 
sort muni 
tempfile xgboost
save `xgboost'
restore
sort muni
merge m:1 muni using `xgboost'   // Merge in xgboost estimates
drop _merge

* Calculate post-transfer poverty rates
matrix results = J(500, 1, .)
forvalues i = 1/3 {    // Only do 3 iterations as an illustration
	disp "************* Beginning iteration `i' *************"
    distribute muni yhat_`i' hhsize $transfer $people pop  // Distribute transfers
	gen poor = (incpc_new <= $pline)   // Calculate post-transfer poverty
    qui sum poor [aw = hhsize]
	matrix results[`i', 1] = `r(mean)'  // Store achieved poverty rates
	drop poor incpc_new	
}
drop yhat_*
matrix list results






