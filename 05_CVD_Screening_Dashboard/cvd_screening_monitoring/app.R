################################################################################

## 1. Packages and Settings ----

options(scipen    = 999)
options(max.print = 5000)
options(tibble.width = Inf)

if(!require("pacman")) install.packages("pacman")

pacman::p_load(
  tidyverse, lubridate, janitor, shiny, shinydashboard, rsconnect, DT
)

# The below gets rid of package function conflicts

filter    <- dplyr::filter
select    <- dplyr::select
summarize <- dplyr::summarize

################################################################################

## DATASET PREPARETION 
# for all dataset work 
df <- read.csv("community_screening.csv") 

# for duplicate check work 
df_dup <- df %>%
  select(study_id, 
         resp_name, resp_age, resp_sex, resp_dad_name, resp_mom_name, 
         svy_date, deviceid, username, 
         demo_town, cal_town, demo_clinic, cal_clinic, demo_vill, cal_vill) 

# for duplicate check work 
df_contvar <- df %>%
  select(resp_age, bp_syst_1, bp_diast_1, bp_syst_rc_1_1, bp_diast_rc_1_1, 
         bp_syst_rc_1_2, bp_diast_rc_1_2, bp_syst_2, bp_diast_2, bp_syst_rc_2_1, 
         bp_diast_rc_2_1, bp_syst_rc_2_2, bp_diast_rc_2_2, bp_syst_3,	bp_diast_3, 
         bp_syst_rc_3_1, bp_diast_rc_3_1, bp_syst_rc_3_2, bp_diast_rc_3_2, 
         weight,	height,	blood_glucose, blood_glucose_rc_cal, bl_glucose_rpt) 

df <- df %>%
  rename(
    "Data Collection Date"        = "svy_date", 
    "township"                    = "demo_town", 
    "Data Collector ID"           = "enu_name"
  )

grouplist <- c("Data Collection Date", 
               "township", 
               "Data Collector ID")

varlist <- df %>%
  names()

dup_var_list <- df_dup %>% names()

cont_var <- df_contvar %>% names()

# "study_id"      = "Study ID", 
# "resp_name"     = "Name",
# "resp_age"      = "Age",
# "resp_sex"      = "Sex", 
# "resp_dad_name" = "Father Name",
# "resp_mom_name" = "Mother Name"


################################################################################
## Shiny environment 
################################################################################


################################################################################
### UI ###
################################################################################

ui <- dashboardPage(
  dashboardHeader(title = "CVD Screening Dashboard"), 
  dashboardSidebar(
    sidebarMenu(
      menuItem("Progress Monitoring", tabName = "progress", icon = icon("dashboard")), 
      menuItem("Duplicate Check", tabName = "duplicate", icon = icon("table")), 
      menuItem("Summary Statistic", tabName = "sumstat", icon = icon("table")), 
      menuItem("Cross-tab", tabName = "crosstab", icon = icon("table"))
    )
    
  ), 
  dashboardBody(
    tabItems(
      
      # first tab content 
      tabItem(tabName = "progress", 
              fluidRow(
                column(width = 4, 
                       align = "left",
                       selectInput("group", "select the grouping variable",
                                   choices = grouplist))
              ), 
              fluidRow(
                box(tableOutput("progress_table"))
              )
      ), 
      # 2nd tab content 
      tabItem(tabName = "duplicate", 
              fluidPage(
                titlePanel("Duplicate Observation Checker"),
                sidebarLayout(
                  sidebarPanel(
                    selectInput("dupvar", "Select Input Variables", 
                                choices = dup_var_list, 
                                multiple = TRUE),
                    downloadButton("downloadData", "Download Data")
                  ),
                  mainPanel(
                    tableOutput("duplicate_table")
                  )
                )
              )
      ), 
      # 3rd tab content 
      tabItem(tabName = "sumstat", 
              fluidPage(
                titlePanel("Sum-stat for continious variable"),
                sidebarLayout(
                  sidebarPanel(
                    selectInput("contvar", "Select Input Variables", 
                                choices = cont_var, 
                                multiple = TRUE)
                    ),
                  mainPanel(
                    dataTableOutput("sumstat_table")
                  )
                )
              )
      ), 
      # 4th tab content 
      tabItem(tabName = "crosstab", 
              fluidRow(
                column(width = 4, 
                       align = "left",
                       selectInput("outcome1", "select the interested variable",
                                   choices = varlist))
              ), 
              fluidRow(
                box(tableOutput("freq_table"))
              ),
              fluidRow(
                column(width = 4, 
                       align = "left",
                       selectInput("outcome2", "select the first interested variable",
                                   choices = varlist)),
                column(width = 4, 
                       align = "left", 
                       selectInput("outcome3", "select the second interested variable", 
                                   choices = varlist)
                       ),
                fluidRow(
                  box(tableOutput("crosstab_table"))
                )
              )
      )
    )
  )
)

