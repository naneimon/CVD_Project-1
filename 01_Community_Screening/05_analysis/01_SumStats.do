/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work - HFC sum-stat			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:



Task outline: 
	1. develop sum-stat table

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$github/00_dir_setting.do"

	********************************************************************************
	* import raw data  *
	********************************************************************************
	
	use "$np_sc_constr/cvd_screening_constract.dta", clear 
	
	
	* Set locals
	local progress_indicator	svy_complete vill_dummy_1 vill_dummy_2 svy_early svy_late svy_duration
	local confirmation_visit	ck_cal_confirm_visit ///
								cf_cal_cvd_risk_yes ck_cf_blood_glucose ck_cf_cal_bf_abnormal ck_cf_cal_syst_avg ///
								ck_cf_cal_diast_avg ck_stroke ck_heartatt ck_aspirin_d ck_statins_d ck_dasp_cf ///
								ck_dstat_cf ck_diabetes ck_diabetes_d ck_hypertension ck_hypertension_d ///
								ck_hpd_cf ck_ddd_cf
	local bp_figure				bp_high_140_90 bp_low_140_90 bp_low_130_85 bp_low_120_80 /// 
								bp_high_140_90_hpm bp_low_140_90_hpm bp_low_130_85_hpm bp_low_120_80_hpm ///
								bp_high_140_90_hpm_only bp_low_140_90_hpm_only bp_low_130_85_hpm_only bp_low_120_80_hpm_only
	
	* Set path
	putexcel set "$sc_check/HFC/Community_Screening_Check_SumStat.xlsx", modify 
	
	* Loop over categories					
	foreach category in progress_indicator confirmation_visit bp_figure {
		
		putexcel set 	"$np_sc_check/HFC/Community_Screening_Check_SumStat.xlsx", ///
						modify sheet("`category'") // remember to specify the full path
			
		/*
		if "`category'" == "egma" {
			putexcel A104 = "Note:", bold
			putexcel A105 = "For level 2 of addition and subtraction, only observations with scores greater than 0 from level 1 were given the level 2 test."
			putexcel A106 = "As a result, the number of observations differed between level 1 and level 2.", 
		}		
		*/

		
		local row = 1	
				
		local category `category'
		putexcel A`row' = "Category: `category'", bold		

		local row = `row' + 2	
		
		putexcel A`row' = "Variable label", bold
		putexcel B`row' = "Variable name", bold
		putexcel C`row' = "Count", bold
		putexcel D`row' = "Min", bold
		putexcel E`row' = "Median", bold
		putexcel F`row' = "Mean", bold
		putexcel G`row' = "Max", bold
		putexcel H`row' = "SD", bold
				
		local row = `row' + 1	
	
		foreach var of local `category' {
									
			foreach var of varlist `var' {
				
				* Var label
				describe `var'
				local varlabel : var label `var'
				putexcel A`row' = ("`varlabel'")
				
				*Desc stat
				tabstat `var', stat(N min p50 mean max sd) columns(statistics) save 
				mat T = r(StatTotal)' // the prime is for transposing the matrix
				
				* Round min, max, P50, mean and sd
				forval i = 2/6{
					matrix T[1,`i'] = round(T[1,`i'], 0.01)
				}
				
				putexcel B`row' = matrix(T), rownames
				local ++row					
			}
		local ++row					
	
		}
	local ++row		
	}

	
	
	// ADD n in the sum-stat table 
	local i = 4
	
	foreach var in `confirmation_visit' {
		
		count if `var' == 1
		
		putexcel set 	"$np_sc_check/HFC/Community_Screening_Check_SumStat.xlsx", ///
						modify sheet("confirmation_visit")
			
		putexcel I`i' = (`r(N)')
		putexcel save
		
		local i = `i' + 2
		
	}
	
	// ADD n in the sum-stat table 
	local i = 4
	
	foreach var in `bp_figure' {
		
		count if `var' == 1
		
		putexcel set 	"$np_sc_check/HFC/Community_Screening_Check_SumStat.xlsx", ///
						modify sheet("bp_figure")
			
		putexcel I`i' = (`r(N)')
		putexcel save
		
		local i = `i' + 2
		
	}
		
****End do-file. 