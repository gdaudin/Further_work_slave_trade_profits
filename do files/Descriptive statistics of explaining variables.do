
clear
*ssc install estout, replace
*ssc install outreg2, replace


capture program drop descriptive_stat
program define descriptive_stat
args OR VSDO VSDR VSDT VSRV VSRT INV INT IMP
*eg profit_analysis 0.5 1 1 0 1 0 1 0 for the baseline
* eg profit_analysis 0.5 1 1 0 1 0 1 0 IMP for the baseline + imputed



use "${output}Ventures&profit_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.dta", clear

local hyp "OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'"

if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0" ///
	local hyp="Baseline"


global varlist_o  YEARAF totalnetexp_silver_ship TONMOD crowd SLAXIMP MORTALITY investment_per_slave pricemarkup

table (var) (nationality_num), ///
	statistic(mean $varlist_o)  ///
	statistic(median $varlist_o)  ///
	statistic(sd $varlist_o)  ///
	statistic(max $varlist_o) ///
	statistic(min $varlist_o) ///
	statistic(count $varlist_o) ///
	name(DS_others) replace

global varlist_d war neutral big_port OUTFITTER_experience_d captain_experience_d either_experience_d /*
	*/ either_regional_experience_d 

table (var) (nationality_num), ///
	statistic(mean $varlist_d)  ///
	statistic(median $varlist_d)  ///
	statistic(sd $varlist_d)  ///
	statistic(count $varlist_d) ///
	name(DS_dummies) replace


collect combine DS= DS_others DS_dummies, replace

global varlist_count  SLAXIMP totalnetexp_silver_ship investment_per_slave TONMOD

collect style cell var, nformat(%5.2fc)
collect style cell var[profit], nformat(%5.3f)
collect style cell var[YEARAF], nformat(%5.0f)
collect style cell var[$varlist_count], nformat(%12.0fc)
collect style cell result[count], nformat(%5.0f)
collect style cell var[$varlist_count]#result[max min], nformat(%12.0fc)


collect layout (var[war neutral big_port] # result[mean median sd count] ///
	var[totalnetexp_silver_ship TONMOD] # result[mean median sd min max count] ///
	var[OUTFITTER_experience_d captain_experience_d] # result[mean median sd count]) (nationality_num) 

if "`hyp'"!="Baseline"  {
	collect export "${output}/Robustness/DS_input_var_`hyp'.txt", as(txt) replace
	collect style putdocx, layout(autofitcontents) title ("`hyp'")
	collect export "${output}/Robustness/DS_input_var_`hyp'.docx", as(docx) replace
}

if "`hyp'"=="Baseline"  {
	collect export "${output}DS_input_var_`hyp'.txt", as(txt) replace
	collect style putdocx, layout(autofitcontents) title ("`hyp'")
	collect export "${output}DS_input_var_`hyp'.docx", as(docx) replace
}

collect layout (var[SLAXIMP crowd MORTALITY investment_per_slave pricemarkup] # result[mean median sd min max count]) (nationality_num) 

if "`hyp'"!="Baseline"  {
	collect export "${output}/Robustness/DS_proxy_var_`hyp'.txt", as(txt) replace
	collect style putdocx, layout(autofitcontents) title ("`hyp'")
	collect export "${output}/Robustness/DS_proxy_var_`hyp'.docx", as(docx) replace
}

if "`hyp'"=="Baseline" {
	collect export "${output}DS_proxy_var_`hyp'.txt", as(txt) replace
	collect style putdocx, layout(autofitcontents) title ("`hyp'")
	collect export "${output}/DS_proxy_var_`hyp'.docx", as(docx) replace
}

collect clear

table (period) (nationality_num)
table (MAJMAJBYIMP) (nationality_num), append
table (FATEcol) (nationality_num), append

collect layout (period MAJMAJBYIMP FATEcol) (nationality_num) 

if "`hyp'"!="Baseline"  {
	collect export "${output}/Robustness/DS_cat_var_`hyp'.txt", as(txt) replace
	collect style putdocx, layout(autofitcontents) title ("`hyp'")
	collect export "${output}/Robustness/DS_cat_var_`hyp'.docx", as(docx) replace

}

if "`hyp'"=="Baseline" {
	collect export "${output}DS_cat_var_`hyp'.txt", as(txt) replace
	collect style putdocx, layout(autofitcontents) title ("`hyp'")
	collect export "${output}DS_cat_var_`hyp'.docx", as(docx) replace
}




end


descriptive_stat 0.5 1 1 0 1 0 1 0





global varlist_o  SLAXIMP YEARAF totalnetexp_silver_ship investment_per_slave TONMOD totalnetexp_silver_ship MORTALITY crowd



***Faire quelque chose pour la région 