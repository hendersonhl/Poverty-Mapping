# Import libraries
import pandas as pd
import numpy as np

# Directory
inpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data/'
outpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results/'

# Import true poverty indicators
true = pd.read_csv(inpath + 'true_mun.csv', header = 0)
true = true.rename(columns={'MiMun': 'muni'})
true = true[['muni', 'poor']]

# Import gradient boosting estimates and merge onto truth
gb_census = pd.read_csv(outpath + 'gb_census_mun.csv', header = 0)
gb_census = pd.merge(gb_census, true)
gb_gis = pd.read_csv(outpath + 'gb_gis_mun.csv', header = 0)
gb_gis = pd.merge(gb_gis, true)
gb_all = pd.read_csv(outpath + 'gb_all_mun.csv', header = 0)
gb_all = pd.merge(gb_all, true)
gb_psu = pd.read_csv(outpath + 'gb_census_psu.csv', header = 0)
gb_psu = pd.merge(gb_psu, true)

# Import BART estimates and merge onto truth
bart_census = pd.read_csv(outpath + 'bart_census_mun.csv', header = 0)
bart_census = pd.merge(bart_census, true)
bart_gis = pd.read_csv(outpath + 'bart_gis_mun.csv', header = 0)
bart_gis = pd.merge(bart_gis, true)
bart_all = pd.read_csv(outpath + 'bart_all_mun.csv', header = 0)
bart_all = pd.merge(bart_all, true)
bart_psu = pd.read_csv(outpath + 'bart_census_psu.csv', header = 0)
bart_psu = pd.merge(bart_psu, true)

# Import random forest estimates and merge onto truth
rf_census = pd.read_csv(outpath + 'rf_census_mun.csv', header = 0)
rf_census = pd.merge(rf_census, true)
rf_gis = pd.read_csv(outpath + 'rf_gis_mun.csv', header = 0)
rf_gis = pd.merge(rf_gis, true)
rf_all = pd.read_csv(outpath + 'rf_all_mun.csv', header = 0)
rf_all = pd.merge(rf_all, true)
rf_psu = pd.read_csv(outpath + 'rf_census_psu.csv', header = 0)
rf_psu = pd.merge(rf_psu, true)

# Import lasso estimates and merge onto truth
lasso_census = pd.read_csv(outpath + 'lasso_census_mun.csv', header = 0)
lasso_census = pd.merge(lasso_census, true)
lasso_gis = pd.read_csv(outpath + 'lasso_gis_mun.csv', header = 0)
lasso_gis = pd.merge(lasso_gis, true)
lasso_all = pd.read_csv(outpath + 'lasso_all_mun.csv', header = 0)
lasso_all = pd.merge(lasso_all, true)
lasso_psu = pd.read_csv(outpath + 'lasso_census_psu.csv', header = 0)
lasso_psu = pd.merge(lasso_psu, true)

# Import OLS estimates and merge onto truth
ols_census = pd.read_csv(outpath + 'ols_census_mun.csv', header = 0)
ols_census = pd.merge(ols_census, true)
ols_gis = pd.read_csv(outpath + 'ols_gis_mun.csv', header = 0)
ols_gis = pd.merge(ols_gis, true)
ols_all = pd.read_csv(outpath + 'ols_all_mun.csv', header = 0)
ols_all = pd.merge(ols_all, true)
ols_psu = pd.read_csv(outpath + 'ols_census_psu.csv', header = 0)
ols_psu = pd.merge(ols_psu, true)

# Calculate MSE and bias for gradient boosting results
mse_gb = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (gb_census[name] - gb_census['poor'])**2
    mse_gb = pd.concat((mse_gb, mse), axis = 1)    
mse_gb_census = np.mean(mse_gb, axis = 1)
bias_gb_census = gb_census.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - gb_census.loc[:, 'poor']

mse_gb = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (gb_gis[name] - gb_gis['poor'])**2
    mse_gb = pd.concat((mse_gb, mse), axis = 1)    
mse_gb_gis = np.mean(mse_gb, axis = 1)
bias_gb_gis = gb_gis.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - gb_gis.loc[:, 'poor']

mse_gb = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (gb_all[name] - gb_all['poor'])**2
    mse_gb = pd.concat((mse_gb, mse), axis = 1)    
