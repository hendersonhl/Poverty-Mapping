# Set up
rm(list = ls())
library(BART)
library(matrixStats)
library(dplyr)
set.seed(123)

# Directories
inpath = "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data"
outpath = "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results"

# Input datasets
svy = file.path(inpath, "svydata_python_psu.csv", fsep = "/")
svy = read.csv(svy)
x = file.path(inpath, "xmatrix_python_psu.csv", fsep = "/")
x = read.csv(x)
x <- subset(x, select = -c(HID_automobile))  # HID_automobile is missing all data

# Filtering covariates
x_census = x[, grepl("HID_", names(x))]
hid = x["HID"]

# Choose outcome variable 
indicator = "poor"

# Illustrate prediction intervals in BART
y = svy[svy$sim_sample == 1, ]     # Get all outcomes for one sample
X = merge(x, y, by = "HID") 
y = X[, indicator]                 # Set y as poverty headcount
X = X[, grepl("HID_", names(X))]   # Set X as chosen predictors
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
    X = merge(x, y, by = "HID") 
    y = X[, indicator]                 # Set y as poverty headcount
    X = X[, grepl("HID_", names(X))]   # Set X as chosen predictors
    
    # Run BART and get predictions
    post = gbart(X, y, x_census)  # Default burn-in is 100 and default returned samples is 1000
    name = paste0("yhat_", i)
    y_pred = post$yhat.test.mean 
    
    # Store results
    name = paste0("yhat_", i)
    prediction = cbind(prediction, y_pred)
    colnames(prediction)[i + 1] = name
}

# Collapse results to municipality level
hhsize = file.path(inpath, "true_psu.csv", fsep = "/")
hhsize = read.csv(hhsize)[c("hhsize")]
prediction = cbind(prediction, hhsize)
prediction["HID"] = prediction["HID"]/1000
names(prediction)[names(prediction) == "HID"] <- "muni"
prediction$muni <- as.integer(prediction$muni)
prediction = prediction %>% group_by(muni) %>% 
  summarise_at(vars(starts_with('yhat')), 
  list(~weighted.mean(., hhsize))) %>% as.data.frame()

# Save results
results = paste0("bart_", "census", "_psu.csv")
results = file.path(outpath, results, fsep = "/")
write.csv(prediction, results, row.names = FALSE)






