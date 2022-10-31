# Import libraries
import pandas as pd
import numpy as np

# Directory
#main    = 'C:/Users/Paul Corral/Documents/GitHub/Poverty-Mapping/'
main    = 'C:/Users/WB378870/GitHub/Poverty-Mapping/'
inpath  = main+'Data/'
outpath = main+'Results/'

# Import true poverty indicators
true = pd.read_csv(inpath + 'true_mun.csv', header = 0)
true = true.rename(columns={'mimun': 'muni'})
true = true[['muni', 'poor']]

# Calculate MSE and bias
mse = true['muni']
bias = true['muni']
model = ['gb_census_mun', 'gb_gis_mun', 'gb_all_mun', 'gb_census_psu',  
         'bart_census_mun', 'bart_gis_mun', 'bart_all_mun', 'bart_census_psu', 
         'rf_census_mun', 'rf_gis_mun', 'rf_all_mun', 'rf_census_psu', 
         'lasso_census_mun', 'lasso_gis_mun', 'lasso_all_mun', 'lasso_census_psu', 
         'ols_census_mun', 'ols_gis_mun', 'ols_all_mun', 'ols_census_psu', 'gb_census_hhid_demo', 'gb_census_psu_wc']
for i in model:
    yhat = pd.read_csv(outpath + i + '.csv', header = 0)
    yhat = pd.merge(yhat, true)
    results = pd.DataFrame()
    for j in range(1,501):
        name = 'yhat_' + str(j)
        res = (yhat[name] - yhat['poor'])**2
        results = pd.concat((results, res), axis = 1)    
    temp =  np.mean(results, axis = 1)   
    mse = pd.concat((mse, temp), axis = 1)  
    temp = yhat.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - yhat.loc[:, 'poor']
    bias = pd.concat((bias, temp), axis = 1)  

# Bring in results from traditional estimators 
trad = pd.read_stata(inpath + 'accumulate_results.dta')
mse_eb = trad[trad['method'] == 'h3no']['fgt0_mse']
mse_eb.reset_index(drop=True, inplace=True)
mse_uc = trad[trad['method'] == 'uceb']['fgt0_mse']
bias_eb = trad[trad['method'] == 'h3no']['fgt0_bias_reg']
bias_eb.reset_index(drop=True, inplace=True)
bias_uc = trad[trad['method'] == 'uceb']['fgt0_bias_reg']
mse = pd.concat((mse, mse_eb, mse_uc), axis = 1) 
bias = pd.concat((bias, bias_eb, bias_uc), axis = 1)  

# Label columns
mse.columns = ['muni', 'mse_gb_census',' mse_gb_gis', 'mse_gb_all', 'mse_gb_psu',
               'mse_bart_census', 'mse_bart_gis', 'mse_bart_all', 'mse_bart_psu',
               'mse_rf_census', 'mse_rf_gis', 'mse_rf_all', 'mse_rf_psu',
               'mse_lasso_census', 'mse_lasso_gis', 'mse_lasso_all', 'mse_lasso_psu',
               'mse_ols_census', 'mse_ols_gis', 'mse_ols_all', 'mse_ols_psu', 'mse_gb_hhid_demo', 'mse_gb_psu_wc',
               'mse_eb', 'mse_uc']
bias.columns = ['muni', 'bias_gb_census',' bias_gb_gis', 'bias_gb_all', 'bias_gb_psu',
               'bias_bart_census', 'bias_bart_gis', 'bias_bart_all', 'bias_bart_psu',
               'bias_rf_census', 'bias_rf_gis', 'bias_rf_all', 'bias_rf_psu',
               'bias_lasso_census', 'bias_lasso_gis', 'bias_lasso_all', 'bias_lasso_psu',
               'bias_ols_census', 'bias_ols_gis', 'bias_ols_all', 'bias_ols_psu', 'bias_gb_hhid_demo', 'bias_gb_psu_wc',
               'bias_eb', 'bias_uc']

# Save results
mse.to_csv(outpath + 'results_mse.csv', index = False)
bias.to_csv(outpath + 'results_bias.csv', index = False)


