/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Confirmation additional questions - Cleaning and correction 			
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
	
	use "$np_addq_raw/cvd_confirmation_additional_questions_raw_nopii.dta", clear 
	
	* Solve duplicate 
	* Duplicate by personal information 
	* no duplicated obs 
	
	* residence changes 
	// this patient reported about changes in residence plan - no longer live in this village for next 6 months	
	drop  if study_id == "1/2/46/20231124113232"

	
	* Save as raw data 
	save "$np_addq_raw/cvd_confirmation_additional_questions_cleaned.dta", replace 
	
	* end of dofile 
