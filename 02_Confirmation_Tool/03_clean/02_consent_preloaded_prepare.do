/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Confirmation work - prepare the preloaded file for VHW logbook 		
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. keep only eligable and consent obs  
	2. export csv file for preloaded file preparation 

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data *
	********************************************************************************
	
	use "$np_cf_clean/cvd_confirmation_cleaned.dta", clear 
	
	****************************************************************************
	** VHW logbook - consented obs preloaded file **
	****************************************************************************
	
	// keep correct eligable for consent patient 
	keep if ck_qualify == 1
	
	// keep only consent patient 
	keep if consent == 1 
	
	* get personal info data 
	merge 1:1 study_id using 	"$sc_check/cvd_screening_check_nodup.dta", ///
								keepusing(resp_name resp_dad_name resp_mom_name) 
	
	keep if _merge == 3
	drop _merge 

	// NEED TO CHECK THOSE XLS FORM VAR WERE UPDATED WITH STATA CHECK VAR RESULTS
	
	// keep only required variable 
	rename resp_sppid ssp_id
	
	//drop weight height 
	rename s_weight weight 
	rename s_height height 
	
	/* need to change XLS programming with ck_* var instead of cal_* 
	local consent_var	demo_town demo_clinic demo_vill	study_id ssp_id	///
						resp_name resp_dad_name	resp_mom_name resp_age resp_sex	///
						weight height cal_hypertension cal_diabetes	mhist_ischemic mhist_stroke	cal_bmi
						*/


	local consent_var	demo_town demo_clinic demo_vill	study_id ssp_id	///
						resp_name resp_dad_name	resp_mom_name resp_age resp_sex	///
						weight height ck_hypertension ck_diabetes mhist_ischemic mhist_stroke bmi
						
						
	
	keep `consent_var'
	
	local yesno	ck_hypertension ck_diabetes mhist_ischemic mhist_stroke
	
	
	foreach var in `yesno' {
	    
		lab val `var' yesno
		tab `var', m 
	} 

	
	// export as csv file 
	export excel using "$cf_check/Enrolled_preload/study_participant_list.xlsx", firstrow(variables) replace

	
	* end of dofile 
