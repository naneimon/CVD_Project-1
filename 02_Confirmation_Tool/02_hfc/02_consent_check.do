/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Confirmation work - HFC 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. Check CVD Risk Calcuation 
	2. Check Enrollment Eligability is working correctly or not

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data *
	********************************************************************************
	
	use "$np_cf_raw/cvd_confirmation_raw_nopii.dta", clear 
	
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
	
	destring 	cal_cvd_risk_who cal_cvd_risk_cvd cal_cvd_risk_raw1 cal_cvd_risk cal_cvd_risk_yes ///
				cal_cvd_risk_cvd_2 cal_cvd_risk_raw2 cal_cvd_risk_final cal_bmi, replace 
	
	* Create variables from parents var for CVD calculation 
	// average BP measurement
	gen ck_cal_syst_avg 		= (bp_syst_2 + bp_syst_3) / 2
	replace ck_cal_syst_avg 	= .m if mi(bp_syst_2) | mi(bp_syst_3)
	gen ck_cal_diast_avg 		= (bp_diast_2 + bp_diast_3) / 2
	replace ck_cal_diast_avg 	= .m if mi(bp_diast_2) | mi(bp_diast_3)
	
	gen sbp 		= ck_cal_syst_avg
	gen ages 		= resp_age
	gen sex 		= resp_sex
	replace sex 	= 2 if resp_sex == 0
	gen smallbin 	= (tobacco > 0 & !mi(tobacco))
	gen bmi 		= cal_bmi // weight/((height/100) ^ 2)
	//replace bmi		= .m if mi(weight) | mi(height)

	tab cal_cvd_risk_who, m // 2 missing - some calculated field were not working - small values in the input parameters

	preserve 
	
		keep 	_uuid `cvdinput' cal_cvd_risk_who /*cal_cvd_risk_cvd cal_cvd_risk_raw1 cal_cvd_risk cal_cvd_risk_yes ///
				cal_cvd_risk_cvd_2 cal_cvd_risk_raw2 cal_cvd_risk_final*/

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
	
	merge 1:1 _uuid using `cvdcheck', assert(3) nogen 
	
	
	** Update the CVD risk value to adjust medical history and examination 
	destring cf_mhist_stroke cf_mhist_heartatt, replace 
		
	// updated the CVD risk based on medical history
	gen stata_cvd_risk = stata_cvd_risk_who
	replace stata_cvd_risk = max(stata_cvd_risk * 2, 20) if (mhist_stroke == 1 | ///
															 mhist_heartatt == 1) 
	replace stata_cvd_risk = floor(stata_cvd_risk)
	tab stata_cvd_risk, m 
	
	gen cvd_final_check = (cal_cvd_risk != stata_cvd_risk)
	replace cvd_final_check = .m if mi(cal_cvd_risk) & mi(stata_cvd_risk)
	lab var cvd_final_check "CVD Risk Final Result Check"
	tab cvd_final_check, m 	
	
	* export as excel file 
	preserve 
	
		keep if cvd_final_check == 1
		
		if _N > 0 {
			
			export excel using "$np_cf_check/HFC/Confirmation_Tool_Check_Outputs.xlsx", ///
								sheet("CVD Risk Error") firstrow(varlabels) sheetmodify
		}
	
	restore 

	** Update with Stroke and Angina Question ** 
	// Stroke question 
	tab consent, m 
	
	destring cal_stroke_score cal_stroke_yes, replace 
	
	foreach var of varlist 	stroke_1 stroke_2 stroke_3 stroke_4 stroke_5 stroke_6 ///
							cal_stroke_score cal_stroke_yes {
		
		replace `var' = .m if consent != 1
		tab `var', m 
	}
	
	egen ck_stroke_score = rowtotal(stroke_1 stroke_2 stroke_3 stroke_4 stroke_5 stroke_6)
	replace ck_stroke_score = .m if mi(stroke_1) & mi(stroke_2) & mi(stroke_3) & ///
									mi(stroke_4) & mi(stroke_5) & mi(stroke_6)
	order ck_stroke_score, after(cal_stroke_score)
	tab ck_stroke_score, m 
	
	count if ck_stroke_score != cal_stroke_score
	
	gen ck_stroke_yes = (ck_stroke_score > 0 | mhist_stroke == 1)
	replace ck_stroke_yes = .m if consent != 1
	order ck_stroke_yes, after(cal_stroke_yes)
	tab ck_stroke_yes, m 
	
	count if ck_stroke_yes != cal_stroke_yes // 1 reslted from calculated mhist_stroke field - not updated 
	
	
	// Angina questions 
	destring	angina_71 angina_72 angina_73 angina_74 angina_78888 angina_70 ///
				cal_angina_7_1 cal_angina_7_2 cal_angina_7_3 cal_angina_7_4 ///
				cal_angina_4 cal_angina_5 cal_angina_6 cal_angina_7 ///
				cal_angina_score cal_angina_yes, replace 
				
	
	// angina_1 angina_2 angina_3 angina_4 angina_5 angina_6 angina_7
	replace angina_1 = .m if consent != 1
	tab angina_1, m 
	
	foreach var of varlist	angina_2 angina_3 angina_4 angina_5 angina_6 ///
							angina_71 angina_72 angina_73 angina_74 angina_78888 angina_70 ///
							cal_angina_4 cal_angina_5 cal_angina_6 cal_angina_7 ///
							cal_angina_score cal_angina_yes {
		
		replace `var' = .m if angina_1 != 1
		tab `var', m 
		
	}
	
	// cal_angina_4 
	gen ck_angina_4 = (angina_4 == 0)
	replace ck_angina_4 = .m if mi(angina_4)
	order ck_angina_4, after(cal_angina_4)
	tab ck_angina_4, m 
	
	// cal_angina_5 
	gen ck_angina_5 = (angina_5 == 1)
	replace ck_angina_5 = .m if mi(angina_5)
	order ck_angina_5, after(cal_angina_5)
	tab ck_angina_5, m 
	
	// cal_angina_6 
	gen ck_angina_6 = (angina_6 == 0)
	replace ck_angina_6 = .m if mi(angina_6)
	order ck_angina_6, after(cal_angina_6)
	tab ck_angina_6, m 
	
	// cal_angina_7
	gen ck_angina_7 = (angina_71 ==1 | angina_72 == 1 | (angina_73 == 1 & angina_74 == 1))
	replace ck_angina_7 = .m if angina_1 != 1
	order ck_angina_7, after(cal_angina_7)
	tab ck_angina_7, m 
	
	// cal_angina_score 
	egen ck_angina_score = rowtotal(angina_1 angina_2 angina_3 ck_angina_4 ck_angina_5 ck_angina_6 ck_angina_7)
	replace ck_angina_score = .m if mi(angina_1) & mi(angina_2) & mi(angina_3) & mi(ck_angina_4) & ///
									mi(ck_angina_5) & mi(ck_angina_6) & mi(ck_angina_7)
	replace ck_angina_score = .m if angina_1 != 1
	order ck_angina_score, after(cal_angina_score)
	tab ck_angina_score, m 
	
	count if ck_angina_score != cal_angina_score
	
	// cal_angina_yes
	gen ck_angina_yes =  (ck_angina_score == 7)
	replace ck_angina_yes = .m if mi(ck_angina_score)
	order ck_angina_yes, after(cal_angina_yes)
	tab ck_angina_yes, m 
	
	count if ck_angina_yes != cal_angina_yes
	
	** Updated the CVD risk based on medical history, stroke and angina questions results 
	gen stata_cvd_risk_final = stata_cvd_risk_who
	replace stata_cvd_risk_final = max(stata_cvd_risk_final * 2, 20) if (mhist_stroke == 1 | ///
															 mhist_heartatt == 1 | ///
															 ck_stroke_yes == 1 | ///
															 ck_angina_yes == 1)
	replace stata_cvd_risk_final = floor(stata_cvd_risk_final)
	tab stata_cvd_risk_final, m 


	****************************************************************************
	** Study Enrollment Eligability Criteria Calculation **
	****************************************************************************
	/*
	** Eligability Criteira **
	
	cal_mi_stroke_hist		10.4	History of MI or Stroke 	If 5.1 = Yes or 5.2 = Yes  >>  YES
	cal_cvd_hist			10.5	History of CVD 	If 7.1 = Yes  >> YES
	cal_hypertension		10.1	Hypertension by history or medications or 
									if [BP > 140/90 at screening AND confirmation visit] or 
									if [BP >160/110 on EITHER visit]
	cal_diabetes			10.2	Diabetes by history, medication or if RBS > 200 mg on 2 occassions [more than once]
	cal_cvd_risk_yes		10.3	CVD risk > 10%
	cal_qualify_sum			
	cal_qualify						Qualify as Study participant 
	
	*/	

	*******************************************
	* Stroke and Heart Attack Medical History *
	*******************************************
	destring cal_mi_stroke_hist, replace 
	
	gen ck_mi_stroke_hist = (mhist_stroke == 1 | mhist_ischemic == 1)
	order ck_mi_stroke_hist, after(cal_mi_stroke_hist)
	tab ck_mi_stroke_hist, m 
	
	count if ck_mi_stroke_hist != cal_mi_stroke_hist // 0
	
	***********************
	* CVD Medical History *
	***********************
	destring cal_cvd_hist, replace 
	
	gen ck_cvd_hist = (mhist_drug_aspirin == 1)
	order ck_cvd_hist, after(cal_cvd_hist)
	tab ck_cvd_hist, m 
	
	count if ck_cvd_hist != cal_cvd_hist // 0

	*****************
	* CVD risk > 10 *
	*****************
	destring cal_cvd_risk_yes, replace 
	
	gen cf_cal_cvd_risk_yes = (stata_cvd_risk > 10 & !mi(stata_cvd_risk))
	order cf_cal_cvd_risk_yes, after(cal_cvd_risk_yes)
	tab1 cf_cal_cvd_risk_yes cal_cvd_risk_yes, m 

	count if cf_cal_cvd_risk_yes != cal_cvd_risk_yes // 0
	
	********************************
	* Hypertension Medical History *
	********************************
	// if(${cf_mhist_hypertension}=1 or ${cf_mhist_drug_bp}=1 or ${cal_bp_pass_1}=1 or ${cal_bp_pass_2}=1,1,0)

	destring 	cf_mhist_hypertension cf_mhist_drug_bp cal_bp_pass_1 cal_bp_pass_2 ///
				s_cal_syst_avg s_cal_diast_avg cal_hypertension, replace 
	
	gen ck_mhist_hypertension = (mhist_hypertension == 1)
	gen ck_mhist_drug_bp = (mhist_drug_bp == 1)
	
	count if ck_mhist_hypertension != cf_mhist_hypertension // 4 obs - calculation error - not updated 
	count if ck_mhist_drug_bp != cf_mhist_drug_bp

	order ck_mhist_hypertension, after(cf_mhist_hypertension)
	order ck_mhist_drug_bp, after(cf_mhist_drug_bp)
	
	// average BP measurement
	// cal_bp_pass_1
	gen ck_bp_pass_1 = ((s_cal_syst_avg > 140 & !mi(s_cal_syst_avg) & ///
						s_cal_diast_avg > 90 & !mi(s_cal_diast_avg)) & ///
						(ck_cal_syst_avg > 140 & !mi(ck_cal_syst_avg) & ///
						ck_cal_diast_avg > 90 & !mi(ck_cal_diast_avg)))
	replace ck_bp_pass_1 = .m if mi(s_cal_syst_avg) | mi(s_cal_diast_avg) | ///
								 mi(ck_cal_syst_avg) | mi(ck_cal_diast_avg)
	order ck_bp_pass_1, after(cal_bp_pass_1)
	tab ck_bp_pass_1, m 
	
	count if ck_bp_pass_1 != cal_bp_pass_1
	

	// cal_bp_pass_2
	gen ck_bp_pass_2 = ((s_cal_syst_avg > 160 & !mi(s_cal_syst_avg) & ///
						s_cal_diast_avg > 110 & !mi(s_cal_diast_avg)) | ///
						(ck_cal_syst_avg > 160 & !mi(ck_cal_syst_avg) & ///
						ck_cal_diast_avg > 110 & !mi(ck_cal_diast_avg)))
	replace ck_bp_pass_2 = .m if mi(s_cal_syst_avg) | mi(s_cal_diast_avg) | ///
								 mi(ck_cal_syst_avg) | mi(ck_cal_diast_avg)
	order ck_bp_pass_2, after(cal_bp_pass_2)
	tab ck_bp_pass_2, m 
	
	count if ck_bp_pass_2 != cal_bp_pass_2
	
	gen ck_hypertension = (ck_mhist_hypertension == 1 | ck_mhist_drug_bp == 1 | ///
						   ck_bp_pass_1 == 1 | ck_bp_pass_2 == 1)
	replace ck_hypertension = .m if mi(ck_mhist_hypertension) & mi(ck_mhist_drug_bp) & ///
									mi(ck_bp_pass_1) & mi(ck_bp_pass_2)
	order ck_hypertension, after(cal_hypertension)
	tab ck_hypertension, m 
	
	count if ck_hypertension != cal_hypertension // 5 obs - resulted by the BP average calculation and hypertension medical history calculation 
	
	// br mhist_hypertension mhist_drug_bp s_cal_syst_avg s_cal_diast_avg ck_cal_syst_avg ck_cal_diast_avg ck_hypertension ck_mhist_hypertension ck_mhist_drug_bp ck_bp_pass_1 ck_bp_pass_2 cal_hypertension cf_mhist_hypertension cf_mhist_drug_bp cal_bp_pass_1 cal_bp_pass_2 if ck_hypertension != cal_hypertension
		
	****************************
	* Diabetes Medical History *
	****************************
	// if(${cf_mhist_diabetes}=1 or ${cf_mhist_drug_bsug}=1 or ${cal_rbs_yes}=1, 1, 0)

	destring cf_mhist_diabetes cf_mhist_drug_bsug cal_rbs_yes s_blood_glucose blood_glucose_rc cal_diabetes, replace 
	
	gen ck_mhist_diabetes = (mhist_diabetes == 1)
	gen ck_diabetes_d = (mhist_drug_bsug == 1)
	
	count if cf_mhist_diabetes != ck_mhist_diabetes
	count if cf_mhist_drug_bsug != ck_diabetes_d

	order ck_mhist_diabetes, after(cf_mhist_diabetes)
	order ck_diabetes_d, after(cf_mhist_drug_bsug) 
	

	// cal_rbs_yes
	// measurement check 
	// br mhist_diabetes mhist_drug_bsug s_blood_glucose blood_glucose blood_glucose_rc_cal bl_glucose_rpt blood_glucose_rc_ref blood_glucose_rc if (s_blood_glucose > 200 & !mi(s_blood_glucose)) | mhist_diabetes == 1 | mhist_drug_bsug == 1
	
	replace blood_glucose_rc = .m if (s_blood_glucose <= 200 | mi(s_blood_glucose)) & mhist_diabetes != 1 & mhist_drug_bsug != 1 
	tab blood_glucose_rc, m 
	
	gen ck_blood_glucose = blood_glucose
	replace ck_blood_glucose = blood_glucose_rc_cal if blood_glucose == 6666 | blood_glucose == 9999
	replace ck_blood_glucose = 0 if ck_blood_glucose == 7777 // if refused to measure 
	replace ck_blood_glucose = .m if (s_blood_glucose <= 200 | mi(s_blood_glucose)) & mhist_diabetes != 1 & mhist_drug_bsug != 1 
	order ck_blood_glucose, after(blood_glucose_rc)
	tab ck_blood_glucose, m 
	
	count if ck_blood_glucose != blood_glucose_rc // 0
	
	replace cal_rbs_yes = .m if (s_blood_glucose <= 200 | mi(s_blood_glucose)) & mhist_diabetes != 1 & mhist_drug_bsug != 1 
	tab cal_rbs_yes, m 
	
	gen ck_rbs_yes = (((s_blood_glucose > 200 & s_blood_glucose <= 900) | s_blood_glucose == 9999) & ///
				     ((ck_blood_glucose > 200 & ck_blood_glucose <= 900) | ck_blood_glucose == 9999))
	replace ck_rbs_yes = .m if mi(ck_blood_glucose) | mi(s_blood_glucose)
	order ck_rbs_yes, after(cal_rbs_yes)
	tab ck_rbs_yes, m 
	
	count if ck_rbs_yes != cal_rbs_yes // 0
	
	
	// cal_diabetes
	gen ck_diabetes = (ck_mhist_diabetes == 1 | ck_diabetes_d == 1 | ck_rbs_yes == 1)
	replace ck_diabetes = .m if mi(ck_mhist_diabetes) & mi(ck_diabetes_d) & mi(ck_rbs_yes)
	order ck_diabetes, after(cal_diabetes)
	tab ck_diabetes, m 
	
	count if ck_diabetes != cal_diabetes // 0
	
	*****************************************
	* Final Check on Enrollment Eligibility *
	*****************************************
	destring cal_qualify, replace 
	
	gen ck_qualify = (ck_mi_stroke_hist == 1 | ck_cvd_hist == 1 | ///
					  cf_cal_cvd_risk_yes == 1 | ck_hypertension == 1 | ///
					  ck_diabetes == 1)
	replace ck_qualify = .m if mi(ck_mi_stroke_hist) & mi(ck_cvd_hist) & ///
							   mi(cf_cal_cvd_risk_yes) & mi(ck_hypertension) & ///
							   mi(ck_diabetes)
	order ck_qualify, after(cal_qualify)
	tab ck_qualify, m 
	
	count if ck_qualify != cal_qualify // 4 obs 
	
