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

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data  *
	********************************************************************************
	
	use "$sc_check/cvd_screening_check.dta", clear 
	
	****************************************************************************
	** Confirmation Visit Calculation **
	****************************************************************************
	/*
	In XLS rogramming, we calculated CVD risk WHO first
	then if the patient have CVD history, adjust the result as following 
	MAX(cvd rish who X 2, 20)
	
	So, in this checking we check for CVD Risk WHO calculation using the parent variables 
	from survey 
	*/
	
	
	* prepare variable required for CVD risk calculation 
	local cvdinput sex ages sbp bmi smallbin // calculated var applied in XLS programming 
	
	destring `cvdinput', replace 
	
	foreach var in `cvdinput' {
	    rename `var' xls_`var'
	}
	
	destring cal_cvd_risk_who cal_cvd_risk_cvd cal_cvd_risk_raw cal_cvd_risk cal_cvd_risk_yes, replace 
	
	* Create variables from parents var for CVD calculation 
	// average BP measurement
	gen ck_cal_syst_avg 	= (bp_syst_2 + bp_syst_3) / 2
	gen ck_cal_diast_avg 	= (bp_diast_2 + bp_diast_3) / 2
	
	gen sbp 		= ck_cal_syst_avg
	gen ages 		= resp_age
	gen sex 		= resp_sex
	replace sex 	= 2 if resp_sex == 0
	gen smallbin 	= (tobacco > 0 & !mi(tobacco))
	gen bmi 		= weight/((height/100) ^ 2)

	
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
	
	
	** Update the CVD risk value to adjust the Confirmatory Visit Status 
	destring cf_mhist_stroke cf_mhist_heartatt, replace 
	
	gen stata_cvd_risk = stata_cvd_risk_who
	replace stata_cvd_risk = max(stata_cvd_risk * 2, 20) if (mhist_stroke == 1 | mhist_heartatt == 1)
	replace stata_cvd_risk = floor(stata_cvd_risk)
	tab stata_cvd_risk, m 
	
	
	gen cvd_final_check = (cal_cvd_risk != stata_cvd_risk)
	replace cvd_final_check = .m if mi(cal_cvd_risk) | mi(stata_cvd_risk)
	lab var cvd_final_check "CVD Risk Final Result Check"
	tab cvd_final_check, m 	
	
	
	* export as excel file 
	preserve 
	
		keep if cvd_final_check == 1
		
		if _N > 0 {
			
			export excel using "$sc_check/HFC/Community_Screening_Check_Outputs.xlsx", ///
								sheet("CVD Risk Error") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	****************************************************************************
	** Confirmation Visit Calculation **
	****************************************************************************
	/*
	** Confirmatory visit criteira **
	
	note_mhist_dbp_no		 	Responsed "No" to the follow-up questions related to taking medication 
								for raised blood pressure in the last 2 weeks question (OR) not able to present the medication
	note_mhist_ddb_no		 	Responsed "No" to the follow-up questions related to taking medication for diabetes 
								in the last 2 weeks question (OR) not able to present the medication
	note_mhist_dasp_no		 	Responsed "No" to the follow-up questions related to taking aspirin in the last 2 weeks question 
								(OR) not able to present the medication
	note_mhist_dstat_no		 	Responsed "No" to the follow-up questions related to taking statins in the last 2 weeks question 
								(OR) not able to present the medication
	note_mhist_hypertension		Medical history of hypertension
	note_mhist_drug_bp			Medical history of taking medication for raised blood pressure in the last 2 weeks
	note_mhist_diabetes			Medical history of diabetes
	note_mhist_drug_bsug		Medical history of taking medication for diabetes in the last 2 weeks
	note_mhist_stroke			Medical history of stroke
	note_mhist_heartatt			Medical history of heart attack
	note_mhist_drug_aspirin		Taking aspirin in the last 2 weeks
	note_mhist_drug_statins		Taking statins in the last 2 weeks
	note_cal_syst_avg			Average Systolic Blood Pressure >140
	note_cal_diast_avg			Average Diastolic Blood Pressure >90
	note_cal_bf_abnormal		At least one time Blood Pressure measurement was abnormal. 
	note_blood_glucose			Blood Blucose (re-check) > 200
	note_cvd_risk_yes			CVD Risk > 10%
	
	Re-calculated all the XLS programming calculation field - and those variable started with 
	"ck_" prefix. then re-construct the check confirmatory visit variable ck_cal_confirm_visit
	
	*/	
	
	* Hypertension Medical History 
	destring cal_mhist_dbp_no cf_mhist_hypertension cf_mhist_drug_bp, replace 
	
	gen ck_hypertension = (mhist_hypertension == 1)
	gen ck_hypertension_d = (mhist_drug_bp_1 == 1 | mhist_drug_bp_2 == 1)
	gen ck_hpd_cf = ((mhist_dbp_reg == 0 & mhist_dbp_am == 0) | mhist_dbp_yn == 0)
	
	count if cf_mhist_hypertension != ck_hypertension
	count if cf_mhist_drug_bp != ck_hypertension_d
	count if cal_mhist_dbp_no != ck_hpd_cf
	
	order ck_hpd_cf, after(cal_mhist_dbp_no) 
	order ck_hypertension, after(cf_mhist_hypertension)
	order ck_hypertension_d, after(cf_mhist_drug_bp)

	* Diabetes Medical History 
	destring cal_mhist_ddb_no cf_mhist_diabetes cf_mhist_drug_bsug, replace 
	
	gen ck_diabetes = (mhist_diabetes == 1)
	gen ck_diabetes_d = (mhist_drug_bsug_1 == 1 | mhist_drug_bsug_2 == 1)
	gen ck_ddd_cf = ((mhist_ddb_reg == 0 & mhist_ddb_am == 0) | mhist_ddb_yn == 0)
	
	count if cf_mhist_diabetes != ck_diabetes
	count if cf_mhist_drug_bsug != ck_diabetes_d
	count if cal_mhist_ddb_no != ck_ddd_cf

	order ck_diabetes, after(cf_mhist_diabetes)
	order ck_diabetes_d, after(cf_mhist_drug_bsug) 
	order ck_ddd_cf, after(cal_mhist_ddb_no)
	
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
	
	order ck_stroke, after(cf_mhist_stroke)
	order ck_heartatt, after(cf_mhist_heartatt)
	order ck_aspirin_d, after(cf_mhist_drug_aspirin)
	order ck_statins_d, after(cf_mhist_drug_statins) 
	order ck_dasp_cf, after(cal_mhist_dasp_no) 
	order ck_dstat_cf, after(cal_mhist_dstat_no)

	* Medical Examination: Blood Pressure 
	destring cf_cal_syst_avg cf_cal_diast_avg cf_cal_bf_abnormal, replace 
	
	// average BP - calculate at CVD risk check step
	gen ck_cf_cal_syst_avg = (ck_cal_syst_avg > 140)
	gen ck_cf_cal_diast_avg = (ck_cal_diast_avg > 90)
	
	count if cf_cal_syst_avg != ck_cf_cal_syst_avg
	count if cf_cal_diast_avg != ck_cf_cal_diast_avg
	
	order ck_cf_cal_syst_avg, after(cf_cal_syst_avg)
	order ck_cf_cal_diast_avg, after(cf_cal_diast_avg) 
	
	
	// abnormal value 
	gen ck_cal_syst_avg_abn = (ck_cal_syst_avg < 90 | ck_cal_syst_avg > 180)
	gen ck_cal_diast_avg_abn = (ck_cal_diast_avg < 50 | ck_cal_diast_avg > 110)
	
	gen ck_cf_cal_bf_abnormal = (ck_cal_syst_avg_abn == 1 | ck_cal_diast_avg_abn == 1)
	
	count if cf_cal_bf_abnormal != ck_cf_cal_bf_abnormal

	order ck_cf_cal_bf_abnormal, after(cf_cal_bf_abnormal)

	* Medical Examination: Blood Pressure 
	destring cf_blood_glucose, replace 
	
	gen ck_cf_blood_glucose = (blood_glucose > 200 & !mi(blood_glucose))
	replace ck_cf_blood_glucose = 1 if blood_glucose_rc_cal > 200 & (blood_glucose == 6666 | blood_glucose == 9999)
		
	count if cf_blood_glucose != ck_cf_blood_glucose
	
	order ck_cf_blood_glucose, after(cf_blood_glucose)
	
	* CVD risk > 10 
	destring cal_cvd_risk_yes, replace 
	
	gen cf_cal_cvd_risk_yes = (stata_cvd_risk > 10 & !mi(cal_cvd_risk_yes))
	order cf_cal_cvd_risk_yes, after(cal_cvd_risk_yes)
	tab1 cf_cal_cvd_risk_yes cal_cvd_risk_yes, m 

	
	* Final Check on Confirmation Visit Eligibility 
	* note: used the revised cvd risk calculation instead of create new one in caluclation 
	/*
	** Confirmatory visit criteira **
	
	note_mhist_dbp_no		 	Responsed "No" to the follow-up questions related to taking medication 
								for raised blood pressure in the last 2 weeks question (OR) not able to present the medication
	note_mhist_ddb_no		 	Responsed "No" to the follow-up questions related to taking medication for diabetes 
								in the last 2 weeks question (OR) not able to present the medication
	note_mhist_dasp_no		 	Responsed "No" to the follow-up questions related to taking aspirin in the last 2 weeks question 
								(OR) not able to present the medication
	note_mhist_dstat_no		 	Responsed "No" to the follow-up questions related to taking statins in the last 2 weeks question 
								(OR) not able to present the medication
	note_mhist_hypertension		Medical history of hypertension
	note_mhist_drug_bp			Medical history of taking medication for raised blood pressure in the last 2 weeks
	note_mhist_diabetes			Medical history of diabetes
	note_mhist_drug_bsug		Medical history of taking medication for diabetes in the last 2 weeks
	note_mhist_stroke			Medical history of stroke
	note_mhist_heartatt			Medical history of heart attack
	note_mhist_drug_aspirin		Taking aspirin in the last 2 weeks
	note_mhist_drug_statins		Taking statins in the last 2 weeks
	note_cal_syst_avg			Average Systolic Blood Pressure >140
	note_cal_diast_avg			Average Diastolic Blood Pressure >90
	note_cal_bf_abnormal		At least one average Blood Pressure measurement was abnormal. 
	note_blood_glucose			Blood Blucose (re-check) > 200
	note_cvd_risk_yes			CVD Risk > 10%
	
	Re-calculated all the XLS programming calculation field - and those variable started with 
	"ck_" prefix. then re-construct the check confirmatory visit variable ck_cal_confirm_visit
	
	*/	
	
	lab var cf_cal_cvd_risk_yes		"CVD Risk > 10%"
	lab var ck_cf_blood_glucose 	"Blood Glucose > 200"
	lab var ck_cf_cal_bf_abnormal 	"At least one Average Blood Pressure measurement was abnormal."
	lab var ck_cf_cal_syst_avg 		"Average Systolic Blood Pressure >140"
	lab var ck_cf_cal_diast_avg 	"Average Diastolic Blood Pressure >90"
	lab var ck_stroke 				"Medical history of stroke"
	lab var ck_heartatt 			"Medical history of heart attack"
	lab var ck_aspirin_d 			"Taking aspirin in the last 2 weeks"
	lab var ck_statins_d 			"Taking statins in the last 2 weeks"
	lab var ck_dasp_cf 				"Aspirin: No to follow up question or not able to present medication"
	lab var ck_dstat_cf 			"Statins: No to follow up question or not able to present medication"
	lab var ck_diabetes 			"Medical history of diabetes"
	lab var ck_diabetes_d 			"Diabetes medication in the last 2 weeks"
	lab var ck_hypertension 		"Medical history of hypertension"
	lab var ck_hypertension_d 		"Anti-hypertension medication in the last 2 weeks"
	lab var ck_hpd_cf				"Anti-hypertension medication: No to follow up question or not able to present medication"
	lab var ck_ddd_cf 				"Diabetes medication: No to follow up question or not able to present medication"
	
	// cal_confirm_visit
	destring cal_confirm_visit, replace 
	gen ck_cal_confirm_visit = (cf_cal_cvd_risk_yes == 1 | ///
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

	order ck_cal_confirm_visit, after(cal_confirm_visit)
	
	count if cal_confirm_visit != ck_cal_confirm_visit
	
	tab cal_confirm_visit ck_cal_confirm_visit, m
	
	
	preserve 
	
		keep if cal_confirm_visit != ck_cal_confirm_visit
		
		if _N > 0 {
			
			export excel using "$sc_check/HFC/Community_Screening_Check_Outputs.xlsx", ///
								sheet("Confirmatory Visit Error") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	// cf_cal_cvd_risk_yes ck_cf_blood_glucose ck_cf_cal_bf_abnormal ck_cf_cal_syst_avg ck_cf_cal_diast_avg ck_stroke ck_heartatt ck_aspirin_d ck_statins_d ck_dasp_cf ck_dstat_cf ck_diabetes ck_diabetes_d ck_hypertension ck_hypertension_d ck_hpd_cf ck_ddd_cf
								
	br bp_syst_3 bp_diast_3 ck_* cal_confirm_sum cal_mhist_dbp_no cal_mhist_ddb_no cal_mhist_dasp_no cal_mhist_dstat_no cal_confirm_medhis_sum cal_confirm_visit  ck_cal_confirm_visit if cal_confirm_visit != ck_cal_confirm_visit
	
	gen confirmation_visit_yes = ck_cal_confirm_visit
	lab var confirmation_visit_yes "Final List for Confirmation Visit"
	
	
	* Save as raw data 
	save "$sc_check/cvd_screening_check.dta", replace 
	
	* end of dofile 
