# Poverty-Mapping

Below is a list of the scripts created for this project and a description of each:

(1) hh_xgboost_mun.py: Implements the directed hyperparameter search (hyperopt) for the municipality-level data. Generates predictions and feature importances for each sample. 

	Dependencies: xgboost, numpy, pandas, sklearn, hyperopt, time
	Inputs: 
		~/xgboost/01_data/intermediate/svydata_mun.csv
		~/xgboost/01_data/intermediate/xmatrix_mun.csv
	Outputs: 
		~/Results/hyperopt_census_mun.csv
		~/Results/hyperopt_gis_mun.csv
		~/Results/hyperopt_all_mun.csv
		~/Results/importance_census_mun.csv
		~/Results/importance_gis_mun.csv
		~/Results/importance_all_mun.csv

(2) hh_xgboost_psu.py: Implements the directed hyperparameter search (hyperopt) for the PSU-level data. Generates predictions and feature importances for each sample. 

	Dependencies: xgboost, numpy, pandas, sklearn, hyperopt, time
	Inputs:
		~/xgboost/01_data/intermediate/svydata_python_psu.csv
		~/xgboost/01_data/intermediate/xmatrix_python_psu.csv
	Outputs:
		~/Results/hyperopt_census_psu.csv
		~/Results/importance_census_psu.csv

(3) hh_plots_xgboost.py: Summarizes and plots the mean squared error, bias, and feature importance for the xgboost simulations. The mean squared error and bias plots compare the results of the hyperopt implementation to the brute force grid search (baseline).

	Dependencies: matplotlib, pandas, numpy 

	Inputs:
		~/Results/true_mun.csv
		~/Results/true_psu.csv
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

(4) hh_bart_mun.r: Implements BART for the municipality-level data and generates predictions for each sample. Also includes an illustration that calculates uncertainty intervals for the predictions. 

	Dependencies: bart, matrixStats

	Inputs: 
		~/xgboost/01_data/intermediate/svydata_mun.csv
		~/xgboost/01_data/intermediate/xmatrix_mun.csv

	Outputs: 
		~/Results/bart_census_mun.csv
		~/Results/bart_gis_mun.csv
		~/Results/bart_all_mun.csv

(5) hh_bart_psu.r: Implements BART for the PSU-level data and generates predictions for each sample. Also includes an illustration that calculates uncertainty intervals for the predictions. 

	Dependencies: bart, matrixStats

	Inputs:
		~/xgboost/01_data/intermediate/svydata_python_psu.csv
		~/xgboost/01_data/intermediate/xmatrix_python_psu.csv
	
	Outputs:
		~/Results/bart_census_psu.csv

(6) hh_plots_bart.r: Summarizes and plots the mean squared error and bias for the BART simulations. The plots compare the results of BART relative to the brute force grid search implementation of xgboost (baseline).

	Dependencies: None

	Inputs:
		~/Results/true_mun.csv
		~/Results/true_psu.csv
		~/Results/bart_census_mun.csv
		~/Results/bart_gis_mun.csv
		~/Results/bart_all_mun.csv
		~/Results/bart_census_psu.csv
		~/Results/baseline_census_mun.csv
		~/Results/baseline_gis_mun.csv
		~/Results/baseline_all_mun.csv
		~/Results/baseline_census_psu.csv

	Outputs: Creates plots without saving

 
