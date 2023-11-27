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
	
	use "$sc_check/cvd_screening_check.dta", clear 
		
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
			
			export excel using "$sc_check/HFC/Community_Screening_Check_Outputs.xlsx", ///
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
			
			export excel using "$sc_check/HFC/Community_Screening_Check_Outputs.xlsx", ///
								sheet("Survey After 6 PM") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
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
	
	
	* Export csv file to use in R-shiny work
	export delimited using "$shiny/community_screening.csv", replace 
	export delimited using "$shiny/cvd_screening_monitoring/community_screening.csv", replace 
	
	
	* save as updated dataset 
	save "$sc_check/cvd_screening_check.dta", replace  

	
	// drop PII
	drop resp_name resp_dad_name resp_mom_name
	save "$sc_check/No_PII/cvd_screening_check_nopii.dta", replace  

	
	* end of dofile 
