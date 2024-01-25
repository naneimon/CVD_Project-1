/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Adhoc data check on Adam request 			
Author				:	Nicholus Tint Zaw
Date				: 	01/25/2024
Modified by			:



Task outline: 
	1. 

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* DATASET COMBINATION *
	********************************************************************************

	
	* CVD Combined Datasets * 
	
	use "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.dta", clear 
	
	
	** Variables to Identify the Presence of Observations in Different Datasets **
	
	/* 
	The following variables can help you identify the presence of each observation in different types of datasets. 
	If the value of "confirmation_tool" is 1, it means that the observations were present in the confirmation visit tool dataset. 
	On the other hand, if the value of "confirmation_tool" is 0, it indicates that the observations were not present in the confirmation visit tool dataset.
	*/
	
	tab screening_tool, m 
	tab confirmation_tool, m 
	tab confirmation_additional, m 
	tab vhw_logbook, m 
	
	
	** Eligibility criteria vary at different stages **
	/* 
	It's important to note that we have various surveys and processes that have different stages of eligibility. 
	Below are the step-by-step processes for different eligibility statuses, from screening to enrollment, along with their corresponding variable names:

		1. Eligibility for screening (s_ck_cal_eligible from the screening tool)
		2. Eligibility for confirmatory visit (s_ck_cal_confirm_visit from screening tool)
		3. Eligibility for enrollment (ck_qualify from the confirmatory tool)
	*/
	
	tab s_ck_cal_eligible, m 
	tab s_ck_cal_confirm_visit, m 
	tab ck_qualify, m 
	
	
	
	
	** Expected condition/action variables: 
	
	/* 
	Those were come from the screening data as those were started with "s_" prefix and 
	below were the code for generation of those variables. 
	
	// expected hypertension medication 
	// if(${cf_mhist_hypertension}=1 or ${cf_mhist_drug_bp}=1 or ${cal_bp_pass_1}=1 or ${cal_bp_pass_2}=1,1,0) - need to revise the XLS code
	gen expt_hypertension = (ck_hypertension == 1 | ///
							 ck_hypertension_d == 1 | ///
							 ck_cf_cal_syst_avg == 1 | ///
							 ck_cf_cal_diast_avg == 1)
	lab var expt_hypertension "Expected hypertension medication"
	replace expt_hypertension = .m if ck_cal_eligible == 0
	tab expt_hypertension, m 
	
	
	// expected diabetes 
	// if(${cf_mhist_diabetes}=1 or ${cf_mhist_drug_bsug}=1 or ${cal_rbs_yes}=1, 1, 0)
	gen expt_diabetes = (ck_diabetes == 1 | ///
						 ck_diabetes_d == 1 | ///
						 ck_cf_blood_glucose == 1) 
	lab var expt_diabetes "Expected diabetes"
	replace expt_diabetes = .m if ck_cal_eligible == 0
	tab expt_diabetes, m 
	
	
	// expected statin medication
	// (${cal_hypertension}=1 and ${cal_diabetes}=1) or ${cal_diabetes}=1 or ${cal_angina_yes}=1 or ${cal_mi_stroke_hist}=1
	gen expt_statin = (expt_hypertension == 1 | ///
					   expt_diabetes == 1 | ///
					   ck_stroke == 1 | ///
					   ck_heartatt == 1)
	lab var expt_statin "expected statin medication"
	replace expt_statin = .m if ck_cal_eligible == 0
	tab expt_statin, m 
	
	*/ 
	
	
	* end of dofile 
