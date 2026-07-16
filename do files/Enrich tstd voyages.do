clear


*"


use "${output}voyages.dta", clear



merge m:1 VOYAGEID using "${tastdb}tastdb-exp-2026.dta"
drop _merge

sort ventureid VOYAGEID

keep ventureid numberofvoyages voyagenumber VOYAGEID YEARAF MAJBYIMP MAJBYIMP_str MJBYPTIMP MJBYPTIMP_str MAJMAJBYIMP MAJMAJBYIMP_num   /*
*/ SLAXIMP SLAMIMP CAPTAIN* OWNER* DATEEND DATEDEP FATE FATEcol FATEbin FATEdum* data nameofoutfitter/*
*/ nameofthecaptain YEARAF_own TONMOD nationality* YEARDEP Percentageofcaptiveswhodieddurin FlagofvesselIMP placeofpurchase
sort ventureid DATEDEP

foreach rank of numlist 1(1)7 {
	foreach var of varlist DATEEND DATEDEP {
	capture gen `var'`rank'=.
	replace `var'`rank'=`var' if voyagenumber==`rank'
	format `var'`rank' %tdNN/DD/CCYY
	}
}

//Here, we assume our data on outfitter is correct
replace OWNERA= nameofoutfitter if nameofoutfitter!=""
//Here, we assume stdt on captain and year is correct
replace CAPTAINA= nameofthecaptain if missing(CAPTAINA)
replace YEARAF = YEARAF_own if missing(YEARAF)
drop nameofoutfitter nameofthecaptain YEARAF_own


**** Major Regions
replace MAJMAJBYIMP="Mixed, unknown or not in Africa" if placeofpurchase=="" & MAJMAJBYIMP==""
replace MAJMAJBYIMP_num=2   if placeofpurchase=="" & MAJMAJBYIMP_num==.

replace MAJMAJBYIMP="West"  if inlist(placeofpurchase,"Sénégal") & MAJMAJBYIMP==""
replace MAJMAJBYIMP_num=4   if inlist(placeofpurchase,"Sénégal") & MAJMAJBYIMP_num==.

replace MAJMAJBYIMP="Gulf of Guinea" if inlist(placeofpurchase,"Côte de Guinée","Côte d’Or","Bonny","Côte de Bénin","Whydah") & MAJMAJBYIMP==""
replace MAJMAJBYIMP_num=1   if inlist(placeofpurchase,"Côte de Guinée","Côte d’Or","Bonny","Côte de Bénin","Whydah") & MAJMAJBYIMP_num==.
//No Côte de Bénin nor Whydah

replace MAJMAJBYIMP="South" if inlist(placeofpurchase,"Côte d’Angola","Mozambic") & MAJMAJBYIMP==""
replace MAJMAJBYIMP_num=3   if inlist(placeofpurchase,"Côte d’Angola","Mozambic") & MAJMAJBYIMP_num==.

***Smaller region
replace MAJBYIMP=9 if (inlist(placeofpurchase,"Côte de Guinée") | placeofpurchase=="") & MAJBYIMP==. /* "Other Africa"*/
***This is too large a region
replace MAJBYIMP=11 if inlist(placeofpurchase,"Sénégal") & MAJBYIMP==. /* Senegambia and offshore Atlantic*/
replace MAJBYIMP=2 if inlist(placeofpurchase,"Côte de Bénin","Whydah","Bonny") & MAJBYIMP==. /* "Bight of Benin"*/
//Only Bonny
replace MAJBYIMP=6 if inlist(placeofpurchase,"Côte d’Or") & MAJBYIMP==. /*Gold	Coast*/
replace MAJBYIMP=14 if inlist(placeofpurchase,"Côte d’Angola") & MAJBYIMP==. /* West Central Africa and St Helena (includes Luanda in TSTD) */
replace MAJBYIMP=4 if inlist(placeofpurchase,"Mozambic") & MAJBYIMP==. /* East Africa and Indian Ocean islands */

