/* Collapsing the conflict dataset on casualties by district.*/

// ssc install distinct 

clear
cd "C:\users\suhishan\Documents\Final Sem Research\Conflict\"

/*
import delimited "Conflict Data\conflict.csv"
 Saving in a stata format. 
save "Conflict Data\conflict.dta"
*/

use "Conflict Data\conflict.dta"


// Clearning District names 

gen district = subinstr(adm_2, " district", "", .)
replace district = lower(trim(district))

// cleaning district names to make the merge happen

replace district = "kapilbastu" if district == "kapilvastu"
replace district = "kavre" if district == "kavrepalanchok"
replace district = "makwanpur" if district == "makawanpur"
replace district = "panchthar" if district == "panchathar"
replace district = "parbat" if district == "parvat"
replace district = "udayapur" if district == "udaypur"




// Collapsing the data to estimate total number of deaths and other variables by district.

// Keep in mind, this sums for whole of Nepal's conflicts from 1990 to 2022. So, there must be some code here that filters between 1998 and 2008.
/*
filterting by date code here 
----------------------------
*/
collapse (sum) deaths_a deaths_b deaths_civilians deaths_unknown best_est high_est low_est, by(district) 
encode district, generate(district_factor) // turn district names into factors/numbers.

save "Conflict Data\conflict_collapsed.dta", replace

