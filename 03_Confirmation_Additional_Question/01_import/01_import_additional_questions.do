/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Confirmatory Visit: Additional Question			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. import raw excel file exported from KoBoToolbox 
	2. label variables and response value
	3. save as raw file for checking and HFC work

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data  *
	********************************************************************************
	
	import excel using "$addq_raw/CVD_Eligible_Person_Additional_Questions.xlsx", sheet("CVD_Eligible_Person_Addition...") firstrow clear 
	
	
	** Labeling 
	* apply WB codebook command 
	//iecodebook template using "$addq_check/codebook/cvd_confirmation_additional_questions_raw.xlsx"
	iecodebook apply using "$addq_check/codebook/cvd_confirmation_additional_questions_raw.xlsx"

	
	** Initial data cleaning 
	* Keep only data collection observation 
	sort starttime
	
	drop if username == "dataliteracy4d" // drop NCL test cases 
	keep if starttime >= tc(15nov2023 00:00:00) // screening start on 15th nov 2023

	local pii	s_resp_name s_resp_dad_name s_resp_mom_name ///
							n_resp_name n_resp_dad_name n_resp_mom_name ///
							resp_info_update1 resp_info_update2 resp_info_update3 ///
							resp_name resp_dad_name resp_mom_name
				
				
	* Save as dta file 
	// PII data
	save "$addq_raw/cvd_confirmation_additional_questions_raw.dta", replace 
	
	// non PII data
	// drop PII
	drop `pii'
	save "$np_addq_raw/cvd_confirmation_additional_questions_raw_nopii.dta", replace
			
	* Save as dta file 
	 

	* end of dofile 
