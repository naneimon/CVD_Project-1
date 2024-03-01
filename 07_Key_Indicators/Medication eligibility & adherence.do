use "cvd_combined_constructed.dta", clear

*** Replacing 6666= Don't know with missing value

foreach var of varlist s_mhist_drug_bp mhist_drug_bp ck_bp_pass_2 s_ck_cal_syst_avg s_ck_cal_diast_avg ck_cal_syst_avg ///
                         ck_cal_diast_avg s_mhist_drug_bsug	mhist_drug_bsug s_blood_glucose blood_glucose ///
						 s_mhist_drug_statins mhist_drug_statins mhist_heartatt mhist_stroke mhist_ischemic ///
						 s_stata_cvd_risk_who stata_cvd_risk_who {
		
		replace `var'= .m if `var'==6666 
		
	}	
*****Medicine Eligibility*****

*For blood pressure medicine*				
gen e_BPMed = ((s_mhist_drug_bp==1 | mhist_drug_bp == 1 | ck_bp_pass_2==1)| ///
                (s_ck_cal_syst_avg >=140 & !mi (s_ck_cal_syst_avg) | s_ck_cal_diast_avg >=90 & !mi (s_ck_cal_diast_avg)) & ///
				(ck_cal_syst_avg >=140 & !mi (ck_cal_syst_avg) | ck_cal_diast_avg >=90 & !mi (ck_cal_diast_avg)))				
				
replace e_BPMed = .m if mi(s_mhist_drug_bp) & mi(mhist_drug_bp) & mi(ck_bp_pass_2)& ///
                         mi(s_ck_cal_syst_avg) & mi(s_ck_cal_diast_avg)& ///
						 mi(ck_cal_syst_avg) & mi(ck_cal_diast_avg)				
tab e_BPMed, m				


*For DM medicine*
gen e_DMMed = ((s_mhist_drug_bsug ==1  | mhist_drug_bsug ==1) | ///
                (s_blood_glucose >=200 & !mi(s_blood_glucose) & blood_glucose >=200 & !mi(blood_glucose)))
								
replace e_DMMed = .m if mi(s_mhist_drug_bsug) & mi(mhist_drug_bsug) & mi(s_blood_glucose ) & mi(blood_glucose)	
tab e_DMMed, m 		

*For Statin*
gen e_Statin = (e_DMMed ==1 | s_mhist_drug_statins ==1 | ///
                  mhist_drug_statins==1 | mhist_heartatt==1 | ///
				  mhist_stroke==1 | mhist_ischemic==1 | ///
				  s_stata_cvd_risk_who >=10 & !mi(s_stata_cvd_risk_who) | stata_cvd_risk_who >=10 & !mi(stata_cvd_risk_who)) 				  
				  
replace e_Statin = .m if mi(e_DMMed) & mi(s_mhist_drug_statins) & mi(mhist_drug_statins) & mi(mhist_heartatt) & mi(mhist_stroke) ///
                     & mi(mhist_ischemic) & mi(s_stata_cvd_risk_who) & mi(stata_cvd_risk_who) 				  
tab e_Statin, m

***Browse***
br study_id s_mhist_drug_bp mhist_drug_bp ck_bp_pass_2 s_ck_cal_syst_avg s_ck_cal_diast_avg ck_cal_syst_avg ck_cal_diast_avg e_BPMed if e_BPMed ==1
br study_id s_mhist_drug_bsug mhist_drug_bsug s_blood_glucose blood_glucose e_DMMed if e_DMMed ==1
br study_id e_DMMed s_mhist_drug_statins mhist_drug_statins mhist_heartatt mhist_stroke mhist_ischemic s_stata_cvd_risk_who stata_cvd_risk_who e_Statin if e_Statin ==1

*****Taking Medicines, Eligibility & Taking Medicine*****

gen t_BPMed = (s_mhist_drug_bp == 1 | mhist_drug_bp ==1) if s_mhist_drug_bp !=. & mhist_drug_bp !=.
tab t_BPMed, m
gen et_BPMed = (e_BPMed == 1 & t_BPMed ==1) if e_BPMed !=. & t_BPMed !=.
tab et_BPMed, m

gen t_DMMed = (s_mhist_drug_bsug == 1 | mhist_drug_bsug ==1) if s_mhist_drug_bsug !=. & mhist_drug_bsug !=.
tab t_DMMed,m
gen et_DMMed = (e_DMMed == 1 & t_DMMed == 1) if e_DMMed !=. & t_DMMed !=.
tab et_DMMed, m

gen t_Statin = (s_mhist_drug_statins ==1 | mhist_drug_statins==1) if s_mhist_drug_statins !=. & mhist_drug_statins !=.
tab t_Statin,m 
gen et_Statin = (e_Statin == 1 & t_Statin == 1) if e_Statin !=. & t_Statin !=.
tab et_Statin,m 


*****Analysis*****

