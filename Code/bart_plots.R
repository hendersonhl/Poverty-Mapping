# Set up
rm(list = ls())
set.seed(123)

# Directory
outpath = "/Users/hendersonhl/Documents/World Bank/Results"

# Select results to plot
# Note: Use "mun" or "psu" for the level variable to select the level at
# which to plot the results. If using "psu" set covars to "census". If using 
# "mun" set covars to "census" for census variables, "gis" for GIS variables, 
# and "all" for all variables.
level = "mun"
covars = "census"

# Set poverty indicator and unit identifier
indicator = "poor" 
if (level == "mun"){
    hid = "MiMun"  
} else {
    hid = "HID"
}

# Import true poverty indicators
true = paste0("true", "_", level, ".csv")
true = file.path(outpath, true, fsep = "/")
true = read.csv(true)
true = true[, c(hid, indicator)]

# Import BART results
bart = paste0("bart_", covars, "_", level, ".csv")
bart = file.path(outpath, bart, fsep = "/")
bart = read.csv(bart)
bart = merge(bart, true, by = hid)

# Import baseline results
baseline = paste0("baseline_", covars, "_", level, ".csv")
baseline = file.path(outpath, baseline, fsep = "/")
baseline = read.csv(baseline) 
baseline[1] = NULL   # Remove row labels
baseline = merge(baseline, true, by = hid)

# Calculate MSE and bias for baseline results
# Note: This calculates MSE for each municipality
mse_baseline = data.frame(matrix(ncol = 0, nrow = nrow(baseline)))
for (i in 1:500){
  name = paste0('yhat_', i)  
  mse = (baseline[name] - baseline['poor'])^2
  mse_baseline = cbind(mse_baseline, mse)
}  
mse_baseline = rowMeans(mse_baseline) 
bias_baseline = rowMeans(baseline[-c(1, ncol(baseline))]) - baseline[indicator]
bias_baseline = unlist(bias_baseline)

# Calculate MSE and bias for BART results
# Note: This calculates MSE for each municipality
mse_bart = data.frame(matrix(ncol = 0, nrow = nrow(baseline)))
for (i in 1:500){
  name = paste0('yhat_', i)  
  mse = (bart[name] - bart['poor'])^2
  mse_bart = cbind(mse_bart, mse)
}  
mse_bart = rowMeans(mse_bart) 
bias_bart = rowMeans(bart[-c(1, ncol(bart))]) - bart[indicator]
bias_bart = unlist(bias_bart)

# Boxplot for MSE 
boxplot(mse_baseline, mse_bart, names = c("Baseline", "BART"))
mean(mse_baseline)
mean(mse_bart)

# Boxplot for bias 
boxplot(bias_baseline, bias_bart, names = c("Baseline", "BART"))
mean(bias_baseline)
mean(bias_bart)



