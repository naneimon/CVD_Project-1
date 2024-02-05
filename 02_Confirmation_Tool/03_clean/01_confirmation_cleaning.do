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
	
	readreplace using "$cf_clean/confirmation_tool_correction.xlsx", ///
				id(_uuid) ///
				variable(var_name) ///
				value(correct_value) ///
				excel ///
				import(sheet("to_drop") firstrow)
	
	drop if to_drop ==  1

	** DATA CORRECTION **
	readreplace using "$cf_clean/confirmation_tool_correction.xlsx", ///
				id(_uuid) ///
				variable(var_name) ///
				value(correct_value) ///
				excel ///
				import(sheet("correction") firstrow)


	
&&
	
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