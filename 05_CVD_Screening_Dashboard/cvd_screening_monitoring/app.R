################################################################################

## 1. Packages and Settings ----

options(scipen    = 999)
options(max.print = 5000)
options(tibble.width = Inf)

if(!require("pacman")) install.packages("pacman")

pacman::p_load(
  tidyverse, lubridate, janitor, shiny, shinydashboard, rsconnect
)

# The below gets rid of package function conflicts

filter    <- dplyr::filter
select    <- dplyr::select
summarize <- dplyr::summarize

################################################################################

## DATASET PREPARETION 

df <- read.csv("community_screening.csv") 


df <- df %>%
  rename(
    "Data Collection Date" = "svy_date", 
    "township" = "demo_town", 
    "Data Collector ID" = "enu_name"
  )

grouplist <- c("Data Collection Date", 
               "township", 
               "Data Collector ID")

varlist <- df %>%
  names()

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
      # second tab content 
      tabItem(tabName = "sumstat", 
              fluidRow(
                column(width = 4, 
                       align = "left",
                       selectInput("outcome1", "select the interested variable",
                                   choices = varlist))
              ), 
              fluidRow(
                box(tableOutput("sumstat_table"))
              )
      ), 
      # Third tab content 
      tabItem(tabName = "crosstab", 
              fluidRow(
                column(width = 4, 
                       align = "left",
                       selectInput("outcome2", "select the first interested variable",
                                   choices = varlist)),
                column(width = 4, 
                       align = "left", 
                       selectInput("outcome3", "select the second interested variable", 
                                   choices = varlist)), 
              ), 
              fluidRow(
                box(tableOutput("crosstab_table"))
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
      select(input$group, svy_complete, confirm_share, confirm_visit, svy_early, svy_late, svy_duration_mean) %>%
      as.data.frame()  # Convert to data frame
  })
  
  # For Summary Statistics
  output$sumstat_table = renderTable({
    tabyl(df, .data[[input$outcome1]])
  })
  
  # For Cross-tab
  output$crosstab_table = renderTable({
    tabyl(df, .data[[input$outcome2]], .data[[input$outcome3]])
  })
  
  
  # # For progress monitoring
  # output$progress_table = renderTable({
  #   df %>%
  #     group_by(input$group) %>%
  #     summarize(svy_complete = sum(svy_complete), 
  #               confirm_visit = sum(ck_cal_confirm_visit), 
  #               svy_early = sum(svy_early), 
  #               svy_late = sum(svy_late),
  #               svy_duration_mean = mean(svy_duration)) %>%
  #     ungroup() %>%
  #     mutate(confirm_share = confirm_visit / svy_complete * 100) %>%
  #     select(input$group, svy_complete, confirm_share, confirm_visit, svy_early, svy_late, svy_duration_mean) %>%
  #     as.data.frame()  # Convert to data frame
  # })
  # 
  # # For Summary Statistics
  # output$sumstat_table = renderTable({
  #   tabyl(df, all_of(input$outcome1))
  # })
  # 
  # # For Cross-tab
  # output$crosstab_table = renderTable({
  #   
  #   tabyl(df, 
  #         input$outcome2, 
  #         input$outcome3)
  # })
}


# Run the application 
shinyApp(ui = ui, server = server)
