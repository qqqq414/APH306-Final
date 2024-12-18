# Load required libraries
library(readxl)
library(dplyr)
library(ggplot2)
library(reshape2)
library(patchwork)

# Load Excel data
file_path <- "/Users/swifty/Desktop/Database for Final Report Task part2.xlsx"
data <- read_excel(file_path, col_names = TRUE)

# Data cleaning and type conversion
data <- data %>%
  mutate(
    Group = as.factor(Group),
    No = as.factor(`No.`),
    Sex = as.factor(Sex),
    Smoking = as.factor(Smoking),
    Alcohol_drinking = as.factor(`alchol drinking`),
    Regular_exercise_habit = as.factor(`Regular exercise habit`),
    Age = as.numeric(Age),
    Height = as.numeric(Height),
    Body_weight = as.numeric(`Body weight`),
    BMI = as.numeric(BMI),
    Sedentary_time = as.numeric(`Sedentary time`),
    TUGT_Pre = as.numeric(`TUGT-Pre`),
    TUGT_Post = as.numeric(`TUGT-Post`),
    KEMS_Pre = as.numeric(`KEMS-Pre`),
    KEMS_Post = as.numeric(`KEMS -Post`),
    MWD_Pre = as.numeric(`6MWD-Pre`),
    MWD_Post = as.numeric(`6MWD-Post`)
  )

# Handle missing values and limit categorical variables
fill_na_with_median <- function(x) {
  ifelse(is.na(x), median(x, na.rm = TRUE), x)
}

limit_categorical <- function(x, valid_values = c(1, 2)) {
  ifelse(x %in% valid_values, x, NA)
}

data <- data %>%
  mutate(
    Sex = limit_categorical(as.numeric(Sex)),
    Alcohol_drinking = limit_categorical(as.numeric(`alchol drinking`)),
    Smoking = limit_categorical(as.numeric(Smoking)),
    Regular_exercise_habit = limit_categorical(as.numeric(`Regular exercise habit`)),
    Age = fill_na_with_median(Age),
    Height = fill_na_with_median(Height),
    Body_weight = fill_na_with_median(Body_weight),
    BMI = fill_na_with_median(BMI),
    Sedentary_time = fill_na_with_median(Sedentary_time),
    TUGT_Pre = fill_na_with_median(TUGT_Pre),
    TUGT_Post = fill_na_with_median(TUGT_Post),
    KEMS_Pre = fill_na_with_median(KEMS_Pre),
    KEMS_Post = fill_na_with_median(KEMS_Post),
    MWD_Pre = fill_na_with_median(MWD_Pre),
    MWD_Post = fill_na_with_median(MWD_Post)
  )

# Generate unique ID variable and reorganize data
data <- data %>%
  mutate(Group_No = paste(Group, `No.`, sep = "_")) %>%
  select(-Group, -`No.`) %>%
  mutate(Group = sub("_.*", "", Group_No))

# Descriptive statistics by group
descriptive_stats <- data %>%
  group_by(Group) %>%
  summarise(
    Age_mean = mean(Age, na.rm = TRUE),
    Age_sd = sd(Age, na.rm = TRUE),
    BMI_mean = mean(BMI, na.rm = TRUE),
    BMI_sd = sd(BMI, na.rm = TRUE),
    Sedentary_time_mean = mean(Sedentary_time, na.rm = TRUE),
    Sedentary_time_sd = sd(Sedentary_time, na.rm = TRUE),
    Smoking_prop = mean(as.numeric(Smoking == 1), na.rm = TRUE) * 100,
    Alcohol_drinking_prop = mean(as.numeric(Alcohol_drinking == 1), na.rm = TRUE) * 100,
    TUGT_Pre_mean = mean(TUGT_Pre, na.rm = TRUE),
    TUGT_Post_mean = mean(TUGT_Post, na.rm = TRUE),
    KEMS_Pre_mean = mean(KEMS_Pre, na.rm = TRUE),
    KEMS_Post_mean = mean(KEMS_Post, na.rm = TRUE),
    MWD_Pre_mean = mean(MWD_Pre, na.rm = TRUE),
    MWD_Post_mean = mean(MWD_Post, na.rm = TRUE)
  )
print(descriptive_stats)

# Compute change scores
data <- data %>%
  mutate(
    TUGT_Change = TUGT_Post - TUGT_Pre,
    KEMS_Change = KEMS_Post - KEMS_Pre,
    MWD_Change = MWD_Post - MWD_Pre
  )

# Correlation matrix for change scores
numeric_data <- data %>% select(TUGT_Change, KEMS_Change, MWD_Change)
cor_matrix <- round(cor(numeric_data, use = "pairwise.complete.obs"), 2)
melted_cor_matrix <- melt(cor_matrix)

# Plot correlation heatmap
ggplot(data = melted_cor_matrix, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "#67a9cf", high = "#ef8a62", mid = "#f7f7f7", midpoint = 0, name = "Correlation") +
  geom_text(aes(label = value), color = "black", size = 4) +
  theme_minimal() +
  labs(title = "Correlation Matrix of Change Scores", x = "", y = "")

# Visualize change scores by group using boxplots
plot_A <- ggplot(data, aes(x = Group, y = TUGT_Change, fill = Group)) +
  geom_boxplot() +
  labs(title = "TUGT Change by Group", x = "Group", y = "TUGT Change") +
  theme_minimal()

plot_B <- ggplot(data, aes(x = Group, y = KEMS_Change, fill = Group)) +
  geom_boxplot() +
  labs(title = "KEMS Change by Group", x = "Group", y = "KEMS Change (kg)") +
  theme_minimal()

plot_C <- ggplot(data, aes(x = Group, y = MWD_Change, fill = Group)) +
  geom_boxplot() +
  labs(title = "MWD Change by Group", x = "Group", y = "MWD Change (m)") +
  theme_minimal()

# Combine boxplots
combined_plot <- (plot_A + plot_B + plot_C) + plot_annotation(tag_levels = 'A')
print(combined_plot)