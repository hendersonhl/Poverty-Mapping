# Set up
rm(list = ls())
options(java.parameters = "-Xmx15000m")  # Sets memory for bartMachine
library(bartMachine)
set_bart_machine_num_cores(4)
library(matrixStats)
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

# Predictions
prediction = hid
for (i in 1:500){
    sim = paste0("Simulation number:", i)
    ptm <- proc.time()
    print(sim)
    y = svy[svy$sim_sample == i, ]     # Get all outcomes for simulation i
    X = merge(x, y, by = "HID") 
    y = X[, indicator]                 # Set y as poverty headcount
    X = X[, grepl("HID_", names(X))]   # Set X as chosen predictors
    
    # Run BART and get predictions
    #post = gbart(X, y, x_census)  # Default burn-in is 100 and default returned samples is 1000
    post = bartMachineCV(X, y, k_folds = 3, k_cvs = c(2, 3), nu_q_cvs = list(c(3, 0.9))) 
    y_pred = predict(post, x_census)
    
    # Store results
    name = paste0("yhat_", i)
    prediction = cbind(prediction, y_pred)
    colnames(prediction)[i + 1] = name
    proc.time() - ptm
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






