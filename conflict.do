
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
gen year96 = (year == 1996)
gen year97 = (year == 1997)
gen year98 = (year == 1998)
gen year99 = (year == 1999)
gen year00 = (year == 2000)
gen year01 = (year == 2001)
gen year02 = (year == 2002)
gen year03 = (year == 2003)
gen year04 = (year == 2004)
gen year05 = (year == 2005)
gen year06 = (year  == 2006)

gen deaths_96 = best_est if year96 == 1
gen deaths_97 = best_est if year97 == 1
gen deaths_98 = best_est if year98 == 1
gen deaths_99 = best_est if year99 == 1
gen deaths_00 = best_est if year00 == 1
gen deaths_01 = best_est if year01 == 1
gen deaths_02 = best_est if year02 == 1
gen deaths_03 = best_est if year03 == 1
gen deaths_04 = best_est if year04 == 1
gen deaths_05 = best_est if year05 == 1
gen deaths_06 = best_est if year06 == 1


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

drop if district == "not available"
save "Conflict Data\conflict_collapsed.dta", replace





/* For now, I have removed the code for defining treatment and control districts so that analysis is not confused with R.

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

*/


