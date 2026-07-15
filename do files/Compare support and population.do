clear

cd "$dir"

use "tastdb-exp-2026_corr+own+various+careers.dta", replace


replace MORTALITY=(SLAXIMP-SLAMIMP)/SLAXIMP if missing(MORTALITY)
replace MORTALITY=Percentageofcaptiveswhodieddurin if missing(MORTALITY) | MORTALITY<=0 
replace MORTALITY=0 if MORTALITY<0
label var MORTALITY "Enslaved people mortality rate"


label define data 0 "No computation possible" 1 "With estimates" 2 "Without estimates"


*global varlist_o  YEARAF, TONMOD, crowd, SLAXIMP, MORTALITY, pricemarkup, length_in_days
*global varlist_d war, neutral, big_port, OUTFITTER_experience_d, captain_experience_d, either_experience_d, MAJMAJBYIMP_num, FATEbin



keep if /*!missing($varlist_o, $varlist_d) & */YEARAF>=1750 & YEARAF<=1795 & (FlagofvesselIMP=="France" | FlagofvesselIMP=="Great Britain" | FlagofvesselIMP=="Netherlands")

gen sample =  1 if data==1 | data==2
replace sample=0 if sample==.
label define sample_l 0 "TSTD (restricted)" 1 "Our sample" 
label values sample sample_l

expand 2 if sample == 1, generate(duplicates)
replace sample = 0 if duplicates ==1 & sample==1

*****Tables for dummies and categorical variables
collect clear
table (var) (sample), statistic(fvfrequency war neutral) statistic(fvproportion war neutral) ///
	statistic(count war neutral) nototals name(war) replace

collect style cell result[fvfrequency],nformat (%5.0fc)
collect style cell result[fvproportion],nformat (%3.2fc)
collect style header result, level(hide)
collect style row stack, nobinder
collect style save support_population, replace
collect preview

collect export "${output}Support_War_Neutrality.txt", as(txt) replace
collect export "${output}Support_War_Neutrality.docx", as(docx) replace


table (var) (sample), statistic(fvfrequency big_port MAJMAJBYIMP_num) statistic(fvproportion big_port MAJMAJBYIMP_num) ///
	statistic(count big_port MAJMAJBYIMP_num) nototals name(african_geography) replace


collect style use support_population
collect style cell result[fvproportion],nformat (%3.2fc)

collect preview

collect export "${output}Support_African_Geography.txt", as(txt) replace
collect export "${output}Support_African_Geography.docx", as(docx) replace


table (var) (sample), statistic(fvfrequency MAJBYIMP) statistic(fvproportion MAJBYIMP) nototals ////
	statistic(count MAJBYIMP) name(african_precise_geography)replace

collect style use support_population
collect style cell result[fvproportion],nformat (%3.2fc)
collect preview


collect export "${output}Support_African_Precise_Geography.txt", as(txt) replace
collect export "${output}Support_African_Precise_Geography.docx", as(docx) replace

table (var) (sample), statistic(fvfrequency OUTFITTER_experience_d captain_experience_d either_experience_d) ///
	statistic(fvproportion  OUTFITTER_experience_d captain_experience_d either_experience_d) ///
	statistic(count OUTFITTER_experience_d captain_experience_d either_experience_d) ///
	nototals name(experience) replace

collect style use support_population
collect style cell result[fvproportion],nformat (%3.2fc)
collect preview


collect export "${output}Support_Experience.txt", as(txt) replace
collect export "${output}Support_Experience.docx", as(docx) replace

table (var) (sample), statistic(fvfrequency FATEbin) statistic(fvproportion  FATEbin) statistic(count FATEbin) nototals name(experience) replace

collect style use support_population
collect style cell result[fvproportion],nformat (%3.2fc)
collect preview

collect export "${output}Support_Fate.txt", as(txt) replace
collect export "${output}Support_Fate.docx", as(docx) replace

***Fate dum n’est pas faite pour le STDT, car nous n’avons pas codé tous outcomes, mais seulement ceux dans le sample

table (var) (sample), statistic(fvfrequency FATEcol) statistic(fvproportion  FATEcol) statistic(count FATEcol) nototals name(experience) replace

