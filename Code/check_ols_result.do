*==========================================
* Program setup
*==========================================

* Set up
clear all
set more off

* Set globals
if (lower("`c(username)'")=="wb378870")    global main "C:\Users\WB378870\GitHub\Poverty-Mapping\"
if (lower("`c(username)'")=="paul corral") global main "C:\Users\Paul Corral\Documents\GitHub\Poverty-Mapping"
if (lower("`c(username)'")=="hendersonhl") global main "/Users/hendersonhl/Documents/Articles/Poverty-Mapping/"

global inpath "$main/Data/"
global outpath "$main/Results/"

import delimited "C:\Users\WB378870\GitHub\Poverty-Mapping\Data\direct_mun.csv", clear
keep if sim==1

tempfile directo
save `directo'


import delimited "C:\Users\WB378870\GitHub\Poverty-Mapping\Results\ols_all_mun.csv", clear

merge 1:1 muni using `directo'