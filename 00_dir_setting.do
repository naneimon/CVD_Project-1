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
		
		global box			"C:\Users\Nicholus Tint Zaw\Box\Myanmar CVD Study 2023-2024\Feasibility Study"
		global googledrive	""
		global github		"C:\Users\Nicholus Tint Zaw\Documents\GitHub\cvd_project"
		
	}


	// CPI team, please update your machine directory. 
	// pls replicate below `else if' statement based on number of user going to use this analysis dofiles  
	else if "`user'" == "XX" {
		* CPI team Directory
		
	}


	****************************************************************************
	** Set sub-directory ** 
	****************************************************************************

	** (1) Community Screening **
	** DATA 
	global screen			"$box/01_Community_Screening/"
	global sc_raw			"$screen/01_raw"
	global sc_check			"$screen/02_check"
	global sc_clean			"$screen/03_cleaned"
	global sc_constr		"$screen/04_construct"
	global sc_analyze		"$screen/05_analysis"
	
	** DOFILE 
	global screen_do		"$github/01_Community_Screening/"
	global sc_do_raw		"$screen_do/01_raw"
	global sc_do_hfc		"$screen_do/02_hfc"
	global sc_do_clean		"$screen_do/03_clean"
	global sc_do_constr		"$screen_do/04_construct"
	global sc_do_analyze	"$screen_do/05_analysis"
	
	** (2) 02_Confirmation Tool **
	** DATA 
	global confirm			"$box/02_Confirmation_Tool/"
	global cf_raw			"$confirm/01_raw"
	global cf_check			"$confirm/02_check"
	global cf_clean			"$confirm/03_cleaned"
	global cf_constr		"$confirm/04_construct"
	global cf_analyze		"$confirm/05_analysis"
	
	** DOFILE 
	global confirm_do		"$github/02_Confirmation_Tool/"
	global cf_do_raw		"$confirm_do/01_raw"
	global cf_do_hfc		"$confirm_do/02_hfc"
	global cf_do_clean		"$confirm_do/03_clean"
	global cf_do_constr		"$confirm_do/04_construct"
	global cf_do_analyze	"$confirm_do/05_analysis"

	** (3) 03_Confirmation Additional Question **
	** DATA 
	global addquest			"$box/03_Confirmation_Additional_Question/"
	global addq_raw			"$addquest/01_raw"
	global addq_check		"$addquest/02_check"
	global addq_clean		"$addquest/03_cleaned"
	global addq_constr		"$addquest/04_construct"
	global addq_analyze		"$addquest/05_analysis"
	
	** DOFILE 
	global addquest_do		"$github/03_Confirmation_Additional_Question/"
	global addq_do_raw		"$addquest_do/01_raw"
	global addq_do_hfc		"$addquest_do/02_hfc"
	global addq_do_clean	"$addquest_do/03_clean"
	global addq_do_constr	"$addquest_do/04_construct"
	global addq_do_analyze	"$addquest_do/05_analysis"

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
