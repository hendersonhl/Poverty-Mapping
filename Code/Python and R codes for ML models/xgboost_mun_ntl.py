# Import libraries
import xgboost as xgb
import numpy as np
import pandas as pd
from sklearn.model_selection import cross_val_score
from hyperopt import fmin, tpe, hp, STATUS_OK, Trials
import time

# Directories
#inpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data/'
#outpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results/'
inpath = r'/Users/Paul Corral/Documents/GitHub/Poverty-Mapping/Data/'
outpath = r'/Users/Paul Corral/Documents/GitHub/Poverty-Mapping/Results/'
#inpath = 'C:/Users/WB378870/GitHub/Poverty-Mapping/Data/'
#outpath = 'C:/Users/WB378870/GitHub/Poverty-Mapping/Results/'

# Input datasets
svy = pd.read_csv(inpath + 'svydata_mun.csv', header = 0)
x = pd.read_csv(inpath + 'xmatrix_mun_ntl.csv', header = 0)
x = x.drop('census_automobile', axis = 1)   # census_automobile is missing all data
columns_to_drop_existing = [col for col in x.columns if col.startswith('gis_ntl_count_') and int(col[-4:]) > 2015]

# Drop columns
x = x.drop(columns=columns_to_drop_existing)

# Filtering covariates
# Note: Use 'census' for census variables, 'gis' for GIS variables, and '' 
# for all variables
covars = 'gis'
columns_to_drop = ['MiMun']

# Filter out columns that exist in x
columns_to_drop_existing = [col for col in columns_to_drop if col in x.columns]

if columns_to_drop_existing:
    x_census = x.drop(columns=columns_to_drop_existing)
    print(f"Dropped columns: {columns_to_drop_existing}")
else:
    print("No columns to drop exist in the DataFrame x")
    x_census = x.copy()  # Create a copy of x if no columns to drop
  
    
variables_to_filter = ['estado','municipio', 'hhid']
x_census = x_census.loc[:, ~x_census.columns.str.startswith(tuple(variables_to_filter))]
x_census = x_census.loc[:, x_census.columns.str.startswith(covars)]

hid = x['MiMun']

# Choose outcome variable 
indicator = 'poor' 

# Parameter space
# Note: To expand the parameter space, add the new component here, but also
# create an entry in the model specification in the tuning function. The 
# parameter listing is here: xgboost.readthedocs.io/en/stable/parameter.html
space = {'n_estimators': hp.choice("n_estimators", [5, 10, 20, 30, 40, 50, 60]), 
        'max_depth': hp.quniform("max_depth", 2, 10, 1), 
        'colsample_bytree': hp.quniform('colsample_bytree', 0.25, 1, 0.25), 
        'eta': hp.quniform('eta', 0.1, 0.4, 0.1)
        }

# Hyperparameter tuning function
# Note: This function uses the currently stored y and X.
def tuning(space):
    model = xgb.XGBRegressor(random_state = 123, n_jobs = 1,
        n_estimators = int(space['n_estimators']), 
        max_depth = int(space['max_depth']),
        colsample_bytree = space['colsample_bytree'],
        eta = space['eta']
        )
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
    X = pd.merge(x, y, on='MiMun')     # Merge y and x for simulation i
    y = X[indicator]                   # Set y as poverty headcount
    X = X.drop(columns = ['MiMun', 'sim_sample', 'e_y', 'poor', 'gap', 'gap2']) 
    X = X.loc[:, ~X.columns.str.startswith(tuple(variables_to_filter))]
    X = X.loc[:, X.columns.str.startswith(covars)]  # Set X as chosen predictors
                           
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
    # Note: The feature importance used here is 'gain'. By design, these
    # will sum to one.
    name1 = 'yhat_' + str(i)
    name2 = 'imp_' + str(i)
    if (i==1): 
        prediction = pd.DataFrame({name1: y_pred})
        importance = pd.DataFrame({'variables': x_census.columns, 
                                name2: model.feature_importances_})
    else:
        prediction = pd.concat([prediction, pd.DataFrame({name1: y_pred})], axis = 1)
        importance = pd.concat([importance, pd.DataFrame({name2: 
                                model.feature_importances_})], axis = 1)
            
# Save results
prediction = pd.concat([hid, prediction], axis = 1)
prediction = prediction.rename(columns={"MiMun": "muni"})
if covars=='': covars = 'all'
prediction.to_csv(outpath + 'gb_' + covars + '_mun_ntl.csv', index = False)
importance.to_csv(outpath + 'gb_importance_' + covars + '_mun_ntl.csv', index = False)





    
    


        
        





