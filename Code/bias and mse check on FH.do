set more off 
clear all

* Set globals
if (lower("`c(username)'")=="wb378870")    global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="paul corral") global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
if (lower("`c(username)'")=="hendersonhl") global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"

global inpath "$main/Data/"
global outpath "$main/Results/"

import delimited using "$inpath/true_mun.csv", clear
keep mimun poor
rename mimun area

merge 1:m area using "$outpath\FH_results.dta", keepusing(estimate)


gen mse  = (estimate - poor)^2
gen bias = estimate - poor

sp_groupfunction, mean(mse bias) by(area)

replace variable = "bias_fh" if variable=="bias"
replace variable = "mse_fh" if variable=="mse"


tempfile uno
save `uno'

import delimited using "$outpath\results_for_tableau_mse_bias.csv", clear

sum value if variable=="bias_uc",d
sum value if variable=="mse_uc",d

gen double area = real(muni)

keep if regexm(variable,"_uc")

append using `uno'

graph hbox value if regexm(variable, "bias"), over(variable)
graph hbox value if regexm(variable, "mse"), over(variable) noout

	
	
