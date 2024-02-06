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
	// drop  if study_id == "1/2/46/20231124113232"
	
	gen to_drop = .m 
	
	readreplace using "$np_cf_clean/confirmation_tool_correction.xlsx", ///
				id(_uuid) ///
				variable(var_name) ///
				value(correct_value) ///
				excel ///
				import(sheet("to_drop") firstrow)
	
	drop if to_drop ==  1
	drop to_drop 

	** DATA CORRECTION **
	gen field_team_note = ""
	
	readreplace using "$np_cf_clean/confirmation_tool_correction.xlsx", ///
				id(_uuid) ///
				variable(var_name) ///
				value(correct_value) ///
				excel ///
				import(sheet("correction") firstrow)

	
	/* 
	FIELD ISSUE NOTE: 
	During the confirmation visit, there were some issues with field work, and some forms of confirmation visits were not successfully uploaded to the server. Though the field team claims that those forms were uploaded. We have identified 7 observations that were eligible to participate in the confirmation visit, but they were not found on the server. Additionally, 2 observations from the additional questions were also not found in the confirmation data. In total, 9 observations were not found in the confirmation visit.
	
	Out of the 9 observations that were not found in the confirmation visit, some of them were eligible to enroll in the study and had provided consent to participate. Therefore, we manually entered their data into the VHW logbook preloaded file to include them in the study.
	*/ 
	
	* prepare the manually updated preload file 
	preserve 
	
		insheet using "$cf_check/Enrolled_preload/study_participant_list_Manual_Update.csv", clear 
		
		* to inline with update preload var - STATA calculation one
		rename cal_bmi				bmi
		rename cal_hypertension 	ck_hypertension 
		rename cal_diabetes			ck_diabetes
		rename ssp_id 				resp_sppid
		
		foreach var of varlist mhist_ischemic mhist_stroke ck_hypertension ck_diabetes {
			
			replace `var' = "1" if `var' == "Yes"
			replace `var' = "0" if `var' == "No"
			destring `var', replace 
		}
		
		drop resp_name resp_dad_name resp_mom_name
		
		tempfile vhw_manual 
		save `vhw_manual'
		
	restore 
	
	* identified the manually added obs 
	preserve 
	
		keep study_id ck_qualify consent 
		merge 1:1 study_id using `vhw_manual'
		
		keep if _merge == 2
		drop _merge 
		
		gen manual_add_consent = 1 
		lab var manual_add_consent "Manually add consent case (as didn't find those case in submission)"
		
		* update ck_qualify consent variables 
		replace ck_qualify = 1
		replace consent = 1
		
		tempfile vhw_manual 
		save `vhw_manual'
	
	restore 
	
	append using `vhw_manual'
	
	* iecodebook for variable selection and labeling 
	//iecodebook template using "$np_cf_clean/codebook/cvd_confirmation_cleaned_prepare.xlsx", replace 

	iecodebook apply using "$np_cf_clean/codebook/cvd_confirmation_cleaned_prepare.xlsx" 

	order	ck_cal_syst_avg ck_cal_diast_avg sbp ages sex smallbin bmi ///
			stata_cvd_risk_who cvd_cal_check stata_cvd_risk cvd_final_check stata_cvd_risk_final, ///
			after(end_note_2)
	
	iecodebook template using "$np_cf_clean/codebook/cvd_confirmation_cleaned.xlsx", replace 
	
	* Save as raw data 
	save "$np_cf_clean/cvd_confirmation_cleaned.dta", replace 
	
	* end of dofile 

	
	/*
	
	** Correction for un-eligable for confirmation visit case **
	local todrop `"2/3/55/20231123111157"'
	
	// Create a local macro with all variable names - except study_id
	ds 
	local allvars `r(varlist)'

	local exclude_var study_id
	local allvars : list allvars - exclude_var
	di "`allvars'"


	foreach var in `allvars' {
		
		capture confirm numeric variable `var'
		
		foreach id in `todrop' {
			
			if !_rc {
				// Variable is numeric, perform numeric replacement
				// For example, replacing missing values with 0
				replace `var' = .m if study_id == "`id'"
			}
			else {
				// Variable is not numeric, assume it's string
				// Perform string replacement if needed
				replace `var' = "" if study_id == "`id'"
			}	
			
		}
	}
	
	
	*/