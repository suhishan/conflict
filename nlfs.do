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
recode sex (2=0) // 1 is male and 0 is female.


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


drop if q02<=5
egen work_hours = rowtotal(q16a-q16i) // work hours/q16 is 0 if all columns are missing.
egen nonwork_hours = rowtotal(q17a-q17g) // q17 (total non work hours) has a bunch of 999 values for 0 so use `nonwork_hours`

egen total_hours  = rowtotal(work_hours nonwork_hours)

// There are 313 people who have total hours greater than 110 and some more who have higher than 140, 150, and even 168.
 count if total_hours > 110 
 
 
 
 
 /* Currently Employed Status (0/1) */
 gen currently_emp = (work_hours !=0  | (q18 == 1 & (q19 == 1  | q20 == 1)))
 //See page 13, Currently Employed Section of NLFS Report 1 for the definition.
 
 /* Currently Unemployed Status (0/1) */
 gen currently_unemp = (q46 == 1 |  (q46 == 2 & q51!=5))
 
 /* Currently economically active/inactive */
 gen currently_active = (currently_emp | currently_unemp)
 gen currently_inactive = !currently_active // (or q45 == 2 | q51 == 5)
 
/* LFPR = Proportion of relevant group who are economically active. */
// For example: LFPR for males and females aged 18-59.

mean currently_active if inrange(age, 18, 58) & sex == 1 // male
mean currently_active if inrange(age, 18, 58) & sex == 0 // female 
 
 




