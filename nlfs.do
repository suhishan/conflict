/* 1. Find out the unit of analysis : Individual.
2. Merging all three datasets by district I think, with variables like employment_1998 and employment 2008.
	To do this: There must be a unique district code.
	
3. Finding out which variables to keep.
*/

clear
cd "C:\users\suhishan\Documents\Final Sem Research\Conflict"
use "NLFS 1\individual_merged.dta"

/* Renaming some important variables */
rename q01 sex
rename q02 age
rename tothhmem hhsize
rename q04 marital_status
recode sex (2=0) // 1 is male and 0 is female.


drop if age<=5 // people aged 5 or lower are dropped because they are not asked labor market questions.


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

* Work Hours and Non Work Hours*
egen work_hours = rowtotal(q16a-q16i) // work hours/q16 is 0 if all columns are missing.
egen nonwork_hours = rowtotal(q17a-q17g) // q17 (total non work hours) has a bunch of 999 values for 0 so use `nonwork_hours`

egen total_hours  = rowtotal(work_hours nonwork_hours)

// There are 313 people who have total hours greater than 110 and some more who have higher than 140, 150, and even 168.
count if total_hours > 168

 
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

* Usually employed and usually unemployed *

histogram q54, freq // There is a lot of data on exactly 360 days.
histogram age if q54 == 360

gen usually_active = (q58 >=180) // if the sum of employed and unemployed days exceeds 180.
gen usually_inactive = !usually_active

gen usually_emp = (usually_active == 1 & q54 > q55 )
gen usually_unemp = (usually_active == 1 & q55 >= q54 )
 
 * Age *
 
 histogram age, freq // Seeing the age distribution of age above 5.
 
* Household Size *

histogram hhsize
// TODO calculating mean hhsize from individual data.

* Marital Status *
gen married = (marital_status == 2)
summarize married if age > 10 // (marital status questions are asked to peopled aged above 10)

/*------------------------------------------------------------*
NLFS 2 Descriptive Statistics
*--------------------------------------------------------------*/

clear
use "NLFS 2/Data/individual_merged.dta"


// renaming some variables.

rename q09 sex
rename q10 age
rename totmemb hhsize
rename q13 marital_status
recode sex (2=0) // 1 is male and 2 is female

drop if age<=5 // people aged 5 or lower are dropped because they are not asked labor market questions.

*NOTE: There are 1459 people for whom every individual data is missing. I am dropping them here but let's see*
drop if missing(q36t)


*Work Hours (Wage employed and self-employed) and Non-work hours*

egen wage_hours = rowtotal(q36a q36b), missing // keeping missing if all values in varlist are missing. 
egen selfemp_hours = rowtotal(q36c-q36j), missing //I want to keep missing values if all values in varlist are missing
egen work_hours = rowtotal(wage_hours selfemp_hours), missing

*NOTE: missing values, i.e. suppose people who didn't work in agricultural wage, are coded as 0.*

egen nonwork_hours = rowtotal(q37a-q37g), missing
egen total_hours = rowtotal(work_hours nonwork_hours), missing


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
histogram age, freq

*Household Size*
histogram hhsize
// TODO calculating mean hhsize from individual data.

*Marital Status*
gen married = (marital_status == 2)
summarize married if age > 10 // (marital status questions are asked to peopled aged above 10)




