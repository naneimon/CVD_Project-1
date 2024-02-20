/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Cleaning Patient Safety Check			
Author				:	Nicholus Tint Zaw
Date				: 	2/07/2024
Modified by			:



Task outline: 
	1. prepare preload file for patient safety checklist 

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"
	
	
	* Import combined dataset * 
	use "$np_vhw_raw/cvd_patient_safety_checklists_raw_nopii.dta", clear  
	
	
	* SOLVE DUPLICATE ** 
	* Duplicate by study id 
	duplicates list study_id visit_date 
	
	
	** DATA CORRECTION **
	gen ps_rbs = "" 
	order ps_rbs, after(bp_diast)
	
	gen doctor_note = ""
	order doctor_note, after(symptoms_now)
	
	lab var ps_rbs "RBS (mg%)"
	lab var doctor_note "Doctor note - question #6"
	
	gen withdrawal_pt = .m 
	order withdrawal_pt, after(study_id)
	lab var withdrawal_pt "Patient withdrawal from the study"
	
	
	readreplace using "$vhw_raw/05_Patient_Safety_Checklists_Correction.xlsx", ///
				id(_uuid) ///
				variable(var_name) ///
				value(correct_value) ///
				excel ///
				import(sheet("correction") firstrow)
	
	// for the diagnosis check 
	br if study_id == "1/2/46/20231124141616"
	br if study_id == "3/2/46/20231115111145"
	br if study_id == "2/3/55/20231123141158"
	
	* apply WB codebook command
	iecodebook template using "$np_vhw_clean/codebook/cvd_patient_safety_checklists_clean_codebook.xlsx", replace 
	//iecodebook apply using "$np_vhw_clean/codebook/cvd_patient_safety_checklists_clean_codebook.xlsx"
			
	
	save "$np_vhw_clean/cvd_patient_safety_checklists_clean_nopii.dta", replace
	export excel using "$np_vhw_clean/cvd_patient_safety_checklists_clean_nopii.xlsx", sheet("patient_safety_checklists") firstrow(variables) replace
	

	
	* end of dofile 