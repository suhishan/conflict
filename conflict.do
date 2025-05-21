
/* Collapsing the conflict dataset on casualties by district.*/

// ssc install distinct 

 clear
 cd "C:\users\suhishan\Documents\Final Sem Research\Conflict"
 use "Conflict Data\conflict.dta"

*gen district = subinstr(adm_2, " district", "",.)
replace district = trim(lower(district))
replace district = "Not available" if missing(district)

save "Conflict Data\conflict.dta", replace

keep if inrange(year, 1996, 2006)

// cleaning district names to make the merge happen

replace district = "kapilbastu" if district == "kapilvastu"
replace district = "kavre" if district == "kavrepalanchok"
replace district = "makwanpur" if district == "makawanpur"
replace district = "panchthar" if district == "panchathar"
replace district = "parbat" if district == "parvat"
replace district = "udayapur" if district == "udaypur"


* Seeing what proportion of deaths occurred before 1999 for each district.*
gen pre99 = (year < 1999)
gen deaths_pre99 = best_est if pre99 == 1
gen deaths_post99 = best_est if pre99 == 0


// Collapsing the data to estimate total number of deaths and other variables by district.
collapse (sum) deaths_a deaths_b deaths_civilians deaths_unknown best_est high_est low_est deaths_pre99 deaths_post99, by(district) 
encode district, generate(district_factor) // turn district names into factors/numbers.

gen propdeaths_pre99 = deaths_pre99/deaths_post99 

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












