The scripts in this folder process the outputs from the "Traditional SAE" and the
"Python and R codes for ML models" folders and produces the figures and other outputs 
presented in the main paper.

	- results_mse.py: calculates MSE and Bias of the estimates from the different models fit.
	- results_rsquared.py: calculate the R2 between model based estimates and survey
	  and true estimates.
	- export_tableu.do: Old script used to produce outputs for tableau. Not used for
	  main document.
	- blog_results.do: Code used to produce figures for let's talk development blog.
	- bias and mse check on FH.do: code produces the MSE and Bias for the FH models.
	  The code is done separately since it was added later to the main paper.
	- prob_mun_select.do: Code calculates the empirical probability of each municipality
          being sampled and then plots MSE and bias values for different methods.
	- results_plots.do: produces main figures presented in the text.