mse_gb_all = np.mean(mse_gb, axis = 1)
bias_gb_all = gb_gis.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - gb_gis.loc[:, 'poor']

mse_gb = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (gb_psu[name] - gb_psu['poor'])**2
    mse_gb = pd.concat((mse_gb, mse), axis = 1)    
mse_gb_psu = np.mean(mse_gb, axis = 1)
bias_gb_psu = gb_psu.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - gb_psu.loc[:, 'poor']

# Calculate MSE and bias for BART results
mse_bart = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (bart_census[name] - bart_census['poor'])**2
    mse_bart = pd.concat((mse_bart, mse), axis = 1)    
mse_bart_census = np.mean(mse_bart, axis = 1)
bias_bart_census = bart_census.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - bart_census.loc[:, 'poor']

mse_bart = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (bart_gis[name] - bart_gis['poor'])**2
    mse_bart = pd.concat((mse_bart, mse), axis = 1)    
mse_bart_gis = np.mean(mse_bart, axis = 1)
bias_bart_gis = bart_gis.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - bart_gis.loc[:, 'poor']

mse_bart = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (bart_all[name] - bart_all['poor'])**2
    mse_bart = pd.concat((mse_bart, mse), axis = 1)    
mse_bart_all = np.mean(mse_bart, axis = 1)
bias_bart_all = bart_all.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - bart_all.loc[:, 'poor']

mse_bart = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (bart_psu[name] - bart_psu['poor'])**2
    mse_bart = pd.concat((mse_bart, mse), axis = 1)    
mse_bart_psu = np.mean(mse_bart, axis = 1)
bias_bart_psu = bart_psu.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - bart_psu.loc[:, 'poor']

# Calculate MSE and bias for random forest results
mse_rf = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (rf_census[name] - rf_census['poor'])**2
    mse_rf = pd.concat((mse_rf, mse), axis = 1)    
mse_rf_census = np.mean(mse_rf, axis = 1)
bias_rf_census = rf_census.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - rf_census.loc[:, 'poor']

mse_rf = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (rf_gis[name] - rf_gis['poor'])**2
    mse_rf = pd.concat((mse_rf, mse), axis = 1)    
mse_rf_gis = np.mean(mse_rf, axis = 1)
bias_rf_gis = rf_gis.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - rf_gis.loc[:, 'poor']

mse_rf = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (rf_all[name] - rf_all['poor'])**2
    mse_rf = pd.concat((mse_rf, mse), axis = 1)    
mse_rf_all = np.mean(mse_rf, axis = 1)
bias_rf_all = rf_all.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - rf_all.loc[:, 'poor']

mse_rf = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (rf_psu[name] - rf_psu['poor'])**2
    mse_rf = pd.concat((mse_rf, mse), axis = 1)    
mse_rf_psu = np.mean(mse_rf, axis = 1)
bias_rf_psu = rf_psu.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - rf_psu.loc[:, 'poor']

# Calculate MSE and bias for lasso results
mse_lasso = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (lasso_census[name] - lasso_census['poor'])**2
    mse_lasso = pd.concat((mse_lasso, mse), axis = 1)    
mse_lasso_census = np.mean(mse_lasso, axis = 1)
bias_lasso_census = lasso_census.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - lasso_census.loc[:, 'poor']

mse_lasso = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (lasso_gis[name] - lasso_gis['poor'])**2
    mse_lasso = pd.concat((mse_lasso, mse), axis = 1)    
mse_lasso_gis = np.mean(mse_lasso, axis = 1)
bias_lasso_gis = lasso_gis.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - lasso_gis.loc[:, 'poor']

mse_lasso = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (lasso_all[name] - lasso_all['poor'])**2
    mse_lasso = pd.concat((mse_lasso, mse), axis = 1)    
mse_lasso_all = np.mean(mse_lasso, axis = 1)
bias_lasso_all = lasso_all.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - lasso_all.loc[:, 'poor']

mse_lasso = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (lasso_psu[name] - lasso_psu['poor'])**2
    mse_lasso = pd.concat((mse_lasso, mse), axis = 1)    
mse_lasso_psu = np.mean(mse_lasso, axis = 1)
bias_lasso_psu = lasso_psu.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - lasso_psu.loc[:, 'poor']

# Calculate MSE and bias for OLS results
mse_ols = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (ols_census[name] - ols_census['poor'])**2
    mse_ols = pd.concat((mse_ols, mse), axis = 1)    
