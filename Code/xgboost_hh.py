# Import libraries
import xgboost as xgb
import numpy as np
import pandas as pd
from sklearn.model_selection import cross_val_score
from hyperopt import fmin, tpe, hp, STATUS_OK, Trials
import time

# Directories
#inpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data/'
inpath = 'C:/Users/wb548031/OneDrive/xgboost/01_data/input/'
outpath = 'C:/Users/wb548031/OneDrive/xgboost/01_data/output/'

# Input datasets
census = pd.read_stata(inpath + 'census_trim.dta')
x = ['hhsize', 'age_hh', 'male_hh', 'piped_water',	'no_piped_water', 
     'no_sewage', 'sewage_pub', 'sewage_priv', 'electricity', 'telephone',
     'cellphone', 'internet', 'computer', 'washmachine', 'fridge',	
     'television', 'share_under15', 'share_elderly', 'share_adult', 
     'max_tertiary', 'max_secondary', 'share_female']


census = census.loc[:, ['hhid', 'HID_mun', 'poor'] + x] # Keep select variables
census = census.rename(columns={"HID_mun": "HID"})  
census = census.replace(to_replace=['No', 'Yes'], value=[0, 1]) # Recoding yes/no
x_census = census.loc[:, x]
hid = census['HID']
samples = pd.read_stata(inpath + 'my_samples_pps_psu@.dta')
samples = samples.drop(samples[samples.sim_sample > 500].index) # Keep samples 1-500

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
    model = xgb.XGBClassifier(random_state = 123, n_jobs = 1, 
        use_label_encoder = False, eval_metric='logloss',
        n_estimators = int(space['n_estimators']), 
        max_depth = int(space['max_depth']),
        colsample_bytree = space['colsample_bytree'],
        eta = space['eta']
        )
    loss = -cross_val_score(model, X, y, cv = 3, scoring="neg_log_loss", 
        n_jobs = -1).mean()
    return {'loss': loss, 'status': STATUS_OK, 'model': model}

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
    samp = samples.loc[samples['sim_sample'] == i]  # Get HH identifiers in sample i
    samp = census[census['hhid'].isin(samp['hhid'])]
    y = samp['poor']
    X = samp.loc[:, x]

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
prediction = prediction.rename(columns={"HID": "muni"})
prediction['muni'] = prediction['muni'].astype(int)
prediction = prediction.groupby(['muni']).mean()   # Collapse to municipality level # have to do for each one
prediction.to_csv(outpath + 'gb_census_hh.csv')
importance.to_csv(outpath + 'gb_importance_census_hh.csv', index = False)
