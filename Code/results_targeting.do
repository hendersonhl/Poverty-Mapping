*==========================================
* Program setup
*==========================================

* Install gtools for faster sorting
* ssc install gtools

* Set up
clear all
set more off
set matsize 11000

* Set file paths
global inpath "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data"
global outpath "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results"

* Define function to distribute transfers
* Note: The arguments for the function are: the muncipality identifier, 
* municipality poverty rates, household sizes, the transfer amount, the 
* number of people that can be treated for a given budget, and the populaion
* for each municipality. 
capture program drop distribute
program define distribute
    args muni prate hhsize transfer people pop
	
	* Initial distribution 
	* Note: Here we sort municipalities by poverty rates and distribute 
	* to the poorest municipalities, ignoring that some HHs in the marginal
	* municipality will receive a transfer and some will not.
	qui hashsort -`prate' `muni'     
	qui gen cumsum = sum(`hhsize')  
	qui gen amount = hhsize * `transfer' if cumsum <= `people'
	
	* Adjustment to marginal municipality
	* Note: Here we redistribute any transfers given to the marginal 
	* municipality to be shared equally among all HHs in that municipality.
	* The marginal municipality will be the one with only a fraction of HHs
	* receiving transfers.
	qui bysort `muni': gegen treated = total(sign(amount) / _N)
    qui bysort `muni': egen cumamt = total(amount)
    qui replace amount = `hhsize' * (cumamt/`pop') if treated > 0 & treated < 1

	* Update income per capita
	qui replace amount = 0 if amount==.
    qui gen incpc_new = incpc + amount/`hhsize'
	drop cumsum treated cumamt amount

end

*==========================================
* Lowest achievable poverty rate
*==========================================

* Open census data and create select variables
use $inpath/census_trim.dta, clear
rename HID_mun muni
label var muni "Municipality identifier"
rename e_y incpc
label var incpc "Income per capita (pre-transfer)"   
bysort muni: egen pop = total(hhsize)  
label var pop "Municipality population"
order muni incpc hhsize pop poor
keep muni-pop

* Set poverty line
sum incpc [aw=hhsize], detail
global pline = `r(p25)'    // Poverty line at 25th percentile

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
* Poverty reductions for all models
*==========================================

* Prep results from traditional estimators
preserve
use "$inpath/h3no19.dta", clear   // EB results
keep Unit avg_fgt0 nsim
rename Unit muni
rename avg_fgt0 yhat
rename nsim sim_sample
order muni sim_sample yhat
sort muni sim_sample
reshape wide yhat, i(muni) j(sim_sample)
rename yhat* yhat_*
outsheet using "$outpath/eb.csv", comma replace
use "$inpath/uceb19.dta", clear   // Unit-context results
keep Unit avg_fgt0 nsim
rename Unit muni
rename avg_fgt0 yhat
rename nsim sim_sample
order muni sim_sample yhat
sort muni sim_sample
reshape wide yhat, i(muni) j(sim_sample)
rename yhat* yhat_*
outsheet using "$outpath/uc.csv", comma replace
restore

* Set up loop
local model gb_census_mun gb_gis_mun gb_all_mun gb_census_psu ///
    bart_census_mun bart_gis_mun bart_all_mun bart_census_psu ///
	rf_census_mun rf_gis_mun rf_all_mun rf_census_psu ///
	lasso_census_mun lasso_gis_mun lasso_all_mun lasso_census_psu ///
	ols_census_mun ols_gis_mun ols_all_mun ols_census_psu eb uc
matrix results = J(500, 22, .)
matrix colnames results = `model'

* Loop over models
foreach i of local model {
	
	* Start timer
    timer clear 1
    timer on 1
	
	* Store results from each model
    preserve      
    import delimited "$outpath/`i'.csv", clear 
    sort muni 
    tempfile results 
    save `results'
    restore
	
	* Calculate results for each sample
    forvalues j = 1/500 {    // Only do 3 iterations as an illustration
	    disp "***** Beginning iteration `j' for `i' *****"
		merge m:1 muni using `results', keepusing(yhat_`j') // Merge in estimates
        drop _merge
        distribute muni yhat_`j' hhsize $transfer $people pop  // Distribute transfers
	    gen poor = (incpc_new <= $pline)   // Calculate post-transfer poverty
        qui sum poor [aw = hhsize]
	    matrix results[`j', colnumb(results, "`i'")] = `r(mean)' 
	    drop poor incpc_new	yhat_`j'
     }
	 
	 * Print computation time
	 timer off 1
     timer list 1
}

* Save results
clear
svmat results, names(col)
gen sim_sample = _n
order sim_sample
outsheet using "$outpath/results_targeting_500_june07.csv", comma replace
 









