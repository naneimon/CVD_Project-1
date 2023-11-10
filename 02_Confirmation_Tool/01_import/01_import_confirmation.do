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
		    //iecodebook template using "$cf_check/codebook/cvd_confirmation_raw.xlsx"
			iecodebook apply using "$cf_check/codebook/cvd_confirmation_raw.xlsx"
			
			* Save as dta file 
			save "$cf_check/cvd_confirmation_raw.dta", replace
			
		}
		else {
		    
			** Labeling 
			* apply WB codebook command
			//iecodebook template using "$cf_check/codebook/cvd_confirmation_raw_`sheet_`x''.xlsx"
			iecodebook apply using "$cf_check/codebook/cvd_confirmation_raw_`sheet_`x''.xlsx"
			
			* Save as dta file 
		
			save "$cf_check/cvd_confirmation_raw_`sheet_`x''.dta", replace
			
		}
		
	}


	* end of dofile 
