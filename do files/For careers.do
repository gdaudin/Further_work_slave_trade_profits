
clear


///////////////////////////////////////////////////////////////////////////////
////Captains and OUTFITTERs’ career.
/////1. Start with tstd enriched with our data.
//// 2. correct names in TSTD
/////3. PREPARE OUTFITTERS’ AND CAPTAINS’ TRACK RECORD
/////4. Merge track record with career data

*1. Start wit tstd enrchided with our data

use "${tastdb}tastdb-exp-2026_corr+own+various.dta", clear

//2. Correct owner’s names TSTD

**We make the assumption the first owner is the outfitter in tsdt
foreach letter in A /*B C D E F G H I J K L M O P*/ {
	//French data
	replace OWNER`letter' = "Chateaubriand" if strmatch(OWNER`letter', "*Chateaubriand*")==1
	replace OWNER`letter' = "Romanet, Adrien" if strmatch(OWNER`letter', "*Romanet*")==1
	replace OWNER`letter' = "Ballan (Aîné)" if strmatch(OWNER`letter',"*Ballan*né*")==1
	replace OWNER`letter' = "Bouteiller Père et Fils" if strmatch(OWNER`letter',"*Bouteiller*")==1
	replace OWNER`letter' = "Chaurand" if strmatch(OWNER`letter',"*Chaurand*")==1
	replace OWNER`letter' = "Darreche (Frères)" if strmatch(OWNER`letter',"*Darreche*")==1
	replace OWNER`letter' = "De Guer" if strmatch(OWNER`letter',"*Deguer*")==1
	replace OWNER`letter' = "Desclos Le Perley freres" if strmatch(OWNER`letter',"*Desclos*")==1
	replace OWNER`letter' = "Geslin" if strmatch(OWNER`letter',"*Geslin*")==1
	replace OWNER`letter' = "Jogues" if strmatch(OWNER`letter',"*Jogues*")==1
	replace OWNER`letter' = "Langevin" if strmatch(OWNER`letter',"*Langevin*")==1
	replace OWNER`letter' = "Arnou" if strmatch(OWNER`letter',"*Arnou*(*)*")==1
	replace OWNER`letter' = "Bertrand, Nicolas" if strmatch(OWNER`letter',"*Bertrand, Nicolas*")==1
	replace OWNER`letter' = "Castaing, François" if strmatch(OWNER`letter',"*Castaing*")==1 & strmatch(OWNER`letter',"*Castaing, Abel*")!=1

	//Dutch data
	replace OWNER`letter' = "Zitter, Jan de" if OWNER`letter' =="Zitter, Jan, de"
	replace OWNER`letter' = "Middelburgse Commercie Compagnie" if OWNER`letter' == "Middelburgsche Commercie Compagnie"

	//English data
	replace OWNER`letter' = "Tuohy, David" if strmatch(OWNER`letter',"*Tuohy*")==1
	replace OWNER`letter' = "Rogers, James" if strmatch(OWNER`letter',"*Rogers*,*James*")==1
	replace OWNER`letter' = "Lumley, Thomas" if strmatch(OWNER`letter',"*Lumley*")==1
	replace OWNER`letter' = "Davenport, William" if strmatch(OWNER`letter',"*Davenport, Wm*")==1

	//Dutch data
	replace OWNER`letter' = "Bargum Trading Society" if strmatch(OWNER`letter',"*Bargum Trading Society*")==1
}


