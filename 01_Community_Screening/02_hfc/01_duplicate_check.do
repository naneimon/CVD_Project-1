/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work - HFC 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. check duplciate 

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data  *
	********************************************************************************
	
	use "$sc_check/cvd_screening_raw.dta", clear 
	
	* (1) Duplicate by ID 
	duplicates tag study_id, gen(dup_id)
	lab var dup_id "Duplicated by Study ID"
	tab dup_id, m 
	
	
	* (2) Duplicate by personal information 
	local pii	resp_name resp_age resp_sex resp_dad_name resp_mom_name
	
	duplicates tag `pii', gen(dup_pii)
	lab var dup_pii "Duplciated by personal information"
	tab dup_pii, m 
	
	
	* export as excel file 
	

	* end of dofile 
