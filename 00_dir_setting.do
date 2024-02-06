/*******************************************************************************

Project Name		: 	CVD Project
Purpose				:	Screening work			
Author				:	Nicholus Tint Zaw
Date				: 	11/09/2023
Modified by			:


*******************************************************************************/

** Settings for stata ** 
clear all
label drop _all

set more off
set mem 100m
set matsize 11000
set maxvar 32767


********************************************************************************
	***SET ROOT DIRECTORY HERE AND ONLY HERE***

	// create a local to identify current user
	local user = c(username)
	di "`user'"

	// Set root directory depending on current user
	if "`user'" == "Nicholus Tint Zaw" {
		* Nicholus Directory
		
		// PII Data 
		global dropbox		"C:\Users\Nicholus Tint Zaw\Dropbox\CVD\With PII data\01_workflow"
		
		// Non-PII Data
		global box			"C:\Users\Nicholus Tint Zaw\Box\Myanmar CVD Study 2023-2024\Feasibility Study"
		
		// Dofiles 
		global github		"C:\Users\Nicholus Tint Zaw\Documents\GitHub\CVD_Project"
		
	}


	// CPI team, please update your machine directory. 
	// pls replicate below `else if' statement based on number of user going to use this analysis dofiles  
	else if "`user'" == "XX" {
		* CPI team Directory
		
		global dropbox		""
		global box			""
		global github		""
		
	}


	****************************************************************************
	** Set sub-directory ** 
	****************************************************************************

	** (1) Community Screening **
	** PII DATA 
	global screen			"$dropbox/01_Community_Screening"
	global sc_raw			"$screen/01_raw"
	global sc_check			"$screen/02_check"
	global sc_clean			"$screen/03_cleaned"
	global sc_constr		"$screen/04_construct"
	global sc_analyze		"$screen/05_analysis"

	** Non-PII DATA 
	global np_screen		"$box/01_Community_Screening"
	global np_sc_raw		"$np_screen/01_raw"
	global np_sc_check		"$np_screen/02_check"
	global np_sc_clean		"$np_screen/03_cleaned"
	global np_sc_constr		"$np_screen/04_construct"
	global np_sc_analyze	"$np_screen/05_analysis"
	
	** DOFILE 
	global screen_do		"$github/01_Community_Screening"
	global sc_do_raw		"$screen_do/01_import"
	global sc_do_hfc		"$screen_do/02_hfc"
	global sc_do_clean		"$screen_do/03_clean"
	global sc_do_constr		"$screen_do/04_construct"
	global sc_do_analyze	"$screen_do/05_analysis"
	
	** (2) 02_Confirmation Tool **
	** PII DATA 
	global confirm			"$dropbox/02_Confirmation_Tool"
	global cf_raw			"$confirm/01_raw"
	global cf_check			"$confirm/02_check"
	global cf_clean			"$confirm/03_cleaned"
	global cf_constr		"$confirm/04_construct"
	global cf_analyze		"$confirm/05_analysis"
	
	** Non-PII DATA 
	global np_confirm			"$box/02_Confirmation_Tool"
	global np_cf_raw			"$np_confirm/01_raw"
	global np_cf_check			"$np_confirm/02_check"
	global np_cf_clean			"$np_confirm/03_cleaned"
	global np_cf_constr			"$np_confirm/04_construct"
	global np_cf_analyze		"$np_confirm/05_analysis"
	
	** DOFILE 
	global confirm_do		"$github/02_Confirmation_Tool"
	global cf_do_raw		"$confirm_do/01_import"
	global cf_do_hfc		"$confirm_do/02_hfc"
	global cf_do_clean		"$confirm_do/03_clean"
	global cf_do_constr		"$confirm_do/04_construct"
	global cf_do_analyze	"$confirm_do/05_analysis"

	** (3) 03_Confirmation Additional Question **
	** PII DATA 
	global addquest			"$dropbox/03_Confirmation_Additional_Question"
	global addq_raw			"$addquest/01_raw"
	global addq_check		"$addquest/02_check"
	global addq_clean		"$addquest/03_cleaned"
	global addq_constr		"$addquest/04_construct"
	global addq_analyze		"$addquest/05_analysis"
	
	** Non-PII DATA  
	global np_addquest			"$box/03_Confirmation_Additional_Question"
	global np_addq_raw			"$np_addquest/01_raw"
	global np_addq_check		"$np_addquest/02_check"
	global np_addq_clean		"$np_addquest/03_cleaned"
	global np_addq_constr		"$np_addquest/04_construct"
	global np_addq_analyze		"$np_addquest/05_analysis"

	** DOFILE 
	global addquest_do		"$github/03_Confirmation_Additional_Question"
	global addq_do_raw		"$addquest_do/01_import"
	global addq_do_hfc		"$addquest_do/02_hfc"
	global addq_do_clean	"$addquest_do/03_clean"
	global addq_do_constr	"$addquest_do/04_construct"
	global addq_do_analyze	"$addquest_do/05_analysis"
	
	
	** (4) COMBINED DATASET 
	** PII DATA  
	global comb				"$dropbox/04_Combined_Screening_Confirmation"
	global comb_clean		"$comb/01_cleaned"
	global comb_constr		"$comb/02_construct"
	global comb_analyze		"$comb/03_analysis"

	** Non-PII DATA  
	global np_comb				"$box/04_Combined_Screening_Confirmation"
	global np_comb_clean		"$np_comb/01_cleaned"
	global np_comb_constr		"$np_comb/02_construct"
	global np_comb_analyze		"$np_comb/03_analysis"

	** DOFILE 
	global cb_do				"$github/04_Combined_Screening_Confirmation"
	global cb_do_clean			"$cb_do/01_cleaned"
	global cb_do_constr			"$cb_do/02_construct"
	global cb_do_analyze		"$cb_do/03_analysis"
	
	** (5) 05_CVD_Screening_Dashboard
	global shiny			"$github/06_CVD_Screening_Dashboard"
	
	** (6) VHW Logbook **
	** PII DATA 
	global vhw				"$dropbox/05_VHW_Logbook"
	global vhw_raw			"$vhw/01_raw"
	global vhw_check		"$vhw/02_check"
	global vhw_clean		"$vhw/03_cleaned"
	global vhw_constr		"$vhw/04_construct"
	global vhw_analyze		"$vhw/05_analysis"
	
	** Non-PII DATA  
	global np_vhw			"$box/05_VHW_Logbook"
	global np_vhw_raw		"$np_vhw/01_raw"
	global np_vhw_check		"$np_vhw/02_check"
	global np_vhw_clean		"$np_vhw/03_cleaned"
	global np_vhw_constr	"$np_vhw/04_construct"
	global np_vhw_analyze	"$np_vhw/05_analysis"

	** DOFILE 
	global vhw_do			"$github/05_VHW_Logbook"
	global vhw_do_raw		"$vhw_do/01_import"
	global vhw_do_hfc		"$vhw_do/02_hfc"
	global vhw_do_clean		"$vhw_do/03_clean"
	global vhw_do_constr	"$vhw_do/04_construct"
	global vhw_do_analyze	"$vhw_do/05_analysis"


	****************************************************************************
	****************************************************************************
	
   ** Plot Setting 
	
	* Setting graph colors (dark to light)
	global cpi1  		maroon*1.5 
	global cpi2    		cranberry
	global cpi3			cranberry*0.4
	global cpi4			maroon*0.4	
	global cpi5			erose*0.6
	global blue4		"87 87 87 *0.4" 		// Grey
	global blue9		"gs15*0.5" 				// light gray 
	global white		white
	
	* Figure globals
	global CompletionRatesPie   "sort descending pie(1,color($wfp_blue1)) pie(2,color($blue2)) plabel(_all percent, size(medium) format(%2.0f)) plabel(_all name, color(black) size(small) gap(22) format(%2.0f)) line(lcolor(black) lalign(center)) graphregion(fcolor(white)) legend(off) title("$title1" "$title2", color(black) margin(medsmall)) note("$note", size(medium))"					
	global Pie					"sort descending plabel(_all percent, size(small) format(%2.0f) gap(21)) line(lcolor(black) lalign(center)) graphregion(fcolor(white)) legend(region(lstyle(none)))"
	global Bar					"ylabel(,nogrid) asyvars showyvars bargap(10) blabel(bar, format(%2.0f)) plotregion(fcolor(white)) graphregion(fcolor(white)) b1title($b1title, color(black)) ytitle($ytitle, color(black)) title("$title1" "$title2", color(black)) note($note)"
	
	* Formatting add-ons
	
	* Pie charts
	global ptext_format ", color(black) size(small)"
	
	* Bar graphs
	global bar_format 			"lwidth(thin) lcolor(black) lalign(outside)"
	global label_format			"label(labsize(small))"
	global label_format_45 		"label(labsize(small) angle(45))"
	global legend_label_format 	"size(vsmall) region(lstyle(none))"
	
	global graph_opts1 ///
	   bgcolor(white) ///
	   graphregion(color(white)) ///
	   legend(region(lc(none) fc(none))) ///
	   ylab(,angle(0) nogrid) ///
	   title(, justification(left) color(black) span pos(11)) ///
	   subtitle(, justification(left) color(black))

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
