/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work - HFC 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. Check CVD Risk Calcuation 
	2. Check Confirmation visit is working correctly or not

*******************************************************************************/
	
	****************************************************************************
	** Confirmation Visit Calculation **
	****************************************************************************
	/*
	In XLS rogramming, we calculated CVD risk WHO first
	then if the patient have CVD history, adjust the result as following 
	MAX(cvd rish who X 2, 20)
	
	So, in this checking we check for CVD Risk WHO calculation
	*/
	
	
	* prepare variable required for CVD risk calculation 
	local cvdinput sex ages sbp bmi smallbin
	
	destring `cvdinput', replace 
	destring cal_cvd_risk_who cal_cvd_risk_cvd cal_cvd_risk_raw cal_cvd_risk cal_cvd_risk_yes, replace 
	
	preserve 
	
		keep _uuid `cvdinput' cal_cvd_risk_who cal_cvd_risk_cvd cal_cvd_risk_raw cal_cvd_risk cal_cvd_risk_yes

		gen ccode = "MMR"
		
		* calculate cvd risk 
		whocvdrisk 
		
		* check STATA output 
		rename cal2_who_cvdx_m2 stata_cvd_risk_who
		replace stata_cvd_risk_who = round(stata_cvd_risk_who * 100, 0.1)

		gen cvd_cal_check = (abs(stata_cvd_risk_who - cal_cvd_risk_who) > 0.1) // as flot point apply abs value function 
		replace cvd_cal_check = .m if mi(stata_cvd_risk_who) | mi(cal_cvd_risk_who)
		lab var cvd_cal_check "CVD Risk WHO Calculation Check"
		tab cvd_cal_check, m 
		
		keep _uuid stata_cvd_risk_who cvd_cal_check
		
		tempfile cvdcheck 
		save `cvdcheck', replace 
	
	restore 
	
	merge 1:1 _uuid using `cvdcheck'
	
	* export as excel file 
	preserve 
	
		keep if cvd_cal_check == 1
		
		if _N > 0 {
			
			export excel using "$sc_check/HFC/Community_Screening_Check_Outputs.xlsx", ///
								sheet("CVD Risk Error") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	
	** Update the CVD risk value to adjust the Confirmatory Visit Status 
	destring cf_mhist_stroke cf_mhist_heartatt, replace 
	
	// cal_cvd_risk_who
	replace cal_cvd_risk_who = stata_cvd_risk_who if cvd_cal_check == 1
	
	// cal_cvd_risk_cvd
	replace cal_cvd_risk_cvd =  max(cal_cvd_risk_who * 2, 20) if cvd_cal_check == 1 & (cf_mhist_stroke == 1 | cf_mhist_heartatt == 1)
	
	// cal_cvd_risk
	// round-down all decimal point
	replace cal_cvd_risk = floor(cal_cvd_risk_cvd) if cvd_cal_check == 1 & (cf_mhist_stroke == 1 | cf_mhist_heartatt == 1)
	
	// cal_cvd_risk_yes
	replace cal_cvd_risk_yes = 1 if cal_cvd_risk > 10 & cvd_cal_check == 1 & (cf_mhist_stroke == 1 | cf_mhist_heartatt == 1)
	
	
	****************************************************************************
	** Confirmation Visit Calculation **
	****************************************************************************
	
	* Hypertension Medical History 
	destring cal_mhist_dbp_no cf_mhist_hypertension cf_mhist_drug_bp, replace 
	
	gen ck_hypertension = (mhist_hypertension == 1)
	gen ck_hypertension_d = (mhist_drug_bp_1 == 1 | mhist_drug_bp_2 == 1)
	gen ck_hpd_cf = ((mhist_dbp_reg == 0 & mhist_dbp_am == 0) | mhist_dbp_yn == 0)
	
	count if cf_mhist_hypertension != ck_hypertension
	count if cf_mhist_drug_bp != ck_hypertension_d
	count if cal_mhist_dbp_no != ck_hpd_cf

	* Diabetes Medical History 
	destring cal_mhist_ddb_no cf_mhist_diabetes cf_mhist_drug_bsug, replace 
	
	gen ck_diabetes = (mhist_diabetes == 1)
	gen ck_diabetes_d = (mhist_drug_bsug_1 == 1 | mhist_drug_bsug_2 == 1)
	gen ck_ddd_cf = ((mhist_ddb_reg == 0 & mhist_ddb_am == 0) | mhist_ddb_yn == 0)
	
	count if cf_mhist_diabetes != ck_diabetes
	count if cf_mhist_drug_bsug != ck_diabetes_d
	count if cal_mhist_ddb_no != ck_ddd_cf
	
	* Stroke and Heart Attack Medical History 
	destring cf_mhist_stroke cf_mhist_heartatt cf_mhist_drug_aspirin cal_mhist_dasp_no cf_mhist_drug_statins cal_mhist_dstat_no, replace 
	
	gen ck_stroke = (mhist_stroke == 1)
	gen ck_heartatt = (mhist_heartatt == 1)
	
	gen ck_aspirin_d = (mhist_drug_aspirin_1 == 1 | mhist_drug_aspirin_2 == 1)
	gen ck_statins_d = (mhist_drug_statins_1 == 1 | mhist_drug_statins_1 == 1)

	gen ck_dasp_cf = ((mhist_dasp_reg == 0 & mhist_dasp_am == 0) | mhist_dasp_yn == 0)
	gen ck_dstat_cf = ((mhist_dstat_reg == 0 & mhist_dstat_am == 0) | mhist_dstat_yn == 0)

	count if cf_mhist_stroke != ck_stroke
	count if cf_mhist_heartatt != ck_heartatt
	
	count if cf_mhist_drug_aspirin != ck_aspirin_d
	count if cf_mhist_drug_statins != ck_statins_d

	count if cal_mhist_dasp_no != ck_dasp_cf
	count if cal_mhist_dstat_no != ck_dstat_cf
	
	* Medical Examination: Blood Pressure 
	destring cf_cal_syst_avg cf_cal_diast_avg cf_cal_bf_abnormal, replace 
	
	// average measurement
	gen ck_bp_syst_1 = bp_syst_1
	replace ck_bp_syst_1 = bp_syst_rc_1_1 if !mi(bp_syst_rc_1_1)
	
	gen ck_bp_diast_1 = bp_diast_1
	replace ck_bp_diast_1 = bp_diast_rc_1_1 if !mi(bp_diast_rc_1_1)

	gen ck_bp_syst_2 = bp_syst_2
	replace ck_bp_syst_2 = bp_syst_rc_2_1 if !mi(bp_syst_rc_2_1)
	
	gen ck_bp_diast_2 = bp_diast_2
	replace ck_bp_diast_2 = bp_diast_rc_2_1 if !mi(bp_diast_rc_2_1)

	gen ck_bp_syst_3 = bp_syst_3
	replace ck_bp_syst_1 = bp_syst_rc_3_1 if !mi(bp_syst_rc_3_1)
	
	gen ck_bp_diast_3 = bp_diast_3
	replace ck_bp_diast_3 = bp_diast_rc_3_1 if !mi(bp_diast_rc_3_1)

	gen ck_cal_syst_avg = (ck_bp_syst_2 + ck_bp_syst_3) / 2
	gen ck_cal_diast_avg = (ck_bp_diast_2 + ck_bp_diast_3) / 2

	gen ck_cf_cal_syst_avg = (ck_cal_syst_avg > 140)
	gen ck_cf_cal_diast_avg = (ck_cal_diast_avg > 90)
	
	count if cf_cal_syst_avg != ck_cf_cal_syst_avg
	count if cf_cal_diast_avg != ck_cf_cal_diast_avg
	
	// abnormal value 
	gen ck_syst_abn_1 = ((bp_syst_rc_1_1 <90 | bp_syst_rc_1_1 > 180) & !mi(bp_syst_rc_1_1))
	gen ck_diast_abn_1 = (bp_diast_rc_1_1 > 110 & !mi(bp_diast_rc_1_1))

	gen ck_syst_abn_2 = ((bp_syst_rc_2_1 <90 | bp_syst_rc_2_1 > 180) & !mi(bp_syst_rc_2_1))
	gen ck_diast_abn_2 = (bp_diast_rc_2_1 > 110 & !mi(bp_diast_rc_2_1))

	gen ck_syst_abn_3 = ((bp_syst_rc_3_1 <90 | bp_syst_rc_3_1 > 180) & !mi(bp_syst_rc_3_1))
	gen ck_diast_abn_3 = (bp_diast_rc_3_1 > 110 & !mi(bp_diast_rc_3_1))
	
	egen ck_bp_abn_all = rowtotal(ck_syst_abn_* ck_diast_abn_*)
	
	gen ck_cf_cal_bf_abnormal = (ck_bp_abn_all > 0)
	
	count if cf_cal_bf_abnormal != ck_cf_cal_bf_abnormal

	* Medical Examination: Blood Pressure 
	destring cf_blood_glucose, replace 
	
	gen ck_cf_blood_glucose = (blood_glucose_rc > 200 & !mi(blood_glucose_rc))
	
	count if cf_blood_glucose != ck_cf_blood_glucose 
	

	* Final Check on Confirmation Visit Eligibility 
	* note: used the revised cvd risk calculation instead of create new one in caluclation 
	
	// cal_confirm_visit
	destring cal_confirm_visit, replace 
	gen ck_cal_confirm_visit = (cal_cvd_risk_yes == 1 | ///
								ck_cf_blood_glucose == 1 | ///
								ck_cf_cal_bf_abnormal == 1 | ///
								ck_cf_cal_syst_avg == 1 | ///
								ck_cf_cal_diast_avg == 1 | ///
								ck_stroke == 1 | ///
								ck_heartatt == 1 | ///
								ck_aspirin_d == 1 | ///
								ck_statins_d == 1 | ///
								ck_dasp_cf == 1 | ///
								ck_dstat_cf == 1 | ///
								ck_diabetes == 1 | ///
								ck_diabetes_d == 1 | ///
								ck_hypertension == 1 | ///
								ck_hypertension_d == 1 | ///
								ck_hpd_cf == 1 | ///
								ck_ddd_cf == 1)

	count if cal_confirm_visit != ck_cal_confirm_visit
	
	tab cal_confirm_visit ck_cal_confirm_visit, m
	tab cal_confirm_visit ck_cal_confirm_visit if starttime >= td(10nov2023), m // working well after 10nov2023 
	
	br bp_syst_3 bp_syst_rc_3_1 bp_diast_3 bp_diast_rc_3_1 ck_* cal_confirm_sum cal_mhist_dbp_no cal_mhist_ddb_no cal_mhist_dasp_no cal_mhist_dstat_no cal_confirm_medhis_sum cal_confirm_visit  ck_cal_confirm_visit if cal_confirm_visit != ck_cal_confirm_visit
	
	gen confirmation_visit_yes = ck_cal_confirm_visit
	lab var confirmation_visit_yes "Final List for Confirmation Visit"
	
	
	* end of dofile 
