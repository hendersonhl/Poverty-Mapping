# Import libraries
import numpy as np
import pandas as pd
import statsmodels.api as sm
import time

# Directories
inpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data/'
outpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results/'

# Input datasets
svy = pd.read_csv (inpath + 'svydata_python_psu.csv', header=0)
x = pd.read_csv (inpath + 'xmatrix_python_psu.csv', header=0)
x = x.drop('HID_automobile', axis = 1)   # HID_automobile is missing all data

# Filtering covariates
x_census = x.loc[:, x.columns.str.startswith('HID_')]
hid = x['HID']

# Choose outcome variable 
indicator = 'poor' 

# Predictions
for i in range(1,501):
    print("Simulation number:", i)
    y = svy.loc[svy['sim_sample']==i]  # Get all outcomes for simulation i
    X = pd.merge(x, y, on='HID')       # Merge y and x for simulation i
    y = X[indicator]                   # Set y as poverty headcount
    X = X.loc[:, X.columns.str.startswith('HID_')]  # Set X as chosen predictors
                           
    # Run OLS
    start = time.perf_counter()   # Start timer
    model = sm.OLS(y,X).fit()
    y_pred = model.predict(x_census)
    end = time.perf_counter()  # Stop timer
    print(f"Iteration completed in {end - start:0.4f} seconds")
        
    # Save results
    name = 'yhat_' + str(i)
    if (i==1): 
        prediction = pd.DataFrame({name: y_pred})
    else:
        prediction = pd.concat([prediction, pd.DataFrame({name: y_pred})], axis = 1)

# Weighted average function for aggregating to municipality level
def weighted(x, cols, w="hhsize"):
    return pd.Series(np.average(x[cols], weights=x[w], axis=0), cols)

# Save results at PSU level
prediction = pd.concat([hid, prediction], axis = 1)
prediction.to_csv(outpath + 'ols_census_psu(disaggregated).csv', index = False)
            
# Collapse to municipality level
hhsize = pd.read_csv(inpath + 'true_psu.csv', header=0)[['HID', 'hhsize']]
prediction = pd.merge(prediction, hhsize, on='HID')
prediction['HID'] = (prediction['HID']/1000).astype(int)  # Fix identifier
prediction = prediction.rename(columns={"HID": "muni"})
cols = list(prediction)[1:-1]
prediction = prediction.groupby(prediction.muni).apply(weighted, cols)

# Save results
prediction.to_csv(outpath + 'ols_census_psu.csv')


