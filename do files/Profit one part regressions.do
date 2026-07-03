
clear
*ssc install estout, replace
*ssc install outreg2, replace


capture program drop profit_reg_onepart
program define profit_reg_onepart
args OR VSDO VSDR VSDT VSRV VSRT INV INT sample
*eg profit_analysis 0.5 1 1 0 1 0 1 0 for the baseline
* eg profit_analysis 0.5 1 1 0 1 0 1 0 BB for the baseline on BB sample

global hyp "OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`sample'"

if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`sample'"=="0.5 1 1 0 1 0 1 0" ///
	global hyp="Baseline"
if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`sample'"=="0.5 1 1 0 1 0 1 0BB" {
	global hyp="Baseline_BBsample"
	local sample=""
}


use "${output}/Ventures&profit_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`sample'.dta", clear
if "$hyp"=="Baseline_BBsample" {
	keep if nationality == "English" | nationality == "French" | nationality == "Dutch" 
	keep if YEARAF>=1750 & YEARAF<=1795
}

drop if completedataonoutlays=="no" & completedataonreturns=="no"
drop if profit ==.

label var nationality_num "Nationality (English omitted)"
label var period "Period (1751-1775 omitted)"
label var MAJMAJBYIMP_num "African region of trade (Bight of Guinea omitted)"




global explaining "ib3.nationality_num war neutral ib2.period"
collect, tag(model[1]  hyp[$hyp]): reg profit $explaining, vce(robust)


global explaining "$explaining i.MAJMAJBYIMP_num big_port"
collect, tag(model[2]  hyp[$hyp]): reg profit $explaining, vce(robust)

collect, tag(model[4]  hyp[$hyp]): reg profit $explaining lnTONMOD, vce(robust)

global explaining "$explaining lnTONMOD"

collect, tag(model[6]  hyp[$hyp]): reg profit $explaining OUTFITTER_experience_d captain_experience_d either_experience_d, vce(robust)
global explaining "$explaining OUTFITTER_experience_d captain_experience_d either_experience_d"

//The product of experiences is not significant. Regional experience drops a lot of voyages

global proxy " MORTALITY pricemarkup ln_length_in_days i.FATEbin"
collect, tag(model[7] hyp[$hyp]):reg profit $explaining $proxy, vce(robust) 

collect, tag(model[8] hyp[$hyp]):reg profit $explaining $proxy crowd, vce(robust) 


collect style cell result, nformat(%3.2fc)  halign(center)
collect style cell result[_r_ci], sformat("[%s]") cidelimiter(,) nformat(%3.2f)

collect style cell result[N], nformat(%5.0f) 
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)

collect style row stack, nobinder
collect style header result[_r_b _r_ci], level(hide)
collect style cell cell_type[row-header], halign(left)
collect style showbase off

collect layout (colname#result[_r_b _r_ci] result[N r2 r2_a]) (model[1 2 4 6 7 8]) (hyp[$hyp])

if "$hyp"=="Baseline" | "$hyp"=="Baseline_BBsample" {
	collect export "$output/reg-onepart_$hyp.txt", replace
	collect export "$output/reg-onepart_$hyp.docx", replace
}
else {
	collect export "$output/Robustness/reg-onepart_$hyp.txt", replace
	collect export "$output/Robustness/reg-onepart_$hyp.docx", replace
}



end

collect clear

profit_reg_onepart 0.5 1 1 0 1 0 1 0

*capture erase "Comparison between different assumptions.csv"
capture _renamefile "Comparison between different assumptions.txt" "Comparison between different assumptions.csv"