mse_ols_census = np.mean(mse_ols, axis = 1)
bias_ols_census = ols_census.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - ols_census.loc[:, 'poor']

mse_ols = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (ols_gis[name] - ols_gis['poor'])**2
    mse_ols = pd.concat((mse_ols, mse), axis = 1)    
mse_ols_gis = np.mean(mse_ols, axis = 1)
bias_ols_gis = ols_gis.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - ols_gis.loc[:, 'poor']

mse_ols = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (ols_all[name] - ols_all['poor'])**2
    mse_ols = pd.concat((mse_ols, mse), axis = 1)    
mse_ols_all = np.mean(mse_ols, axis = 1)
bias_ols_all = ols_all.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - ols_all.loc[:, 'poor']

mse_ols = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (ols_psu[name] - ols_psu['poor'])**2
    mse_ols = pd.concat((mse_ols, mse), axis = 1)    
mse_ols_psu = np.mean(mse_ols, axis = 1)
bias_ols_psu = ols_psu.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - ols_psu.loc[:, 'poor']

# Bring in results from traditional estimators 
trad = pd.read_stata(inpath + 'accumulate_results.dta')
mse_eb = trad[trad['method'] == 'h3no']['fgt0_mse']
mse_eb.reset_index(drop=True, inplace=True)
mse_uc = trad[trad['method'] == 'uceb']['fgt0_mse']
bias_eb = trad[trad['method'] == 'h3no']['fgt0_bias_reg']
bias_eb.reset_index(drop=True, inplace=True)
bias_uc = trad[trad['method'] == 'uceb']['fgt0_bias_reg']

# Combine MSE results
mse = true['muni']
mse = pd.concat([mse, mse_gb_census, mse_gb_gis, mse_gb_all, mse_gb_psu,
                 mse_bart_census, mse_bart_gis, mse_bart_all, mse_bart_psu,
                 mse_rf_census, mse_rf_gis, mse_rf_all, mse_rf_psu,
                 mse_lasso_census, mse_lasso_gis, mse_lasso_all, mse_lasso_psu,
                 mse_ols_census, mse_ols_gis, mse_ols_all, mse_ols_psu,
                 mse_eb, mse_uc], axis = 1, ignore_index = True)
mse.columns = ['muni', 'mse_gb_census',' mse_gb_gis', 'mse_gb_all', 'mse_gb_psu',
               'mse_bart_census', 'mse_bart_gis', 'mse_bart_all', 'mse_bart_psu',
               'mse_rf_census', 'mse_rf_gis', 'mse_rf_all', 'mse_rf_psu',
               'mse_lasso_census', 'mse_lasso_gis', 'mse_lasso_all', 'mse_lasso_psu',
               'mse_ols_census', 'mse_ols_gis', 'mse_ols_all', 'mse_ols_psu',
               'mse_eb', 'mse_uc']

# Combine bias results
bias = true['muni']
bias = pd.concat([bias, bias_gb_census, bias_gb_gis, bias_gb_all, bias_gb_psu,
                 bias_bart_census, bias_bart_gis, bias_bart_all, bias_bart_psu,
                 bias_rf_census, bias_rf_gis, bias_rf_all, bias_rf_psu,
                 bias_lasso_census, bias_lasso_gis, bias_lasso_all, bias_lasso_psu,
                 bias_ols_census, bias_ols_gis, bias_ols_all, bias_ols_psu,
                 bias_eb, bias_uc], axis = 1, ignore_index = True)
bias.columns = ['muni', 'bias_gb_census',' bias_gb_gis', 'bias_gb_all', 'bias_gb_psu',
               'bias_bart_census', 'bias_bart_gis', 'bias_bart_all', 'bias_bart_psu',
               'bias_rf_census', 'bias_rf_gis', 'bias_rf_all', 'bias_rf_psu',
               'bias_lasso_census', 'bias_lasso_gis', 'bias_lasso_all', 'bias_lasso_psu',
               'bias_ols_census', 'bias_ols_gis', 'bias_ols_all', 'bias_ols_psu',
               'bias_eb', 'bias_uc']

# Save results
mse.to_csv(outpath + 'results_mse.csv', index = False)
bias.to_csv(outpath + 'results_bias.csv', index = False)