****Port
replace MJBYPTIMP=2 if inlist(placeofpurchase,"","Côte de Guinée") & MJBYPTIMP==. /* Africa, port unspecified*/
replace MJBYPTIMP=167 if inlist(placeofpurchase,"Sénégal") & MJBYPTIMP==. /* Sénégal*/
replace MJBYPTIMP=25 if inlist(placeofpurchase,"Côte de Bénin") & MJBYPTIMP==. /* Bight of Benin, place unspecified*/
///There is none
replace MJBYPTIMP=187 if inlist(placeofpurchase,"Whydah") & MJBYPTIMP==. /* Whydah, Ouidah*/
///There is none
replace MJBYPTIMP=33 if (inlist(placeofpurchase,"Bonny") | placeofpurchase=="") & MJBYPTIMP==. /* "Bonny"*/

replace MJBYPTIMP=85 if inlist(placeofpurchase,"Côte d’Or") & MJBYPTIMP==. /*Gold Coast, Fr definition*/
replace MJBYPTIMP=11 if inlist(placeofpurchase,"Côte d’Angola") & MJBYPTIMP==. /* Angola to Ardra */
replace MJBYPTIMP=129 if inlist(placeofpurchase,"Mozambic") & MJBYPTIMP==. /* Mozambique */


***Fate
replace FATEbin=0 if FATEbin==.
replace FATEbin=1 if FATEdum1==1

label values FATEcol fate
label values FATEbin fatebin

//labels defined at tstd import
label var FATEcol "Fate of venture (4 outcomes)"
label var FATEbin "Fate of venture (binary)"

**Crowding
gen crowd=SLAXIMP/TONMOD if SLAXIMP!=0
label var crowd "Number of embarked enslaved persons per ton"

* APPEND SLAVE PRICES
merge m:1 YEARAF using "${output}Prices.dta"
drop if _merge==2
drop _merge
gen pricemarkup=priceamerica/priceafrica
label var pricemarkup "Slave price markup between America and Africa"

***Give nationality (our coding) to TSTD voyages (where nationlity is coded in FlagofvesselIMP)
codebook FlagofvesselIMP

tab FlagofvesselIMP, missing
tab nationality, missing

replace nationality="French" if FlagofvesselIMP=="France" & nationality==""
replace nationality="English" if FlagofvesselIMP=="Great Britain" & nationality==""
replace nationality="Dutch" if FlagofvesselIMP=="Netherlands" & nationality==""
replace nationality="Spanish" if (FlagofvesselIMP=="Spain" | FlagofvesselIMP=="Spain / Uruguay") & nationality==""
replace nationality="Danish" if (FlagofvesselIMP=="Denmark / Baltic") & nationality==""
*We only need these five for the support / population comparison

encode nationality, generate(nationality_num)

*APPEND WARS
merge m:1 YEARAF nationality using "${output}European wars.dta"
drop if _merge==2
drop _merge

***APPEND NEUTRALITY
merge m:1 YEARAF nationality using  "${output}Neutrality.dta"
drop if _merge==2
drop _merge


**Compute the length of each voyage (if possible)
gen length_in_days=DATEEND-DATEDEP
label var length_in_days "Length of voyage (Europe to Europe) in days"
*drop DATEEND DATEDEP

*****Periods
gen period=1 if YEARAF<1751
replace period=2 if YEARAF>1750 & YEARAF<1776
replace period=3 if YEARAF>1775 & YEARAF<1801
replace period=4 if YEARAF>1800 & !missing(YEARAF)
label define lab_period 1 "pre-1750" 2 "1751-1775" 3 "1776-1800" 4 "post-1800"
label values period lab_period
label var period "Period"


***To get rid of values that cannot be averaged because some other one is missing (if we want to do that)
foreach var of varlist  SLAXIMP SLAMIMP length_in_days YEARAF {
	gen test`var'=1 if `var'==.
	replace test`var'=0 if `var'!=.
	egen test1=max(test`var'), by(ventureid)
	replace `var' =. if test1==1 & ventureid!=""
	drop test`var' test1	
}

****Voyage-level mortality
gen MORTALITY=(SLAXIMP-SLAMIMP)/SLAXIMP
replace MORTALITY=Percentageofcaptiveswhodieddurin if missing(MORTALITY) | MORTALITY<=0 
replace MORTALITY=0 if MORTALITY<0
label var MORTALITY "Enslaved people mortality rate"

********* save voyages with enriched data
save "tastdb-exp-2026_corr+own+various.dta", replace

