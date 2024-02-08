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


	** Identify the visit - Changes in the dosage
	// Sort the dataset by patient_id and visit_date
	sort study_id visit_date
	bysort study_id: gen visit_num = _n 
		
	order study_id visit_num, before(visit_date)
	sort study_id visit_num visit_date

	
	local medications amlodipine losartan hctz atorvastatin metformin aspirin atenolol omeprazole 
	
	foreach var in `medications' {
		
		// to indicate the previous dosage for each patient
		bysort study_id: gen `var'_prev = `var'[_n - 1]
		
		lab var `var'_prev "Previous Dosage"
		
		label values `var'_prev `var'
		order `var'_prev, after(`var')
		
		// to indicate dosage changes between consecutive visits
		bysort study_id: gen `var'_change = (`var' != `var'_prev & visit_num > 1 & !mi(visit_num))
		
		lab var `var'_change "Dosage changes between consecutive visits"
		order `var'_change, after(`var'_prev)
		
		// to indicate the visit when the dosage changes occured 
		bysort study_id: gen `var'_chgnum = visit_num if `var'_change == 1
		replace `var'_chgnum = .m if visit_num == 1
		lab var `var'_chgnum "Number of visit when Dosage changes occured"
		order `var'_chgnum, after(`var'_change)
		
	}


	* CODEBOOK *
	iecodebook template using "$np_vhw_constr/codebook/cvd_vhw_logbook_constructed_codebook.xlsx", replace 

	* Save as raw data 
	save "$np_vhw_constr/cvd_vhw_logbook_constructed.dta", replace 
	
	* export as exel doc 
	export excel using "$np_vhw_constr/cvd_vhw_logbook_constructed.xlsx", sheet("vhw_logbook") firstrow(variables) replace 
	
	* end of dofile 
