# Poverty Mapping in the Age of Machine Learning

All code for this project is located in the "Code" folder. There are two types of scripts. First, there are several scripts whose file name is a combination of a method name and some unit of analysis. These scripts implement the corresponding method at the listed unit of analysis. For example, "xgboost_mun.py" implements gradient boosting using data at the municipality level. There are scripts for Bayesian additive regression trees, lasso, ordinary least squares, random forest, and gradient boosting. Each method is implemented at the municipality and PSU level.

Second, there are several scripts that aggregate the results from the various methods. The script "results_mse.py" calculates the mean squared error and bias for each method, "results_plots.do" generates select plots, "results_rsquared.py" calculates the R-squared from regressions of the true poverty indicators on the predictions from various methods, and 
"results_targeting.do" implements the targeting simulations.

To run any script, the user only needs to change the file paths at the top of each script and install any packages that the script depends on.

All the data used for the analysis is located in the "Data" folder. Two data files -- "census_trim.dta" and "my_samples_pps_pse@.dta" -- are too large to be uploaded to the repository and are available upon request. All results are located in the "Results" folder. The output from the various methods are in files named by combining the method name, the covariates used, and the level of analysis. For example, "gb_all_mun.csv" contains results from applying gradient boosting to the municipality-level data using all available covariates. There are also a number of files name "results_*.csv" and these files contain the above-mentioned aggregated results from the various methods.

Finally, the "Manuscript" folder contains the files that generate the manuscript, including the .bib file and all figures.



