/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	CVD Patient Safety Checklist 		
Author				:	Nicholus Tint Zaw
Date				: 	02/17/2024
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
	
	import excel using "$vhw_raw/05_Patient_Safety_Checklists.xlsx", describe 
		
	forvalue x = 1/`r(N_worksheet)' {
		
		local sheet_`x' `r(worksheet_`x')'
	}

	forvalue x = 1/`r(N_worksheet)' {
		
		import excel using 	"$vhw_raw/05_Patient_Safety_Checklists.xlsx", ///
							sheet("`sheet_`x''") firstrow clear 
		
 
		if `x' == 1 {
		    			
			** Initial data cleaning 
			* Keep only data collection observation 
			sort starttime
						
			local pii	resp_name_c resp_dad_name_c resp_mom_name_c ///
						resp_name resp_dad_name resp_mom_name ///
						n_resp_name n_resp_dad_name n_resp_mom_name 
			
			rename _index key 
			
			
			* Save as dta file 
			// PII data
			save "$vhw_raw/cvd_patient_safety_checklists_raw.dta", replace 
			export excel using "$vhw_raw/cvd_patient_safety_checklists_raw.xlsx", sheet("patient_safety_checklists") firstrow(variables) replace
			
			// non PII data
			// drop PII
			drop `pii'
			save "$np_vhw_raw/cvd_patient_safety_checklists_raw_nopii.dta", replace
			export excel using "$np_vhw_raw/cvd_patient_safety_checklists_raw_nopii.xlsx", sheet("patient_safety_checklists") firstrow(variables) replace

			* Save as dta file 
			
			
		}
		else {
		    		
			rename _parent_index key 
			
			merge m:1 key using "$vhw_raw/cvd_patient_safety_checklists_raw.dta", keepusing(key)
			
			keep if _merge == 3 
			drop _merge 
			
			if _N > 0 {
			    
				* Save as dta file 
				save "$vhw_raw/cvd_patient_safety_checklists_raw_`sheet_`x''.dta", replace
				
				save "$np_vhw_raw/cvd_patient_safety_checklists_raw_`sheet_`x''_nopii.dta", replace			    
					
			}

		}
		
	}
	

	****************************************************************************
	** Append Repeat Group Long Form Dataset into Main wide format datase ** 
	****************************************************************************
	
	* Transform long format 
	
	* oth_drug_rep 
	use "$vhw_raw/cvd_patient_safety_checklists_raw_oth_drug_rep.dta", clear 
	
	// drop meatadata 
	drop _submission__id - _submission__tags _parent_table_name _index 
	
	// prepare for reshape 
	destring cal_oth_drug, replace 
	
	rename oth_drug_* ps_oth_drug_*_
	
	reshape wide ps_oth_drug_*, i(key) j(cal_oth_drug)
	
	tempfile oth_drug_rep
	save `oth_drug_rep', replace	
	
	
	* side effect report 
	use "$vhw_raw/cvd_patient_safety_checklists_raw_sefft_rpt.dta", clear 
	
	// drop meatadata 
	drop _submission__id - _submission__tags _parent_table_name _index 
	
	// prepare for reshape 
	destring sefft_id, replace 
	
	rename sefft_* sefft_*_
	
	rename sefft_id_ sefft_id
	
	reshape wide sefft_*_, i(key) j(sefft_id)
	
	tempfile sideffect
	save `sideffect', replace	

	
	* MERGE with main wide data 
	// PII data
	use "$vhw_raw/cvd_patient_safety_checklists_raw.dta", clear 
	
	merge 1:m key using `oth_drug_rep', assert(1 3) nogen 
	order ps_oth_drug_name_1 - ps_oth_drug_mdosu_oth_1, after(oth_drug_num)

	merge 1:m key using `sideffect', assert(1 3) nogen 
	order sefft_note_1 - sefft_action_3, after(sefft_num)
	
	
	* apply WB codebook command
	//iecodebook template using "$vhw_check/codebook/cvd_patient_safety_checklists_raw_prepare.xlsx", replace 
	iecodebook apply using "$vhw_check/codebook/cvd_patient_safety_checklists_raw_prepare.xlsx"
			
	
	save "$vhw_raw/cvd_patient_safety_checklists_raw.dta", replace 
	export excel using "$vhw_raw/cvd_patient_safety_checklists_raw.xlsx", sheet("patient_safety_checklists") firstrow(variables) replace
	
	// non PII data
	// drop PII
	drop `pii'
	save "$np_vhw_raw/cvd_patient_safety_checklists_raw_nopii.dta", replace
	export excel using "$np_vhw_raw/cvd_patient_safety_checklists_raw_nopii.xlsx", sheet("patient_safety_checklists") firstrow(variables) replace
	

	* end of dofile 

