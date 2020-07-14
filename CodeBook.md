### CodeBook for the "Getting and Cleaning Data" Project
Author: Stuart M. Leeds  
Date: July 13 2020  

#### Introduction
This code book sets out the process of cleaning and tidying the original data 
set (found here: [UCI HAR Dataset](https://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)); and indicates the variables and summaries calculated, along with units and 
any other relevant information. The data relates to an experiment[1] carried out 
to measure the activity levels of participants (n= 30) wearing a smartphone on 
their waist, undertaking various activities (n= 6).


#### The process of cleaning and tidying (see run_analysis.R)
__Data preparation__

* After checking the existance of a "./data" file (if none exists, then create 
one),
```
if(!file.exists("./data")){dir.create("./data")}
```
* the data were downloaded from [this link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) 
into the destination data file as, "originalData.zip".
```
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./data/originalData.zip", method = "curl")
```
* The data were then unzipped with `unzip()` in order to read into the RScript.
```
unzip("./data/originalData.zip")
```
* The unzipped folder "UCI HAR Dataset" contained the following data files:
```
- activity_labels.txt: Labels for the activities (n= 6)
- features.txt: Measurement criteria for the experiment (n= 561)
- features_info.txt: Information for the features, variables and additional 
vectors obtained
- README.txt: Original experiment, record and file information

  and two folders:
- test, containing:
   - subject_test.txt: Participant number ID (n= 30)
   - X_test.txt: Test set
   - Y_test.txt: Test labels
- train, containing:
   - subject_train.txt: Participant ID number (n= 30)
   - X_train.txt: Training set
   -Y_train.txt: Training labels
```
* These text files were opened and read in order to understand their content.

* The final stage in preparing the data to be cleaned involved reading the data 
into table format with `read.table()`. The data were assigned to descriptive 
variables for ease of recognition and use through the rest of the tidying 
process:
```
main data
features <- read.table("UCI HAR Dataset/features.txt")
activityLabel <- read.table("UCI HAR Dataset/activity_labels.txt")

test data
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
XTest <- read.table("UCI HAR Dataset/test/X_test.txt")
YTest <- read.table("UCI HAR Dataset/test/Y_test.txt")

train data
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
XTrain <- read.table("UCI HAR Dataset/train/X_train.txt")
YTrain <- read.table("UCI HAR Dataset/train/Y_train.txt")
```

#### Data cleaning and tidying
__1. Merging the data sets__

* Once the data were formatted into data frames, checked with `str()`, the 
related 'test' and 'training' data were combined by column (`cbind()`) and 
assigned to descriptive variables.
```
testData <- cbind(subjectTest, YTest, XTest)
trainData <- cbind(subjectTrain, YTrain, XTrain)
```
* The two new data frames wer combined by `row()` to form the 'mergedData' 
variable:
```
mergedData <- rbind(testData, trainData)
```
* At this point, the original column names were replaced with necessary 
descriptors; and incorporating the names in the features.txt file:
```
colnames(mergedData) <- c("subject", "activity",
                          features$V2)
```
__2. Extract mean and standard deviation measurements__

* A new variable named 'tidyData' was the created to store the mean and std 
information from 'mergedData' using `select()` which returned only the 
observations that contained "mean" and "std"
```
tidyData <- select(mergedData, subject, activity,
               contains("mean"),
               contains("std"))
```
__3. Use descriptive activity names for tidyData activities__

```
Original activity descriptions

  V1                 V2
1  1            WALKING
2  2   WALKING_UPSTAIRS
3  3 WALKING_DOWNSTAIRS
4  4            SITTING
5  5           STANDING
6  6             LAYING
```
* The original descriptive activity names (above) from the 'activityLabel' 
variable, were mutated into a specific variable (activities). In order to 
replace the numerical values, the activity column of 'tidyData' had to be 
reclassed `as.factor()`, afterwhich, the transfer was carried out using `gsub()`:
```
activities <- mutate(activityLabel, V2)

reclass tidyData activity column to factor to be able to rename activities:
tidyData$activity <- as.factor(tidyData$activity)

Assign to data:
tidyData$activity <- gsub("1", activities[1,2], tidyData$activity) 
tidyData$activity <- gsub("2", activities[2,2], tidyData$activity)
tidyData$activity <- gsub("3", activities[3,2], tidyData$activity)
tidyData$activity <- gsub("4", activities[4,2], tidyData$activity)
tidyData$activity <- gsub("5", activities[5,2], tidyData$activity)
tidyData$activity <- gsub("6", activities[6,2], tidyData$activity)

removing 'under-score' in activities:

tidyData$activity <- gsub("_", " ", tidyData$activity) %>%
        tolower()
```
* Additionally, `gsub()` was used to remove the underscore from activities 2 and 
3, and then the descriptions were transformed `tolower()` case characters:
```
New activity descriptions

1            walking
2   walking upstairs
3 walking downstairs
4            sitting
5           standing
6             laying 
```
__4. Descriptive labels for the variable names__

* To expand the original variable names (see 'features.txt' for full list) into
descriptive labels, `gsub()` was used again to fascilitate the process in
`names(tidyData)` to replace abbreviations with full names:
```
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
```
* Below is a few examples of _before_ and _after_ the variable name changes, as 
the full lists are too long to be of use here:
```
1. Before
   a. tBodyAcc-mean()-X
   b. tGravityAccMag-mean()
   c. fBodyAcc-std()-Z
   
2. After
   a. Time Body: Accelerometer Mean(X)
   b. Time Gravity: Accelerometer Magnitude Mean()
   c. Frequency Body: Accelerometer SD(Z)
```
__5. A second independent tidy data set with relevant averages__

* Finally, the tidied data was assigned to "TidyDataSet" by grouping the subject
and activity columns in "tidyData". This grouping was then summarised by
`list(mean)` as `funs()` is depreciated. The "TidyDataSet" was saved as a `.txt`
file:
```
TidyDataSet <- tidyData %>%
        group_by(subject, activity) %>%
        summarise_all(list(mean))

check final TidyDataSet
str(TidyDataSet)

# save final TidyDataSet
write.table(TidyDataSet, "TidyDataSet.txt", row.name=FALSE)
```
#### Reference
[1]Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and 
Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a 
Multiclass Hardware-Friendly Support Vector Machine. International Workshop of 
Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

