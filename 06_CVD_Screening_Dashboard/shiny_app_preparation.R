# calculation test file 

## 1. Packages and Settings ----

options(scipen    = 999)
options(max.print = 5000)
options(tibble.width = Inf)

if(!require("pacman")) install.packages("pacman")

pacman::p_load(
  tidyverse, lubridate, janitor
)

# The below gets rid of package function conflicts

filter    <- dplyr::filter
select    <- dplyr::select
summarize <- dplyr::summarize

################################################################################

## 2. Set root ----

# here::here()
here::i_am("cvd_project.Rproj")

# input data 
com_screening <- here::here("05_CVD_Screening_Dashboard", "community_screening.csv")

################################################################################

df <- read.csv(com_screening)

df_select <- df %>%
  select(svy_date, demo_town, ck_cal_confirm_visit, svy_complete, svy_duration, svy_early, svy_late)

frequency_table <- df_select %>%
  group_by(demo_town) %>%
  summarize(count = n()) %>%
  ungroup() %>%
  mutate(percent = count / sum(count) * 100)



df_select %>%
  group_by(svy_date) %>%
  summarize(svy_complete = sum(svy_complete), 
            confirm_visit = sum(ck_cal_confirm_visit), 
            svy_early = sum(svy_early), 
            svy_late = sum(svy_late),
            svy_duration_mean = mean(svy_duration)) %>%
  ungroup() %>%
  mutate(confirm_share = confirm_visit / svy_complete * 100) %>%
  select(svy_date, svy_complete, confirm_share, confirm_visit, svy_early, svy_late, svy_duration_mean)



df %>% tabyl(tobacco, demo_town)
df %>% tabyl(tobacco, mhist_hypertension)
