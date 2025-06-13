
* --------------------------------------------------------*
* Merging NLFS 1 household and individual data*
clear
use "C:\users\suhishan\Documents\Final Sem Research\Conflict\NLFS 1\household.dta"
merge 1:m psuhhno using "NLFS 1\individual.dta"

// some data on the household dataset (30 of them) are not in the individual information so drop them i guess. 
keep if _merge == 3
save "NLFS 1\individual_merged.dta", replace // saved the merged data as individual_merged.dta

* Merging NLFS 2 household and individual data *

clear
cd "C:\users\suhishan\Documents\Final Sem Research\Conflict"

use "C:\users\suhishan\Documents\Final Sem Research\Conflict\NLFS 2\Data\HOUSEHOLD_INFO.dta"

// Merge the household and the individual dataset by psu and household id. 
// remember I am in HOUSEHOLD_INFO.dta


merge 1:m psu hhid using "NLFS 2\Data\INDIVIDUAL_INFO.dta"
save "NLFS 2\Data\individual_merged.dta", replace // saved the merged data as individual_merged.dta






* -------------------------------------------*
*THIS IS NOW NOT NECESSARY (JUNE 10, 2025)
clear
cd "C:\users\suhishan\Documents\Final Sem Research\Conflict"
use "NLFS 2\Data\individual_merged.dta"


*Merging the conflict data with NLFS 2.
// Generate lowercase district names
gen district = lower(trim(dname))

// cleaning district names to make the merge happen.

replace district = "sindhupalchowk" if district == "sindhupalchok"
replace district = "chitwan" if district == "chitawan"
replace district = "dhanusha" if district == "dhanusa"

// Merging this dataset with the conflict deaths dataset.

merge m:1 district using "Conflict Data\conflict_collapsed.dta", generate(_m_district)

/* Note while merging there were two districts that didn't merge:

No mustang and manang in the conflict data.
No manang and dolpa in the NLFS data.
Therefore, dolpa from conflict data (2) and mustang from NLFS data (80) are not merged. 
*/








