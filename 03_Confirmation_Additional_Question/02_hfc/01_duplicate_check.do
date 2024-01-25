/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Confirmatory Visit: Additional Question	 - HFC 			
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
	
	use "$addq_raw/cvd_confirmation_additional_questions_raw.dta", clear 
	
	* (1) Duplicate by ID 
	duplicates tag study_id, gen(dup_id)
	lab var dup_id "Duplicated by Study ID"
	tab dup_id, m 
	
	* export as excel file 
	preserve 
	
		keep if dup_id == 1
		
		if _N > 0 {
			
			export excel using "$addq_check/HFC/Confirmation_ADDQuestion_Check_Duplicate.xlsx", ///
								sheet("Duplicated by ID") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	* (2) Duplicate by personal information 
	local pii	s_resp_name s_resp_age s_resp_sex s_resp_dad_name s_resp_mom_name
	
	duplicates tag `pii', gen(dup_pii)
	lab var dup_pii "Duplciated by personal information"
	tab dup_pii, m 
	
	* export as excel file 
	preserve 
	
		keep if dup_pii == 1
		
		if _N > 0 {
			
			export excel using "$addq_check/HFC/Confirmation_ADDQuestion_Check_Duplicate.xlsx", ///
								sheet("Duplicated by Personal info") firstrow(varlabels) sheetmodify
		}
	
	restore 	
	
	// temporary solution for duplicate  
	sort starttime 
	duplicates drop study_id, force 
	duplicates drop s_resp_name s_resp_age s_resp_sex s_resp_dad_name s_resp_mom_name, force 
	
	* Save as raw data 
	save "$addq_check/cvd_confirmation_additional_questions_check_nodup.dta", replace 

	* end of dofile 
