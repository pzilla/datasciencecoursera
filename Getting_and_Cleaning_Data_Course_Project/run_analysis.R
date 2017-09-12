library(tidyr)
library(dplyr)

dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
localFile <- "project_dataset.zip"

# Check if .zip file already exists locally
if (!file.exists(localFile)){
    download.file(dataURL, localFile, method="curl")
} 

# Unzip local .zip file
unzip(localFile) 

# Read in all datasets
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)
features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)

# Set features (columns) to read in for Training and Test datasets
features <- features[grep("(*mean\\(\\)*)|(*std\\(\\)*)", features$V2), ]

# Continue reading in datasets
training_set <- read.table("UCI HAR Dataset/train/X_train.txt", stringsAsFactors = FALSE)[features$V1]
training_labels <- data.table(read.table("UCI HAR Dataset/train/y_train.txt"), stringsAsFactors = FALSE)
training_subject <- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactors = FALSE)
test_set <- read.table("UCI HAR Dataset/test/X_test.txt", stringsAsFactors = FALSE)[features$V1]
test_labels <- read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactors = FALSE)
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactors = FALSE)

# Combine Training data and Test data
training_data <- bind_cols(training_subject, training_labels, training_set)
test_data <- bind_cols(test_subject, test_labels, test_set)
result_data <- bind_rows(training_data, test_data)

# Update column names to be meaningful names from features dataset
colnames(result_data) <- c("subject", "activity", features$V2)

# Update activity column to show meaningful names from activity_labels dataset
result_data$activity <- activity_labels[match(result_data$activity, activity_labels$V1), 2]

# Create new dataset which calculates mean for all columns
result_data.means <- result_data %>% group_by(subject, activity) %>% summarise_all(mean)

rm(test_data, test_labels, test_set, test_subject, training_data, training_labels, training_set, training_subject, activity_labels, features)
