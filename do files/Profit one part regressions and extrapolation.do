
clear
*ssc install estout, replace
*ssc install outreg2, replace


*******Creating the estimation program that will be bootstrapped

capture program drop one_part
	program define one_part, rclass
	args explicatives model collect
	
	if "`collect'"=="yes" local collect_txt_reg = "collect, tag(model[`model']  hyp[$hyp] step[Regression]):"
	if "`collect'"=="no" local collect_txt_reg = ""

	if "`collect'"=="yes" local collect_txt_extra = "collect, tag(model[`model']  hyp[$hyp] step[Extrapolation]):"
	if "`collect'"=="no" local collect_txt_extra = ""
	else local collect_txt = ""

	`collect_txt_reg' reg profit `explicatives' if tstd_voyages==0, vce(robust) 
	frame population {
		predict predicted_profit, xb
		`collect_txt_extra' summarize predicted_profit
		return scalar mean_pred = r(mean)
		drop predicted_profit
	}
end


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
keep if (nationality == "English" | nationality == "French" | nationality == "Dutch")
replace lnTONMOD=ln(TONMOD) if tstd_voyages==1
replace ln_length_in_days=ln(length_in_days) if tstd_voyages==1
generate Crewatvoyageoutset_ln = ln(Crewatvoyageoutset)
label var Crewatvoyageoutset_ln "Crew at voyage outset (ln)"

gen oos_prediction_sample =0
replace oos_prediction_sample=1 if tstd_voyages==1 & (lnTONMOD<=ln(500) | lnTONMOD==.) & (ln_length_in_days<=ln(1000) | ln_length_in_days==.) ///
		& (Crewatvoyageoutset_ln<=ln(70) | Crewatvoyageoutset_ln==.) & (crowd<=4 | crowd==.)

gen prediction_sample =1 if profit !=.

capture frame drop population
frame put * if oos_prediction_sample ==1, into(population) 


///////Begining of collect
collect clear

local var_mod_0a ib3.nationality_num war neutral ib2.period i.MAJMAJBYIMP_num big_port OUTFITTER_experience_d captain_experience_d 1.either_experience_d
one_part "`var_mod_0a'" 0a yes
collect, tag(model[0a]  hyp[$hyp] step[Boot]): bootstrap r(mean_pred), noisily trace reps(1000) seed(12345) strata(oos_prediction_sample): one_part "ib3.nationality_num war neutral ib2.period i.MAJMAJBYIMP_num big_port OUTFITTER_experience_d captain_experience_d 1.either_experience_d" 0a no

local var_mod_0b `var_mod_0a' lnTONMOD Crewatvoyageoutset_ln
one_part "`var_mod_0b'" 0b yes
collect, tag(model[0b]  hyp[$hyp] step[Boot]): bootstrap r(mean_pred), noisily trace reps(1000) seed(12345) strata(oos_prediction_sample): one_part "`var_mod_0b'" 0b no

local var_mod_0y pricemarkup i.FATEbin 
one_part "`var_mod_0y'" 0y yes
collect, tag(model[0y]  hyp[$hyp] step[Boot]): bootstrap r(mean_pred), noisily trace reps(1000) seed(12345) strata(oos_prediction_sample): one_part "`var_mod_0y'" 0y no

local var_mod_0z `var_mod_0z' MORTALITY crowd ln_length_in_days 
one_part "`var_mod_0z'" 0z yes
collect, tag(model[0z]  hyp[$hyp] step[Boot]): bootstrap r(mean_pred), noisily trace reps(1000) seed(12345) strata(oos_prediction_sample): one_part "`var_mod_0z'" 0z no

local var_mod_1 `var_mod_0a' `var_mod_0y'
one_part "`var_mod_1'" 1 yes
collect, tag(model[1]  hyp[$hyp] step[Boot]): bootstrap r(mean_pred), noisily trace reps(1000) seed(12345) strata(oos_prediction_sample): one_part "`var_mod_1'" 1 no

local var_mod_2 `var_mod_0b' `var_mod_0z'
one_part "`var_mod_2'" 2 yes
collect, tag(model[2]  hyp[$hyp] step[Boot]): bootstrap r(mean_pred), noisily trace reps(1000) seed(12345) strata(oos_prediction_sample): one_part "`var_mod_2'" 2 no



collect style cell result, nformat(%3.2fc)  halign(center)
collect style cell result[mean], nformat(%4.3fc)  halign(center)
collect style cell result[_r_ci], sformat("[%s]") cidelimiter(,) nformat(%3.2f)
collect style cell result[N], nformat(%5.0fc)


collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)

collect style row stack, nobinder
collect label levels step Regression  "Number of observations for regression"
collect label levels step Extrapolation  "Number of observations for extrapolation"
collect label levels result _r_ci  "95% confidence interval (bootstrapped)", modify
collect style header result[_r_b _r_ci N], level(hide)
collect label levels result mean "Mean extrapolated profitability (bootstrapped confidence interval)" r2 "R-squared" r2_a "Adjusted R-squared", replace
collect style header result[mean], level(label)
collect style header Regression, title(label)
collect style cell cell_type[row-header], halign(left)
collect style showbase off

collect style cell result[r2_a], border(bottom, pattern(single))


collect layout (colname[2.nationality_num 3.nationality_num 4.nationality_num war neutral 1.period 2.period 3.period 4.period ///
			1.MAJMAJBYIMP_num 2.MAJMAJBYIMP_num 3.MAJMAJBYIMP_num 4.MAJMAJBYIMP_num big_port OUTFITTER_experience_d ///
			captain_experience_d 1.either_experience_d lnTONMOD Crewatvoyageoutset_ln ///
            pricemarkup 0.FATEbin 1.FATEbin MORTALITY crowd ln_length_in_days _cons]#result[_r_b _r_ci] ///
			result[N]#step[Regression] result[r2 r2_a]  result[N]#step[Extrapolation] result[mean _r_ci] )  ///
			(model[0a 0b 0y 0z 1 2]) (hyp[$hyp])
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

