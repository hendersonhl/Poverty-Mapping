The codes in this folder produce the ML results all in python or R

- XGboost models
	- xgboost_mun.py: Codes fit a mun level model where the lhs is the poverty rate
	  of the municipality and on the rhs are municipality level aggregates from the
	  census, or GIS covariates, or both.
	- xgboost_psu.py: Codes fit a PSU level model where the lhs is the poverty rate
	  at the psu level and on the rhs are psu level aggregates from the census. 
	  Estimates are then aggregated to the municipality level.
	- xgboost_psu_wc.py: Similar to xgboost_psu.py except that we add to the RHS 
	  municipality level covariates.
	- xgboost_hh.py: COdes fit a household level model where the lhs is the household's
	  poverty status (0,1). Covariates are at the household, psu, and mun level. 
	  Results from this simulation are not shown in main document.

- Random Forest models
	- rf_mun.py: Codes fit a mun level model where the lhs is the poverty rate
	  of the municipality and on the rhs are municipality level aggregates from the
	  census, or GIS covariates, or both.
	- rf_psu.py: Codes fit a PSU level model where the lhs is the poverty rate
	  at the psu level and on the rhs are psu level aggregates from the census. 
	  Estimates are then aggregated to the municipality level. 
- Ordinary Least squares
	- ols_mun.py: Codes fit a mun level model where the lhs is the poverty rate
	  of the municipality and on the rhs are municipality level aggregates from the
	  census, or GIS covariates, or both.
	- ols_psu.py: Codes fit a PSU level model where the lhs is the poverty rate
	  at the psu level and on the rhs are psu level aggregates from the census. 
	  Estimates are then aggregated to the municipality level. 
- LASSO models
	- lasso_mun.py: Codes fit a mun level model where the lhs is the poverty rate
	  of the municipality and on the rhs are municipality level aggregates from the
	  census, or GIS covariates, or both.
	- lasso_psu.py: Codes fit a PSU level model where the lhs is the poverty rate
	  at the psu level and on the rhs are psu level aggregates from the census. 
	  Estimates are then aggregated to the municipality level. 
- BART models
	- bart_mun.py: Codes fit a mun level model where the lhs is the poverty rate
	  of the municipality and on the rhs are municipality level aggregates from the
	  census, or GIS covariates, or both.
	- bart_psu.py: Codes fit a PSU level model where the lhs is the poverty rate
	  at the psu level and on the rhs are psu level aggregates from the census. 
	  Estimates are then aggregated to the municipality level. 
