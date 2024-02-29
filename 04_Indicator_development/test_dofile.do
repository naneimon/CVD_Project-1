/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	No medication			
Author				:	Nicholus Tint Zaw
Date				: 	02/26/2024
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
	
	// keep correct eligable for consent patient 
	keep if ck_qualify == 1
	
	// keep only consent patient 
	keep if consent == 1 
	
	
	* Medication - Yes/No * based on confirmation visit  
	egen medication_yes = rowtotal(amlodipine_yn losartan_yn hctz_yn atorvastatin_yn metformin_yn aspirin_yn atenolol_yn omeprazole_yn)
	replace medication_yes = 1 if medication_yes > 0 
	replace medication_yes = .m if 	mi(amlodipine_yn) & mi(losartan_yn) & mi(hctz_yn) & ///
									mi(atorvastatin_yn) & mi(metformin_yn) & mi(aspirin_yn) & ///
									mi(atenolol_yn) & mi(omeprazole_yn)
	tab medication_yes, m 
	
	
	// ck_qualify ck_mi_stroke_hist ck_cvd_hist cf_cal_cvd_risk_yes ck_hypertension ck_diabetes
	
	egen enroll_check = rowtotal(ck_mi_stroke_hist ck_cvd_hist cf_cal_cvd_risk_yes ck_hypertension ck_diabetes)
	tab enroll_check, m // no 0 cases - correct 
	
	
	* Medication - no  
	sum ck_mi_stroke_hist ck_cvd_hist cf_cal_cvd_risk_yes ck_hypertension ck_diabetes if medication_yes == 0
	* medication - missing 
	sum ck_mi_stroke_hist ck_cvd_hist cf_cal_cvd_risk_yes ck_hypertension ck_diabetes if mi(medication_yes)
	
	
	gen quality_cvdrisk_only = (cf_cal_cvd_risk_yes == 1 & ck_mi_stroke_hist != 1 & ///
								ck_cvd_hist != 1 & ck_hypertension != 1 & ck_diabetes != 1)
	tab quality_cvdrisk_only, m 
	
	
	* Medication - Yes/No * based on confirmation + VHW fist visit  
	egen medication_yes_cvhw = rowtotal(amlodipine_yn losartan_yn hctz_yn atorvastatin_yn metformin_yn aspirin_yn atenolol_yn omeprazole_yn ///
								   medication1_1 medication2_1 medication3_1 medication4_1 medication5_1 medication6_1 medication7_1 medication8_1)
	replace medication_yes_cvhw = 1 if medication_yes_cvhw > 0 
	replace medication_yes_cvhw = .m if 	mi(amlodipine_yn) & mi(losartan_yn) & mi(hctz_yn) & ///
									mi(atorvastatin_yn) & mi(metformin_yn) & mi(aspirin_yn) & ///
									mi(atenolol_yn) & mi(omeprazole_yn) & ///
									mi(medication1_1) & mi(medication2_1) & mi(medication3_1) & ///
									mi(medication4_1) & mi(medication5_1) & mi(medication6_1) & ///
									mi(medication7_1) & mi(medication8_1)
	tab medication_yes_cvhw, m 
	
	
	
	* end of dofile 
