## Load packages
library(dplyr)


### Preparing the data
# Download and store data
if(!file.exists("./data")){dir.create("./data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./data/originalData.zip", method = "curl")

# Unzip data file
unzip("./data/originalData.zip")

# Read .txt data into tables
# main data
features <- read.table("UCI HAR Dataset/features.txt")
activityLabel <- read.table("UCI HAR Dataset/activity_labels.txt")

# test data
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
XTest <- read.table("UCI HAR Dataset/test/X_test.txt")   # Test set
YTest <- read.table("UCI HAR Dataset/test/Y_test.txt")   # Test labels

# train data
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
XTrain <- read.table("UCI HAR Dataset/train/X_train.txt")   # Training set
YTrain <- read.table("UCI HAR Dataset/train/Y_train.txt")   # Training labels


### 1. Merging the data sets
# column bind test data and train data
testData <- cbind(subjectTest, YTest, XTest)   # Test: subject, label, data 
trainData <- cbind(subjectTrain, YTrain, XTrain)   # Train: subject, label, data

# row bind the two combined data sets
mergedData <- rbind(testData, trainData)

# suitably rename columns
colnames(mergedData) <- c("subject", "activity",
                          features$V2)


### 2. Extract mean and SD measurements
tidyData <- select(mergedData, subject, activity,
               contains("mean"),
               contains("std"))


### 3. Use descriptive activity names for tidyData activities
activities <- mutate(activityLabel, V2)

# reclass tidyData activity column to factor to be able to rename activities
tidyData$activity <- as.factor(tidyData$activity)

# Assign to data
tidyData$activity <- gsub("1", activities[1,2], tidyData$activity) 
tidyData$activity <- gsub("2", activities[2,2], tidyData$activity)
tidyData$activity <- gsub("3", activities[3,2], tidyData$activity)
tidyData$activity <- gsub("4", activities[4,2], tidyData$activity)
tidyData$activity <- gsub("5", activities[5,2], tidyData$activity)
tidyData$activity <- gsub("6", activities[6,2], tidyData$activity)

# removing 'under-score' in activities
tidyData$activity <- gsub("_", " ", tidyData$activity) %>%
        tolower()   # and then making 'activities' lower-case


### 4. Descriptive labels for the variable names
names(tidyData) <- gsub("tBody", "Time Body: ", names(tidyData))
names(tidyData) <- gsub("fBody", "Frequency Body: ", names(tidyData))
names(tidyData) <- gsub("tGravity", "Time Gravity: ", names(tidyData))
names(tidyData) <- gsub("Acc", "Accelerometer ", names(tidyData))
names(tidyData) <- gsub("Gyro", "Gyroscope ", names(tidyData))
names(tidyData) <- gsub("gravity", "Gravity ", names(tidyData))
names(tidyData) <- gsub("angle", "Angle ", names(tidyData))
names(tidyData) <- gsub("Mag", "Magnitude ", names(tidyData))
names(tidyData) <- gsub("Jerk", "Jerk ", names(tidyData))
names(tidyData) <- gsub("-std", "SD", names(tidyData))
names(tidyData) <- gsub("-mean", "Mean", names(tidyData))
names(tidyData) <- gsub("mean,", "Mean ", names(tidyData))
names(tidyData) <- gsub("meanFreq()", "Mean Frequency()", names(tidyData))
names(tidyData) <- gsub("\\()-X", "(X)", names(tidyData))
names(tidyData) <- gsub("\\()-Y", "(Y)", names(tidyData))
names(tidyData) <- gsub("\\()-Z", "(Z)", names(tidyData))
names(tidyData) <- gsub("X,", "(X)", names(tidyData))
names(tidyData) <- gsub("Y,", "(Y)", names(tidyData))
names(tidyData) <- gsub("Z,", "(Z)", names(tidyData))


### 5. A second independent tidy data set with relevant averages
TidyDataSet <- tidyData %>%
        group_by(subject, activity) %>%
        summarise_all(list(mean))

# check final TidyDataSet
str(TidyDataSet)

# save tidyData2
write.table(TidyDataSet, "TidyDataSet.txt", row.name=FALSE)
