# Set up
rm(list = ls())
options(java.parameters = "-Xmx15000m")  # Sets memory for bartMachine
library(bartMachine)
set_bart_machine_num_cores(4)
library(matrixStats)
set.seed(123)

# Directories
#inpath = "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data"
#outpath = "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results"
inpath = '/Users/lupin/GitHub/Poverty-Mapping/Data/'
outpath ='/Users/lupin/GitHub/Poverty-Mapping/Results/'

# Input datasets
svy = file.path(inpath, "svydata_mun.csv", fsep = "/")
svy = read.csv(svy)
x = file.path(inpath, "xmatrix_mun_ntl.csv", fsep = "/")
x = read.csv(x)
x <- subset(x, select = -c(census_automobile))  # census_automobile is missing all data

# Filtering covariates
# Note: Use "census" for census variables, "gis" for GIS variables, and "" 
# for all variables
covars = "gis"
x_census = x[-c(1)]   # If covars = "" must drop "MiMun"
x_census = x_census[, grepl(covars, names(x_census))]
hid = x["MiMun"]

# Choose outcome variable 
indicator = "poor"

# Predictions
prediction = hid
for (i in 1:500){
    sim = paste0("Simulation number:", i)
    print(sim)
    ptm <- proc.time()  # Start timer
    y = svy[svy$sim_sample == i, ]     # Get all outcomes for simulation i
    X = merge(x, y, by = "MiMun") 
    y = X[, indicator]                 # Set y as poverty headcount
    X = X[, -which(names(X) %in% c("MiMun", "sim_sample", "e_y", "poor", "gap", "gap2"))] 
    X = X[, grepl(covars, names(X))]   # Set X as chosen predictors
    
    # Run BART and get predictions
    # Note: BART cross-validation only searches over k and m, nu and q are set to default values.
    post = bartMachineCV(X, y, k_folds = 3, k_cvs = c(2, 3), nu_q_cvs = list(c(3, 0.9))) 
    y_pred = predict(post, x_census)

    # Store results
    name = paste0("yhat_", i)
    prediction = cbind(prediction, y_pred)
    colnames(prediction)[i + 1] = name
    proc.time() - ptm   # End timer
}

# Save results
if (covars == ""){covars = "all"}
names(prediction)[names(prediction) == "MiMun"] <- "muni"
results = paste0("bart_", covars, "_mun.csv")
results = file.path(outpath, results, fsep = "/")
write.csv(prediction, results, row.names = FALSE)






