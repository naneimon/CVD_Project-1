/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Combined Screening + Confirmation + Additional Question + VHW Logbook 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. drop duplicate and perform data correction (if required) 

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"
	
	
	* VARIABLE NAME CHECKING *
	* (1) Additional Questions 
	import excel using "$np_vhw_clean/codebook/cvd_vhw_logbook_cleaned.xlsx", firstrow clear 
	
	drop name label type choices
	
	rename namecurrent name 
	
	drop if mi(name) | name == "resp_confirm" | name == "resp_sppid" | name == "study_id"
	
	keep name 
	gen vhwlog = 1 
	
	tempfile vhwlog 
	save `vhwlog', replace 
	
	
	* (2) Combined Dataset 
	import excel using "$np_comb_clean/codebook/cvd_screening_confirmation_combined_codebook.xlsx", firstrow clear 
	
	drop name label type choices
	
	rename namecurrent name 
	
	drop if mi(name)
	
	keep name 
	gen combined = 1 

	merge 1:1 name using `vhwlog'
	
	// 24 variables including demographic var and medication records infomration variables 
	// were identical between combined data and vhw logbook dataset  
	// action required for variable name changes 
	
	levelsof name if _merge == 3, local(tochange)

	********************************************************************************
	** MERGE with COMBINED DATASET **
	********************************************************************************
	
	use "$np_vhw_clean/cvd_vhw_logbook_cleaned.dta", clear 
	
	** rename variable as add "v_" prefix to distinguished with same var name from vhwlogbook 
	foreach var in `tochange' {
		
		rename `var' v_`var'
	}
	
	** check unique id or not 
	keep resp_sppid - medic_note_3 study_id
	isid  study_id visit_date
	
	* for Field Team App 
	sort  study_id visit_date
	
	tempfile vlwlong 
	save `vlwlong', replace 
	
	* create index var for reshape dataset 	
	bysort study_id: gen visit_index = _n 
	
	order visit_index resp_sppid study_id 
	
	foreach var of varlist resp_confirm - medic_note_3 { 
		
		rename `var' `var'_
	} 
	
	reshape wide *_ , i(resp_sppid study_id) j(visit_index)
	
	isid  study_id
	
	gen vhw_logbook = 1 
	
	
	* iecodebook for variable selection and labeling 
	//iecodebook template using "$np_vhw_clean/codebook/cvd_vhw_logbook_prepare_wide.xlsx", replace 
	iecodebook apply using "$np_vhw_clean/codebook/cvd_vhw_logbook_prepare_wide.xlsx" 
	
	tempfile vhwwide 
	save `vhwwide', replace 
	
	
	** Update the combined dataset + add VHW Logbook ** 
	use "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.dta", clear 
	
	preserve 
		merge 1:m study_id using `vlwlong', assert(1 3) 
		
		keep if _merge == 3 // keep only variable required for VHW logbook 
		
		isid  study_id visit_date
		sort  study_id visit_date
	
		// non PII data
		* Save as combined cleaned data 
		save "$np_comb_clean/LONG_cvd_screening_confirmation_combined_cleaned.dta", replace 
		
		* export as exel doc 
		export excel using "$np_comb_clean/LONG_cvd_screening_confirmation_combined_cleaned.xlsx", sheet("LONG_Combined_Data") firstrow(variables) replace 
		
		* codebook 
		iecodebook template using "$np_comb_clean/codebook/LONG_cvd_screening_confirmation_combined_codebook.xlsx", replace 

	restore 
	
	
	merge 1:1 study_id using `vhwwide', assert(1 3) nogen 
	
	replace vhw_logbook = 0 if mi(vhw_logbook)
	

	* Save as dta file 
	
	// non PII data
	* Save as combined cleaned data 
	save "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.dta", replace 
	
	* export as exel doc 
	export excel using "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.xlsx", sheet("combined_data") firstrow(variables) replace 
	
	* codebook 
	// codebookout "$np_comb_clean/codebook/cvd_screening_confirmation_combined_codebook.xlsx", replace 
	iecodebook template using "$np_comb_clean/codebook/cvd_screening_confirmation_combined_codebook.xlsx", replace 


	// PII data
	merge 1:1 study_id using "$sc_raw/cvd_screening_raw.dta", keepusing(resp_name resp_dad_name resp_mom_name) assert(2 3)
	
	drop if _merge == 2

	* Save as combined cleaned data 
	save "$comb_clean/cvd_screening_confirmation_combined_cleaned_pii.dta", replace 
	
	* export as exel doc 
	export excel using "$comb_clean/cvd_screening_confirmation_combined_cleaned_pii.xlsx", sheet("combined_data") firstrow(variables) replace 
	
	* codebook 
	// codebookout "$np_comb_clean/codebook/cvd_screening_confirmation_combined_codebook.xlsx", replace 
	iecodebook template using "$comb_clean/codebook/cvd_screening_confirmation_combined_pii_codebook.xlsx", replace 

	
	* end of dofile 