################################################################################
### SERVER ###
################################################################################

server <- function(input, output) {
  
  # For progress monitoring
  output$progress_table = renderTable({
    df %>%
      group_by(.data[[input$group]]) %>%
      summarize(svy_complete = sum(svy_complete), 
                confirm_visit = sum(ck_cal_confirm_visit), 
                svy_early = sum(svy_early), 
                svy_late = sum(svy_late),
                svy_duration_mean = mean(svy_duration)) %>%
      ungroup() %>%
      mutate(confirm_share = confirm_visit / svy_complete * 100) %>%
      select(input$group, svy_complete, confirm_share, confirm_visit, 
             svy_early, svy_late, svy_duration_mean) %>%
      rename(
        "Total Survey Completed"                = "svy_complete", 
        "Eligable for Confirmation Visit"       = "confirm_visit",
        "% of Patient for Confirmation Visit"   = "confirm_share",
        "Number of survey started before 7 AM"  = "svy_early",
        "Number of survey started after 6 PM"   = "svy_late",
        "Average Survey Duration"               = "svy_duration_mean"
      ) %>%
      as.data.frame()  # Convert to data frame
  })
  
  # For Duplicate Check
  duplicates <- reactive({
    if (!is.null(input$dupvar) && length(input$dupvar) > 0) {
      selected_vars <- all_of(input$dupvar)
      data_subset <- df_dup[, selected_vars, drop = FALSE]
      return(df_dup[duplicated(data_subset), ])
    } else {
      return(NULL)
    }
  })
  
  output$duplicate_table <- renderDataTable({
    duplicates()
  })
  
  # Function to download the duplicate data as a CSV file
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("duplicates.csv")
    },
    content = function(file) {
      write.csv(duplicates(), file)
    }
  )
  

  
  # For Summary Statistics
  df_sumstat <- reactive({
    if (!is.null(input$contvar) && length(input$contvar) > 0) {
      
      selected_contvars <- all_of(input$contvar)
      
      summary_df <- df %>%
        select(selected_contvars) %>%
        summary() %>% 
        as.data.frame() %>% 
        tidyr::separate(Freq, c("Stat", "Value"), sep = ":") %>% 
        tidyr::pivot_wider(names_from = Stat, values_from = Value) %>%
        rename(
          "Variable name" = "Var2"
        ) %>%
        select(!Var1)
    
      return(summary_df)

    } else {
      return(NULL)
    }
  })
  
  output$sumstat_table <- renderDataTable({
    df_sumstat()
  })
  
  
  # For Cross-tab
  output$freq_table = renderTable({
    tabyl(df, 
          .data[[input$outcome1]])
  })
  
  output$crosstab_table = renderTable({
    tabyl(df, 
          .data[[input$outcome2]], 
          .data[[input$outcome3]])
  })
  
}


# Run the application 
shinyApp(ui = ui, server = server)

