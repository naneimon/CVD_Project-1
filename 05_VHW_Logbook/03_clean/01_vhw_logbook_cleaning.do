/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	VHW Logbook - Cleaning and correction 			
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

	********************************************************************************
	* import raw data *
	********************************************************************************
	
	use "$np_vhw_raw/cvd_vhw_logbook_raw_nopii.dta", clear 
	
	* SOLVE DUPLICATE ** 
	* Duplicate by study id 
	duplicates list resp_sppid visit_date // need to dicuss with Cho Zin 
	
	
	* drop the duplicate case - feedback from field team
	gen to_drop = .m 
	
	readreplace using "$np_vhw_clean/vhw_logbook_correction.xlsx", ///
				id(_uuid) ///
				variable(var_name) ///
				value(correct_value) ///
				excel ///
				import(sheet("duplicate") firstrow)
	
	drop if to_drop ==  1
	drop to_drop
	
	duplicates drop resp_sppid visit_date, force 	
	
	
	** DATA CORRECTION **
	tostring amlodipine_stop_oth, replace 
	
	readreplace using "$np_vhw_clean/vhw_logbook_correction.xlsx", ///
				id(_uuid) ///
				variable(var_name) ///
				value(correct_value) ///
				excel ///
				import(sheet("correction") firstrow)
	
	
	* iecodebook for variable selection and labeling 
	// iecodebook template using "$np_vhw_clean/codebook/cvd_vhw_logbook_prepare.xlsx", replace 
	iecodebook apply using "$np_vhw_clean/codebook/cvd_vhw_logbook_prepare.xlsx" 

	
	* get study ID 
	preserve
	
		use "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.dta", clear 
		
		drop if mi(resp_sppid) | resp_sppid == "9999"
		
		keep resp_sppid study_id
		
		tempfile resp_sppid
		save `resp_sppid', replace 
		
		
		insheet using 	"$vhw_raw/study_participant_list_Manual_Update.csv", clear
		
		rename ssp_id resp_sppid
		keep resp_sppid study_id
		
		tempfile preload_csv 
		save `preload_csv', replace 
	
	restore 
	
	merge m:1 resp_sppid using `resp_sppid', keepusing(study_id)
	
	drop if _merge == 2 
	drop _merge 

	merge m:1 resp_sppid using `preload_csv', keepusing(study_id) update 
	
	drop if _merge < 3
	drop _merge 
	
	
	* drop un-necessary and metadata variable 
	drop starttime - demo_vill _id - key
	
	iecodebook template using "$np_vhw_clean/codebook/cvd_vhw_logbook_cleaned_codebook.xlsx", replace 

	* Save as raw data 
	save "$np_vhw_clean/cvd_vhw_logbook_cleaned.dta", replace 
	
	* export as exel doc 
	export excel using "$np_vhw_clean/cvd_vhw_logbook_cleaned.xlsx", sheet("vhw_logbook") firstrow(variables) replace 
	
	* end of dofile 
