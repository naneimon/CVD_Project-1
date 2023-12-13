/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Confirmatory Visit Work			
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
	
	import excel using "$cf_raw/CVD_Confirmatory_Visit_Data_Record_Tool.xlsx", describe 
	
	// sheet("CVD_Confirmatory_Visit_Data_...") firstrow clear 
	
	forvalue x = 1/`r(N_worksheet)' {
		
		local sheet_`x' `r(worksheet_`x')'
	}

	forvalue x = 1/`r(N_worksheet)' {
		
		import excel using 	"$cf_raw/CVD_Confirmatory_Visit_Data_Record_Tool.xlsx", ///
							sheet("`sheet_`x''") firstrow clear 
		
 
		if `x' == 1 {
		    
			** Labeling 
			* apply WB codebook command
		    //iecodebook template using "$cf_check/codebook/cvd_confirmation_raw.xlsx", replace 
			iecodebook apply using "$cf_check/codebook/cvd_confirmation_raw.xlsx"
			
			
			** Initial data cleaning 
			* Keep only data collection observation 
			sort starttime
			
			drop if username == "dataliteracy4d" // drop NCL test cases 
			keep if starttime >= tc(15nov2023 00:00:00) // screening start on 15th nov 2023

	
			* respondent info reconciliation 			
			// name 
			tostring resp_name, replace 
			replace resp_name = s_resp_name if resp_info_update1 == 0
			
			// dad name 
			tostring resp_dad_name, replace 
			replace resp_dad_name = s_resp_dad_name if resp_info_update2 == 0
			
			// mom name 
			tostring resp_mom_name, replace 
			replace resp_mom_name = s_resp_mom_name if resp_info_update3 == 0
			
			// resp_age 
			destring resp_age, replace 
			tab resp_age, m 
			
			// sex 
			destring resp_sex, replace 
			lab val resp_sex resp_sex_c
			tab resp_sex, m 
			
			local pii	s_resp_name s_resp_dad_name s_resp_mom_name ///
						n_resp_name n_resp_dad_name n_resp_mom_name ///
						resp_info_update1 resp_info_update2 resp_info_update3 ///
						resp_name resp_dad_name resp_mom_name
			
			rename _index key 
			
			* Save as dta file 
			// PII data
			save "$cf_raw/cvd_confirmation_raw.dta", replace 
			
			// non PII data
			// drop PII
			drop `pii'
			save "$np_cf_raw/cvd_confirmation_raw_nopii.dta", replace

			* Save as dta file 
			
			
		}
		else {
		    
			** Labeling 
			* apply WB codebook command
			//iecodebook template using "$cf_check/codebook/cvd_confirmation_raw_`sheet_`x''.xlsx"
			iecodebook apply using "$cf_check/codebook/cvd_confirmation_raw_`sheet_`x''.xlsx"
			
			rename _parent_index key 
			
			merge m:1 key using "$cf_raw/cvd_confirmation_raw.dta", keepusing(key)
			
			keep if _merge == 3 
			drop _merge 
			
			if _N > 0 {
			    
				* Save as dta file 
				save "$cf_raw/cvd_confirmation_raw_`sheet_`x''.dta", replace
				
				save "$np_cf_raw/cvd_confirmation_raw_`sheet_`x''_nopii.dta", replace			    
					
			}

		}
		
	}

	* end of dofile 
