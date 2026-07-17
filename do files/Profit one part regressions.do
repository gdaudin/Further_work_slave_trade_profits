
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
}


if "$hyp"=="Baseline" | "$hyp"=="Baseline_BBsample" use "${output}Ventures&profit_Baseline.dta", clear
else use "${output}/Robustness/Ventures&profit_$hyp.dta", clear


if "$hyp"=="Baseline_BBsample" {
	keep if nationality == "English" | nationality == "French" | nationality == "Dutch" 
	keep if YEARAF>=1750 & YEARAF<=1795
}

drop if completedataonoutlays=="no" & completedataonreturns=="no"
drop if profit ==.

label var nationality_num "Nationality (English omitted)"
label var period "Period (1751-1775 omitted)"
label var MAJMAJBYIMP_num "African region of trade (Gulf of Guinea omitted)"

append using "${dir}/tastdb-exp-2026_corr+own+various+careers.dta", generate(tstd_voyages)
keep if tstd_voyages==0 | (YEARAF>=1750 & YEARAF<=1795 & (nationality == "English" | nationality == "French" | nationality == "Dutch"))
replace lnTONMOD=ln(TONMOD) if tstd_voyages==1
replace ln_length_in_days=ln(length_in_days) if tstd_voyages==1

collect clear
global explaining "ib3.nationality_num war neutral ib2.period"
collect, tag(model[0a]  hyp[$hyp] step[Regression]): reg profit $explaining if tstd_voyages==0, vce(robust) 

predict predicted_profit if tstd_voyages==1, xb 
collect, tag(model[0a]  hyp[$hyp] step[Extrapolation]): summarize predicted_profit if tstd_voyages==1
drop predicted_profit


global explaining "$explaining i.MAJMAJBYIMP_num big_port"
collect, tag(model[0b]  hyp[$hyp] step[Regression]): reg profit $explaining if tstd_voyages==0, vce(robust)
predict predicted_profit if tstd_voyages==1, xb 
collect, tag(model[0b]  hyp[$hyp] step[Extrapolation]): summarize predicted_profit if tstd_voyages==1
drop predicted_profit

collect, tag(model[0c]  hyp[$hyp] step[Regression]): reg profit $explaining lnTONMOD if tstd_voyages==0, vce(robust)
predict predicted_profit if tstd_voyages==1, xb 
collect, tag(model[0c]  hyp[$hyp] step[Extrapolation]): summarize predicted_profit if tstd_voyages==1
drop predicted_profit



global explaining "$explaining lnTONMOD"
collect, tag(model[0d]  hyp[$hyp] step[Regression]): reg profit $explaining OUTFITTER_experience_d captain_experience_d 1.either_experience_d if tstd_voyages==0, vce(robust)

predict predicted_profit if tstd_voyages==1 & lnTONMOD<=ln(500), xb 
collect, tag(model[0d]  hyp[$hyp] step[Extrapolation]): summarize predicted_profit if tstd_voyages==1
drop predicted_profit


global explaining "$explaining OUTFITTER_experience_d captain_experience_d 1.either_experience_d"

global proxy " MORTALITY pricemarkup "
collect, tag(model[1] hyp[$hyp] step[Regression]):reg profit $explaining $proxy ln_length_in_days i.FATEbin if tstd_voyages==0, vce(robust) 
predict predicted_profit if tstd_voyages==1 & lnTONMOD<=ln(500) & ln_length_in_days<=ln(1000), xb 
collect, tag(model[1]  hyp[$hyp] step[Extrapolation]): summarize predicted_profit if tstd_voyages==1
drop predicted_profit

collect, tag(model[2] hyp[$hyp] step[Regression]):reg profit $explaining $proxy ln_length_in_days i.FATEbin crowd if tstd_voyages==0, vce(robust)
predict predicted_profit if tstd_voyages==1, xb 
collect, tag(model[2]  hyp[$hyp] step[Extrapolation]): summarize predicted_profit if tstd_voyages==1 & lnTONMOD<=ln(500) & ln_length_in_days<=ln(1000) & crowd<=4
drop predicted_profit

collect, tag(model[3] hyp[$hyp] step[Regression]):reg profit $explaining $proxy i.FATEbin if tstd_voyages==0, vce(robust) 
predict predicted_profit if tstd_voyages==1, xb 
collect, tag(model[3]  hyp[$hyp] step[Extrapolation]): summarize predicted_profit if tstd_voyages==1 & lnTONMOD<=ln(500)
drop predicted_profit

collect, tag(model[4] hyp[$hyp] step[Regression]):reg profit $explaining $proxy ln_length_in_days if tstd_voyages==0, vce(robust) 
predict predicted_profit if tstd_voyages==1, xb 
collect, tag(model[4]  hyp[$hyp] step[Extrapolation]): summarize predicted_profit if tstd_voyages==1 & lnTONMOD<=ln(500) & ln_length_in_days<=ln(1000)
drop predicted_profit

collect, tag(model[5] hyp[$hyp] step[Regression]):reg profit $explaining $proxy i.FATEbin crowd if tstd_voyages==0, vce(robust) 
predict predicted_profit if tstd_voyages==1, xb 
collect, tag(model[5]  hyp[$hyp] step[Extrapolation]): summarize predicted_profit if tstd_voyages==1 & lnTONMOD<=ln(500) & crowd<=4
drop predicted_profit


collect style cell result, nformat(%3.2fc)  halign(center)
collect style cell result[mean], nformat(%4.3fc)  halign(center)
collect style cell result[_r_ci], sformat("[%s]") cidelimiter(,) nformat(%3.2f)
collect style cell result[N], nformat(%5.0fc)


collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)

collect style row stack, nobinder
collect label levels step Regression  "Number of observations for regression"
collect label levels step Extrapolation  "Number of observations for extrapolation"
collect style header result[_r_b _r_ci N], level(hide)
collect label levels result mean "Mean extrapolated profitability" r2 "R-squared" r2_a "Adjusted R-squared", replace
collect style header result[mean], level(label)
collect style header Regression, title(label)
collect style cell cell_type[row-header], halign(left)
collect style showbase off

collect style cell result[r2_a], border(bottom, pattern(single))


collect layout (colname#result[_r_b _r_ci] result[N]#step[Regression] result[r2 r2_a]  result[N]#step[Extrapolation] result[mean] )  ///
		(model[0a 0b 0c 0d 2 1 3 4 5]) (hyp[$hyp])
collect preview

if "$hyp"=="Baseline" | "$hyp"=="Baseline_BBsample" {
	collect export "$output/reg-onepart_$hyp.txt", replace
	collect export "$output/reg-onepart_$hyp.docx", replace
	collect export "$output/reg-onepart_$hyp.pdf", replace
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