collect style use support_population
collect style cell result[fvproportion],nformat (%3.2fc)
collect preview

collect export "${output}Support_Fate_precise.txt", as(txt) replace
collect export "${output}Support_Fate_precise.docx", as(docx) replace


capture erase support_population

***********************
*******Histograms for quantitative variables
**********************************************
quietly summarize MORTALITY if sample==1
local nbr_1=`r(N)'
quietly summarize MORTALITY if sample==0
local nbr_0=`r(N)'
twoway (histogram MORTALITY if sample==1, fraction width(0.05) start(-0.025) color(black%15)) ///
	(histogram MORTALITY if sample==0, fraction width(0.05) start(-0.025) color(black%30)),  ///
	legend(order(1 "TSDT (restricted)" 2 "Sample") position(6) row(1)) name(full, replace) note("TSTD: `nbr_0' obs; Sample: `nbr_1' obs" )

quietly summarize MORTALITY if sample==1 & MORTALITY<=.4
local nbr_1=`r(N)'
quietly summarize MORTALITY if sample==0 & MORTALITY<=.4
local nbr_0=`r(N)'
twoway (histogram MORTALITY if sample==1 & MORTALITY<=.4, fraction width(0.025) start(-0.0125) color(black%15)) ///
	(histogram MORTALITY if sample==0 & MORTALITY<=.4, fraction width(0.025) start(-0.0125) color(black%30)),  ///
	legend(order(1 "TSDT (restricted)" 2 "Sample") position(6) row(1)) name(zoom, replace) note("TSTD: `nbr_0' obs; Sample: `nbr_1' obs" )

graph combine full zoom
graph export "$graphs/Support_mortality.png",as(png) replace

quietly summarize TONMOD if sample==1
local nbr_1=`r(N)'
quietly summarize TONMOD if sample==0
local nbr_0=`r(N)'
twoway (histogram TONMOD if sample==1, fraction width(25) start(-12.5) color(black%15)) ///
	 (histogram TONMOD if sample==0, fraction width(25) start(-12.5) color(black%30)),  ///
	 legend(order(1 "TSDT (restricted)" 2 "Sample") position(6) row(1)) note("TSTD: `nbr_0' obs; Sample: `nbr_1' obs" )


graph export "$graphs/Support_TONMOD.png",as(png) replace


quietly summarize length_in_days if sample==1
local nbr_1=`r(N)'
quietly summarize length_in_days if sample==0
local nbr_0=`r(N)'
twoway (histogram length_in_days if sample==1, fraction width(25) start(-12.5) color(black%15)) ///
	 (histogram length_in_days if sample==0, fraction width(25) start(-12.5) color(black%30)),  ///
	 legend(order(1 "TSDT (restricted)" 2 "Sample") position(6) row(1)) note("TSTD: `nbr_0' obs; Sample: `nbr_1' obs")

graph export "$graphs/Support_length_in_days.png",as(png) replace


quietly summarize crowd if sample==1
local nbr_1=`r(N)'
quietly summarize crowd if sample==0
local nbr_0=`r(N)'
twoway (histogram crowd if sample==1, fraction width(0.1) start(-0.05) color(black%15)) ///
	 (histogram crowd if sample==0, fraction width(0.1) start(-0.05) color(black%30)),  ///
	 legend(order(1 "TSDT (restricted)" 2 "Sample") position(6) row(1)) note("TSTD: `nbr_0' obs; Sample: `nbr_1' obs")

graph export "$graphs/Support_crowd.png",as(png) replace


quietly summarize pricemarkup if sample==1
local nbr_1=`r(N)'
quietly summarize pricemarkup if sample==0
local nbr_0=`r(N)'
twoway (histogram pricemarkup if sample==1, fraction width(0.5) start(1.75) color(black%15)) ///
	 (histogram pricemarkup if sample==0, fraction width(0.5) start(1.75) color(black%30)),  ///
	 legend(order(1 "TSDT (restricted)" 2 "Sample") position(6) row(1)) note("TSTD: `nbr_0' obs; Sample: `nbr_1' obs")

graph export "$graphs/Support_pricemarkup.png",as(png) replace













