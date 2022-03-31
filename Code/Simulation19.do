set more off
clear all
set processors 8


// Replication of Molina and Rao's 2010 simulation - SAE Guidelines
global main "C:\Users\\`c(username)'\OneDrive\WPS_2020\999.Survey Sim\"
global dpath   "$main\0.data"
global simdata "$dpath\simdata\"
global thedo   "$main\1.dofiles\"


*===============================================================================
//Macros for inputs to the simulation
*===============================================================================
set seed 648265

global sim = 19
global bcox = 999
global thesamples "$dpath\my_samples_pps_psu@.dta"

*===============================================================================
//Simulations
*===============================================================================
global redo=0
local z = 456
global sample = 456

while (`z'<=500){
    sae_closefiles
	global zed = `z'
	
	dis as error "SIM `z'"
	// Can be random_sim, or random_sim_spec, or random_sim_spec2
	//run "$thedo\qnorm_model_select_comp_xgboost.do"
	run "$thedo\random_sim_xgboost.do"
	
	if ($redo==1)	local z= `z'
	else			local ++z
				
	global sample = $sample + 1
	
}
