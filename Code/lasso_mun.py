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
svy = pd.read_csv(inpath + 'svydata_mun.csv', header = 0)
x = pd.read_csv(inpath + 'xmatrix_mun.csv', header = 0)
x = x.drop('census_automobile', axis = 1)   # census_automobile is missing all data

# Filtering covariates
# Note: Use 'census' for census variables, 'gis' for GIS variables, and '' 
# for all variables
covars = ''
x_census = x.drop(columns = ['MiMun'])  # If covars = '' need to drop 'MiMun'
x_census = x_census.loc[:, x_census.columns.str.startswith(covars)]
x_census = StandardScaler().fit_transform(x_census) # Standardize the covariates
hid = x['MiMun']

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

# Predictions using xgboost
for i in range(1,501):
    print("Simulation number:", i)
    y = svy.loc[svy['sim_sample']==i]  # Get all outcomes for simulation i
    X = pd.merge(x, y, on='MiMun')     # Merge y and x for simulation i
    y = X[indicator]                   # Set y as poverty headcount
    X = X.drop(columns = ['MiMun', 'sim_sample', 'e_y', 'poor', 'gap', 'gap2'])  
    X = X.loc[:, X.columns.str.startswith(covars)]  # Set X as chosen predictors
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
           
# Save results
prediction = pd.concat([hid, prediction], axis = 1)
prediction = prediction.rename(columns={"MiMun": "muni"})
if covars=='': covars = 'all'
prediction.to_csv(outpath + 'lasso_' + covars + '_mun.csv', index = False)





    
    


        
        





