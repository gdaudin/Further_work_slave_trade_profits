clear


*"


use  "${tastdb}tastdb-exp-2026_corr+own+various+careers.dta", clear


****We work only on the voyages in the profit database

drop if ventureid==""
**** replace region by mixed if it is not constant inside each ventureid

foreach var of varlist MAJMAJBYIMP {
	bys  ventureid (`var'): replace `var'="Mixed, unknown or not in Africa" if `var'[1]!=`var'[_N]
}

gsort - SLAXIMP
sort ventureid YEARAF, stable


codebook nationality_num

******move back to ventures
collapse (first)  MAJMAJBYIMP data nationality_num (mean) YEARDEP YEARAF SLAXIMP SLAMIMP length_in_days (max) numberofvoyages  FATEdum* DATEDEP* DATEEND* /*
			*/ (min) OUTFITTER_experience* OUTFITTER_regional_experience* captain_experience* captain_regional_experience* /*
			*/ (mean) OUTFITTER_total_career* captain_total_career* priceamerica/*
			*/ (mean) big_port crowd pricemarkup war neutral TONMOD Percentageofcaptiveswhodieddurin/*
			*/, by(ventureid)



label var MAJMAJBYIMP "African region of trade"
label var neutral "Neutrality of own nation"
label var war "War involving own nation"
label var TONMOD "Tonnage standardized on British measured tons, 1773-1835"
label var crowd "Number of embarked enslaved people per ton"
label var pricemarkup "Enslaved people price markup between America and Africa"
label var SLAXIMP "Imputed number of enslaved people embarked"
label var OUTFITTER_total_career "Total number of voyages of the outfitter (mean)"
label var captain_total_career "Total number of voyages of the captain (mean)"
label var OUTFITTER_experience_d "Not the first voyage of the outfitter (min)"
label var captain_experience_d "Not the first voyage of the captain (min)"
label var big_port "Big African slave-trading port"
label var nationality_num "Nationality"

///various labels
label define nation_num 1 "Danish" 2 "Dutch" 3 "English" 4 "French" 5 "Spanish" 
label values nationality_num nation_num


label values war war
label values neutral neutral


*make dummies out of means

foreach var in war neutral {
	replace `var' = 1 if `var' >=0.5
	replace `var' = 0 if `var' <0.5
}


sort ventureid YEARAF

*** GENERATE FATEcol from dummy variables after collapsing.
gen FATEcol=1 if FATEdum1==1
replace FATEcol=3 if FATEdum3==1
replace FATEcol=2 if FATEdum2==1
replace FATEcol=4 if FATEdum4==1
replace FATEcol=4 if FATEcol==.
gen FATEbin=0
replace FATEbin=1 if FATEdum1==1
drop FATEdum*

label values FATEcol fate
label values FATEbin fatebin

//labels defined at tstd import
label var FATEcol "Fate of venture (4 outcomes)"
label var FATEbin "Fate of venture (binary)"


save "${output}Ventures+TSTD variables.dta", replace

/////Enrich Venture all.dta








