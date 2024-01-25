/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Confirmation visit - HFC 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. check duplciate 

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data  *
	********************************************************************************
	
	use "$cf_raw/cvd_confirmation_raw.dta", clear 
	
	* (1) Duplicate by ID 
	duplicates tag study_id, gen(dup_id)
	lab var dup_id "Duplicated by Study ID"
	tab dup_id, m 
	
	* export as excel file 
	preserve 
	
		keep if dup_id != 0 & !mi(dup_id)
		
		if _N > 0 {
			
			export excel using "$cf_check/HFC/Confirmation_Tool_Check_Duplicate.xlsx", ///
								sheet("Duplicated by ID") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	* (2) Duplicate by personal information 
	local pii	resp_name resp_age resp_sex resp_dad_name resp_mom_name
	
	duplicates tag `pii', gen(dup_pii)
	lab var dup_pii "Duplciated by personal information"
	tab dup_pii, m 
	
	* export as excel file 
	preserve 
	
		keep if dup_pii != 0 & !mi(dup_pii)
		
		if _N > 0 {
			
			export excel using "$cf_check/HFC/Confirmation_Tool_Check_Duplicate.xlsx", ///
								sheet("Duplicated by Personal info") firstrow(varlabels) sheetmodify
		}
	
	restore 	
	
	
	* (3) SPP ID Check
	duplicates tag resp_sppid if !mi(resp_sppid) & resp_sppid != "9999", gen(dup_sppid)
	tab dup_sppid, m 
	
	* export as excel file 
	preserve 
	
		keep if dup_sppid != 0 & !mi(dup_sppid)
		
		if _N > 0 {
			
			export excel using "$cf_check/HFC/Confirmation_Tool_Check_Duplicate.xlsx", ///
								sheet("Duplicated by SPP ID") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	
	// temporary solution for duplicate  
	sort starttime 
	duplicates drop study_id, force 
	duplicates drop resp_name resp_age resp_sex resp_dad_name resp_mom_name, force 
	
	* Save as raw data 
	save "$cf_check/cvd_confirmation_tool_check_nodup.dta", replace 

	* end of dofile 
