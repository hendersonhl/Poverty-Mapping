# Import libraries
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm

# Directory
inpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data/'
outpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results/'

# Select results to plot
# Note: Use 'mun', 'psu', or 'hh' for the level variable to select the level 
# at which predictions were made (all predictions are already aggregated to 
# the municipality). If using 'psu' or 'hh' set covars to 'census'. If using 
# 'mun' set covars to 'census' for census variables, 'gis' for GIS variables, 
# and 'all' for all variables.
level = 'mun'
covars = 'census'
indicator = 'poor' 

# Import true poverty indicators
# Note: All calculations are based on municipality-level data
true = pd.read_csv(inpath + 'true_mun.csv', header = 0)
true = true.rename(columns={'MiMun': 'muni'})
true = true[['muni', indicator]]

# Import xgboost estimates and merge onto truth
hyperopt = pd.read_csv(outpath + 'hyperopt_' + covars + '_' + level + '.csv', 
    header = 0)
cols = list(hyperopt)[1:]    # Reshape wide to long
hyperopt = pd.melt(hyperopt, id_vars='muni', value_vars=cols)
hyperopt = hyperopt.rename(columns={"value": "yhat", "variable": "sim_sample"})
hyperopt['sim_sample'] = np.repeat(np.arange(1,501), true.shape[0])
results = pd.merge(hyperopt, true)

# Import direct estimates and merge onto truth
direct = pd.read_csv(inpath + 'direct_mun.csv', header = 0)
results = pd.merge(results, direct, on=['muni', 'sim_sample'], how = 'outer')
results['svysample'] = np.where(results['dpoor'].isnull(), 0, 1)

# Calculate r-squared for true and xgboost estimates (svysample = 0)
true_xg_cons0 = []
true_xg_nocons0 = []
for i in range(1,501):
    temp = results[(results['sim_sample'] == i) & (results['svysample'] == 0)]
    reg = sm.ols('poor ~ yhat', temp).fit()   # Model w/ constant
    true_xg_cons0.append(reg.rsquared)
    reg = sm.ols('poor ~ yhat - 1', temp).fit()  # Model w/o constant
    true_xg_nocons0.append(reg.rsquared)
     
# Calculate r-squared for true and xgboost estimates (svysample = 1)
true_xg_cons1 = []
true_xg_nocons1 = []
for i in range(1,501):
    temp = results[(results['sim_sample'] == i) & (results['svysample'] == 1)]
    reg = sm.ols('poor ~ yhat', temp).fit() 
    true_xg_cons1.append(reg.rsquared)
    reg = sm.ols('poor ~ yhat - 1', temp).fit() 
    true_xg_nocons1.append(reg.rsquared)
    
# Calculate r-squared for direct and xgboost estimates
direct_xg_cons = []
direct_xg_nocons = []
for i in range(1,501):
    temp = results[(results['sim_sample'] == i) & (results['svysample'] == 1)]
    reg = sm.ols('dpoor ~ yhat', temp).fit() 
    direct_xg_cons.append(reg.rsquared)
    reg = sm.ols('dpoor ~ yhat - 1', temp).fit() 
    direct_xg_nocons.append(reg.rsquared)
    
    
    

    
    
