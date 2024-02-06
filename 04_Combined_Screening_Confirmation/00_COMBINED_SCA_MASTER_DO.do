/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Combination of screening + confirmation + addditional question - MASTER DOFILE 			
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
	
	local combine		1
	local construct 	0
	local analyse		0
	
	****************************************************************************
	* (1) Combine Screening and Confirmation Datasets
	
	if `combine' ==  1 {
	    do "$cb_do_clean/01_screening_confirmation_combined.do"
	}
	
	* (2) Construction
	
	if `construct' ==  1 { 
	    do "$cb_do_constr/XX.do"
	}
	
	* (3) Analysis 
	
	if `analyse' == 1 {
	    do "$cb_do_analyze/XX.do"
	}
	

	* end of dofile 