////// Correct captain’s names TSTD
foreach letter in A B C {
	replace CAPTAIN`letter' = "Devigne, Et" if strmatch(CAPTAIN`letter', "*Devigne, E*")==1
	replace CAPTAIN`letter' = "Barkley, John" if strmatch(CAPTAIN`letter', "*Barkley,J*")==1
	replace CAPTAIN`letter' = "Berthomme, Nicolas" if strmatch(CAPTAIN`letter', "*Berthommé, Nicholas*")==1
	replace CAPTAIN`letter' = "Bodin Desplantes" if strmatch(CAPTAIN`letter', "*Bodin Desplantes*")==1
	replace CAPTAIN`letter' = "Brancker, Peter" if strmatch(CAPTAIN`letter', "*Brancker, P*")==1
	replace CAPTAIN`letter' = "Brettargh, William" if strmatch(CAPTAIN`letter', "*Brettargh, William*")==1
	replace CAPTAIN`letter' = "Callow, C" if strmatch(CAPTAIN`letter', "*Callow*")==1
	replace CAPTAIN`letter' = "Carus, Chris" if strmatch(CAPTAIN`letter', "*Carus, Chr*")==1
	replace CAPTAIN`letter' = "Chateaubriand du Plessis, Pierre-Anne-Marie" if strmatch(CAPTAIN`letter', "*Chateaubriand*")==1
	replace CAPTAIN`letter' = "Clark, William" if strmatch(CAPTAIN`letter', "*Clark, W*")==1
	replace CAPTAIN`letter' = "Clémenceau, Alexandre" if strmatch(CAPTAIN`letter', "*Cl*menceau, Al*")==1
	replace CAPTAIN`letter' = "Durocher-Sorin" if strmatch(CAPTAIN`letter', "Durocher")==1 // there are homonymes, but not around the same time//
	replace CAPTAIN`letter' = "Fowler, John" if strmatch(CAPTAIN`letter', "*Fowler, John*")==1
	replace CAPTAIN`letter' = "Guyot, Jean" if strmatch(CAPTAIN`letter', "Guyot, J")==1
	replace CAPTAIN`letter' = "La Causse, Bernard" if strmatch(CAPTAIN`letter', "*La Causse*")==1
	replace CAPTAIN`letter' = "Lawson, William" if strmatch(CAPTAIN`letter', "*Lawson, W*m*")==1
	replace CAPTAIN`letter' = "Le Sourd, J-Fr" if strmatch(CAPTAIN`letter', "*Le Sourd, J-F*")==1
	replace CAPTAIN`letter' = "Mary, Joseph" if strmatch(CAPTAIN`letter', "*Mary, Jos*")==1
	replace CAPTAIN`letter' = "Nicholson, Joseph" if strmatch(CAPTAIN`letter', "*Nicholson, Jos*")==1
	replace CAPTAIN`letter' = "Pacaud, Pierre" if strmatch(CAPTAIN`letter', "*Pacaud, P*")==1
	replace CAPTAIN`letter' = "Ringeard, Mathurin" if strmatch(CAPTAIN`letter', "*Ringeard*")==1
	replace CAPTAIN`letter' = "Smale, John" if strmatch(CAPTAIN`letter', "*Smale, Jno*")==1
	replace CAPTAIN`letter' = "Smith, John" if strmatch(CAPTAIN`letter', "*Smith, Jn*")==1
	replace CAPTAIN`letter' = "Stangeways, James" if strmatch(CAPTAIN`letter', "*Stangeways, Jas*")==1
	replace CAPTAIN`letter' = "Tanquerel, Julien-Edouard" if strmatch(CAPTAIN`letter', "*Tanquerel, J-E*")==1
	replace CAPTAIN`letter' = "Van Alstein, Pierre-Ignace-Lievin" if strmatch(CAPTAIN`letter', "*Alstein*Pierre*")==1
	replace CAPTAIN`letter' = "Vigneron, François" if strmatch(CAPTAIN`letter', "*Vigneron*")==1
	replace CAPTAIN`letter' = "Wotherspoon, Alex" if strmatch(CAPTAIN`letter', "*Wotherspoon, Alexander*")==1
}


save "${tastdb}tastdb-exp-2026_corr+own+various.dta", replace


// * 3. PREPARE OUTFITTERS’ AND CAPTAINS’ TRACK RECORD

use "${tastdb}tastdb-exp-2026_corr+own+various.dta", clear
keep CAPTAINA CAPTAINB CAPTAINC YEARAF VOYAGEID MAJMAJBYIMP

capture erase "${output}Captain.dta"
 
foreach captainletter in A B C {
	drop if CAPTAIN`captainletter' == ""
	preserve
	keep CAPTAIN`captainletter' YEARAF VOYAGEID MAJMAJBYIMP
	rename CAPTAIN`captainletter' CAPTAIN
	capture append using "${output}Captain.dta"
	duplicates report CAPTAIN VOYAGEID
	save "${output}Captain.dta", replace
	restore
}


//THERE IS AN ISSUE IN TSDT DATAT
use "${output}Captain.dta", clear
duplicates drop CAPTAIN VOYAGEID, force
save "${output}Captain.dta", replace
 
use "${tastdb}tastdb-exp-2026_corr+own+various.dta", clear

 keep OWNERA /*OWNERB OWNERC OWNERD /*
 */ OWNERE OWNERF OWNERG OWNERH OWNERI OWNERJ OWNERK OWNERL OWNERM OWNERN /* 
 */ OWNERO OWNERP*/ YEARAF VOYAGEID MAJMAJBYIMP

  
capture erase "${output}OUTFITTER.dta"
 
foreach letter in A /*B C D E F G H I J K L M O P*/ {
	drop if OWNER`letter' == ""
	preserve
	keep OWNER`letter' YEARAF VOYAGEID MAJMAJBYIMP
	rename OWNER`letter' OUTFITTER
	capture append using "${output}OUTFITTER.dta"
	save "${output}OUTFITTER.dta", replace
	restore
}

