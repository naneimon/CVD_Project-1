/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening + Confirmation Combined			
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
	
	********************************************************************************
	* DATASET COMBINATION *
	********************************************************************************
	
	* Merge Two Confirmation Datasets * 
	
	use "$np_cf_clean/cvd_confirmation_cleaned.dta", clear 
	
	gen confirmation_tool = 1 
	
	
	preserve 
	
		use "$np_addq_clean/cvd_confirmation_additional_questions_cleaned.dta", clear 
		
		gen confirmation_additional = 1 
		
		// keep study_id resp_confirm - end_note_1 confirmation_additional
		
		tempfile confirmation_additional_data
		save `confirmation_additional_data', replace 
		
	restore 
	
	merge 1:1 study_id using `confirmation_additional_data'
	
	drop _merge 
	
	tempfile confirmation_all
	save `confirmation_all', replace 
	
	* Merge with Screening Construct Data * 
	
	use "$np_sc_constr/cvd_screening_constract.dta", clear 
	
	* rename variable 
 	rename * s_* // added s_ prefix to distinguished with confirmation visit data
	
	rename s_study_id study_id
	rename s_confirmation_visit_yes confirmation_visit_yes
	rename s_cal_confirm_visit cal_confirm_visit
	
	gen screening_tool = 1
	
	merge 1:1 study_id using `confirmation_all', force 
	
	drop _merge 
	
	****************************************************************************
	** Matching Check **
	****************************************************************************
	
	replace confirmation_tool = 0 if mi(confirmation_tool)
	replace confirmation_tool = .m if mi(confirmation_visit_yes)
	
	
	replace confirmation_additional = 0 if mi(confirmation_additional)
	replace confirmation_additional = .m if mi(confirmation_visit_yes)
	
	tab1 confirmation_visit_yes confirmation_tool confirmation_additional, m 
	
	* eligible for confirmation but not surveyed in confirmation visit 
	gen confirmed_nosvy = (confirmation_visit_yes == 1 & confirmation_tool == 0)
	replace confirmed_nosvy = .m if mi(confirmation_visit_yes) & mi(confirmation_tool)
	lab var confirmed_nosvy "Eligible for confirmation but not surveyed in confirmation visit "
	tab confirmed_nosvy, m 
	
	* consent for enrollment but no additional question data 
	gen consent_noaddquest = (consent == 1 & confirmation_additional == 0)
	replace consent_noaddquest = .m if mi(consent) & mi(confirmation_additional)
	lab var consent_noaddquest "Consented for enrollment but no additional question data"
	tab consent_noaddquest, m 

	* no consent but additional question data 
	gen addquest_consent = (mi(consent)& confirmation_additional == 1)
	replace addquest_consent = .m if mi(consent) & mi(confirmation_additional)
	lab var addquest_consent "Additional question data but not Consented"
	tab addquest_consent, m 	
	
	* export as exel doc 
	export excel using "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.xlsx", sheet("combined_data") firstrow(variables) replace 
	
	* codebook 
	// codebookout "$np_comb_clean/codebook/cvd_screening_confirmation_combined_codebook.xlsx", replace 
	//iecodebook template using "$np_comb_clean/codebook/cvd_screening_confirmation_combined_codebook.xlsx", replace 
	iecodebook apply using "$np_comb_clean/codebook/cvd_screening_confirmation_combined_codebook.xlsx" 

	* Save as combined cleaned data 
	save "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.dta", replace 

	
	****************************************************************************
	****************************************************************************
	** Export as excel file - PII DATA 
	
	************************************************************************************
	* (0) Screening Confirmatory list 
	************************************************************************************
	use "$np_sc_constr/cvd_screening_constract.dta", clear 
	
	preserve 
	
		putexcel set 	"$np_comb_clean/Check_Output/SUMMARY_CHECK_OUTPUT.xlsx", ///
						modify sheet("SUMMARY")
						
			
		* label setting 
		putexcel B1 	= "SUMMARY PROGRESS FIGURE", bold
		
		putexcel B3 	= "Progress", bold
		
		putexcel B4 = "Census: Eligible for Screening (census + additional census)"
		putexcel B5 = "Actual Screened (all screening visits)"
		putexcel B6 = "Screened But Not Included in Census"
		putexcel B7 = "Not Screened but in Census"

		putexcel B9 = "Eligible for Screening (not pregnant + permanent resident)"
		putexcel B10 = "Eligible for Confirmation Visit"
		putexcel B11 = "Actual Surveyed at Confirmation Visit"
		putexcel B12 = "Eligible to Enroll in Study"
		putexcel B13 = "Consented to Enroll in Study"

		putexcel B15 = "Matching Issue", bold
		putexcel B16 = "Missing: Eligible for Confirmation but Not Surveyed Yet with Confirmation Tools"
		putexcel B17 = "Missing: Consented but Not Found at Additional Questions Tool"
		putexcel B18 = "Missing: Not Consented but Found at Additional Questions Tool"
		
		
		putexcel B19 = "XLS Form Calculation Issue", bold
		putexcel B20 = "Screening Tool", bold 
		putexcel B21 = "CVD Risk Calculation Error"
		putexcel B22 = "Confirmatorion Visit Eligibility Error"
		
		putexcel B23 = "Confirmatory Visit Tool", bold 
		putexcel B24 = "CVD Risk Calculation Error"
		putexcel B25 = "Enrollment Eligibility Error"
		
		
		* geo setting 
		putexcel C2 	= "Overall", bold
		
		levelsof cal_vill, local(vill)
		local cols D E F G H I J K L M N O P 
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			putexcel `col'2 	= "`v'", bold
			
			local i = `i' + 1
		}
		
		** Value setting 
		* Total screened 
		putexcel C5 = (_N)
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'"
			
			putexcel `col'5 	= (`r(N)')
			
			local i = `i' + 1
		}	
		
		* Screening - eligable 
		count if ck_cal_eligible == 1
		putexcel C9 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & ck_cal_eligible == 1
			
			putexcel `col'9 	= (`r(N)')
			
			local i = `i' + 1
		}	
		
		* Eligable for confirmatory visit 
		count if confirmation_visit_yes == 1
		putexcel C10 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & confirmation_visit_yes == 1
			
			putexcel `col'10 	= (`r(N)')
			
			local i = `i' + 1
		}	
		
		
			
		* XLS CVD Risk calculator error  
		count if cvd_final_check == 1
		putexcel C21 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & cvd_final_check == 1
			
			putexcel `col'21 	= (`r(N)')
			
			local i = `i' + 1
		}	

		
		* XLS Confirmatorion visit eligibility error  
		count if 	confirmation_visit_yes != cal_confirm_visit & ///
					!mi(confirmation_visit_yes) & !mi(cal_confirm_visit)
		putexcel C22 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if 	cal_vill == "`v'" & confirmation_visit_yes != cal_confirm_visit & ///
						!mi(confirmation_visit_yes) & !mi(cal_confirm_visit)
			
			putexcel `col'22 	= (`r(N)')
			
			local i = `i' + 1
		}	
		
		putexcel save
	
	restore 
	
	* get personal info data 
	merge 1:1 study_id using 	"$sc_check/cvd_screening_check_nodup.dta", ///
								keepusing(resp_name resp_dad_name resp_mom_name)
								// assert(3) nogen - 2 unmatched - need to check with Cho Zin
	
	order resp_name resp_dad_name resp_mom_name study_id
	
	preserve 
	
		keep if confirmation_visit_yes == 1
		
		if _N > 0 {
			
			export excel using "$comb_clean/Check_Output/Screening_Vs_Confirmation_Tool_Check_Outputs.xlsx", ///
								sheet("Screening Eligible Confirmation") firstrow(varlabels) sheetmodify
		}
	
	restore 	
	
		

		
		
	************************************************************************************
	* (1) Enrollment Eligibility Error: Not Eligible but Enrolled
	************************************************************************************
	use "$np_cf_clean/cvd_confirmation_cleaned.dta", clear 
	

	preserve 
	
		putexcel set 	"$np_comb_clean/Check_Output/SUMMARY_CHECK_OUTPUT.xlsx", ///
						modify sheet("SUMMARY")
						
		levelsof cal_vill, local(vill)
		local cols D E F G H I J K L M N O P 
	
		* Actual surveyed at confirmation visit 
		putexcel C11 = (_N)
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" 
			
			putexcel `col'11 	= (`r(N)')
			
			local i = `i' + 1
		}	
		
		
		* Eligable for study enrollment 
		count if ck_qualify == 1
		putexcel C12 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & ck_qualify == 1
			
			putexcel `col'12 	= (`r(N)')
			
			local i = `i' + 1
		}				

	
		* Consented study enrollment 
		count if consent == 1
		putexcel C13 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & consent == 1
			
			putexcel `col'13 	= (`r(N)')
			
			local i = `i' + 1
		}				

				
		* XLS CVD risk calculator error  
		count if cvd_final_check == 1
		putexcel C24 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & cvd_final_check == 1
			
			putexcel `col'24 	= (`r(N)')
			
			local i = `i' + 1
		}				

		
		* XLS CVD risk calculator error  
		count if ck_qualify != cal_qualify
		putexcel C25 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & ck_qualify != cal_qualify
			
			putexcel `col'25 	= (`r(N)')
			
			local i = `i' + 1
		}				

		
		
		putexcel save
	
	restore 
	
	preserve 
	
		keep if ck_qualify == 0 & cal_qualify == 1
		
		if _N > 0 {
			
			export excel using "$np_comb_clean/Check_Output/SUMMARY_CHECK_OUTPUT.xlsx", ///
								sheet("Not Eligibility but Enrolled") firstrow(varlabels) sheetmodify
		}
	
	restore
	
	
	* get personal info data 
	merge 1:1 study_id using 	"$sc_check/cvd_screening_check_nodup.dta", ///
								keepusing(resp_name resp_dad_name resp_mom_name) 
	
	keep if _merge == 3
	drop _merge 
	
	order resp_name resp_dad_name resp_mom_name study_id
	
	preserve 
	
		keep if ck_qualify == 0 & cal_qualify == 1
		
		if _N > 0 {
			
			export excel using "$comb_clean/Check_Output/Screening_Vs_Confirmation_Tool_Check_Outputs.xlsx", ///
								sheet("Not Eligibility but Enrolled") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	************************************************************************************
	* (2) Enrollment Eligibility Error: Eligible but not Enrolled
	************************************************************************************
	preserve 
	
		keep if ck_qualify == 1 & cal_qualify == 0
		
		if _N > 0 {
			
			export excel using "$comb_clean/Check_Output/Screening_Vs_Confirmation_Tool_Check_Outputs.xlsx", ///
								sheet("Eligibility but not Enrolled") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	************************************************************************************
	* (3) Eligible for Confirmation Visit but not included in confirmation tools survey
	************************************************************************************
	use "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.dta", clear  

	preserve 
	
		putexcel set 	"$np_comb_clean/Check_Output/SUMMARY_CHECK_OUTPUT.xlsx", ///
						modify sheet("SUMMARY")
						
		levelsof cal_vill, local(vill)
		local cols D E F G H I J K L M N O P 
			
		* Eligable for confirmatory visit but not surveyed yet  
		count if confirmed_nosvy == 1
		putexcel C16 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & confirmed_nosvy == 1
			
			putexcel `col'16 	= (`r(N)')
			
			local i = `i' + 1
		}				

	
		* Consented but not found at additional question tools
		count if consent_noaddquest == 1
		putexcel C17 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & consent_noaddquest == 1
			
			putexcel `col'17 	= (`r(N)')
			
			local i = `i' + 1
		}				

		* Not Consented but found at additional question tools
		count if addquest_consent == 1
		putexcel C18 = (`r(N)')
		
		local i = 1
		foreach v in `vill' {
		    
		    local col : word `i' of `cols'
			
			count if cal_vill == "`v'" & addquest_consent == 1
			
			putexcel `col'17 	= (`r(N)')
			
			local i = `i' + 1
		}	

		putexcel save
	
	restore 

	
	preserve 
	
		keep if confirmed_nosvy == 1
		
		if _N > 0 {
			
			export excel using "$np_comb_clean/Check_Output/SUMMARY_CHECK_OUTPUT.xlsx", ///
								sheet("Confirmed but not survey") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	
	* get personal info data 
	merge 1:1 study_id using 	"$sc_check/cvd_screening_check_nodup.dta", ///
								keepusing(resp_name resp_dad_name resp_mom_name) 
								// assert(3) nogen 2 unmatched obs - need to check with Cho Zin
	
	order resp_name resp_dad_name resp_mom_name study_id

	preserve 
	
		keep if confirmed_nosvy == 1
		
		if _N > 0 {
			
			export excel using "$comb_clean/Check_Output/Screening_Vs_Confirmation_Tool_Check_Outputs.xlsx", ///
								sheet("Confirmed but not survey") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	************************************************************************************
	* (4) Consented for enrollment but not found additional question data 
	************************************************************************************
	* no pii 
	preserve 
	
		keep if consent_noaddquest == 1
		
		drop resp_name resp_dad_name resp_mom_name 
		
		if _N > 0 {
			
			export excel using "$np_comb_clean/Check_Output/SUMMARY_CHECK_OUTPUT.xlsx", ///
								sheet("Consented but no ADD data") firstrow(varlabels) sheetmodify
		}
	
	restore 	
	
	* with pii 
	preserve 
	
		keep if consent_noaddquest == 1
		
		if _N > 0 {
			
			export excel using "$comb_clean/Check_Output/Screening_Vs_Confirmation_Tool_Check_Outputs.xlsx", ///
								sheet("Consented but no ADD data") firstrow(varlabels) sheetmodify
		}
	
	restore 

	** additional question but no consent 
	* no pii 
	preserve 
	
		keep if addquest_consent == 1
		
		drop resp_name resp_dad_name resp_mom_name 
		
		if _N > 0 {
			
			export excel using "$np_comb_clean/Check_Output/SUMMARY_CHECK_OUTPUT.xlsx", ///
								sheet("No Consented but ADD data") firstrow(varlabels) sheetmodify
		}
	
	restore 	
	
	
	
	* with pii 
	preserve 
	
		keep if addquest_consent == 1
		
		if _N > 0 {
			
			export excel using "$comb_clean/Check_Output/Screening_Vs_Confirmation_Tool_Check_Outputs.xlsx", ///
								sheet("No Consented but ADD data") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	************************************************************************************
	* (5) Request Cases
	************************************************************************************
	preserve 
	
		keep if study_id == "4/2/46/202311167119"
		
		if _N > 0 {
			
			export excel using "$comb_clean/Check_Output/Screening_Vs_Confirmation_Tool_Check_Outputs.xlsx", ///
								sheet("Requested Cases") firstrow(varlabels) sheetmodify
		}
	
	restore 
	
	* end of dofile 
