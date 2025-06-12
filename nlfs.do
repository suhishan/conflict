/* 1. Find out the unit of analysis : Individual.
2. Merging all three datasets by district I think, with variables like employment_1998 and employment 2008.
	To do this: There must be a unique district code.
	
3. Finding out which variables to keep.

REMEMBER: GRADE COMPLETED HAS NOT BEEN MADE THE SAME IN BOTH DATASETS.
*/

clear
cd "C:\users\suhishan\Documents\Final Sem Research\Conflict"
use "NLFS 1\individual_merged.dta"

*numlabel, add //adds values to labels for all data.

/* Renaming some important variables */
rename q01 sex
rename q02 age
rename tothhmem hhsize
rename q04 marital_status
replace marital_status = (marital_status == 2)
rename ethnicty ethnicity
recode sex (2=0) // 1 is male and 0 is female.
drop if age<=10 // people aged 10 or lower are dropped for comparability while we do still wanna see teenage labor outcomes.

*NLFS year*
gen nlfs_year = 1998

*urban/rural

gen urbrur = (urbrural == 1 | urbrural == 2)


/* On Districts */
rename district dname
decode dname, gen(district_name)
gen district= trim(lower(district_name))

*District renaming for merging and comparability*
replace district = "kapilbastu" if district == "kapilvastu"
replace district = "kavre" if district == "kavrepalanchok"
replace district = "makwanpur" if district == "makawanp"
replace district = "panchthar" if district == "panchathar"
replace district = "parbat" if district == "parvat"
replace district = "udayapur" if district == "udaypur"
replace district = "chitwan" if district == "chitawan" 
replace district = "kavre" if district == "kavrepalanchok"
replace district = "dhanusha" if district == "dhanusa"
replace district = "dhak" if district == "dhankuta"
replace district = "sinp" if district == "sindhupa"


gen district_abbrev = substr(district, 1, 4)


/* Religion */
gen religion_recode = religion
label define religion_lbl 1 "Hindu" 2 "Buddhist" 3 "Islam" 4 "Christian" 5 "Others"
label values religion_recode religion_lbl
gen hindu = (religion_recode == 1)


/*Ethnicity Labels*/
label define ethnicity_lbl 1 "Chhetri" 2 "Brahmin" 3 "Magar" 4 "Tharu" 5 "Newar" 6 "Tamang" 7 "Kami" 8 " Yadav" 9 "Muslim" 10 "Rai" 11 "Gurung" 12 "Damai" 13 "Limbu" 14 "Sarki" 15 "Others"
label values ethnicity ethnicity_lbl
gen brahmin_chhetri = (ethnicity == 1 | ethnicity == 2)


// Making descriptive statistics for NLFS 1. 

/* 
The variables required:
	1. Employed [X]
	2. Hours Worked per 7days[X] /month/year
	3. Wages
	4. Age
	5. Household Size
	6. Status of migration
	7. Male/Female

I think it is advisable to filter the dataset into two distinct groups:
One teenagers (13-20) (with further decomposition into male and female) and other Adults (21 - 59)
*/



/* 1. Work Hours in the past week.
I am classifying work hours as the sum of hours from q16a to a16f:
Wage job, business operated, Agriculture, Milling and other food processing, Handicrafts, and construction.*/



/* Remember to also do wage-employed and self-employed hours

-------------------------------------Here ---------------------------------------

*/

*Work Hours and Non Work Hours*
gen wage_hours = q16a
egen selfemp_hours = rowtotal(q16b-q16i)

egen work_hours = rowtotal(q16a-q16i) // work hours/q16 is 0 if all columns are missing.
gen work_morethan_84 = (work_hours>84)
replace work_hours = 84 if work_hours >84
egen nonwork_hours = rowtotal(q17a-q17g) // q17 (total non work hours) has a bunch of 999 values for 0 so use `nonwork_hours`

egen total_hours  = rowtotal(work_hours nonwork_hours)
gen total_morethan_110 = (total_hours >110)
replace total_hours = 110 if total_hours > 110

// TNOTE: here are 313 people who have total hours greater than 110 and some more who have higher than 140, 150, and even 168.
count if total_hours > 98


 
 * Currently Active (currently employed/unemployed) and currently inactive *
 gen currently_emp = (work_hours !=0  | (q18 == 1 & (q19 == 1  | q20 == 1)))
 gen currently_unemp = (q46 == 1 |  (q46 == 2 & q51!=5))
 gen currently_underemp = (q16 < 40 & inrange(q37, 1, 6))
 
 //See page 13, Currently Employed Section of NLFS Report 1 for the definition.
 
 gen currently_active = (currently_emp | currently_unemp)
 gen currently_inactive = !currently_active // (or q45 == 2 | q51 == 5)
 
 
* LFPR = Proportion of relevant group who are economically active.*
// For example: LFPR for males and females aged 18-59.

