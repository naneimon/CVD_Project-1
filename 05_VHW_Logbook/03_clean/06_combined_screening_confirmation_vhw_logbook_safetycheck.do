/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Combined Screening + 
						Confirmation + 
						Additional Question + 
						VHW Logbook + 
						Patient Safety Checklist
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
	
	
	* VARIABLE NAME CHECKING *
	* (1) Patient Safety Check
	
	use "$np_vhw_clean/cvd_patient_safety_checklists_clean_nopii.dta", clear 
	
	drop s_weight - v_blood_glucose_3
	
	* apply WB codebook command
	iecodebook template using "$np_vhw_clean/codebook/cvd_patient_safety_checklists_combined_check.xlsx", replace 
			
	import excel using "$np_vhw_clean/codebook/cvd_patient_safety_checklists_combined_check.xlsx", firstrow clear 
	
	drop name label type choices
	
	rename namecurrent name 
	
	drop if mi(name) | name == "resp_confirm" | name == "resp_sppid" | name == "study_id"
	
	keep name 
	gen patient_safetyck = 1 
	
	tempfile patient_safetyck 
	save `patient_safetyck', replace 
	
	
	* (2) Combined Dataset 
	import excel using "$np_comb_clean/codebook/cvd_screening_confirmation_combined_all_codebook.xlsx", firstrow clear 
	
	drop name label type choices
	
	rename namecurrent name 
	
	drop if mi(name)
	
	keep name 
	gen combined = 1 

	merge 1:1 name using `patient_safetyck'

	// 24 variables including demographic var and respondent information confiramtion variables 
	// were identical between combined data and patient safety checklist dataset  
	// action required for variable name changes 
	
	levelsof name if _merge == 3, local(tochange)

	********************************************************************************
	** MERGE with COMBINED DATASET **
	********************************************************************************
	
	use "$np_vhw_clean/cvd_patient_safety_checklists_clean_nopii.dta", clear 
	
	drop s_weight - v_blood_glucose_3
	
	** rename variable as add "v_" prefix to distinguished with same var name from vhwlogbook 
	foreach var in `tochange' {
		
		rename `var' ps_`var'
	}
	
	** check unique id or not 
	keep study_id - affirm_study
	isid  study_id visit_date
	
	* for Field Team App 
	sort  study_id visit_date
	
	gen patient_safety_ck = 1 
	
	tempfile ps_checklist 
	save `ps_checklist', replace 
	
	
	** Update the combined dataset + add patient safety checklist ** 
	use "$comb_clean/cvd_screening_confirmation_combined_cleaned_pii.dta", clear 
		
	merge 1:1 study_id using `ps_checklist', assert(1 3) nogen 
	
	replace patient_safety_ck = 0 if mi(patient_safety_ck)

	
	* Save as dta file 
	
	// PII data
	* Save as combined cleaned data 
	save "$comb_clean/cvd_screening_confirmation_combined_cleaned_pii.dta", replace 
	
	* export as exel doc 
	export excel using "$comb_clean/cvd_screening_confirmation_combined_cleaned_pii.xlsx", sheet("combined_data") firstrow(variables) replace 
	
	* codebook 
	// codebookout "$np_comb_clean/codebook/cvd_screening_confirmation_combined_codebook.xlsx", replace 
	iecodebook template using "$comb_clean/codebook/cvd_screening_confirmation_combined_all_pii_codebook.xlsx", replace 

	
	
	// non PII data
	* Save as combined cleaned data 
	drop resp_name resp_dad_name resp_mom_name 
	
	save "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.dta", replace 
	
	* export as exel doc 
	export excel using "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.xlsx", sheet("combined_data") firstrow(variables) replace 
	
	* codebook 
	// codebookout "$np_comb_clean/codebook/cvd_screening_confirmation_combined_codebook.xlsx", replace 
	iecodebook template using "$np_comb_clean/codebook/cvd_screening_confirmation_combined_all_codebook.xlsx", replace 


	
	* end of dofile 
