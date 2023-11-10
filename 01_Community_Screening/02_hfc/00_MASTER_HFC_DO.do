/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work - HFC MASTER DOFILE 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:


Task outline: 
	1. Run all HFC dofiles

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* Dofile Setting *
	********************************************************************************
	
	* (1) Duplicate Check 
	do "$sc_do_hfc/01_duplicate_check.do"
	
	* (2) Confirmation Visit Check 
	do "$sc_do_hfc/02_confirmation_check.do"
	
	* (3) Created Confirmation Visit Preloaded File 
	do "$sc_do_hfc/03_confirmation_preload.do"
	
	
	* end of dofile 
