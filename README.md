# Poverty Mapping and Machine Learning

Below is a list of the scripts created for this project and a description of each:

(1) bart_mun.r: Implements BART for the municipality-level data and generates predictions for each sample. Also includes an illustration that calculates uncertainty intervals for the predictions. 

	Dependencies: bart, matrixStats

	Inputs: 
		~/Data/svydata_mun.csv
		~/Data/xmatrix_mun.csv

	Outputs: 
		~/Results/bart_census_mun.csv
		~/Results/bart_gis_mun.csv
		~/Results/bart_all_mun.csv

(2) bart_plots.r: Summarizes and plots the mean squared error and bias for the BART simulations. The plots compare the results of BART relative to the brute force grid search implementation of xgboost (baseline).

	Dependencies: None

	Inputs:
		~/Data/true_mun.csv
		~/Data/true_psu.csv
		~/Results/bart_census_mun.csv
		~/Results/bart_gis_mun.csv
		~/Results/bart_all_mun.csv
		~/Results/bart_census_psu.csv
		~/Results/baseline_census_mun.csv
		~/Results/baseline_gis_mun.csv
		~/Results/baseline_all_mun.csv
		~/Results/baseline_census_psu.csv

	Outputs: Generates plots without saving

(3) bart_psu.r: Implements BART for the PSU-level data and generates predictions for each sample. Also includes an illustration that calculates uncertainty intervals for the predictions. 

	Dependencies: bart, matrixStats, dplyr

	Inputs:
		~/Data/svydata_python_psu.csv
		~/Data/xmatrix_python_psu.csv
	
	Outputs:
		~/Results/bart_census_psu.csv

(4) rsquared.py: Calculates r-squared values from regressions of true poverty headcounts on various estimates of poverty headcounts. All regressions are at the PSU level.

	Dependencies: pandas, numpy, statsmodels 

	Inputs:
		~/Data/true_psu.csv
		~/Data/direct_psu.csv
		~/Results/hyperopt_census_psu.csv
	
	Outputs: Generates results without saving

(5) targeting.do: Conducts targeting exercises to examine the implications of using different poverty  maps/estimates for distributing assistance. All exercises are at the municipality level.

	Dependencies: gtools

	Inputs:
		~/Data/census_trim.dta
		~/Results/hyperopt_census_mun.csv
	
	Outputs: Generates results without saving

(6) xgboost_hh.py: Implements the directed hyperparameter search (hyperopt) for the household-level data. Generates predictions for each sample. 

	Dependencies: xgboost, numpy, pandas, sklearn, hyperopt, time

	Inputs:
		~/Data/census_trim.dta
		~/Data/my_samples_pps_psu@.dta

	Outputs:
		~/Results/hyperopt_census_hh.csv

(7) xgboost_mun.py: Implements the directed hyperparameter search (hyperopt) for the municipality-level data. Generates predictions and feature importances for each sample. 

	Dependencies: xgboost, numpy, pandas, sklearn, hyperopt, time

	Inputs: 
		~/Data/svydata_mun.csv
		~/Data/xmatrix_mun.csv

	Outputs: 
		~/Results/hyperopt_census_mun.csv
		~/Results/hyperopt_gis_mun.csv
		~/Results/hyperopt_all_mun.csv
		~/Results/importance_census_mun.csv
		~/Results/importance_gis_mun.csv
		~/Results/importance_all_mun.csv

(8) xgboost_plots.py: Summarizes and plots the mean squared error, bias, and feature importance for the xgboost simulations. The mean squared error and bias plots compare the results of the hyperopt implementation to the brute force grid search (baseline).

	Dependencies: matplotlib, pandas, numpy 

	Inputs:
		~/Data/true_mun.csv
		~/Data/true_psu.csv
		~/Results/hyperopt_census_mun.csv
		~/Results/hyperopt_gis_mun.csv
		~/Results/hyperopt_all_mun.csv
		~/Results/hyperopt_census_psu.csv
		~/Results/baseline_census_mun.csv
		~/Results/baseline_gis_mun.csv
		~/Results/baseline_all_mun.csv
		~/Results/baseline_census_psu.csv
		~/Results/importance_census_mun.csv
		~/Results/importance_gis_mun.csv
		~/Results/importance_all_mun.csv
		~/Results/importance_census_psu.csv

	Outputs: Creates plots without saving

(9) xgboost_psu.py: Implements the directed hyperparameter search (hyperopt) for the PSU-level data. Generates predictions and feature importances for each sample. 

	Dependencies: xgboost, numpy, pandas, sklearn, hyperopt, time

	Inputs:
		~/Data/svydata_python_psu.csv
		~/Data/xmatrix_python_psu.csv

	Outputs:
		~/Results/hyperopt_census_psu.csv
		~/Results/hyperopt_census_psu(disaggregated).csv
		~/Results/importance_census_psu.csv











 
