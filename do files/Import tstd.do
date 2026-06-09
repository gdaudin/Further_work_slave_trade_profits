clear all

import delimited "$dir/2026 06 09 tstd from www.slavevoyages.org:voyage:trans-atlantic#voyages.csv", varnames(1) case(preserve) bindquote(strict)

*import delimited "$dir/2026 03 25 tstd from www.slavevoyages.org:voyage:trans-atlantic#voyages.csv", varnames(1) case(preserve) bindquote(strict)


/*///Here are the indications I have about the coding of YEARAF in the original databese
Below is the syntax section related to the imputation of YEARAF along with a note by the creators of the impute script (David Eltis and Paul Lachance):

* Variables defining yeardep, yearaf, yearam, year5, year10, year25, and year100 depend on
* independent coding of datedepc, d1slatrc, dlslatrc, datarr34, datarr38, datarr41,
* ddepamc, and datarr45 -- CONTRIBUTE program should generate distinct day, month,
* and year variables for each stage of voyage as well as composite date variables where
* all three components (yyyy-mm-dd).  SPSS commands to extract year variables using
* Date and Time Wizard deleted since assumed they will be created as data variables
* from information entered by contributor.

Compute yearaf=dlslatrc. // according to the SPSS codebook this is Year that vessel left last slaving port
If (missing(yearaf)) yearaf=d1slatrc. // according to the SPSS codebook this is Year that slave purchase began
If (missing(yearaf)) yearaf=datedepc. // according to the SPSS codebook this is Year that voyage began
If (missing(yearaf)) yearaf=datarr34. // according to the SPSS codebook this is Year of first disembarkation of slaves
If (missing(yearaf)) yearaf=ddepamc. // according to the SPSS codebook this is Year of departure from last place of landing
If (missing(yearaf)) yearaf=datarr45. // according to the SPSS codebook this is Year in which voyage completed

*/

gen YEARAF = real(substr(DatevesseldepartedAfrica, 1, 4))
replace YEARAF = real(substr(Datepurchaseofcaptivesbegan, 1, 4)) if missing(YEARAF)
replace YEARAF = real(substr(Datevoyagebegan, 1, 4)) if missing(YEARAF)
replace YEARAF = real(substr(Datefirstdisembarkationofcaptive, 1, 4)) if missing(YEARAF)
replace YEARAF = real(substr(Datedepartedlastplaceoflanding, 1, 4)) if missing(YEARAF)
replace YEARAF = real(substr(Datevoyagecompleted, 1, 4)) if missing(YEARAF)


/*Information on " Outcome of voyage for owner
RECODE fate
(1, 49, 68, 77, 79, 88, 92, 135, 203, 205, 206, 207, 208=1)
(2, 3, 4, 5, 27, 28, 29, 30, 54, 58, 59, 85, 86, 91, 94, 95, 97=2)
(6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 31, 39, 41, 42, 43, 44,
45, 46, 47, 48, 50, 51, 52, 53, 55, 56, 57, 66, 67, 69, 71, 72, 73, 74, 75, 76, 78, 80, 81, 82, 87,
89, 90, 93, 98, 99, 102, 103, 104, 106, 108, 109,110,111,112,113,114,118,120,121,122,123,124,
125,126,127,128,130,132,134,138,141,142,144,148,153,154,155,156,157,159,160,161,162,163,
164,165,166,170,171,172,173,174,176,177,178,179,180,181,182,183,184,185,187,188,189,191,
192,193,194,195,196,198,199,201,202=3)
(40,70,96,208=4)
into fate4.
EXECUTE.

There is a contradiction in this definition (208), both coded at 1 and 4. I have coded it as not-1. Anyway, I am only interested at the 1 category

*/


gen FATE4 = 1 if inlist(Particularoutcome,"Voyage completed as intended","Sold slaves in Americas - subsequent fate unknown","Sold in the Americas after disembarking slaves")
replace FATE4 = 1 if inlist(Particularoutcome,"Arrived in Africa, subsequent fate unknown","Crew mutiny; slaves landed in the Americas","Sold prematurely in Europe after disembarking slaves in the Americas")
replace FATE4 = 1 if inlist(Particularoutcome,"Returned direct to Africa after bringing slaves to the Americas","Vice-Admiralty Court, Tortola, restored","Captured by the British, retaken by original crew, completed voyage")
replace FATE4 = 1 if inlist(Particularoutcome,"Captured by English, slaves turned loose on Spanish Main","Sold slaves in Africa","Sold slaves in Europe, subsequent fate unknown")

rename VoyageID VOYAGEID
tostring(VOYAGEID), replace

encode Imputedprincipalplaceofcaptivepu,generate(MJBYPTIMP)
rename TotalembarkedIMP SLAXIMP

save "tastdb-exp-2026.dta", replace



