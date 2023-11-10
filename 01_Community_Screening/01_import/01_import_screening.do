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
	
	
	** Labeling 
	* apply WB codebook command 
	//iecodebook template using "$sc_check/codebook/cvd_screening_raw.xlsx"
	iecodebook apply using "$sc_check/codebook/cvd_screening_raw.xlsx"


	* Save as dta file 
	save "$sc_check/cvd_screening_raw.dta", replace  

	* end of dofile 
