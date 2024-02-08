/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	VHW Logbook - Created a Monitoring Variables		
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. process a constructed variable required for monitoring

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data *
	********************************************************************************
	
	use "$np_vhw_clean/cvd_vhw_logbook_cleaned.dta", clear 
	
	** VAR CONSTRUCTION ** 

	// average BP measurement
	destring cal_syst_avg cal_diast_avg, replace
	
	gen vhw_syst_avg 		= (bp_syst_2 + bp_syst_3) / 2
	replace vhw_syst_avg 	= .m if mi(bp_syst_2) | mi(bp_syst_3)
	gen vhw_diast_avg 		= (bp_diast_2 + bp_diast_3) / 2
	replace vhw_diast_avg 	= .m if mi(bp_diast_2) | mi(bp_diast_3) 
	
	count if vhw_syst_avg != cal_syst_avg
	count if vhw_diast_avg != cal_diast_avg
	
	order vhw_syst_avg vhw_diast_avg, after(cal_diast_avg)


	// New Symptoms 
	destring newsymptom0, replace 
	gen newsymptom_yes = (newsymptom0 != 1)
	replace newsymptom_yes = .m if mi(newsymptom0)
	tab1 newsymptom_yes newsymptom0, m 

	
	// blood_glucose
	tab1 blood_glucose blood_glucose_cf, m 
	replace blood_glucose = .m if mi(blood_glucose)
	replace blood_glucose_cf = .m if mi(blood_glucose_cf)


	&&

// Sort the dataset by patient_id and visit_date
sort patient_id visit_date

// Generate a variable to indicate the previous dosage for each patient
by patient_id: gen prev_dosage = amalodipine_dosage[_n-1]

// Generate variables to indicate dosage changes between consecutive visits
forval i = 2/`=_N' {
    gen dosage_change_`i' = (amalodipine_dosage == prev_dosage[_n-1]) & (prev_dosage != .)
}

// Label the dosage_change variables
forval i = 2/`=_N' {
    label variable dosage_change_`i' "Dosage change between visit `= (`i' - 1)' and `i'"
}

// Replace missing values with 0
foreach var of varlist dosage_change_* {
    replace `var' = 0 if missing(`var')
}

// Drop the prev_dosage variable
drop prev_dosage

	
	
	&&
	* CODEBOOK *
	iecodebook template using "$np_vhw_clean/codebook/cvd_vhw_logbook_constructed_codebook.xlsx", replace 

	* Save as raw data 
	save "$np_vhw_clean/cvd_vhw_logbook_constructed.dta", replace 
	
	* export as exel doc 
	export excel using "$np_vhw_clean/cvd_vhw_logbook_constructed.xlsx", sheet("vhw_logbook") firstrow(variables) replace 
	
	* end of dofile 
