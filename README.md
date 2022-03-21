# Poverty Mapping in the Age of Machine Learning

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

(2) bart_psu.r: Implements BART for the PSU-level data and generates predictions for each sample. Also includes an illustration that calculates uncertainty intervals for the predictions. 

	Dependencies: bart, matrixStats, dplyr

	Inputs:
		~/Data/svydata_python_psu.csv
		~/Data/xmatrix_python_psu.csv
	
	Outputs:
		~/Results/bart_census_psu.csv

(3) plots.py: Summarizes and plots the mean squared error and bias for gradient boosting, BART, and random forest. 

	Dependencies: matplotlib, pandas, numpy 

	Inputs:
		~/Data/true_mun.csv
		~/Results/hyperopt_census_mun.csv
		~/Results/hyperopt_gis_mun.csv
		~/Results/hyperopt_all_mun.csv
		~/Results/hyperopt_census_psu.csv
		~/Results/bart_census_mun.csv
		~/Results/bart_gis_mun.csv
		~/Results/bart_all_mun.csv
		~/Results/bart_census_psu.csv
		~/Results/rf_census_mun.csv
		~/Results/rf_gis_mun.csv
		~/Results/rf_all_mun.csv
		~/Results/rf_census_psu.csv

	Outputs: Creates plots without saving

(4) rf_mun.r: Implements random forest for the municipality-level data. Generates predictions and feature importances for each sample.  

	Dependencies: numpy, pandas, sklearn, hyperopt, time

	Inputs: 
		~/Data/svydata_mun.csv
		~/Data/xmatrix_mun.csv

	Outputs: 
		~/Results/rf_census_mun.csv
		~/Results/rf_gis_mun.csv
		~/Results/rf_all_mun.csv
		~/Results/rf_importance_census_mun.csv
		~/Results/rf_importance_gis_mun.csv
		~/Results/rf_importance_all_mun.csv


(5) rf_psu.r: Implements random forest for the PSU-level data. Generates predictions and feature importances for each sample.  

	Dependencies: numpy, pandas, sklearn, hyperopt, time

	Inputs:
		~/Data/svydata_python_psu.csv
		~/Data/xmatrix_python_psu.csv
	
	Outputs:
		~/Results/rf_census_psu.csv
		~/Results/rf_census_psu(disaggregated).csv
		~/Results/rf_importance_census_psu.csv

(6) rsquared_mun.py: Calculates r-squared values from regressions of true poverty headcounts on various estimates of poverty headcounts. All regressions are at the municipality level.

	Dependencies: pandas, numpy, statsmodels 

	Inputs:
		~/Data/true_mun.csv
		~/Data/direct_mun.csv
		~/Results/hyperopt_census_mun.csv
		~/Results/hyperopt_gis_mun.csv
		~/Results/hyperopt_census_mun.csv
		~/Results/hyperopt_census_psu.csv
		~/Results/hyperopt_census_hh.csv
	
	Outputs: Generates results without saving

(7) rsquared_psu.py: Calculates r-squared values from regressions of true poverty headcounts on various estimates of poverty headcounts. All regressions are at the PSU level.

	Dependencies: pandas, numpy, statsmodels 

	Inputs:
		~/Data/true_psu.csv
		~/Data/direct_psu.csv
		~/Results/hyperopt_census_psu(disaggregated).csv
	
	Outputs: Generates results without saving

(8) targeting.do: Conducts targeting exercises to examine the implications of using different poverty maps/estimates for distributing assistance. All exercises are at the municipality level.

	Dependencies: gtools

	Inputs:
		~/Data/census_trim.dta
		~/Results/hyperopt_census_mun.csv
	
	Outputs: Generates results without saving

(9) xgboost_hh.py: Implements the directed hyperparameter search (hyperopt) for the household-level data. Generates predictions and feature importances for each sample. 

	Dependencies: xgboost, numpy, pandas, sklearn, hyperopt, time

	Inputs:
		~/Data/census_trim.dta
		~/Data/my_samples_pps_psu@.dta

	Outputs:
		~/Results/hyperopt_census_hh.csv
		~/Results/importance_census_hh.csv

(10) xgboost_mun.py: Implements the directed hyperparameter search (hyperopt) for the municipality-level data. Generates predictions and feature importances for each sample. 

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

(11) xgboost_psu.py: Implements the directed hyperparameter search (hyperopt) for the PSU-level data. Generates predictions and feature importances for each sample. 

	Dependencies: xgboost, numpy, pandas, sklearn, hyperopt, time

	Inputs:
		~/Data/svydata_python_psu.csv
		~/Data/xmatrix_python_psu.csv

	Outputs:
		~/Results/hyperopt_census_psu.csv
		~/Results/hyperopt_census_psu(disaggregated).csv
		~/Results/importance_census_psu.csv











 
