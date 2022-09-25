# Import libraries
import xgboost as xgb
import numpy as np
import pandas as pd
from sklearn.model_selection import cross_val_score
from hyperopt import fmin, tpe, hp, STATUS_OK, Trials
import time

# Directories
#inpath = '/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data/'
#inpath = 'C:/Users/wb548031/Documents/xgboost/01_data/'
#outpath = 'C:/Users/wb548031/Documents/xgboost/03_results/'
inpath = '/Users/Paul Corral/Documents/GitHub/Poverty-Mapping/Data/'
outpath = '/Users/Paul Corral/Documents/GitHub/Poverty-Mapping/Results/'

# Input datasets
census = pd.read_stata(inpath + 'census_trim.dta', convert_categoricals=True) # census data at hh, psu(HID), and mun level
#census = census.head(10000)
census = census.rename(columns={'HID_mun':'muni'})  # renaming to make more sense
xmat = pd.read_stata(inpath + 'xmatrix_python_mun.dta') # census and GIS covariates at mun level
xmat = xmat.rename(columns={'mimun': 'muni'})       # renaming so we can merge afterwards
census = pd.merge(census, xmat, on='muni')          # merge both datasets; THIS DATASET INCLUDES ALL X AT ALL LEVELS
census = census.drop('HID_automobile', axis = 1)    # HID_automobile is missing all data
census = census.drop('census_automobile', axis = 1) # census_automobile is missing all data

# Filtering covariates
# By household level
xhh = ['hhsize', 'age_hh', 'male_hh', 'piped_water',	'no_piped_water', 
     'no_sewage', 'sewage_pub', 'sewage_priv', 'electricity', 'telephone',
     'cellphone', 'internet', 'computer', 'washmachine', 'fridge',	
     'television', 'share_under15', 'share_elderly', 'share_adult', 
     'max_tertiary', 'max_secondary', 'share_female']

# By HID(psu) level
xhid = list(census.loc[:, census.columns.str.startswith('HID_')])

# By Mun level (both census and GIS)
xcensus = list(census.loc[:, census.columns.str.startswith('census_')])              
xgis    = list(census.loc[:, census.columns.str.startswith('gis_')])


# Change as you wish ##########################################################
# Modify if you wnat to exclude GIS vars or Census vars
# Adding all covariates names, modify as you wish
###############################################################################

# Choose covariates and their level xhh, xhid,xmun
# Change this one if you are indcluding covariates at the municipal level
xmun = xcensus + xgis  # you can exclude GIS or Census or all

x = xhh + xhid + xmun  # Note: xmun alone wont work.
 
# Choose outcome variable y
indicator = 'poor'

# Choose level HID or hhid of prediction
level = 'hhid'


# Change this  
census = census.loc[:, [level, 'HID','muni', indicator] + x] # For hh level      
# census = census.loc[:, [level, 'muni', indicator] + x] # Use this for HID level

###############################################################################


census = census.replace(to_replace=['No', 'Yes'], value=[0, 1]) # Recoding yes/no
x_census = census.loc[:, x]
hid = census['HID']
muni = census['muni']
samples = pd.read_stata(inpath + 'my_samples_pps_psu@.dta') ### creo q esto deberia ser a nivel hh o no? preguntar a Paul
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
    model = xgb.XGBClassifier(random_state = 123, n_jobs = 3, 
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
    samp = samples.loc[samples['sim_sample'] == i]   # Get HH identifiers in sample i
    samp = census[census[level].isin(samp[level])]
    y = samp[indicator]                              # Set y as poverty headcount
    X = samp.loc[:, x]                               # Set X as chosen predictors

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

# Weighted average function for aggregating to municipality level
def weighted(x, cols, w="hhsize"):
    return pd.Series(np.average(x[cols], weights=x[w], axis=0), cols) 


# Save results at HH or HID level 
z = census[level]
prediction = pd.concat([z,hid,muni,prediction], axis = 1) # hh level
#prediction = pd.concat([z,muni,prediction], axis = 1)    # Use this for HID level
hhsize = pd.read_stata(inpath + 'census_trim.dta')[[level,'hhsize']]  
prediction = pd.merge(prediction, hhsize, on=level)
prediction.to_csv(outpath + 'gb_census_' + level +'(disaggregated)_demo.csv', index = False) 

# Collapse to municipality levels
prediction['muni'] = prediction['muni'].astype(int)
cols = list(prediction)[1:-1]
prediction = prediction.groupby(prediction.muni).apply(weighted, cols)

# Save results 
prediction.to_csv(outpath + 'gb_census_' + level +'_demo.csv')
importance.to_csv(outpath + 'gb_importance_census_' + level +'_demo.csv', index = False)




