/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work - HFC MASTER DOFILE 			
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
	local construct 	1
	local analyse		1
	
	****************************************************************************
	* (1) Import
	
	if `import' ==  1 {
	    do "$cf_do_raw/01_import_confirmation.do"
	}
	
	* (2) HFC Check Check 
	
	if `hfc' ==  1 { 
	    do "$cf_do_hfc/00_MASTER_HFC_DO.do"
	}
	
	* (3) Cleaning 
	
	if `clean' == 1 {
	    do "$cf_do_clean/00_MASTER_CLEAN_DO.do"
	}
	

	* end of dofile 
