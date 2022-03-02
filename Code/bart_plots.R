# Set up
rm(list = ls())
set.seed(123)

# Directories
inpath = "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Data"
outpath = "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/Results"

# Select results to plot
# Note: Use "mun" or "psu" for the level variable to select the level at which predictions 
# were made (all predictions are already aggregated to the municipality). If using "psu" 
# set covars to "census". If using "mun" set covars to "census" for census variables, "gis" 
# for GIS variables, and "all" for all variables.
level = "mun"
covars = "census"
indicator = "poor" 

# Import true poverty indicators
true = paste0("true_mun", ".csv")
true = file.path(inpath, true, fsep = "/")
true = read.csv(true)
names(true)[names(true) == "MiMun"] <- "muni"
true = true[, c("muni", indicator)]

# Import BART results
bart = paste0("bart_", covars, "_", level, ".csv")
bart = file.path(outpath, bart, fsep = "/")
bart = read.csv(bart)
bart = merge(bart, true, by = "muni")

# Import baseline results
# Note: Always use the municipality files for the baseline estimates.
baseline = paste0("baseline_", covars, "_mun", ".csv")
baseline = file.path(outpath, baseline, fsep = "/")
baseline = read.csv(baseline) 
baseline = merge(baseline, true, by = "muni")

# Calculate MSE and bias for baseline results
# Note: This calculates MSE and bias for each municipality
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
# Note: This calculates MSE and bias for each municipality
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



