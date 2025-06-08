clear
cd "C:\users\suhishan\Documents\Final Sem Research\Conflict"
use "appended_nlfs.dta"

/* Now the dataset is ready for analysis */

eststo clear

estpost summarize currently_emp work_hours ever_school years_of_edu_all age treatment if nlfs_year == 1998

#delimit ;
esttab using "Data Presentation/summary_1998.tex", ///
    cells("mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0)) count(fmt(0))") ///
    label title("Summary Statistics 1998") ///
    nonumber collabels("Mean" "SD" "Min" "Max" "Count") ///
    coeflabels ("Currently Employed" currently_emp "Work Hours" work_hours "Ever attended school" ever_school "Years of education" years_of_edu_all  "Age" age "Treatment" treatment) ///
    nomtitles ///
	nocons ///
    replace ///

;
#delimit cr;

eststo clear
estpost summarize currently_emp work_hours ever_school years_of_edu_all age treatment if nlfs_year == 2008

#delimit ;
esttab using "Data Presentation/summary_2008.tex", ///
    cells("mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0)) count(fmt(0))") ///
    label title("Summary Statistics 2008") ///
    nonumber collabels("Mean" "SD" "Min" "Max" "Count") ///
    coeflabels ("Currently Employed" currently_emp "Work Hours" work_hours "Ever attended school" ever_school "Years of education" years_of_edu_all  "Age" age "Treatment" treatment) ///
    nomtitles ///
	nocons ///
    replace ///

;
#delimit cr;

 
 
 
 *A huge table for summary statistics*
 
***All People
eststo grp1: estpost tabstat currently_emp work_hours nonwork_hours ever_school years_of_edu_all age treatment, c(stat) stat(mean sd min max n) nototal by(nlfs_year)

***Adult (18-59)  Men
eststo grp2: estpost tabstat currently_emp work_hours nonwork_hours ever_school years_of_edu_all age treatment if sex == 1 & inrange(age, 18, 59), c(stat) stat(mean sd min max n) nototal by(nlfs_year)

***Adult (18-59) Women
eststo grp3: estpost tabstat currently_emp work_hours nonwork_hours ever_school years_of_edu_all age treatment if sex == 0 & inrange(age, 18, 59), c(stat) stat(mean sd min max n) nototal by(nlfs_year)




#delimit ;
	 esttab grp* using "Data Presentation/male and female summary stats.tex",
	  replace ///Replace file if already exists
	  cells("mean(fmt(2))" "sd(par)") ///Which Stats to Output
	 nonumber ///Do not put numbers below column titlles
	  mtitle("All" "Adult Men" "Adult Women") ///This option mainly for regression tables
	  nostar /// No Stars for Significance
	  unstack ///Vertical from Stata to Diff Columns
	  booktabs ///Top, Mid, Bottom Rule
	  noobs ///We don't need observation counts because count is N
	  title("Summary Stats by Group\label{by_group}") ///Latex number this for us
	  collabels(none) /// Name of each column
	  addnote("Note: Summary statistics") ///Note below table
	  coeflabels( "Employed(Last 7 days)" currently_emp "Hours Worked (Last 7 days)" work_hours
  "Non Work Hours (Last 7 days)" nonwork_hours 
  "Ever Attended School" ever_school
  "Years of Education" years_of_edu
  "Age" age
  "Conflict District (Treatment)" treatment) ///Label variables right in command
  ;
  
  #delimit cr;
	 
	 
*Difference of means balance test.
eststo clear
estpost ttest currently_emp usually_emp work_hours nonwork_hours ever_school years_of_edu_all age hindu brahmin_chhetri if nlfs_year == 1998, by(treatment)

********Option 1--Main and Aux
#delimit ;
esttab using "Data Presentation/ttest.tex",
 replace ///Replace file if already exists
 cells("mu_1(fmt(2)) mu_2 b(star) se(par) count(fmt(0))") ///Which Stats to Output
 star(* 0.1 * 0.05 ** 0.01) /// Can Define Custom Stars
 nonumber ///Do not put numbers below column titlles
 booktabs ///Top, Mid, Bottom Rule
 noobs ///We don't need observation counts because count is N
 title("Balance Test by Treatment") ///Latex number this for us
 collabels("Control " "Treatment " "Difference" "Std. Error" "N") /// Name of each column
 addnote("Note: Difference defined as Control-Treatmenet." "Source: NLFS 1 (Author's Calculation)" "* 0.1 ** 0.05") ///Note below table
;
#delimit cr;



*The Actual Regression*
gen post = (nlfs_year == 2008)

eststo clear

eststo :reg currently_emp i.post i.treatment post#treatment, level(89) robust


eststo: logit currently_emp i.post i.treatment post#treatment, level(89) robust

eststo: logit currently_emp i.post i.treatment post#treatment years_of_edu_all age, robust


#delimit ;
esttab using "Data Presentation/logit_reg1.tex", 
  se(3) /// SE with 3 Decimal Places
  b(2) /// Coefficients with 2 Decimal Places
  label
  nostar
  replace /// Replace File
  title(Initial Regression \label{tab1}) /// Title of Tabel
  mtitles("LPM" "Logit" "Logit(c)") /// Column Titles
  keep(1.post 1.treatment 1.post#1.treatment _cons)
  coeflabels(1.post "Post (2008)"
  1.treatment "Treatment or Control District" 1.post#1.treatment "Post X Treatment") /// Label Variables
  addnote("Note: The controls in column 3 are : Years of education and a person's age. ")
;

#delimit cr;


*keep(mpg weight length) /// Don't want all Control Coefficients

logit currently_emp i.post i.treatment post#treatment years_of_edu_all age brahmin_chhetri, robust