mean currently_active if inrange(age, 18, 58) & sex == 1 // male
mean currently_active if inrange(age, 18, 58) & sex == 0 // female 


/* Usually employed and usually unemployed 
histogram q54, freq // There is a lot of data on exactly 360 days.
histogram age if q54 == 360 */

gen usually_active = (q58 >=180) // if the sum of employed and unemployed days exceeds 180.
gen usually_inactive = !usually_active

gen usually_emp = (usually_active == 1 & q54 > q55 )
gen usually_unemp = (usually_active == 1 & q55 >= q54 )
 
 
 * Age *
 *histogram age, freq // Seeing the age distribution of age above 5.
 
 
* Household Size *
*histogram hhsize
// TODO calculating mean hhsize from individual data.


* Marital Status *
gen married = (marital_status == 2)
summarize married if age > 10 // (marital status questions are asked to peopled aged above 10)


* Education Metrics*
gen can_read = q08
gen can_write = q09
gen current_attend = q10 
gen ever_attend = q11
gen years_of_edu = q12

gen edu_others = (q12 == 16)
recode years_of_edu (16 = 99) (13 = 16) (14 15 = 18) // Bachelors means 16 years of education, Masters and Prof Degress coded as 18.
replace years_of_edu = . if years_of_edu == 99 // Others counted as missing after storing stuff at edu_others
gen ever_school = (q10  == 1 | q11 == 1)
gen years_of_edu_all = years_of_edu
replace years_of_edu_all = 0 if ever_school == 0

/*-------------------------------------------*
Some Descriptive Statistics
*---------------------------------------------*/
tabstat currently_active, by(district) stat(mean)


* Keep all the necessary variables from NLFS individual_merged.dta, and save it in another file for appending with NLFS 2*

#delimit ;
keep nlfs_year sex age hhsize urbrur marital_status religion_recode hindu ethnicity brahmin_chhetri district district_abbrev 
wage_hours selfemp_hours work_hours nonwork_hours total_hours 
currently_emp currently_unemp currently_underemp
currently_active currently_inactive
usually_active usually_inactive 
can_read can_write current_attend ever_attend years_of_edu ever_school years_of_edu_all
usually_emp usually_unemp ;
#delimit cr

save "NLFS 1\kept_individual.dta", replace

/*------------------------------------------------------------*
NLFS 2 Descriptive Statistics
*--------------------------------------------------------------*/

clear
use "NLFS 2\Data\individual_merged.dta"


.
*NOTE: There are 1459 people for whom every individual data is missing. I am dropping them here but let's see*
drop if missing(q36t)


*NLFS year*
gen nlfs_year = 2008

*Urban/Rural

replace urbrur = 0  if urbrur == 2

// renaming some variables.

rename q09 sex
rename q10 age
rename totmemb hhsize
rename q13 marital_status
replace marital_status = (marital_status == 2)
recode sex (2=0) // 1 is male and 2 is female
drop if age<=10 // people aged 10 or lower are dropped for comparability while we do still wanna see teenage labor outcomes.

* Matching religion with NLFS 1*
gen religion_recode = religion
replace religion_recode = 9 if inlist(religion_recode,4, 6, 7, 8, 9)
replace religion_recode = 4 if religion_recode == 5
replace religion_recode = 5 if religion_recode == 9

label define religion_lbl 1 "Hindu" 2 "Buddhist" 3 "Islam" 4 "Christian" 5 "Others"
label values religion_recode religion_lbl
gen hindu = (religion_recode == 1)


*Matching Ethnicity with NLFS 1*
gen ethnicity = .
replace ethnicity = 1 if q11 == 1
replace ethnicity = 2 if q11 == 2
replace ethnicity = 3 if q11 == 3
replace ethnicity = 4 if q11 == 4
replace ethnicity = 5 if q11 == 6
replace ethnicity = 6 if q11 == 5
replace ethnicity = 9 if q11 == 7
replace ethnicity = 7 if q11 == 8
replace ethnicity = 8 if q11 == 9
replace ethnicity = 10 if q11 == 10
replace ethnicity = 11 if q11 == 11
replace ethnicity = 12 if q11 == 12
replace ethnicity = 13 if q11 == 13
replace ethnicity = 14 if q11 == 15
replace ethnicity = 15 if q11 == 14 | inrange(q11, 16, 103)

label define ethnicity_lbl 1 "Chhetri" 2 "Brahmin" 3 "Magar" 4 "Tharu" 5 "Newar" 6 "Tamang" 7 "Kami" 8 " Yadav" 9 "Muslim" 10 "Rai" 11 "Gurung" 12 "Damai" 13 "Limbu" 14 "Sarki" 15 "Others"
label values ethnicity ethnicity_lbl
gen brahmin_chhetri = (ethnicity == 1 | ethnicity == 2)


