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

	
	* CVD Combined Datasets * 
	
	use "$np_comb_clean/cvd_screening_confirmation_combined_cleaned.dta", clear 
	
	** Equity Wealth - Quantile 
	// recoding for national wealth quantile calculation 
	
	local i = 1
	foreach var of varlist 	eqttool_1 eqttool_2 eqttool_3 eqttool_4 eqttool_5 ///
							eqttool_6 eqttool_7 eqttool_8 eqttool_9 eqttool_10 ///
							eqttool_11 {
				
	//replace `var' 	= .r if `var' == 666
	tab `var', m 
	
	gen Q`i' = `var'
	tab Q`i', m 
	
	local i = `i' + 1
							}

	// water
	tab eqttool_12, m 
	
	gen Q12 = (eqttool_12 == 6)
	replace Q12 = .m if mi(eqttool_12)
	tab Q12, m 
	
	// house_floor
	tab eqttool_13, m 
	
	gen Q13 = (eqttool_13 == 4)
	replace Q13 = .m if mi(eqttool_13)
	tab Q13, m 
	
	// house_wall
	tab eqttool_14, m 
	
	gen Q14 = (eqttool_14 == 3)
	replace Q14 = .m if mi(eqttool_14)
	tab Q14, m 
	
	// house_cooking
	tab eqttool_15, m 
	
	gen Q15 = (eqttool_15 == 1)
	replace Q15 = .m if mi(eqttool_15)
	replace Q15 = 2 if eqttool_15 == 2
	tab Q15, m 
 
	
	* national quantile score 
	recode Q1 	(1 =0.0690823167469157) 	(0=-0.090564375679863)  	(else = .), generate (Q1_NAT)
	recode Q2 	(1 =0.0425159468667336) 	(0=-0.102017459669619)  	(else = .), generate (Q2_NAT)
	recode Q3 	(1 =0.196151902825549) 		(0=-0.0347236890124324)  	(else = .), generate (Q3_NAT)
	recode Q4 	(1 =0.039846704588856) 		(0=-0.0932240427690655)  	(else = .), generate (Q4_NAT)
	recode Q5 	(1 =0.0601696840973599) 	(0=-0.0914676246157446)  	(else = .), generate (Q5_NAT)
	recode Q6 	(1 =0.0860143518664307) 	(0=-0.0588690059465842)  	(else = .), generate (Q6_NAT)
	recode Q7 	(1 =0.053153739646388) 		(0=-0.0902879152715415)  	(else = .), generate (Q7_NAT)
	recode Q8 	(1 =0.145901751708448) 		(0=-0.0506677564135179)  	(else = .), generate (Q8_NAT)
	recode Q9 	(1 =0.253757481765658) 		(0=-0.0113242934366423)  	(else = .), generate (Q9_NAT)
	recode Q10 	(1 =0.0333845651540212) 	(0=-0.0422556495324506)  	(else = .), generate (Q10_NAT)
	recode Q11 	(1 =0.148211753309913) 		(0=-0.0201035838731444)  	(else = .), generate (Q11_NAT)
	recode Q12 	(1 =0.162636747669074) 		(0=-0.0277509041255903)  	(else = .), generate (Q12_NAT)
	recode Q13 	(1 =0.155494152541655) 		(0=-0.0248934954185016)  	(else = .), generate (Q13_NAT)
	recode Q14 	(1 =-0.0528762137328121) 	(0=0.0479863944863473)  	(else = .), generate (Q14_NAT)
	recode Q15 	(1 =0.24423835602352) 		(2=-0.0964473961662472) 	(0=0.0582018771645681)  (else = .), generate (Q15_NAT)

	
	** Calculate the sum of the national scores
	gen double NationalScore =  Q1_NAT+ Q2_NAT+ Q3_NAT+ Q4_NAT+ Q5_NAT+ Q6_NAT+ ///
								Q7_NAT+ Q8_NAT+ Q9_NAT+ Q10_NAT+ Q11_NAT+ ///
								Q12_NAT+ Q13_NAT+ Q14_NAT+ Q15_NAT
								
	** Assign respondents to national quintiles based on their national scores
	generate NationalQuintile = .
	replace NationalQuintile = 1 if 	NationalScore > -100 & NationalScore <-0.523858129524
	replace NationalQuintile = 2 if   	NationalScore >=-0.523858129524
	replace NationalQuintile = 3 if  	NationalScore >=-0.231140689739
	replace NationalQuintile = 4 if 	NationalScore >=0.075731996126
	replace NationalQuintile = 5 if 	NationalScore >=0.587364826752
	replace NationalQuintile = . if 	NationalScore ==.

	tab NationalQuintile, m 
	
	lab def hequantile 1"Poorest" 2"Poor" 3"Medium" 4"Wealthy" 5"Wealthiest"
	lab val NationalQuintile hequantile
	lab var NationalQuintile "EquityTool National Quintile"
	tab NationalQuintile, m 

	
	* Save as combined cleaned data 
	save "$np_comb_constr/cvd_combined_constructed.dta", replace 
	
	* codebook 
	codebookout "$np_comb_constr/codebook/cvd_combined_constructed_codebook.xlsx", replace 

	
	* end of dofile 
