# Import libraries
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Directory
inpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data/'
outpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results/'

# Select results to plot
# Note: Use 'mun' or 'psu' for the level variable to select the level 
# at which predictions were made (all predictions are already aggregated to 
# the municipality). If using 'psu' set covars to 'census'. If using 
# 'mun' set covars to 'census' for census variables, 'gis' for GIS variables, 
# and 'all' for all variables.
level = 'psu'
covars = 'census'
indicator = 'poor' 

# Import true poverty indicators
true = pd.read_csv(inpath + 'true_mun.csv', header = 0)
true = true.rename(columns={'MiMun': 'muni'})
true = true[['muni', indicator]]

# Import estimates and merge onto truth
gb = pd.read_csv(outpath + 'hyperopt_' + covars + '_' + level + '.csv', header = 0)
gb = pd.merge(gb, true)
bart = pd.read_csv(outpath + 'bart_' + covars + '_' + level + '.csv', header = 0)
bart = pd.merge(bart, true)
rf = pd.read_csv(outpath + 'rf_' + covars + '_' + level + '.csv', header = 0)
rf = pd.merge(rf, true)

# Calculate MSE and bias for gradient boosting results
# Note: This calculates MSE and bias for each municipality
mse_gb = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (gb[name] - gb[indicator])**2
    mse_gb = pd.concat((mse_gb, mse), axis = 1)    
mse_gb = np.mean(mse_gb, axis = 1)
bias_gb = gb.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - gb.loc[:, 'poor']

# Calculate MSE and bias for BART results
mse_bart = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (bart[name] - bart[indicator])**2
    mse_bart = pd.concat((mse_bart, mse), axis = 1)    
mse_bart = np.mean(mse_bart, axis = 1)
bias_bart = bart.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - bart.loc[:, 'poor']

# Calculate MSE and bias for random forest results
mse_rf = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (rf[name] - rf[indicator])**2
    mse_rf = pd.concat((mse_rf, mse), axis = 1)    
mse_rf = np.mean(mse_rf, axis = 1)
bias_rf = rf.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - rf.loc[:, 'poor']

# Boxplot for MSE  
plt.figure(figsize = (10, 7))
results = pd.concat((mse_gb, mse_bart, mse_rf), axis = 1) 
plt.boxplot(results, labels = ['GB', 'BART', 'RF'])
plt.ylabel('Mean Squared Error')
print(np.mean(mse_gb))
print(np.mean(mse_bart))
print(np.mean(mse_rf))

# Boxplot for bias 
plt.figure(figsize =(10, 7))
results = pd.concat((bias_gb, bias_bart, bias_rf), axis = 1) 
plt.boxplot(results, labels = ['GB', 'BART', 'RF'])
plt.ylabel('Bias')
print(np.mean(bias_gb))
print(np.mean(bias_bart))
print(np.mean(bias_rf))





