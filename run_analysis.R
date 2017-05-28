# DATA PREPARATION 1: GET THE DATA

# Check if the ./data directory exists and create it if not
if(!file.exists("./data")){dir.create("./data")}

# Download the data
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="auto")

# Unizip the Zip File
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# DATA PREPARATION 2: READ THE DATA FROM THE TARGETED FILES

# Get the list of files on the selected path named as Custom_Path 
Custom_Path <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(Custom_Path, recursive=TRUE)

# Let's read all the files and assign them to a data.frame
Activity_Test <- read.table(file.path(Custom_Path, "test" , "Y_test.txt" ),header = FALSE)
Activity_Train <- read.table(file.path(Custom_Path, "train", "Y_train.txt"),header = FALSE)

Subject_Train <- read.table(file.path(Custom_Path, "train", "subject_train.txt"),header = FALSE)
Subject_Test <- read.table(file.path(Custom_Path, "test" , "subject_test.txt"),header = FALSE)

Features_Test <- read.table(file.path(Custom_Path, "test" , "X_test.txt" ),header = FALSE)
Features_Train <- read.table(file.path(Custom_Path, "train", "X_train.txt"),header = FALSE)

# ACTION ITEM 1: MERGES THE TRAINING AND THE TEST SETS TO CREATE ONE DATA SET

# Step 1: Join Training & Test data by rows
Subject <- rbind(Subject_Train, Subject_Test)
Activity <- rbind(Activity_Train, Activity_Test)
Features <- rbind(Features_Train, Features_Test)

# Step 2: Set names to variables
names(Subject) <-c("subject")
names(Activity) <- c("activity")
Features_Names <- read.table(file.path(Custom_Path, "features.txt"), head=FALSE) 
names(Features)<- Features_Names$V2

# Step 3: Merge all data in a single data.frame: All_Data
All_Data <- cbind(Features, Subject, Activity) # Now it is a data.frame of 10299 obs of 563 variables

# ACTION ITEM 2: EXTRACTS ONLY THE MEASUREMENTS ON THE MEAN AND THE STANDARD DEVIATION FOR EACH MEASUREMENT

# Step 1: Get all the variable names that includes "mean" or "std" on their names
Sub_Features_Names <-Features_Names$V2[grep("mean\\(\\)|std\\(\\)", Features_Names$V2)]

# Step 2: Add those that have "subject" or "activity" and subset the All_Data data.frame
selectedNames <- c(as.character(Sub_Features_Names), "subject", "activity" )
All_Data <- subset(All_Data,select=selectedNames) # Now it is a data.frame of 10299 obs of 68 variables

# ACTION ITEM 3: USES DESCRIPTIVE ACTIVITY NAMES TO NAME THE ACTIVITIES IN THE DATA SET

Activity_Labels <- read.table(file.path(Custom_Path, "activity_labels.txt"), header = FALSE)

# ACTION ITEM 4: APPROPRIATELY LABELS THE DATA SET WITH DESCRIPTIVE VARIABLE NAMES

# Replace Prefix "t" by "time", prefix "f" by "frequency", "Acc" by "Accelerometer", "Gyro" by "Gyroscope",
# "Mag" by "Magnitude" and "BodyBody" by "Body"

names(All_Data)<-gsub("^t", "time", names(All_Data))
names(All_Data)<-gsub("^f", "frequency", names(All_Data))
names(All_Data)<-gsub("Acc", "Accelerometer", names(All_Data))
names(All_Data)<-gsub("Gyro", "Gyroscope", names(All_Data))
names(All_Data)<-gsub("Mag", "Magnitude", names(All_Data))
names(All_Data)<-gsub("BodyBody", "Body", names(Data))

# ACTION ITEM 5: CREATES A SECOND, INDEPENDENT TIDY DATA SET AND OUTPUT IT

library(dplyr) # Just in case you haven't it already installed

All_Data_2 <- aggregate(. ~subject + activity, All_Data, mean)
All_Data_2 <- All_Data_2[order(All_Data_2$subject, All_Data_2$activity), ]
write.table(All_Data_2, file = "./data/Coursera_Tidy_Data.txt", row.name=FALSE)

