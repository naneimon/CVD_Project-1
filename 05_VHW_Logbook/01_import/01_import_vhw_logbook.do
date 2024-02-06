/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	VHW Log Book		
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
		
	import excel using "$vhw_raw/VHW_Log_Book.xlsx", describe 
		
	forvalue x = 1/`r(N_worksheet)' {
		
		local sheet_`x' `r(worksheet_`x')'
	}

	forvalue x = 1/`r(N_worksheet)' {
		
		import excel using 	"$vhw_raw/VHW_Log_Book.xlsx", ///
							sheet("`sheet_`x''") firstrow clear 
		
 
		if `x' == 1 {
		    
			** Labeling 
			* apply WB codebook command
		    //iecodebook template using "$vhw_check/codebook/cvd_vhw_logbook_raw.xlsx", replace 
			//iecodebook apply using "$vhw_check/codebook/cvd_vhw_logbook_raw.xlsx"
			
			
			** Initial data cleaning 
			* Keep only data collection observation 
			sort starttime
			
			drop if username == "dataliteracy4d" // drop NCL test cases 
			keep if starttime >= tc(01dec2023 00:00:00) // screening start on 15th nov 2023

				
			local pii	c_resp_name c_resp_dad_name c_resp_mom_name ///
						n_resp_name n_resp_dad_name n_resp_mom_name 
			
			rename _index key 
			
			
			* Save as dta file 
			// PII data
			save "$vhw_raw/cvd_vhw_logbook_raw.dta", replace 
			export excel using "$vhw_raw/cvd_confirmation_raw.xlsx", sheet("vhw_logbook") firstrow(variables) replace
			
			// non PII data
			// drop PII
			drop `pii'
			save "$np_vhw_raw/cvd_vhw_logbook_raw_nopii.dta", replace
			export excel using "$np_vhw_raw/cvd_vhw_logbook_raw_nopii.xlsx", sheet("vhw_logbook") firstrow(variables) replace

			* Save as dta file 
			
			
		}
		else {
		    
			** Labeling 
			* apply WB codebook command
			//iecodebook template using "$cf_check/codebook/cvd_confirmation_raw_`sheet_`x''.xlsx"
			//iecodebook apply using "$cf_check/codebook/cvd_confirmation_raw_`sheet_`x''.xlsx"
			
			rename _parent_index key 
			
			merge m:1 key using "$vhw_raw/cvd_vhw_logbook_raw.dta", keepusing(key)
			
			keep if _merge == 3 
			drop _merge 
			
			if _N > 0 {
			    
				* Save as dta file 
				save "$vhw_raw/cvd_vhw_logbook_raw_`sheet_`x''.dta", replace
				
				save "$np_vhw_raw/cvd_vhw_logbook_raw_`sheet_`x''_nopii.dta", replace			    
					
			}

		}
		
	}
	

	****************************************************************************
	** Append Repeat Group Long Form Dataset into Main wide format datase ** 
	****************************************************************************
	
	* Transform long format 
	
	* oth_drug_rep 
	use "$vhw_raw/cvd_vhw_logbook_raw_oth_drug_rep.dta", clear 
	
	// drop meatadata 
	drop _submission__id - _submission__tags _parent_table_name _index 
	
	// prepare for reshape 
	destring cal_oth_drug, replace 
	
	rename oth_drug_* oth_drug_*_
	
	reshape wide oth_drug_*, i(key) j(cal_oth_drug)
	
	tempfile oth_drug_rep
	save `oth_drug_rep', replace	
	
	
	* MERGE with main wide data 
	// PII data
	use "$vhw_raw/cvd_vhw_logbook_raw.dta", clear 
	
	merge 1:m key using `oth_drug_rep', assert(1 3) nogen 
	order oth_drug_name_1 - cal_oth_drug_dosu, after(oth_drug_num)

	save "$vhw_raw/cvd_vhw_logbook_raw.dta", replace 
	export excel using "$vhw_raw/cvd_vhw_logbook_raw.xlsx", sheet("vhw_logbook") firstrow(variables) replace
	
	// non PII data
	// drop PII
	drop `pii'
	save "$np_vhw_raw/cvd_vhw_logbook_raw_nopii.dta", replace
	export excel using "$np_vhw_raw/cvd_vhw_logbook_raw_nopii.xlsx", sheet("vhw_logbook") firstrow(variables) replace
	

	* end of dofile 

