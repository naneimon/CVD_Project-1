/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work - HFC 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. prepare the preloded csv file for confirmation visit

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data  *
	********************************************************************************
	
	use "$np_sc_clean/cvd_screening_cleaned.dta", clear 
		
	****************************************************************************
	** Confirmation Visit Preloaded File **
	****************************************************************************
	tab confirmation_visit_yes, m 
	
	// keep only required obs 
	keep if confirmation_visit_yes == 1
	
	* get personal info data 
	merge 1:1 study_id using 	"$sc_check/cvd_screening_check_nodup.dta", ///
								keepusing(resp_name resp_dad_name resp_mom_name) 
	
	keep if _merge == 3
	drop _merge 
	
	// NEED TO CHECK THOSE XLS FORM VAR WERE UPDATED WITH STATA CHECK VAR RESULTS
	
	// keep only required variable - need to correct in XLS form with ck_* var instead of cf_* var
	/*
	local cf_var	demo_town demo_clinic demo_vill study_id study_id_issue resp_name ///
					resp_dad_name resp_mom_name resp_age resp_sex tobacco blood_glucose	///
					cal_syst_avg cal_diast_avg weight height cal_bmi cal_cvd_risk ///
					cf_mhist_hypertension cf_mhist_drug_bp cf_mhist_diabetes cf_mhist_drug_bsug	///
					cf_mhist_stroke cf_mhist_heartatt cf_mhist_drug_aspirin cf_mhist_drug_statins ///
					cal_mhist_dbp_no cal_mhist_ddb_no cal_mhist_dasp_no cal_mhist_dstat_no
	*/ 
	
	local cf_var	demo_town demo_clinic demo_vill study_id study_id_issue resp_name ///
					resp_dad_name resp_mom_name resp_age resp_sex tobacco blood_glucose	///
					ck_cal_syst_avg ck_cal_diast_avg weight height bmi stata_cvd_risk ///
					ck_hypertension ck_hypertension_d ck_diabetes ck_diabetes_d	///
					ck_stroke ck_heartatt ck_aspirin_d ck_statins_d ///
					ck_hpd_cf ck_ddd_cf ck_dasp_cf ck_dstat_cf
	
	
	keep `cf_var'
	
	local yesno		ck_hypertension ck_hypertension_d ck_diabetes ck_diabetes_d	///
					ck_stroke ck_heartatt ck_aspirin_d ck_statins_d ///
					ck_hpd_cf ck_ddd_cf ck_dasp_cf ck_dstat_cf
	
	
	foreach var in `yesno' {
	    
		lab val `var' yesno
		tab `var', m 
	} 

	
	// export as csv file 
	export excel using "$sc_check/Confirmation_preload/confirm_list.xlsx", firstrow(variables) replace
	
	
	* end of dofile 
