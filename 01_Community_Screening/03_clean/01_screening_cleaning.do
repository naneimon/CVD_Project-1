/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work - Cleaning and correction 			
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
	
	use "$np_sc_check/cvd_screening_check.dta", clear 
	
	* Solve duplicate 
	* Duplicate by personal information 
	drop if _uuid == "02890697-eab0-4819-adb2-8ab891e89c62"
	
	
	* residence changes 
	// this patient reported about changes in residence plan - no longer live in this village for next 6 months
	
	preserve 
	
		keep if study_id == "1/2/46/20231124113232"
		
		replace resp_livenow = 0 
		replace cal_eligible = 0 
		replace ck_cal_eligible = 0
		replace confirmation_visit_yes = .m 
		
		keep starttime - resp_livenow cal_eligible ck_cal_eligible confirmation_visit_yes _id - _index
		
		tempfile case 
		save `case', replace 
		
	restore 
	
	
	drop  if study_id == "1/2/46/20231124113232"
	
	append using `case'
	
	
	
	* iecodebook for variable selection and labeling 
	//iecodebook template using "$np_sc_clean/codebook/cvd_screening_cleaned.xlsx", replace 
	iecodebook apply using "$np_sc_clean/codebook/cvd_screening_cleaned_prepare.xlsx" 
	
	
	order	sbp ages sex smallbin bmi stata_cvd_risk_who cvd_cal_check ///
			stata_cvd_risk cvd_final_check ck_cal_syst_avg_abn ck_cal_diast_avg_abn ///
			confirmation_visit_yes, after(ck_cal_confirm_visit_tot)
			

	iecodebook template using "$np_sc_clean/codebook/cvd_screening_cleaned.xlsx", replace 
	
	
	* Save as raw data 
	save "$np_sc_clean/cvd_screening_cleaned.dta", replace 
	
	* end of dofile 
