/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Confirmatory Visit: Additional Question			
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
	
	import excel using "$addq_raw/CVD_Eligible_Person_Additional_Questions.xlsx", sheet("CVD_Eligible_Person_Addition...") firstrow clear 
	
	
	** Labeling 
	* apply WB codebook command 
	//iecodebook template using "$addq_check/codebook/cvd_confirmation_additional_questions_raw.xlsx"
	iecodebook apply using "$addq_check/codebook/cvd_confirmation_additional_questions_raw.xlsx"


	* Save as dta file 
	save "$addq_check/cvd_confirmation_additional_questions_raw.dta", replace  

	* end of dofile 
