/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	No medication			
Author				:	Nicholus Tint Zaw
Date				: 	02/26/2024
Modified by			:



Task outline: 
	1. 

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* DATASET COMBINATION *
	********************************************************************************

	
	* CVD Combined Datasets * 
	
	use "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.dta", clear 
	
	// keep correct eligable for consent patient 
	keep if ck_qualify == 1
	
	// keep only consent patient 
	keep if consent == 1 
	
	
	* Medication - Yes/No * 
	egen medication_yes = rowtotal(amlodipine_yn losartan_yn hctz_yn atorvastatin_yn metformin_yn aspirin_yn atenolol_yn omeprazole_yn)
	replace medication_yes = 1 if medication_yes > 0 
	replace medication_yes = .m if 	mi(amlodipine_yn) & mi(losartan_yn) & mi(hctz_yn) & ///
									mi(atorvastatin_yn) & mi(metformin_yn) & mi(aspirin_yn) & ///
									mi(atenolol_yn) & mi(omeprazole_yn)
	tab medication_yes, m 
	
	
	
	
	
	
	
	* end of dofile 
