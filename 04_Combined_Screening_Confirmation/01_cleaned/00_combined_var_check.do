/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Var name checking: to combine Screening + Confirmation			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. Combined dataset 
	2. Observe the mis-matched obs 

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"
	
	/*
	"$np_sc_clean/codebook/cvd_screening_cleaned.xlsx"
	
	"$np_cf_clean/codebook/cvd_confirmation_cleaned.xlsx"
	
	"$np_addq_clean/codebook/cvd_confirmation_additional_questions_cleaned.xlsx"
	
	"$np_vhw_clean/codebook/cvd_vhw_logbook_cleaned.xlsx"
	*/

	********************************************************************************
	* VARIABLE NAME CHECKING *
	********************************************************************************
	
	* (1) Screening 
	import excel using "$np_sc_clean/codebook/cvd_screening_cleaned.xlsx", firstrow clear 
	
	drop name label type choices
	
	rename namecurrent name 
	
	drop if mi(name)
	
	keep name 
	gen screening = 1 
	
	tempfile screening 
	save `screening', replace 
	
	* (2) Confirmation 
	import excel using "$np_cf_clean/codebook/cvd_confirmation_cleaned.xlsx", firstrow clear 
	
	drop name label type choices
	
	rename namecurrent name 
	
	drop if mi(name)
	
	keep name 
	gen confirmation = 1 
	
	tempfile confirm 
	save `confirm', replace 

	* (3) Additional Questions 
	import excel using "$np_addq_clean/codebook/cvd_confirmation_additional_questions_cleaned.xlsx", firstrow clear 
	
	drop name label type choices
	
	rename namecurrent name 
	
	drop if mi(name)
	
	keep name 
	gen add_question = 1 
	
	tempfile add_question 
	save `add_question', replace 

	****************************************************************************
	** Var Check - across screening and confirmation dataset ** 
	****************************************************************************
	
	use `confirm', clear 
	
	merge 1:1 name using `add_question' 
	
	// only demographic var were identical between confirmation and additional question 
	// no action required for variable name changes 
	
	drop _merge 
	
	merge 1:1 name using `screening'
	
	// 52 variables including demographic var and medical records infomration variables 
	// were identical between confirmation and additional question 
	// action required for variable name changes 
	


	
	* end of dofile 
