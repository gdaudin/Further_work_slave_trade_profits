
clear
*ssc install estout, replace
*ssc install outreg2, replace


capture program drop profit_regv2
program define profit_regv2
args OR VSDO VSDR VSDT VSRV VSRT INV INT sample
*eg profit_analysis 0.5 1 1 0 1 0 1 0 for the baseline
* eg profit_analysis 0.5 1 1 0 1 0 1 0 IMP for the baseline + imputed

global hyp "OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`sample'"

if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`sample'"=="0.5 1 1 0 1 0 1 0" ///
	global hyp="Baseline"
if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`sample'"=="0.5 1 1 0 1 0 1 0BB" {
	global hyp="Baseline_BBsample"
}


if "$hyp"=="Baseline" | "$hyp"=="Baseline_BBsample" use "${output}/Ventures&profit_Baseline.dta", clear
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




global explaining "ib3.nationality_num war neutral ib2.period"
collect, tag(model[1] reg[main] hyp[$hyp]): reg profit $explaining, vce(robust)


global explaining "$explaining i.MAJMAJBYIMP_num big_port"
collect, tag(model[2] reg[main] hyp[$hyp]): reg profit $explaining, vce(robust)

collect, tag(model[3] reg[main] hyp[$hyp]): reg profit $explaining ln_totalnetexp_silver_ship, vce(robust)

collect, tag(model[4] reg[main] hyp[$hyp]): reg profit $explaining lnTONMOD, vce(robust)

global explaining "$explaining ln_totalnetexp_silver_ship lnTONMOD"
collect, tag(model[5] reg[main] hyp[$hyp]): reg profit $explaining, vce(robust)

*collect, tag(model[6] reg[main] hyp[$hyp]): reg profit $explaining OUTFITTER_experience_d captain_experience_d, vce(robust)

collect, tag(model[6] reg[main] hyp[$hyp]): reg profit $explaining OUTFITTER_experience_d captain_experience_d 1.either_experience_d, vce(robust)

//The product of experiences is not significant. Regional experience is too limitative


collect style cell result, nformat(%3.2fc)  halign(center)
collect style cell result[_r_ci], sformat("[%s]") cidelimiter(,) nformat(%3.2f)
collect style cell result[_r_b]#colname[lnTONMOD], nformat(%5.4fc)

collect style cell result[N], nformat(%5.0f) 
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)

collect style row stack, nobinder
collect style header result[_r_b _r_ci], level(hide)
collect style cell cell_type[row-header], halign(left)

collect layout (colname#result[_r_b _r_ci] result[N r2 r2_a]) (model) (reg[main]#hyp[$hyp])

collect style showbase off
collect style save "profit_regressionv2.collectstyle", replace

collect preview



if "$hyp"=="Baseline" | "$hyp"=="Baseline_BBsample" {
	collect export "$output/regv2_$hyp.txt", replace
	collect export "$output/regv2_$hyp.docx", replace
}
else {
	collect export "$output/Robustness/regv2_$hyp.txt", replace
	collect export "$output/Robustness/regv2_$hyp.docx", replace
}

*if "$hyp"=="Baseline" blif

*test OUTFITTER_experience_d  OUTFITTER_regional_experience_d OUTFITTER_total_career
*test captain_experience_d  captain_regional_experience_d captain_total_career
*test war neutral
*test YEARAF yearsq

////////Proxy regressions



global proxy "ln_SLAXIMP MORTALITY ln_investment_per_slave pricemarkup "
collect, tag(model[1] reg[proxy] hyp[$hyp]):reg profit $proxy ln_length_in_days  i.FATEbin, vce(robust) 

collect, tag(model[2] reg[proxy] hyp[$hyp]):reg profit $proxy crowd ln_length_in_days i.FATEbin, vce(robust) 

collect, tag(model[3] reg[proxy] hyp[$hyp]):reg profit $proxy  i.FATEbin, vce(robust) 

collect, tag(model[4] reg[proxy] hyp[$hyp]):reg profit $proxy  ln_length_in_days, vce(robust) 

collect, tag(model[5] reg[proxy] hyp[$hyp]):reg profit $proxy  crowd i.FATEbin, vce(robust) 

collect style use "profit_regressionv2.collectstyle"

collect style cell result, nformat(%3.2fc)  halign(center)
collect style cell result[_r_ci], sformat("[%s]") cidelimiter(,) nformat(%3.2f)

collect style cell result[N], nformat(%5.0f) 
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)

collect style row stack, nobinder
collect style header result[_r_b _r_ci], level(hide)
collect style cell cell_type[row-header], halign(left)

collect layout (colname#result[_r_b _r_ci] result[N r2 r2_a]) (model[2 1 3 4 5 ]) (reg[proxy]#hyp[$hyp])

if "$hyp"=="Baseline" | "$hyp"=="Baseline_BBsample" {
	collect export "$output/regv2proxy_$hyp.txt", replace
	collect export "$output/regv2proxy_$hyp.docx", replace
}
else {
	collect export "$output/Robustness/regv2proxy_$hyp.txt", replace
	collect export "$output/Robustness/regv2proxy_$hyp.docx", replace
}

erase "profit_regressionv2.collectstyle"

end

capture erase "$output/Table6.xls"
capture erase "$output/Table6.txt"
capture erase "$output/Comparison between different assumptions.xls"
capture erase "$output/Comparison between different assumptions.txt"
capture erase "$output/TableBaseline-Imputed.xls"
capture erase "$output/TableBaseline-Imputed.txt"

collect clear

profit_regv2 0.5 1 1 0 1 0 1 0

*capture erase "Comparison between different assumptions.csv"
capture _renamefile "Comparison between different assumptions.txt" "Comparison between different assumptions.csv"

