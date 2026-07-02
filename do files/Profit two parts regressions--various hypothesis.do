
clear
*ssc install estout, replace
*ssc install outreg2, replace



///////Regression on BB sample

*profit_regv2 0.5 1 1 0 1 0 1 0 BB

///Other hypotheses

global hyp_list "" 
global hyp_list 			 0.5 1 1 0 1 0 1 0
global hyp_list  `"$hyp_list  . 1 1 0 1 0 1 0"'
global hyp_list  `"$hyp_list 0 1 1 0 1 0 1 0"'
global hyp_list	 `"$hyp_list 1 1 1 0 1 0 1 0"'
global hyp_list	 `"$hyp_list 0.5 1.5 1 0 1 0 1 0"'
global hyp_list	 `"$hyp_list 0.5 1 0.83 0 1.2 0 1 0"'
global hyp_list	 `"$hyp_list 0.5 1 1 0 1 0 0 0"'
global hyp_list	 `"$hyp_list 0.5 1 1 0 1 0 1 1"'
global hyp_list	 `"$hyp_list 0.5 1 1 1 1 1 1 0"'
global hyp_list	 `"$hyp_list 0.5 1 1 1 1 1 1 1"'

*/





collect clear

forvalues i = 1/2 {
	local h`i'
	local b = (`i'-1)*8+1
	local e = `i'*8
	forvalues j = `b'/`e' {
    	local h`i' "`h`i'' `=word("$hyp_list", `j')'"
	}
}

*macro list

local k 1
foreach hyp in h1 h2 /*h3 h4 h5 h6 h7 h8 h9 h10*/ {
	profit_regv2 ``hyp''
	local hyp`k' `hyp'
	local k=`k'+1
*`'
*	if "`hyp'" == "h2" blif
}
macro list
global hyp_list_name `""Baseline" "Observations with outstanding claims excluded from analysis""'
global hyp_list_name `"$hyp_list_name" "Claims outstanding assumed to not have been paid at all"'
global hyp_list_name `"$hyp_list_name" "Claims outstanding assumed to have been paid in full"'
global hyp_list_name `"$hyp_list_name" "Higher cost of hull relative to other outlays (25% instead of 17% in baseline)"'
global hyp_list_name `"$hyp_list_name" "Lower rate of depreciation (10% instead of baseline 25%)"'
global hyp_list_name `"$hyp_list_name" "Cost of insurance not added to any voyages"'
global hyp_list_name `"$hyp_list_name" "Cost of insurance added to outlays, even in cases where accounts seem to suggest total outlays"'
global hyp_list_name `"$hyp_list_name" "Value of hull (outgoing/incoming) added to outlays/returns, even in cases where accounts seem to suggest total outlays/returns"'
global hyp_list_name `"$hyp_list_name" "Both value of hull and cost of insurance added, in cases where accounts seem to suggest total outlays/returns"'

tokenize `"$hyp_list_name"'


collect label levels hyp "`h1'" "`1'" "`h2'" "`2'" "`h3'" "`3'" "`h4'" "`4'" "`h5'" "`5'" "`h6'" "`6'" "`h7'" "`7'" "`h8'" "`8'" "`h9'" "`9'" "`h10'" "`10'", modify

collect style header hyp, level(label)
collect layout (colname#result[_r_b _r_ci] result[N r2 r2_a]) (model[6]#hyp) (reg[main])
blif
	
collect export "$output/regv2main_appendix.txt", replace
collect export "$output/regv2main_appendix.docx", replace

collect layout (colname#result[_r_b _r_ci] result[N r2 r2_a]) (model[1]#hyp) (reg[proxy])
	
collect export "$output/regv2proxy_appendix.txt", replace
collect export "$output/regv2proxy_appendix.docx", replace
	
	
	
	