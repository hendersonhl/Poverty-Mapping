# Import libraries
import pandas as pd
import numpy as np
import statsmodels.api as sm

# Directory
#inpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data/'
#outpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results/'
inpath = '/Users/WB378870/GitHub/Poverty-Mapping/Data/'
outpath = '/Users/WB378870/GitHub/Poverty-Mapping/Results/'

# Import true poverty indicators and reshape
# Note: All calculations are based on municipality-level data
true = pd.read_csv(inpath + 'true_mun.csv', header = 0)
true = true.rename(columns={'mimun': 'muni'})
true = true[['muni', 'poor']]
results = pd.DataFrame(np.repeat(true.values, 500, axis=0), columns=true.columns)  
results['sim_sample'] = np.tile(np.arange(1,501), true.shape[0])
results['muni'] = results['muni'].astype(int)
results = results[['muni', 'sim_sample', 'poor']]

# Import direct estimates and merge onto truth
direct = pd.read_csv(inpath + 'direct_mun.csv', header = 0)
results = pd.merge(results, direct, on=['muni', 'sim_sample'], how = 'outer')
results['svysample'] = np.where(results['dpoor'].isnull(), 0, 1)

# Merge in results
model = ['gb_census_mun', 'gb_gis_mun', 'gb_all_mun', 'gb_census_psu',  
         'bart_census_mun', 'bart_gis_mun', 'bart_all_mun', 'bart_census_psu', 
         'rf_census_mun', 'rf_gis_mun', 'rf_all_mun', 'rf_census_psu', 
         'lasso_census_mun', 'lasso_gis_mun', 'lasso_all_mun', 'lasso_census_psu', 
         'ols_census_mun', 'ols_gis_mun', 'ols_all_mun', 'ols_census_psu']
for i in model:
    res = pd.read_csv(outpath + i + '.csv', header = 0)
    cols = list(res)[1:]    # Reshape wide to long
    res = pd.melt(res, id_vars='muni', value_vars=cols)
    res = res.rename(columns={"value": i, "variable": "sim_sample"})
    res['sim_sample'] = np.repeat(np.arange(1,501), true.shape[0])
    results = pd.merge(results, res, on=['muni', 'sim_sample'], how = 'outer')
    
# Add in results from traditional estimators
res_uc = pd.read_stata(inpath + 'uceb19.dta')
res_uc = res_uc[['Unit','avg_fgt0__6744898','nsim']]
res_uc.columns = ['muni', 'uc', 'sim_sample']
res_uc['muni'] = res_uc['muni'].astype(int)
results = pd.merge(results, res_uc, on=['muni', 'sim_sample'], how = 'outer')

res_eb = pd.read_stata(inpath + 'h3no19.dta')
res_eb = res_eb[['Unit','avg_fgt0__6744898','nsim']]
res_eb.columns = ['muni', 'eb', 'sim_sample']
res_eb['muni'] = res_eb['muni'].astype(int)
results = pd.merge(results, res_eb, on=['muni', 'sim_sample'], how = 'outer')

#add in FH results
res_fh = pd.read_stata(outpath + 'FH_results.dta')
res_fh = res_fh[['area','estimate','simul']]
res_fh.columns = ['muni','fh','sim_sample']
res_fh['muni'] = res_fh['muni'].astype(int)
results = pd.merge(results, res_fh, on = ['muni', 'sim_sample'], how = 'outer')
    
# Calculate r-squared values
model = model + ['eb', 'uc', 'fh']
rsquared = pd.DataFrame()
rsquared['sim_sample'] = np.arange(1,501)
for i in model:     # Loop over all models and samples
    print(i)
    true = []
    constrain = []
    direct = []
    for j in range(1,501):
        data = results[(results['sim_sample'] == j) & (results['svysample'] == 1)]
        y = data['poor']      # Get true R-squared
        X = data[i]
        X = sm.add_constant(X)
        reg = sm.OLS(y, X).fit()
        true.append(reg.rsquared)
        y_bar = y.mean()    # Get constrained R-squared
        ss_tot = ((y - y_bar)**2).sum()
        ss_res = ((y - data[i])**2).sum()
        constrain.append(1 - (ss_res/ss_tot))
        y = data['dpoor']    # Get direct R-squared
        reg = sm.OLS(y, X).fit()
        direct.append(reg.rsquared)
    name1 = i + '_true'
    name2 = i + '_constrain'
    name3 = i + '_direct'
    rsquared[name1] = true
    rsquared[name2] = constrain
    rsquared[name3] = direct
    
# Save results
rsquared.to_csv(outpath + 'results_rsquared.csv', index = False)
    
    

    
    
