/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	CVD - MASTER DOFILE 			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:


Task outline: 
	1. Run all MASTER dofiles

*******************************************************************************/

	****************************************************************************
	** Directory Settings **
	****************************************************************************

	do "$github/00_dir_setting.do"

	****************************************************************************
	* Dofile Setting *
	****************************************************************************
	
	local screening				1
	local confirmation 			1
	local additional			1
	local combine_three_dts 	1
	local vhwlogbook			1
	
	****************************************************************************
	* (1) Screening
	
	if `screening' ==  1 {
	    do "$screen_do/00_SCREENING_MASTER_DO.do"
	}
	
	* (2) Confirmation
	
	if `confirmation' ==  1 { 
	    do "$confirm_do/00_CONFIRMATION_MASTER_DO.do"
	}
	
	* (3) Additional Questions   
	
	if `additional' == 1 {
	    do "$addquest_do/00_CONFIRMATION_ADDITIONAL_MASTER_DO.do"
	}
	
	* (4) Combined 3 dataset: Screening + Confirmation + Additional Questions  
	
	if `combine_three_dts' == 1 {
	    do "$cb_do/00_COMBINED_SCA_MASTER_DO.do"
	}
	
	* (5) VHW logbook + Patient Safety Checklist & Combined Dataset  
	
	if `vhwlogbook' == 1 {
	    do "$vhw_do/00_VHW_LOGBOOK_MASTER_DO.do"
	}
	
	* end of dofile 
