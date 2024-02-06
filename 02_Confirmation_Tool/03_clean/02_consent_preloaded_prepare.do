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
	
	
	/* 
	FIELD ISSUE NOTE: 
	During the confirmation visit, there were some issues with field work, and some forms of confirmation visits were not successfully uploaded to the server. Though the field team claims that those forms were uploaded. We have identified 7 observations that were eligible to participate in the confirmation visit, but they were not found on the server. Additionally, 2 observations from the additional questions were also not found in the confirmation data. In total, 9 observations were not found in the confirmation visit.
	
	Out of the 9 observations that were not found in the confirmation visit, some of them were eligible to enroll in the study and had provided consent to participate. Therefore, we manually entered their data into the VHW logbook preloaded file to include them in the study.
	*/ 
	
	insheet using "$cf_check/Enrolled_preload/study_participant_list_Manual_Update.csv", clear 
	
	rename cal_bmi				bmi
	rename cal_hypertension 	ck_hypertension 
	rename cal_diabetes			ck_diabetes
	
	tempfile vhw_manual 
	save `vhw_manual'
	
	

	********************************************************************************
	* import raw data *
	********************************************************************************
	
	use "$np_cf_clean/cvd_confirmation_cleaned.dta", clear 

	/*
	// keep correct eligable for consent patient 
	//keep if ck_qualify == 1
	
	// keep only consent patient 
	//keep if consent == 1 
	
	keep study_id ck_qualify consent 
	
	merge 1:1 study_id using `vhw_manual'
	
	&&
	
	
	keep demo_town demo_clinic demo_vill	study_id ssp_id	///
						resp_name resp_dad_name	resp_mom_name resp_age resp_sex	///
						weight height ck_hypertension ck_diabetes mhist_ischemic mhist_stroke bmi
						
						
	*/
	
	****************************************************************************
	** VHW logbook - consented obs preloaded file **
	****************************************************************************
	
	// keep correct eligable for consent patient 
	keep if ck_qualify == 1
	
	// keep only consent patient 
	keep if consent == 1 
	
	* get personal info data 
	merge 1:1 study_id using 	"$np_sc_check/cvd_screening_check.dta", ///
								keepusing(resp_name resp_dad_name resp_mom_name) 

	keep if _merge == 3
	drop _merge 

	// NEED TO CHECK THOSE XLS FORM VAR WERE UPDATED WITH STATA CHECK VAR RESULTS
	
	// keep only required variable 
	rename resp_sppid spp_id
	
	//drop weight height 
	rename s_weight weight 
	rename s_height height 
	
	/* need to change XLS programming with ck_* var instead of cal_* 
	local consent_var	demo_town demo_clinic demo_vill	study_id ssp_id	///
						resp_name resp_dad_name	resp_mom_name resp_age resp_sex	///
						weight height cal_hypertension cal_diabetes	mhist_ischemic mhist_stroke	cal_bmi
						*/


	local consent_var	demo_town demo_clinic demo_vill	study_id spp_id	///
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
