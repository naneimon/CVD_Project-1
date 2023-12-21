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
	
	
	// replace with correct study_id 
	replace study_id = "8/2/46/20231128122626" if study_id == "8/2/46/202311281226"
	
	* iecodebook for variable selection and labeling 
	//iecodebook template using "$np_cf_clean/codebook/cvd_confirmation_cleaned.xlsx", replace 
	iecodebook apply using "$np_cf_clean/codebook/cvd_confirmation_cleaned.xlsx" 

	order	ck_cal_syst_avg ck_cal_diast_avg sbp ages sex smallbin bmi ///
			stata_cvd_risk_who cvd_cal_check stata_cvd_risk cvd_final_check stata_cvd_risk_final, ///
			after(end_note_2)
	
	
	* Save as raw data 
	save "$np_cf_clean/cvd_confirmation_cleaned.dta", replace 
	
	* end of dofile 