use "${output}OUTFITTER.dta", clear

//This command insures that when multiple members of the same family are listed as OUTFITTERs, they are not counted twice
bys OUTFITTER VOYAGEID YEARAF: keep if _n==1

save "${output}OUTFITTER.dta", replace

**COMPUTE EXPERIENCE TAKING INTO ACCOUNT HOMONYMES

use "${output}Captain.dta", clear
drop if CAPTAIN=="" | YEARAF==.
sort CAPTAIN YEARAF

sort CAPTAIN YEARAF 

gen homonyme=0
foreach nbr of num 1(1)6 {
replace homonyme = `nbr' if CAPTAIN==CAPTAIN[_n-1] & homonyme[_n-1] ==`nbr'-1 & YEARAF-YEARAF[_n-1] >=20
replace homonyme = `nbr' if CAPTAIN==CAPTAIN[_n-1] & homonyme[_n-1] ==`nbr'
}


sort CAPTAIN homonyme YEARAF 
bys CAPTAIN homonyme: generate captain_total_career = _N
label var captain_total_career "Total number of voyages of the captain"
bys CAPTAIN homonyme: generate captain_experience= _n-1
label var captain_experience "Number of previous voyages of the captain"

sort CAPTAIN homonyme  MAJMAJBYIMP YEARAF
bys CAPTAIN homonyme MAJMAJBYIMP : generate captain_regional_experience= _n-1 if MAJMAJBYIMP!=""

*For multiple voyages in a year (we take the max experience)
*First line workes if all the voyages in a specific year are to the same region
collapse (min) captain_experience captain_total_career captain_regional_experience (count) nbr_in_year=captain_experience, by(CAPTAIN YEARAF homonyme MAJMAJBYIMP)
egen temp_captain_experience = min(captain_experience), by(CAPTAIN YEARAF homonyme)
replace captain_experience=temp_captain_experience if captain_experience!=temp_captain_experience
drop temp_captain_experience

**Dummy creation
gen captain_experience_d=1 
replace captain_experience_d=0 if captain_experience>0 
label var captain_experience_d "First voyage of the captain"

gen captain_regional_experience_d=1 
replace captain_regional_experience_d=0 if captain_regional_experience>0 
label var captain_regional_experience_d "First voyage of the captain in the region"

gen captain_total_career_d=1 
replace captain_total_career_d=0 if captain_total_career>1
label var captain_total_career_d "Only voyage of the captain"

save "${output}Captain.dta", replace


//Idem for OUTFITTERs


use "${output}OUTFITTER.dta", clear
drop if OUTFITTER=="" | YEARAF==.
sort OUTFITTER YEARAF

sort OUTFITTER YEARAF

gen homonyme=0
foreach nbr of num 1(1)6 {
replace homonyme = `nbr' if OUTFITTER==OUTFITTER[_n-1] & homonyme[_n-1] ==`nbr'-1 & YEARAF-YEARAF[_n-1] >=20
replace homonyme = `nbr' if OUTFITTER==OUTFITTER[_n-1] & homonyme[_n-1] ==`nbr'
}


sort OUTFITTER homonyme OUTFITTER 
bys OUTFITTER homonyme: generate OUTFITTER_total_career = _N
label var OUTFITTER_total_career "Total number of voyages of the outfitter"
bys OUTFITTER homonyme: generate OUTFITTER_experience= _n-1
label var OUTFITTER_experience "Number of previous voyages of the outfitter"

sort OUTFITTER homonyme MAJMAJBYIMP YEARAF 
bys OUTFITTER homonyme MAJMAJBYIMP: generate OUTFITTER_regional_experience= _n-1 if MAJMAJBYIMP!=""


*First line works if all the voyages in a specific year are to the same region
collapse (min) OUTFITTER_experience OUTFITTER_total_career OUTFITTER_regional_experience (count) nbr_in_year=OUTFITTER_experience, by(OUTFITTER YEARAF homonyme MAJMAJBYIMP)
egen temp_OUTFITTER_experience = min(OUTFITTER_experience), by(OUTFITTER YEARAF homonyme)
replace OUTFITTER_experience=temp_OUTFITTER_experience if OUTFITTER_experience!=temp_OUTFITTER_experience
drop temp_OUTFITTER_experience


