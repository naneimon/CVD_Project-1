/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. import raw excel file exported from KoBoToolbox 
	2. label variables and response value
	3. save as raw file for checking and HFC work

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data  *
	********************************************************************************
	
	import excel using "$sc_raw/CVD_Community_Screening_Tool.xlsx", sheet("CVD_Community_Screening_Tool") firstrow clear 
	
	destring mhist_drug_bp mhist_drug_bsug mhist_drug_aspirin mhist_drug_statins, replace 
	
	** Labeling 
	* apply WB codebook command 
	//iecodebook template using "$sc_check/codebook/cvd_screening_raw.xlsx", replace 
	iecodebook apply using "$sc_check/codebook/cvd_screening_raw.xlsx"


	** Initial data cleaning 
	* Keep only data collection observation 
	sort starttime
	
	drop if username == "dataliteracy4d" // drop NCL test cases 
	keep if starttime >= tc(15nov2023 00:00:00) // screening start on 15th nov 2023
	
	* export as excel file 
	preserve 
	
		keep if demo_vill == 47
		
		if _N > 0 {
			
			export excel using "$sc_check/HFC/Community_Screening_Check_Outputs.xlsx", ///
								sheet("not - Ta Re Poe Kwee") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	* Re-construct the study ID - the first village result with duplicate in last 2 digit 
	* as it mentioned the month number instead of minute 
	* as a result, got duplicated study_id
	
	sort starttime

	// correct the village name and id 
	replace cal_vill = "Ta Re Poe Kwee" if _uuid == "48ed031b-c1b3-4680-bdcb-31dca36bdd5d"
	replace cal_vill = "Ta Re Poe Kwee" if _uuid == "8f715a1f-0761-412c-8547-b4119827a5b9"
	replace cal_vill = "Ta Re Poe Kwee" if _uuid == "e9d53cc4-715b-4d17-b410-d881bdc83462"

	replace demo_vill = 46 if _uuid == "48ed031b-c1b3-4680-bdcb-31dca36bdd5d"
	replace demo_vill = 46 if _uuid == "8f715a1f-0761-412c-8547-b4119827a5b9"
	replace demo_vill = 46 if _uuid == "e9d53cc4-715b-4d17-b410-d881bdc83462"
	
	replace study_id = subinstr(study_id, "/47/", "/46/", 1) if _uuid == "48ed031b-c1b3-4680-bdcb-31dca36bdd5d"
	replace study_id = subinstr(study_id, "/47/", "/46/", 1) if _uuid == "8f715a1f-0761-412c-8547-b4119827a5b9"
	replace study_id = subinstr(study_id, "/47/", "/46/", 1) if _uuid == "e9d53cc4-715b-4d17-b410-d881bdc83462"	

	// revised study id generator form was not use in some of the survey from Paya Ngoh Toe
	gen study_id_issue = study_id //if starttime >= tc(15nov2023 00:00:00) & starttime < tc(22nov2023 00:00:00) 
	lab var study_id_issue "Error Study ID - month instead of minute"
	order study_id_issue, after(study_id)
	
	// revised the issue id obs 
	replace study_id = substr(study_id, 1, strlen(study_id) - 2) //if starttime >= tc(15nov2023 00:00:00) & starttime < tc(22nov2023 00:00:00) 
	
	// to replace with minute value 
	gen minute = mm(starttime)
	tostring minute, replace 
	order minute, after(study_id) 
	
	// reconstruct the unique study_id
	replace study_id = study_id_issue + minute //if starttime >= tc(15nov2023 00:00:00) & starttime < tc(22nov2023 00:00:00) 
	
	// Check the number 
	distinct study_id_issue 
	distinct study_id

	assert `r(ndistinct)' == _N 
	
	drop minute

		
	* Save as dta file 
	save "$sc_raw/cvd_screening_raw.dta", replace  

	* end of dofile 
