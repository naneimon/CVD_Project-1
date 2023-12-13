/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work - HFC 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. develop the key performance indicators for progress monitoring

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
	** KPI indicators **
	****************************************************************************

	* complete svy 
	gen svy_complete = 1
	lab var svy_complete "Completed Screening"
	
	
	* survey per village 
	tab cal_vill, gen(vill_dummy_)
	
	* interview date
	gen svy_date = dofc(starttime)
	format svy_date %td 
	lab var svy_date "Data Collection Date"
	order svy_date, after(starttime)
	
	* interview duration 
	gen svy_duration = (endtime - starttime) /(60 * 1000)
	replace svy_duration = round(svy_duration, 0.1)
	lab var svy_duration "Survey Duration (minute)"
	order svy_duration, after(endtime)
	tab svy_duration if ck_cal_eligible == 1, m 
	hist svy_duration if ck_cal_eligible == 1 & svy_duration < 300
	
	* Time only var  
	foreach var of varlist starttime endtime {
		
		local labold : variable label `var'
		
		gen double `var'_hm = mod(`var', 24 * 60 * 60000)
		order `var'_hm, after(`var')

		lab var `var'_hm "`labold' time"
		
		format `var'_hm %tcHH:MM 
	
	}
	
	
	* Flag start/end time
	gen svy_early = (starttime_hm < tc(07:00)) // before 7 AM
	lab var svy_early "Survey Before 7 AM"
	order svy_early, after(starttime_hm)
	tab svy_early, m 
	
	preserve 
	
		keep if svy_early == 1
		
		if _N > 0 {
			
			export excel using "$np_sc_check/HFC/Community_Screening_Check_Outputs.xlsx", ///
								sheet("Survey Before 7 AM") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	gen svy_late = (endtime_hm > tc(18:00) & !mi(endtime)) // after 6 PM
	lab var svy_late "Survey After 6 PM"
	order svy_late, after(endtime_hm)
	tab svy_late, m 
	
	preserve 
	
		keep if svy_late == 1
		
		if _N > 0 {
			
			export excel using "$np_sc_check/HFC/Community_Screening_Check_Outputs.xlsx", ///
								sheet("Survey After 6 PM") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	
	****************************************************************************
	** Independent Variables **
	****************************************************************************
	// resp_age
	tab resp_age, m 

	// tobacco
	gen smoking_yes = (tobacco > 0 & !mi(tobacco))
	replace smoking_yes = .m if mi(tobacco)
	order smoking_yes, after(tobacco)
	lab var smoking_yes "Smoking status - yes"
	tab smoking_yes, m 
	
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
	
	****************************************************************************
	** CASE - category **
	****************************************************************************
	
	** Hypertension **
	// medical history 
	tab ck_hypertension, m 
	
	// drug - no history 
	gen mhist_drug_bp_no = (mhist_drug_bp_1 == 0)
	replace mhist_drug_bp_no = .m if ck_cal_eligible == 0 
	order mhist_drug_bp_no, after(ck_hypertension)
	lab var mhist_drug_bp_no "No Anti-hypertension medication in the last 2 weeks"
	tab mhist_drug_bp_no, m 
	
	** Diabetes **
	// medical history 
	tab ck_diabetes, m 
	
	// drug - no history 
	gen mhist_drug_bsug_no = (mhist_drug_bsug_1 == 0)
	replace mhist_drug_bsug_no = .m if ck_cal_eligible == 0 
	order mhist_drug_bsug_no, after(ck_diabetes)
	lab var mhist_drug_bsug_no "No Diabetes medication in the last 2 weeks"
	tab mhist_drug_bsug_no, m 	
	
	
	** Stroke and Heart Attack **
	// medical history 
	tab ck_stroke, m 
	
	tab ck_heartatt, m 
	
	// drug - no history 
	gen mhist_drug_aspirin_no = (mhist_drug_aspirin_1 == 0)
	replace mhist_drug_aspirin_no = .m if ck_cal_eligible == 0 
	order mhist_drug_aspirin_no, after(ck_stroke)
	lab var mhist_drug_aspirin_no "Not Taking aspirin in the last 2 weeks"
	tab mhist_drug_aspirin_no, m 	
	
	gen mhist_drug_statins_no = (mhist_drug_statins_1 == 0)
	replace mhist_drug_statins_no = .m if ck_cal_eligible == 0 
	order mhist_drug_statins_no, after(ck_heartatt)
	lab var mhist_drug_statins_no "Not Taking statins in the last 2 weeks"
	tab mhist_drug_statins_no, m 	
	
	// blood glucose cases - yes/no 
	tab ck_blood_glucose_yes, m 
	
	** at least one medication history 
	gen mhist_drug_noall = (mhist_drug_bp_no == 1 & mhist_drug_bsug_no == 1 & ///
							mhist_drug_aspirin_no == 1 & mhist_drug_statins_no == 1)
	replace mhist_drug_noall = .m if 	mi(mhist_drug_bp_no) & mi(mhist_drug_bsug_no) & ///
										mi(mhist_drug_aspirin_no) & mi(mhist_drug_statins_no)
	lab var mhist_drug_noall "No medication history questions"
	tab mhist_drug_noall, m 
	
	egen mhist_drug_nocount = rowtotal(mhist_drug_bp_no mhist_drug_bsug_no mhist_drug_aspirin_no mhist_drug_statins_no)
	replace mhist_drug_nocount = .m if 	mi(mhist_drug_bp_no) & mi(mhist_drug_bsug_no) & ///
										mi(mhist_drug_aspirin_no) & mi(mhist_drug_statins_no)
	lab var mhist_drug_nocount "Number of no medication history questions (total 4 types of medication questions)"
	tab mhist_drug_nocount, m 
	
	gen no_mhistdrug_bg = (mhist_drug_noall == 1 & ck_blood_glucose_yes == 1)
	replace no_mhistdrug_bg = .m if mi(mhist_drug_noall) | mi(ck_blood_glucose_yes)
	lab var no_mhistdrug_bg "No medication history questions & No Blood Glucose measurement"
	tab no_mhistdrug_bg, m 
	
	
	** BP Category **
	// >= 140/90  <140/90  ; <130/85  ;   <120/80
	gen bp_high_140_90 = ((ck_cal_syst_avg >= 140 & !mi(ck_cal_syst_avg)) | ///
						  (ck_cal_diast_avg >= 90 & !mi(ck_cal_diast_avg)))
	replace bp_high_140_90 = .m if mi(ck_cal_syst_avg) | mi(ck_cal_diast_avg)
	lab var bp_high_140_90 "BP >= 140/90"
	tab bp_high_140_90, m 
	
	gen bp_low_140_90 = (ck_cal_syst_avg < 140 | ck_cal_diast_avg < 90)
	replace bp_low_140_90 = .m if mi(ck_cal_syst_avg) | mi(ck_cal_diast_avg)
	lab var bp_low_140_90 "BP < 140/90"
	tab bp_low_140_90, m 

	gen bp_low_130_85 = (ck_cal_syst_avg < 130 | ck_cal_diast_avg < 85)
	replace bp_low_130_85 = .m if mi(ck_cal_syst_avg) | mi(ck_cal_diast_avg)
	lab var bp_low_130_85 "BP <130/85"
	tab bp_low_130_85, m 

	gen bp_low_120_80 = (ck_cal_syst_avg < 120 | ck_cal_diast_avg < 80)
	replace bp_low_120_80 = .m if mi(ck_cal_syst_avg) | mi(ck_cal_diast_avg)
	lab var bp_low_120_80 "BP <120/80"
	tab bp_low_120_80, m 

	
	* BP category with hypertension medical history + no medication history 
	foreach var of varlist bp_high_140_90 bp_low_140_90 bp_low_130_85 bp_low_120_80 {
		
		local labvar : variable label `var'
		gen `var'_hpm = `var' if ck_hypertension == 1 & ck_hypertension_d == 0
		replace `var'_hpm = .m if mi(`var'_hpm)
		lab var `var'_hpm "`labvar': hypertension medical history but no medication history"
		tab `var'_hpm
		
	}

	
	foreach var of varlist bp_high_140_90 bp_low_140_90 bp_low_130_85 bp_low_120_80 {
		
		local labvar : variable label `var'
		gen `var'_hpm_only = `var' if 	 cf_cal_cvd_risk_yes == 0 & ///
										 ck_cf_blood_glucose == 0 & ///
										 ck_cf_cal_bf_abnormal == 0 & ///
										 ck_cf_cal_syst_avg == 0 & ///
										 ck_cf_cal_diast_avg == 0 & ///
										 ck_stroke == 0 & ///
										 ck_heartatt == 0 & ///
										 ck_aspirin_d == 0 & ///
										 ck_statins_d == 0 & ///
										 ck_dasp_cf == 0 & ///
										 ck_dstat_cf == 0 & ///
										 ck_diabetes == 0 & ///
										 ck_diabetes_d == 0 & ///
										 ck_hypertension == 1 & ///
										 ck_hypertension_d == 0 & ///
										 ck_hpd_cf == 0 & ///
										 ck_ddd_cf == 0
		replace `var'_hpm_only = .m if mi(`var'_hpm_only)
		lab var `var'_hpm_only "`labvar': hypertension medical history only"
		tab `var'_hpm_only
		
	}
	
										 
										 
	* Export csv file to use in R-shiny work
	export delimited using "$shiny/community_screening.csv", replace 
	export delimited using "$shiny/cvd_screening_monitoring/community_screening.csv", replace 
	
	
	* save as updated dataset 
	save "$np_sc_constr/cvd_screening_constract.dta", replace  
	
	* end of dofile 
