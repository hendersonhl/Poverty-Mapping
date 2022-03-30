# Import libraries
import matplotlib.pyplot as plt
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

# Import BART estimates and merge onto truth
bart_census = pd.read_csv(outpath + 'bart_census_mun.csv', header = 0)
bart_census = pd.merge(bart_census, true)
bart_gis = pd.read_csv(outpath + 'bart_gis_mun.csv', header = 0)
bart_gis = pd.merge(bart_gis, true)
bart_all = pd.read_csv(outpath + 'bart_all_mun.csv', header = 0)
bart_all = pd.merge(bart_all, true)

# Import random forest estimates and merge onto truth
rf_census = pd.read_csv(outpath + 'rf_census_mun.csv', header = 0)
rf_census = pd.merge(rf_census, true)
rf_gis = pd.read_csv(outpath + 'rf_gis_mun.csv', header = 0)
rf_gis = pd.merge(rf_gis, true)
rf_all = pd.read_csv(outpath + 'rf_all_mun.csv', header = 0)
rf_all = pd.merge(rf_all, true)

# Import lasso estimates and merge onto truth
lasso_census = pd.read_csv(outpath + 'lasso_census_mun.csv', header = 0)
lasso_census = pd.merge(lasso_census, true)
lasso_gis = pd.read_csv(outpath + 'lasso_gis_mun.csv', header = 0)
lasso_gis = pd.merge(lasso_gis, true)
lasso_all = pd.read_csv(outpath + 'lasso_all_mun.csv', header = 0)
lasso_all = pd.merge(lasso_all, true)

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

# Boxplot for MSE  
plt.figure(figsize = (10, 7))
results = pd.concat((mse_gb_census, mse_bart_census, mse_rf_census, mse_lasso_census,
                     mse_gb_gis, mse_bart_gis, mse_rf_gis, mse_lasso_gis,
                     mse_gb_all, mse_bart_all, mse_rf_all, mse_lasso_all), axis = 1) 
labels = ['GB (Census)', 'BART (Census)', 'RF (Census)', 'LASSO (Census)', 
          'GB (GIS)', 'BART (GIS)', 'RF (GIS)', 'LASSO (GIS)',
          'GB (All)', 'BART (All)', 'RF (All)', 'LASSO (All)']
plt.boxplot(results, sym = '', labels = labels, vert = False)
plt.gca().invert_yaxis()
plt.xlabel('Mean Squared Error')

# Boxplot for bias  
plt.figure(figsize = (10, 7))
results = pd.concat((bias_gb_census, bias_bart_census, bias_rf_census, bias_lasso_census,
                     bias_gb_gis, bias_bart_gis, bias_rf_gis, bias_lasso_gis,
                     bias_gb_all, bias_bart_all, bias_rf_all, bias_lasso_all), axis = 1) 
labels = ['GB (Census)', 'BART (Census)', 'RF (Census)', 'LASSO (Census)', 
          'GB (GIS)', 'BART (GIS)', 'RF (GIS)', 'LASSO (GIS)',
          'GB (All)', 'BART (All)', 'RF (All)', 'LASSO (All)']
plt.boxplot(results, sym = '', labels = labels, vert = False)
plt.gca().invert_yaxis()
plt.xlabel('Bias')






