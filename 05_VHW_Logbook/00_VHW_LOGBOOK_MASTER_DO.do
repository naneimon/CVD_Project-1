/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	VHW log book work - MASTER DOFILE 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:


Task outline: 
	1. Run all HFC dofiles

*******************************************************************************/

	****************************************************************************
	** Directory Settings **
	****************************************************************************

	do "$github/00_dir_setting.do"

	****************************************************************************
	* Dofile Setting *
	****************************************************************************
	
	local import		1
	local hfc 			1
	local clean			1
	local construct 	0
	local analyse		0
	
	****************************************************************************
	* (1) Import
	
	if `import' ==  1 {
	    do "$vhw_do_raw/01_import_vhw_logbook.do"
	}
	
	* (2) HFC Check Check 
	
	if `hfc' ==  1 { 
	    do "$vhw_do_hfc/01_duplicate_check.do"
	}
	
	* (3) Cleaning 
	
	if `clean' == 1 {
	    do "$vhw_do_clean/01_vhw_logbook_cleaning.do"
		
		do "$vhw_do_clean/02_combined_screening_confirmation_vhw_logbook.do"
	}
	

	* (4) Construction
	
	if `construct' ==  1 { 
	    do "$vhw_do_constr/01_cvd_combined_construct.do"
	}
	
	* (5) Analysis 
	
	if `analyse' == 1 {
	    do "$vhw_do_analyze/adhoc_data_check.do"
	}
	
	* end of dofile 
