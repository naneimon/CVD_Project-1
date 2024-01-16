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
	* Duplicate by study id 
	duplicates list study_id // need to dicuss with Cho Zin 
	
	duplicates drop study_id, force 
	
	
	
	* residence changes 
	// this patient reported about changes in residence plan - no longer live in this village for next 6 months	
	drop  if study_id == "1/2/46/20231124113232"

	// replace with correct study_id 
	replace study_id = "8/2/46/20231128122626" if study_id == "8/2/46/202311281226"
	
	* iecodebook for variable selection and labeling 
	//iecodebook template using "$np_addq_clean/codebook/cvd_confirmation_additional_questions_cleaned.xlsx", replace 
	iecodebook apply using "$np_addq_clean/codebook/cvd_confirmation_additional_questions_cleaned.xlsx" 

	
	* Save as raw data 
	save "$np_addq_clean/cvd_confirmation_additional_questions_cleaned.dta", replace 
	
	* end of dofile 
