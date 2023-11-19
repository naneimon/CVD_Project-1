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
	tab svy_duration, m 
	hist svy_duration
	
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
	
	
	* Export csv file to use in R-shiny work
	export delimited using "$shiny/community_screening.csv", replace 
	export delimited using "$shiny/cvd_screening_monitoring/community_screening.csv", replace 
	
	
	* save as updated dataset 
	save "$sc_check/cvd_screening_check.dta", replace  

	
	// drop PII
	drop resp_name resp_dad_name resp_mom_name
	save "$sc_check/No_PII/cvd_screening_check_nopii.dta", replace  

	
	* end of dofile 