/*	// manual check
	br 	study_id /// 
		ck_qualify cal_qualify ///
		ck_mi_stroke_hist ck_cvd_hist cf_cal_cvd_risk_yes ck_hypertension ck_diabetes ///
		cal_mi_stroke_hist cal_cvd_hist cal_hypertension cal_diabetes cal_cvd_risk_yes ///
		cf_mhist_hypertension cf_mhist_drug_bp /// 
		mhist_hypertension mhist_drug_bp ///
		s_cal_syst_avg s_cal_diast_avg ///
		ck_cal_syst_avg ck_cal_diast_avg ///
		cal_syst_avg cal_diast_avg ///
		ck_bp_pass_1 ck_bp_pass_2 cal_bp_pass_1 cal_bp_pass_2 ///
		if ck_qualify != cal_qualify
*/
	
	preserve 
	
		keep if ck_qualify != cal_qualify
		
		if _N > 0 {
			
			export excel using "$np_cf_check/HFC/Confirmation_Tool_Check_Outputs.xlsx", ///
								sheet("Enrollment Eligibility Error") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	
	lab var ck_qualify 				"Eligible for study enrollment"
	lab var ck_mi_stroke_hist 		"History of MI or Stroke"
	lab var ck_cvd_hist 			"History of CVD"
	lab var cf_cal_cvd_risk_yes 	"CVD risk > 10%"
	lab var ck_hypertension 		"Hypertension"
	lab var ck_diabetes				"Diabetes"
	

	****************************************************************************
	****************************************************************************
	
	* Consent Check 
	tab ck_qualify consent, m 
	 
	
	
	* Save as raw data 
	save "$np_cf_check/cvd_confirmation_check.dta", replace 
	
	* end of dofile 