**Dummy creation
gen OUTFITTER_experience_d=1 
replace OUTFITTER_experience_d=0 if OUTFITTER_experience>0 
label var OUTFITTER_experience_d "First voyage of the outfitter"

gen OUTFITTER_regional_experience_d=1 
replace OUTFITTER_regional_experience_d=0 if OUTFITTER_regional_experience>0 
label var OUTFITTER_regional_experience_d "First voyage of the outfitter in the region"

gen OUTFITTER_total_career_d=1
replace OUTFITTER_total_career_d=0 if OUTFITTER_total_career>1 
label var OUTFITTER_total_career_d "Only voyage of the outfitter"

save "${output}OUTFITTER.dta", replace


/////4. Merge voyage db with career database

*****Now merge voyages with careers

use "${tastdb}tastdb-exp-2026_corr+own+various.dta", clear


* MERGE WITH Career DATASET (CAPTAIN)
generate CAPTAIN = ""
replace CAPTAIN = CAPTAINA
*replace CAPTAIN = nameofthecaptain if CAPTAIN==""
replace CAPTAIN="" if CAPTAIN=="."
merge m:1 CAPTAIN YEARAF MAJMAJBYIMP using "${output}Captain.dta"
drop if _merge==2
*For debugging
*br CAPTAIN YEARAF ventureid VOYAGEID if _merge==1 & (CAPTAIN!="" & YEARAF !=.)
assert (CAPTAIN=="" | YEARAF ==.) if _merge==1 
drop _merge



* MERGE WITH Career DATASET (OUTFITTER)
generate OUTFITTER = ""
replace OUTFITTER = OWNERA if OUTFITTER==""
replace OUTFITTER="" if OUTFITTER=="."
merge m:1 OUTFITTER YEARAF MAJMAJBYIMP using "${output}OUTFITTER.dta"
drop if _merge==2
*For debugging
*br OUTFITTER YEARAF ventureid VOYAGEID if _merge==1 & (OUTFITTER!="" & YEARAF !=.)
assert (OUTFITTER=="" | YEARAF ==.) if _merge==1
drop _merge

////de base
replace captain_experience_d=1 if captain_experience_d==.
replace OUTFITTER_experience_d=1 if OUTFITTER_experience_d==.
label define exp_dum 0 "Not first voyage or unknown" 1 "First voyage", replace
label value captain_experience_d exp_dum 
label value OUTFITTER_experience_d exp_dum 


gen either_experience_d = 2 if OUTFITTER_experience_d==1 & captain_experience_d==1
replace either_experience_d = 1 if (OUTFITTER_experience_d==1 | captain_experience_d==1) & either_experience_d==.
replace either_experience_d = 0  if (OUTFITTER_experience_d==0 |OUTFITTER_experience_d==.) & (captain_experience_d==0 |captain_experience_d==.) 
label var either_experience_d "First voyage of the captain and the outfitter"
label  define exp_dum_square 0 "Not the first voyage (or unknown) of both the captain and the outfitter" ///
		1 "First voyage of only one of the captain or the outfitter" ///
		2 "First voyage of both the captain and the outfitter", replace
label value either_experience_d exp_dum_square

////idem, regional
replace captain_regional_experience_d=1 if captain_regional_experience_d==.
replace OUTFITTER_regional_experience_d=1 if OUTFITTER_regional_experience_d==.
label define exp_regional_dum 0 "Not first voyage in the region or unknown" 1 "First voyage in the region", replace
label value captain_regional_experience_d exp_regional_dum 
label value OUTFITTER_regional_experience_d exp_regional_dum 


gen either_regional_experience_d = 2 if OUTFITTER_regional_experience_d==1 & captain_regional_experience_d==1
replace either_regional_experience_d = 1 if (OUTFITTER_regional_experience_d==1 | captain_regional_experience_d==1) & either_regional_experience_d==.
replace either_regional_experience_d = 0  if (OUTFITTER_regional_experience_d==0 |OUTFITTER_regional_experience_d==.) & (captain_regional_experience_d==0 |captain_regional_experience_d==.) 
label var either_regional_experience_d "First voyage in the region of the captain and the outfitter"
label  define exp_regional_dum_square 0 "Not the first voyage in the region (or unknown) of both the captain and the outfitter " ///
		1 "First voyage in the region of only one of the captain or the outfitter" ///
		2 "First voyage in the region of both the captain and the outfitter", replace
label value either_regional_experience_d exp_dum_square

save "${tastdb}tastdb-exp-2026_corr+own+various+careers.dta", replace
