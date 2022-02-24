# Set up
rm(list = ls())
library(BART)
library(matrixStats)
set.seed(123)

# Directories
inpath = "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data"
outpath = "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results"

# Input datasets
svy = file.path(inpath, "svydata_mun.csv", fsep = "/")
svy = read.csv(svy)
x = file.path(inpath, "xmatrix_mun.csv", fsep = "/")
x = read.csv(x)
x <- subset(x, select = -c(census_automobile))  # census_automobile is missing all data

# Filtering covariates
# Note: Use "census" for census variables, "gis" for GIS variables, and "" 
# for all variables
covars = "census"
x_census = x[-c(1)]   # If covars = "" must drop "MiMun"
x_census = x_census[, grepl(covars, names(x_census))]
hid = x["MiMun"]

# Choose outcome variable 
indicator = "poor"

# Illustrate prediction intervals in BART
y = svy[svy$sim_sample == 1, ]     # Get all outcomes for one sample
X = merge(x, y, by = "MiMun") 
y = X[, indicator]                 # Set y as poverty headcount
X = X[, -which(names(X) %in% c("MiMun", "sim_sample", "e_y", "poor", "gap", "gap2"))] 
X = X[, grepl(covars, names(X))]   # Set X as chosen predictors
post = gbart(X, y, x_census)       # Default burn-in is 100 and default returned samples is 1000
y_preds = post$yhat.test           # Get all posterior samples
interval = colQuantiles(y_preds, probs = c(0.05, 0.95))  # Get credible interval
y_pred = post$yhat.test.mean   # Get predictions (i.e., posterior means)
prediction = cbind(hid, y_pred, interval)  # Combine into one dataframe
head(prediction)

# Predictions for all samples using BART
prediction = hid
for (i in 1:500){
    sim = paste0("Simulation number:", i)
    print(sim)
    y = svy[svy$sim_sample == i, ]     # Get all outcomes for simulation i
    X = merge(x, y, by = "MiMun") 
    y = X[, indicator]                 # Set y as poverty headcount
    X = X[, -which(names(X) %in% c("MiMun", "sim_sample", "e_y", "poor", "gap", "gap2"))] 
    X = X[, grepl(covars, names(X))]   # Set X as chosen predictors
    
    # Run BART and get predictions
    post = gbart(X, y, x_census)  # Default burn-in is 100 and default returned samples is 1000
    name = paste0("yhat_", i)
    y_pred = post$yhat.test.mean 
    
    # Store results
    name = paste0("yhat_", i)
    prediction = cbind(prediction, y_pred)
    colnames(prediction)[i + 1] = name
}

# Save results
if (covars == ""){covars = "all"}
names(prediction)[names(prediction) == 'MiMun'] <- 'muni'
results = paste0("bart_", covars, "_mun.csv")
results = file.path(outpath, results, fsep = "/")
write.csv(prediction, results, row.names = FALSE)






