This folder contains the do-files for the traditional SAE methods implemented in the paper. 
The ado files for the codes used are available online, specifically:

1) https://github.com/pcorralrodas/SAE-Stata-Package
2) https://github.com/jpazvd/fhsae
3) https://github.com/jpazvd/groupfunction

For unit-level models:
1) The results for unit level area models are obtained from:
	- Simulation19.do runs "qnorm_model_select_comp_xgboost" and "random_sim_xgboost"
		- File names means they're comparably run to xgboost in the sense that
		  under each sample a new model is selected.
	- the simulation takes quite a bit of time to complete (about a week or so)
	- I recommend you first run the selection in its entirety (500 sims), and then
	  run the models - qnorm_model_select_comp_xgboost.do
2) The results for area level models are obtained from:
	- FH estimation - does the model at the PSU level and aggregates to mun level
	- FH estimation mun - does model and results at mun level
	- FH estimation mun GIS - does model and results at mun level using only GIS covariates
