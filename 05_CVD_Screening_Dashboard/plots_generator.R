# calculation test file 

## 1. Packages and Settings ----

options(scipen    = 999)
options(max.print = 5000)
options(tibble.width = Inf)

if(!require("pacman")) install.packages("pacman")

pacman::p_load(
  tidyverse, lubridate, janitor, ggplot2
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

# duration plot 
svy_duration <- df$svy_duration[df$svy_duration  < 300 & df$ck_cal_eligible == 1]
mean_val <- mean(svy_duration, na.rm = TRUE)
median_val <- median(svy_duration, na.rm = TRUE)
q1_val <- quantile(svy_duration, probs = 0.25, na.rm = TRUE)
q3_val <- quantile(svy_duration, probs = 0.75, na.rm = TRUE)


df %>%
  filter(svy_duration  < 300 & ck_cal_eligible == 1) %>%
  ggplot(aes(svy_duration)) +
  geom_histogram(binwidth = 5, fill = "lightblue", color = "black") +
  geom_vline(xintercept = mean_val, color = "red", linetype = "dashed") +
  geom_vline(xintercept = median_val, color = "green", linetype = "dashed") +
  geom_vline(xintercept = q1_val, color = "blue", linetype = "dashed") +
  geom_vline(xintercept = q3_val, color = "purple", linetype = "dashed") +
  labs(title = "Survey Duration Distribution",
       x = "Duration (minutes)",
       y = "Frequency") +
  theme_minimal() +
  annotate("text", x = mean_val, y = 10, label = paste("Mean =", round(mean_val, 2)), vjust = -1, size = 4, color = "red") +
  annotate("text", x = median_val, y = 15, label = paste("Median =", round(median_val, 2)), vjust = -1, size = 4, color = "green") +
  annotate("text", x = q1_val, y = 20, label = paste("Q1 =", round(q1_val, 2)), vjust = -1, size = 4, color = "blue") +
  annotate("text", x = q3_val, y = 25, label = paste("Q3 =", round(q3_val, 2)), vjust = -1, size = 4, color = "purple")
  
# duration by case type 
df %>%
  filter(svy_duration  < 300 & ck_cal_eligible == 1) %>%
  mutate(mhist_drug_noall = ifelse(mhist_drug_noall == 1, "No Medication Questions", "At least one type medication question")) %>%
  ggplot(aes(mhist_drug_noall, svy_duration, fill = mhist_drug_noall)) + 
  geom_boxplot() +
  labs(x = "No Medication History Question", y = "Survey Duration") +
  stat_summary(geom = "text", fun.y = quantile,
               aes(label=sprintf("%1.1f", ..y..)),
               position=position_nudge(x=0.4), size=3.5) +
  theme(legend.position="none")

df %>%
  filter(svy_duration  < 300 & ck_cal_eligible == 1) %>%
  ggplot(aes(mhist_drug_nocount, svy_duration, fill = factor(mhist_drug_nocount))) + 
  geom_boxplot() +
  labs(x = "Number of medication history question not administered", y = "Survey Duration") +
  stat_summary(geom = "text", fun.y = quantile,
               aes(label=sprintf("%1.1f", ..y..)),
               position=position_nudge(x=0.4), size=3.5) +
  theme(legend.position="none")
