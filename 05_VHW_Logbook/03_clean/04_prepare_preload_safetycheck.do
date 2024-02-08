/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Prepare a preload file for Patient Safety Check			
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
	use "$comb_clean/cvd_screening_confirmation_combined_cleaned_pii.dta", clear  
	
	local demovar		demo_town demo_clinic demo_vill	study_id ///
						resp_name resp_dad_name	resp_mom_name resp_age resp_sex	
						
	local enrollvar 	s_weight s_height bmi ///
						s_cal_syst_avg s_cal_diast_avg bp_syst_2 bp_diast_2 bp_syst_3 bp_diast_3 ///
						ck_cal_syst_avg ck_cal_diast_avg ck_bp_pass_1 ck_bp_pass_2 ///
						ck_mhist_hypertension ///
						ck_mhist_drug_bp ck_hypertension s_blood_glucose ck_blood_glucose ck_rbs_yes ///
						ck_mhist_diabetes ck_diabetes_d ck_diabetes	///
						mhist_stroke mhist_ischemic ck_mi_stroke_hist mhist_drug_aspirin ck_cvd_hist ///
						stata_cvd_risk_who stata_cvd_risk cf_cal_cvd_risk_yes ck_stroke_score ck_stroke_yes	///
						ck_angina_score ck_angina_yes stata_cvd_risk_final ck_qualify

	local medix_conf	amlodipine_yn amlodipine losartan_yn losartan hctz_yn hctz ///
						atorvastatin_yn atorvastatin metformin_yn metformin ///
						aspirin_yn aspirin atenolol_yn atenolol omeprazole_yn omeprazole ///
						oth_drug_name_1 oth_drug_dos_1 oth_drug_name_2 oth_drug_dos_2 oth_drug_name_3 oth_drug_dos_3
	
	/*
	local medix_vhw		v_amlodipine_1 amlodipine_pt_1 amlodipine_m_1 amlodipine_mp_1 ///
	v_losartan_1 losartan_pt_1 losartan_m_1 losartan_mp_1 v_hctz_1 hctz_pt_1 hctz_m_1 hctz_mp_1 v_atorvastatin_1 atorvastatin_pt_1 atorvastatin_m_1 atorvastatin_mp_1 v_metformin_1 metformin_pt_1 metformin_m_1 metformin_mp_1 v_aspirin_1 aspirin_pt_1 aspirin_m_1 aspirin_mp_1 v_atenolol_1 atenolol_pt_1 atenolol_m_1 atenolol_mp_1 v_omeprazole_1 omeprazole_pt_1 omeprazole_m_1 omeprazole_mp_1  ///
	
						
	v_oth_drug_name_1_1 v_oth_drug_dos_1_1 v_oth_drug_dosu_1_1 v_oth_drug_dosu_oth_1_1 oth_drug_pt_1_1 oth_drug_medic_1_1 oth_drug_mdos_1_1 oth_drug_mdosu_1_1 oth_drug_mdosu_oth_1_1
	v_oth_drug_name_2_1 v_oth_drug_dos_2_1 v_oth_drug_dosu_2_1 v_oth_drug_dosu_oth_2_1 oth_drug_pt_2_1 oth_drug_medic_2_1 oth_drug_mdos_2_1 oth_drug_mdosu_2_1 oth_drug_mdosu_oth_2_1
	*/
	
	keep 	`demovar' `enrollvar' `medix_conf' ///
			v_amlodipine_* amlodipine_pt_* amlodipine_m_* amlodipine_mp_* ///
			v_losartan_* losartan_pt_* losartan_m_* losartan_mp_* ///
			v_hctz_* hctz_pt_* hctz_m_* hctz_mp_* ///
			v_atorvastatin_* atorvastatin_pt_* atorvastatin_m_* atorvastatin_mp_* ///
			v_metformin_* metformin_pt_* metformin_m_* metformin_mp_* ///
			v_aspirin_* aspirin_pt_* aspirin_m_* aspirin_mp_* ///
			v_atenolol_* atenolol_pt_* atenolol_m_* atenolol_mp_* ///
			v_omeprazole_* omeprazole_pt_* omeprazole_m_* omeprazole_mp_* ///
			v_oth_drug_name_1_* v_oth_drug_dos_1_* v_oth_drug_dosu_1_* v_oth_drug_dosu_oth_1_* oth_drug_pt_1_* oth_drug_medic_1_* oth_drug_mdos_1_* oth_drug_mdosu_1_* oth_drug_mdosu_oth_1_* ///
			v_oth_drug_name_2_* v_oth_drug_dos_2_* v_oth_drug_dosu_2_* v_oth_drug_dosu_oth_2_* oth_drug_pt_2_* oth_drug_medic_2_* oth_drug_mdos_2_* oth_drug_mdosu_2_* oth_drug_mdosu_oth_2_*
			
	
	local yesno	ck_hypertension ck_diabetes mhist_ischemic mhist_stroke
	
	
	foreach var in `yesno' {
	    
		lab val `var' yesno
		tab `var', m 
	} 

	
	* codebook 
	iecodebook template using "$comb_clean/safety_checklist/safety_checklist_preload_codebook.xlsx", replace 
	
	
	// export as csv file 
	export excel using "$comb_clean/safety_checklist/safety_checklist_preload.xlsx", firstrow(variables) replace

	
	* end of dofile 