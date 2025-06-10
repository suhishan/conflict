
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


* Seeing what proportion of deaths occurred before each of the years.  for each district.*
gen pre97 = (year < 1997)
gen pre98 = (year < 1998)
gen pre99 = (year < 1999)
gen pre00 = (year < 2000)
gen pre01 = (year < 2001)
gen pre02 = (year < 2002)
gen pre03 = (year < 2003)
gen pre04 = (year < 2004)
gen pre05 = (year < 2005)
gen pre06 = (year < 2006)

gen deaths_pre97 = best_est if pre97 == 1
gen deaths_post97 = best_est if pre97 == 0

gen deaths_pre98 = best_est if pre98 == 1
gen deaths_post98 = best_est if pre98 == 0

gen deaths_pre99 = best_est if pre99 == 1
gen deaths_post99 = best_est if pre99 == 0

gen deaths_pre00 = best_est if pre00 == 1
gen deaths_post00 = best_est if pre00 == 0


gen deaths_pre01 = best_est if pre01 == 1
gen deaths_post01 = best_est if pre01 == 0

gen deaths_pre02 = best_est if pre02 == 1
gen deaths_post02 = best_est if pre02 == 0 // Remember even if it says post02, it includes 02, however pre02 doesnot include 02.

gen deaths_pre03 = best_est if pre03 == 1
gen deaths_post03 = best_est if pre03 == 0

gen deaths_pre04 = best_est if pre04 == 1
gen deaths_post04 = best_est if pre04 == 0

gen deaths_pre05 = best_est if pre05 == 1
gen deaths_post05 = best_est if pre05 == 0

gen deaths_pre06 = best_est if pre06 == 1
gen deaths_post06 = best_est if pre06 == 0 // Also contains 2006

gen incidents = 1 // To count the number of incidents per district later on.


// Collapsing the data to estimate total number of deaths and other variables by district.

#delimit;
collapse (sum)  deaths_a deaths_b deaths_civilians deaths_unknown best_est high_est low_est 
deaths_pre97 deaths_post97
deaths_pre98 deaths_post98
deaths_pre99 deaths_post99
deaths_pre00 deaths_post00
deaths_pre01 deaths_post01
deaths_pre02 deaths_post02
deaths_pre03 deaths_post03
deaths_pre04 deaths_post04
deaths_pre05 deaths_post05
deaths_pre06 deaths_post06
pre97 pre98 pre99 pre00 pre01 pre02 pre03 pre04 pre05 pre06

incidents, by(district) 

;
#delimit cr;
*encode district, generate(district_factor) // turn district names into factors/numbers.


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

	reg best_est forest_cover elevation, vce(robust)

	sum forest_cover, detail
	scalar p75 = r(p75)
	gen treatment = (forest_cover > p75)
	
	_pctile forest_cover, p(65)
	scalar p65 = r(r1)
	gen treatment_65 = (forest_cover > p65)

	save "Conflict Data\conflict_collapsed.dta", replace


	ee
* Some descriptive Statistics*
tabstat best_est, by(treatment) stats (mean n sd)

*ttest for districts*

estpost ttest pov_rate advantaged_caste lin_polar caste_polar norm_forest tot_lit_91, by(treatment)

#delimit ;
esttab using "Data Presentation/ttest_2.tex",
 replace ///Replace file if already exists
 cells("mu_1(fmt(2)) mu_2 b(star) se(par) count(fmt(0))") ///Which Stats to Output
 star(* 0.1 * 0.05 ** 0.01) /// Can Define Custom Stars
 nonumber ///Do not put numbers below column titlles
 booktabs ///Top, Mid, Bottom Rule
 noobs ///We don't need observation counts because count is N
 title("Balance Test by Treatment") ///Latex number this for us
 collabels("Control " "Treatment " "Difference" "Std. Error" "N") /// Name of each column
 addnote("Note: Difference defined as Control-Treatmenet." "Source: Data from Do and Iyer (2008)" "* 0.1 ** 0.05") ///Note below table
;
#delimit cr;


