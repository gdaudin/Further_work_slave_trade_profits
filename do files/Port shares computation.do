*ssc install rangestat

clear

/*
PLAC1TRA PLAC2TRA PLAC3TRA First, second and third place of purchase
YEARAF Year departed Africa (imputed)
TSLAVESP Total slave purchase
SLAXIMP Imputed total slaves embarked
NCAR13 NCAR15 NCAR17 Slaves carried from first, second, third port of purchase
Klas recommends using MAJBUYPT (place) MJBYPTIMP (imputed place), region, MAJBYIMP.
and SLAXIMP (imputed total slaves embarked)
*/


use "${tastdb}tastdb-exp-2026.dta", clear

keep YEARAF  MJBYPTIMP SLAXIMP MAJMAJBYIMP
collapse (sum) SLAXIMP, by(MJBYPTIMP YEARAF MAJMAJBYIMP)
xtset MJBYPTIMP YEARAF
decode MJBYPTIMP, generate(MJBYPTIMP_str)
rangestat (sum) totalslaves15y=SLAXIMP, interval(YEARAF -7 7)
label var totalslaves15y "Total slaves embarked (15 y. window)"
rangestat (sum) portslaves15y=SLAXIMP, interval(YEARAF -7 7) by(MJBYPTIMP)
label var portslaves15y "Total slaves embarked (15 y. window)"
gen port_share = portslaves15y/totalslaves15y if MAJMAJBYIMP!="Mixed, unknown or not in Africa" ////
        & strmatch(MJBYPTIMP_str,"*unspecified*")!=1
label var port_share "Share of slaves embarked (15 y. window)"


format SLAXIMP totalslaves15y portslaves15y %12.0gc
sort YEARAF

////Big ports
gen big_port=0
replace big_port=1 if port_share>0.01 & !missing(port_share)
label var big_port "Big African slave-trading port"
///For places that are too large
replace big_port=0 if inlist(MJBYPTIMP_str,"São Tomé or Princes Island", "Gold Coast, Fr definition","Gold Coast + Bight of Benin + Bight of Biafra")
label define big_port 0 "Less that 1% of total trade +/- 7 years" 1 "s. more that 1% of total trade +/- 7 years"
label value big_port big_port

twoway (line  totalslaves15y YEARAF)


save "${output}port_shares.dta", replace

/*
twoway line  port_share YEARAF if MJBYPTIMP_str=="St. Paul de Loanda", title("Share of St. Paul de Loanda")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Senegal", title("Share of Senegal")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Costa da Mina", title("Share of Costa da Mina")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Whydah", title("Share of Whydah")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Bonny", title("Share of Bonny")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Calabar", title("Share of Calabar")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Benguela", title("Share of Benguela")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Cabinda", title("Share of Cabinda")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Mozambique", title("Share of Mozambique")