*Work Hours (Wage employed and self-employed) and Non-work hours*

egen wage_hours = rowtotal(q36a q36b), missing // keeping missing if all values in varlist are missing. 
egen selfemp_hours = rowtotal(q36c-q36j), missing //I want to keep missing values if all values in varlist are missing
egen work_hours = rowtotal(wage_hours selfemp_hours), missing
gen work_morethan_84 = (work_hours>84)
replace work_hours = 84 if work_hours >84

*NOTE: missing values, i.e. suppose people who didn't work in agricultural wage, are coded as 0.*

egen nonwork_hours = rowtotal(q37a-q37g), missing
egen total_hours = rowtotal(work_hours nonwork_hours), missing
gen total_morethan_110 = (total_hours >110)
replace total_hours = 110 if total_hours > 110


* Currently Employed, Currently Unemployed and Curretly Underemployed Stats*
gen currently_emp = (work_hours >0  | (q38 == 1 & (q39 == 1  | q40 == 1)))
gen currently_unemp = (q77 == 1 | (q77 == 2 & q82 != 5))
gen currently_underemp = (work_hours < 40 & inrange(q68, 1, 6))


*Currently Active and Currently Inactive*
gen currently_active = currently_emp | currently_unemp
gen currently_inactive = !currently_active // or (q76 == 2 |  q82 == 5) 


*Usually Active(usually employed and usually unemployed) and Usually Inactive
gen usually_active  = (q88 >= q87) // NOTE: 6 months in both q88 and q87 will be considered usually active.
gen usually_inactive = !usually_active


gen usually_emp = (usually_active == 1 & (q85 == 12 | q85>q86))
gen usually_unemp = (usually_active == 1 & (q85 !=12 & q86 >= q85))


*Age*
*histogram age, freq


*Household Size*
*histogram hhsize
// TODO calculating mean hhsize from individual data.


*Marital Status*
gen married = (marital_status == 2)
summarize married if age > 10 // (marital status questions are asked to peopled aged above 10)


* Education Metrics *
gen can_read = q26
gen can_write = q27
gen current_attend = q28 
gen ever_attend = q29
gen years_of_edu = q30 // TODO: think about ways of recoding education to make it similar to NLFS 1.

replace years_of_edu = . if inlist(years_of_edu, 16, 17) //  Literate and Illiterate are redundant info when we have can read and can write.
recode years_of_edu (11 = 11.5) (13 = 16) (14 15 = 18)
gen ever_school = (q28 == 1 | q29 == 1)
gen years_of_edu_all = years_of_edu
replace years_of_edu_all = 0 if ever_school == 0



/* On Districts */

gen district = trim(lower(dname))

* District renaming for merging and comparability"
replace district = "kapilbastu" if district == "kapilvastu"
replace district = "kavre" if district == "kavrepalanchok"
replace district = "makwanpur" if district == "makawanpur"
replace district = "panchthar" if district == "panchathar"
replace district = "parbat" if district == "parvat"
replace district = "udayapur" if district == "udaypur"
replace district = "chitwan" if district == "chitawan" 
replace district = "kavre" if district == "kavrepalanchok"
replace district = "sindhupalchowk" if district == "sindhupalchok"
replace district = "dhanusha" if district == "dhanusa"
replace district = "tehrathum" if district == "terhathum"

gen district_abbrev = lower(substr(district, 1, 4))
replace district_abbrev = "dhak" if district == "dhankuta"
replace district_abbrev = "sinp" if district == "sindhupalchowk"
replace district_abbrev = "dadh" if district_abbrev == "dade"


* Keeping only relevant variables and save in another file for ease of append.*

#delimit ;
keep nlfs_year sex age hhsize urbrur marital_status religion_recode hindu ethnicity brahmin_chhetri district district_abbrev 
wage_hours selfemp_hours work_hours nonwork_hours total_hours 
currently_emp currently_unemp currently_underemp
currently_active currently_inactive
usually_active usually_inactive 
can_read can_write current_attend ever_attend years_of_edu ever_school years_of_edu_all
usually_emp usually_unemp ;
#delimit cr

save "NLFS 2\Data\kept_individual.dta", replace


/*-----------------------------------------------------*
Append NLFS 1 kept variables data with NLFS 2 kept variables data on top of one another. 
*--------------------------------------------------------*/
clear
cd "C:\users\suhishan\Documents\Final Sem Research\Conflict"

use "NLFS 1\kept_individual.dta"
append using "NLFS 2\Data\kept_individual.dta"
save "appended_nlfs.dta", replace


/* Again, I have removed the code for assigning treatment and control status from stata so that there is no more confusion
* Merge with the conflict data for treatment/control status*
merge m:1 district_abbrev using "Conflict Data\conflict_collapsed.dta", keepusing(treatment treatment_65)
save "appended_nlfs.dta", replace
*/



