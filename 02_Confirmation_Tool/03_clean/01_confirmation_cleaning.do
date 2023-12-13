/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Confirmation work - Cleaning and correction 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. drop duplicate and perform data correction (if required) 

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data *
	********************************************************************************
	
	use "$np_cf_check/cvd_confirmation_check.dta", clear 
	
	* Solve duplicate 
	* Duplicate by personal information 
	* no duplicated cases 
	
	* residence changes 
	// this patient reported about changes in residence plan - no longer live in this village for next 6 months	
	drop  if study_id == "1/2/46/20231124113232"
	
	* Save as raw data 
	save "$np_cf_clean/cvd_confirmation_cleaned.dta", replace 
	
	* end of dofile 
