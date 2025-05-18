
/* Collapsing the conflict dataset on casualties by district.*/

// ssc install distinct 

 clear
 cd "C:\users\suhishan\Documents\Final Sem Research\Conflict"
 use "Conflict Data\conflict.dta"


// cleaning district names to make the merge happen

replace district = "kapilbastu" if district == "kapilvastu"
replace district = "kavre" if district == "kavrepalanchok"
replace district = "makwanpur" if district == "makawanpur"
replace district = "panchthar" if district == "panchathar"
replace district = "parbat" if district == "parvat"
replace district = "udayapur" if district == "udaypur"


// Keep in mind, this sums for whole of Nepal's conflicts from 1990 to 2022. So, there must be some code here that filters between 1998 and 2008.
/*
filterting by date code here 
----------------------------
*/

// Collapsing the data to estimate total number of deaths and other variables by district.
collapse (sum) deaths_a deaths_b deaths_civilians deaths_unknown best_est high_est low_est, by(district) 
encode district, generate(district_factor) // turn district names into factors/numbers.

save "Conflict Data\conflict_collapsed.dta", replace


/* Load the forest dataset */

use "Do and Iyer\forest.dta", clear
gen district = trim(lower(distname))

replace district = "chitwan" if district == "chitawan" 
// chitawan to chitwan
replace district = "kavre" if district == "kavrepalanchok"
// kavrepalanchok to kavre.
replace district = "sindhupalchowk" if district == "sindhupalchok"
// sindhupalchowk to sindhupalchok
replace district = "dhanusha" if district == "dhanusa"


/* Merge the conflict dataset with the forest data */

merge 1:1 district using "Conflict Data\conflict_collapsed.dta"
save "Conflict Data\conflict_collapsed.dta", replace












