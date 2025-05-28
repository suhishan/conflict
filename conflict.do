
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
replace district = "tehrathum" if district == "terhathum"
replace district = "dadheldura" if district == "dadeldhura"






* Seeing what proportion of deaths occurred before 1999 for each district.*
gen pre99 = (year < 1999)
gen pre02 = (year < 2002)
gen deaths_pre99 = best_est if pre99 == 1
gen deaths_post99 = best_est if pre99 == 0
gen deaths_pre02 = best_est if pre02 == 1
gen deaths_post02 = best_est if pre02 == 0 // Remember even if it says post02, it includes 02, however pre02 doesnot include 02.

gen incidents = 1 // To coun the number of incidents per district later on.


// Collapsing the data to estimate total number of deaths and other variables by district.
collapse (sum)  deaths_a deaths_b deaths_civilians deaths_unknown best_est high_est low_est deaths_pre99 deaths_post99 deaths_pre02 deaths_post02 incidents, by(district) 
*encode district, generate(district_factor) // turn district names into factors/numbers.

gen propdeaths_pre99 = deaths_pre99/deaths_post99 
gen propdeaths_pre02 = deaths_pre02/deaths_post02
gen district_abbrev = lower(substr(district, 1, 4))
replace district_abbrev = "dhak" if district == "dhankuta"
replace district_abbrev = "sinp" if district == "sindhupalchowk"

save "Conflict Data\conflict_collapsed.dta", replace


/* Load the forest dataset */

	use "Do and Iyer\forest.dta", clear
	gen district = trim(lower(distname))

	replace district = "chitwan" if district == "chitawan" 
	replace district = "kavre" if district == "kavrepalanchok"
	replace district = "sindhupalchowk" if district == "sindhupalchok"
	replace district = "dhanusha" if district == "dhanusa"
	replace district = "tehrathum" if district == "terhathum"

	gen district_abbrev =  lower(substr(district, 1, 4))
	replace district_abbrev = "dhak" if district == "dhankuta"
	replace district_abbrev = "sinp" if district == "sindhupalchowk"
	replace district_abbrev = "dadh" if district_abbrev == "dade"

	/* Merge the conflict dataset with the forest data */

	merge 1:1 district_abbrev using "Conflict Data\conflict_collapsed.dta"
	save "Conflict Data\conflict_collapsed.dta", replace


	/* Now, we are trying to gauge treatment and control districts

	Two stylized methods: 
	1. Using the 75th percentile of forest cover to determine treatment and control.
	2. Using pre 1999 conflict levels, or pre 2002 conflict, which may be endogenous tho. */

	drop if district == "not available"
	*Using the 75th percentile for forest cover to determine treatment and control*

	*First Stage Regression*
	gen forest_cover = round(norm_forest * 100, .001)
	gen elevation = elevation_max * 1000

	reg best_est forest_cover elevation, vce(robust)

	sum forest_cover, detail
	scalar p75 = r(p75)
	scalar p65  = r(p65)

	gen treatment = (forest_cover > p75)

	save "Conflict Data\conflict_collapsed.dta", replace


* Some descriptive Statistics*
tabstat best_est, by(treatment) stats (mean n sd)






