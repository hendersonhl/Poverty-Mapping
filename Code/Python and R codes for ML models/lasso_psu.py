# Import libraries
import numpy as np
import pandas as pd
from sklearn.linear_model import Lasso
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import cross_val_score
from hyperopt import fmin, tpe, hp, STATUS_OK, Trials
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
x_census = StandardScaler().fit_transform(x_census) # Standardize the covariates
hid = x['HID']

# Choose outcome variable 
indicator = 'poor' 

# Parameter space
space = {'alpha': hp.quniform("max_depth", 0.001, 0.01, 0.0001)}

# Hyperparameter tuning function
# Note: This function uses the currently stored y and X.
def tuning(space):
    model = Lasso(alpha = space['alpha'], max_iter = 10000)
    mse = -cross_val_score(model, X, y, cv = 3, scoring="neg_mean_squared_error", 
        n_jobs = -1).mean()
    return {'loss': mse, 'status': STATUS_OK, 'model': model}

# Function for retrieving best model
def best(trials):
    valid = [trial for trial in trials if STATUS_OK == trial['result']['status']]
    losses = [float(trial['result']['loss']) for trial in valid]
    idx = np.argmin(losses)
    best = valid[idx]
    return best['result']['model']

# Predictions
for i in range(1,501):
    print("Simulation number:", i)
    y = svy.loc[svy['sim_sample']==i]  # Get all outcomes for simulation i
    X = pd.merge(x, y, on='HID')       # Merge y and x for simulation i
    y = X[indicator]                   # Set y as poverty headcount
    X = X.loc[:, X.columns.str.startswith('HID_')]  # Set X as chosen predictors
    X = StandardScaler().fit_transform(X) # Standardize the covariates
                           
    # Run HYPEROPT function
    # Note: This procedure calls the y and X currently stored
    start = time.perf_counter()   # Start timer
    trials = Trials()
    params = fmin(fn = tuning, space = space, algo = tpe.suggest, 
        max_evals = 200, trials = trials)  # Run HYPEROPT
    print(params)   # Print the best parameters 
    model = best(trials)
    model.fit(X, y)   # Fit the best model and get predictions
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
prediction.to_csv(outpath + 'lasso_census_psu(disaggregated).csv', index = False)
            
# Collapse to municipality level
hhsize = pd.read_csv(inpath + 'true_psu.csv', header=0)[['HID', 'hhsize']]
prediction = pd.merge(prediction, hhsize, on='HID')
prediction['HID'] = (prediction['HID']/1000).astype(int)  # Fix identifier
prediction = prediction.rename(columns={"HID": "muni"})
cols = list(prediction)[1:-1]
prediction = prediction.groupby(prediction.muni).apply(weighted, cols)

# Save results
prediction.to_csv(outpath + 'lasso_census_psu.csv')


