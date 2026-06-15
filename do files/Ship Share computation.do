
clear
use "${output}Cash flow all.dta"

* guillaume-claire-judith 
replace timing="Outfitting" if typeofcashflow=="Expenditure" 


* ASSUMPTION ABOUT THE TIMING OF INSURANCE PAYMENTS FOR OBS WHERE EXACT TIMING IS UNKNONWN, I.E. THEY ARE NOW ASSUMED TO HAVE BEEN PAID ONLY AFTER THE VOYAGE

replace timing="Return" if timing=="Unknown" & specification=="Insurance" |  timing=="Unknown" & specification=="Assurances" | timing=="Unknown" & specification=="Insurance (Assurances)"

* MERGE CASH FLOW AND VENTURE-DATABASES INTO ONE

merge m:1 ventureid using "${output}Venture all.dta", nogen
keep if completedataonoutlays=="yes" 
drop if ventureid=="NR028"
save "${output}Outlays database.dta", replace

*replace specificationcategory="NoShip" if specificationcategory!="Ship"

keep if timing=="Outfitting"

gen expenditure=value if typeofcashflow=="Expenditure" & timing=="Outfitting" & intermediarytradingoperation==0
replace expenditure=0 if missing(expenditure)
gen insurance=value if specification=="Insurance" & timing=="Outfitting" & intermediarytradingoperation==0


gen discount=value if typeofcashflow=="Return" & timing=="Outfitting" & intermediarytradingoperation==0
replace discount=0 if missing(discount)


bysort ventureid: egen totalgrossexp=total(expenditure)
bysort ventureid: egen totaldisc=total(discount)
bysort ventureid: egen totalinsurance=total(insurance)

replace expenditure = 0 if specificationcategory != "Ship"

bysort ventureid: egen totalship=total(expenditure)

bysort ventureid: keep if _n==1

replace totalgrossexp=totalgrossexp-totalship

gen shipshare = totalship/(totalgrossexp-totaldisc)
drop if shipshare==0



bys nationality : summarize shipshare

