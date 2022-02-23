# Import libraries
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Directory
outpath = '/Users/hendersonhl/Documents/World Bank/Results/'

# Select results to plot
# Note: Use 'mun' or 'psu' for the level variable to select the level at
# which to plot the results. If using 'psu' set covars to 'census'. If using 
# 'mun' set covars to 'census' for census variables, 'gis' for GIS variables, 
# and 'all' for all variables.
level = 'mun'
covars = 'all'
indicator = 'poor' 

# Weighted average function for aggregated to municipality level
def weighted(x, cols, w="hhsize"):
    return pd.Series(np.average(x[cols], weights=x[w], axis=0), cols)

# Import true poverty indicators
true = pd.read_csv(outpath + 'true_' + level + '.csv', header = 0)
if level == 'mun':      # Keep only the chosen outcome
    true = true[['MiMun', indicator]]
else:
    true = true[['HID', indicator, 'hhsize']]
    
# Import all estimates and merge onto truth
baseline = pd.read_csv(outpath + 'baseline_' + covars + '_' + level + '.csv', header = 0)
baseline = pd.merge(baseline, true)
hyperopt = pd.read_csv(outpath + 'hyperopt_' + covars + '_' + level + '.csv', header = 0)
hyperopt = pd.merge(hyperopt, true)

# Collapse to municipality level if at PSU level
if level == 'psu':
    baseline['HID'] = (baseline['HID']/1000).astype(int)  # Fix identifier
    hyperopt['HID'] = (hyperopt['HID']/1000).astype(int)
    cols = list(baseline)[2:-1]
    baseline = baseline.groupby(baseline.HID).apply(weighted, cols)
    hyperopt = hyperopt.groupby(hyperopt.HID).apply(weighted, cols)

# Calculate MSE and bias for baseline results
# Note: This calculates MSE for each municipality
mse_baseline = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (baseline[name] - baseline[indicator])**2
    mse_baseline = pd.concat((mse_baseline, mse), axis = 1)    
mse_baseline = np.mean(mse_baseline, axis = 1)
bias_baseline = baseline.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - baseline.loc[:, 'poor']

# Calculate MSE and bias for HYPEROPT results
# Note: This calculates MSE for each municipality
mse_hyperopt = pd.DataFrame()
for i in range(1,501):
    name = 'yhat_' + str(i)
    mse = (hyperopt[name] - hyperopt[indicator])**2
    mse_hyperopt = pd.concat((mse_hyperopt, mse), axis = 1)    
mse_hyperopt = np.mean(mse_hyperopt, axis = 1)
bias_hyperopt = hyperopt.loc[:, 'yhat_1':'yhat_500'].mean(axis = 1) - hyperopt.loc[:, 'poor']

# Boxplot for MSE  
plt.figure(figsize = (10, 7))
results = pd.concat((mse_baseline, mse_hyperopt), axis = 1) 
plt.boxplot(results, labels = ['Baseline', 'Hyperopt'])
plt.ylabel('Mean Squared Error')
print(np.mean(mse_baseline))
print(np.mean(mse_hyperopt))

# Boxplot for bias 
plt.figure(figsize =(10, 7))
results = pd.concat((bias_baseline, bias_hyperopt), axis = 1) 
plt.boxplot(results, labels = ['Baseline', 'Hyperopt'])
plt.ylabel('Bias')
print(np.mean(bias_baseline))
print(np.mean(bias_hyperopt))

# Plot feature importance
importance = pd.read_csv(outpath + 'importance_' + covars + '_' + level + '.csv', header = 0)
importance['mean'] = importance.iloc[:, 2:].mean(axis=1)
importance = importance.sort_values('mean')
plt.figure(figsize = (10,30))
plt.barh('variables', 'mean', data=importance)
plt.xlabel('Gain')