tab e_BPMed et_BPMed, m
tab e_DMMed et_DMMed, m
tab e_Statin et_Statin, m 


***** Adherence (Lenient) *****
*For BP Medicines & Statin*
egen e_total  = rowtotal(e_BPMed e_Statin) if e_BPMed !=. & e_Statin !=. 
egen et_total = rowtotal(et_BPMed et_Statin) if et_BPMed !=. & et_Statin !=.
tab e_total et_total, m

gen Any_ad = .m
replace Any_ad = 0 if e_total >0 & e_total !=.
replace Any_ad = 1 if et_total >0 & et_total !=.
tab Any_ad, m
tab Any_ad


*For BP Medicine*
gen Any_ad_BP = .m
replace Any_ad_BP = 0 if e_BPMed >0 & e_BPMed !=.
replace Any_ad_BP = 1 if et_BPMed >0 & et_BPMed !=.
tab Any_ad_BP, m
tab Any_ad_BP


*For Statin*
gen Any_ad_Statin = .m
replace Any_ad_Statin = 0 if e_Statin >0 & e_Statin !=.
replace Any_ad_Statin = 1 if et_Statin >0 & et_Statin !=.
tab Any_ad_Statin, m
tab Any_ad_Statin


******Strict Adherence-Morisky Medication Adherence Scale*****

destring ahder_1, replace
destring ahder_2, replace
destring ahder_3, replace
destring ahder_4, replace
destring ahder_5, replace
destring ahder_6, replace
destring ahder_7, replace
destring ahder_8, replace

gen ahder_8r = .m
replace ahder_8r = 0 if ahder_8 == 1 | ahder_8 == 2 & ahder_8 !=. 
replace ahder_8r = 0.25 if ahder_8 == 3 & ahder_8 !=. 
replace ahder_8r = 0.5 if ahder_8 == 4 & ahder_8 !=. 
replace ahder_8r = 0.75 if ahder_8 == 5 & ahder_8 !=. 
///replace ahder_8r = 1 if ahder_8 == 6 & ahder_8 !=. 


recode ahder_3 (1=0) (0=1)

egen Ad_total_M = rowtotal (ahder_1 ahder_2 ahder_3 ahder_4 ahder_5 ahder_6 ahder_7 ahder_8r) if ahder_1!=. & ahder_2!=. & ahder_3!=. & ahder_4!=. & ahder_5!=. & ahder_6!=. & ahder_7!=. & ahder_8r!=.    

*For BP Medicine& Statin (et_total)*
gen M_ad = .m
replace M_ad = 0 if Ad_total_M >2 & Ad_total_M !=.
replace M_ad = 1 if Ad_total_M <=2 & Ad_total_M !=.
lab def M_ad 1 "High adherence" 0 "Low adherence"
lab val M_ad M_ad
replace M_ad =. if et_total <1
replace M_ad =. if et_total ==.
tab M_ad, m
tab M_ad

*For BP Medicine (et_BPMed)*
gen M_ad_BP = .m
replace M_ad_BP = 0 if Ad_total_M >2 & Ad_total_M !=.
replace M_ad_BP = 1 if Ad_total_M <=2 & Ad_total_M !=.
lab def M_ad_BP 1 "High adherence" 0 "Low adherence"
lab val M_ad_BP M_ad_BP
replace M_ad_BP =. if et_BPMed <1
replace M_ad_BP =. if et_BPMed ==.
tab M_ad_BP, m
tab M_ad_BP


*For Statin (et_Statin)*
gen M_ad_Statin = .m
replace M_ad_Statin = 0 if Ad_total_M >2 & Ad_total_M !=.
replace M_ad_Statin = 1 if Ad_total_M <=2 & Ad_total_M !=.
lab def M_ad_Statin 1 "High adherence" 0 "Low adherence"
lab val M_ad_Statin M_ad_Statin
replace M_ad_Statin =. if et_Statin <1
replace M_ad_Statin =. if et_Statin ==.
tab M_ad_Statin, m
tab M_ad_Statin

***Adherence (Lenient & Morisky)
clonevar adherence_combine = Any_ad
replace adherence_combine = 2 if M_ad == 1
tab adherence_combine

clonevar adherence_combine_BP = Any_ad_BP
replace adherence_combine_BP = 2 if M_ad_BP == 1
tab adherence_combine_BP

clonevar adherence_combine_Statin = Any_ad_Statin
replace adherence_combine_Statin = 2 if M_ad_Statin == 1
tab adherence_combine_Statin


***Proportion of taking medicines to eligible medicines***
gen taking_e = et_total/e_total if et_total !=. & e_total !=.
gen pro_taking = .m
replace pro_taking = 1 if taking_e ==1
replace pro_taking = 2 if taking_e <1 & taking_e >0
replace pro_taking = 3 if taking_e ==0
lab def pro_taking 1"Good" 2"Average" 3"Non"
lab val pro_taking pro_taking
tab pro_taking, m













