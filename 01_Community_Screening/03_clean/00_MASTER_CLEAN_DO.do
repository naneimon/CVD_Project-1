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
	
	local clean			1
	local preload		1
	
	****************************************************************************
	* (1) Data Cleaning
	
	if `clean' ==  1 {
	    do "$sc_do_clean/01_screening_cleaning.do"
	}
	
	
	* (2) Created Confirmation Visit Preloaded File 
	
	if `preload' == 1 {
	    do "$sc_do_clean/02_confirmation_preload.do"
	}
	
	* end of dofile 
