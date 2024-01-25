/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	VHW log book - HFC 			
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
	
	use "$vhw_raw/cvd_vhw_logbook_raw.dta", clear 
	
	* (1) Duplicate by ID + Visit Date
	duplicates tag resp_sppid visit_date, gen(dup_id)
	lab var dup_id "Duplicated by SPP ID and Visit Date"
	tab dup_id, m 
	
	* export as excel file 
	preserve 
	
		keep if dup_id == 1
		
		if _N > 0 {
			
			export excel using "$vhw_check/HFC/VHW_LogBook_Check_Duplicate.xlsx", ///
								sheet("Duplicated by ID & Visit Date") firstrow(varlabels) sheetmodify
		}
	
	restore 
		
	// temporary solution for duplicate  
	sort starttime 
	duplicates drop resp_sppid visit_date, force 
	
	* Save as raw data 
	save "$vhw_raw/cvd_vhw_logbook_check_nodup.dta", replace 

	* end of dofile 
