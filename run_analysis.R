############
# JHDS03 - Getting and cleaning data
#
# Course Project
#
# Goals...
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 



#############
# FILE CONTENTS, FROM THE README...

#- 'features_info.txt': Shows information about the variables used on the feature vector.
#- 'features.txt': List of all features.
#- 'activity_labels.txt': Links the class labels with their activity name.
#- 'train/X_train.txt': Training set.
#- 'train/y_train.txt': Training labels.
#- 'test/X_test.txt': Test set.
#- 'test/y_test.txt': Test labels.


# required libraries
library(plyr)   # for join, arrange
library(utils)  # for read.table, write.table
library(stats)  # for aggregate


# FOR TESTING, HARDCODE STARTING DIRECTORY
#setwd("/Users/peter.nelson/Documents/Coursera/jhds-03-getdata/week3/jhds03_repo")


##############
# 1. Merges the training and the test sets to create one data set.

# variables...
main_directory <- getwd()
data_directory <- paste(main_directory, "/UCI HAR Dataset", sep="")
output_file <- paste(main_directory, "/subset_means_by_subject_and_activitity.txt", sep="")

#set working directory to data dir
setwd(data_directory)

# read the feature names (to be used as column headers)
featuresDF <- read.table("./features.txt", col.names=c("column_number", "column_name"))

# convert invalid columnname characters into nice periods
featuresDF$column_name <- gsub("()-", ".", featuresDF$column_name, fixed=TRUE)
featuresDF$column_name <- gsub("()" , ".", featuresDF$column_name, fixed=TRUE)
featuresDF$column_name <- gsub("-"  , ".", featuresDF$column_name, fixed=TRUE)

# read the activities (more informative text than just the integer)
activitiesDF <- read.table("./activity_labels.txt", col.names=c("y", "activity"))

# read the test-set data
test_subject_DF <- read.table("./test/subject_test.txt", col.names=c("subject"), colClasses=c("integer")) # if I use col.classes=c("factor") here it sets levels based on string order
test_y_DF <- read.table("./test/y_test.txt", col.names=c("y"), colClasses=c("integer"))
test_y_DF <- join(x=test_y_DF, y=activitiesDF, by="y") # and join activity leves to them
test_x_DF <- read.table("./test/X_test.txt", col.names=featuresDF[, 2]) # read the test-set text file for X values
test_DF <- cbind(test_subject_DF, test_y_DF, test_x_DF) # combine subject, y/activity, and all x-values into a single test dataframe

# similarly read the training-set data
train_subject_DF <- read.table("./train/subject_train.txt", col.names=c("subject"), colClasses=c("integer"))
train_y_DF <- read.table("./train/y_train.txt", col.names=c("y"), colClasses=c("integer"))
train_y_DF <- join(x=train_y_DF, y=activitiesDF, by="y")
train_x_DF <- read.table("./train/X_train.txt", col.names=featuresDF[, 2])
train_DF <- cbind(train_subject_DF, train_y_DF, train_x_DF)

# combine test and training datasets into one full dataset, dimensions are 10299x564
# that's the original 561 columns, plus: subject, y, activity
full_dataset <- rbind(test_DF, train_DF)

# fix the 'subject' and 'y' columns, make them a factor instead of an int.
# don't do this using read.table's colclasses argument because that gives
# the same levels to different values in each dataset, and merging them
# becomes problematic. rather, keep those columns as int until the sets are
# merged.
full_dataset$y <- as.factor(full_dataset$y)
full_dataset$subject <- as.factor(full_dataset$subject)

# get index of which column names contain mean, or std, plus indexes to the subject/y/activity columns
subject_column <- colnames(full_dataset) == "subject"
y_column <- colnames(full_dataset) == "y"
activity_column <- colnames(full_dataset) == "activity"
mean_columns <- grepl("mean", colnames(full_dataset))  # grepl returns a logical vector, very nice
std_columns <- grepl("std", colnames(full_dataset))

# doing some fancy boolean logic here, to get all the desired columns in a single logical vector
desired_columns <- subject_column | y_column | activity_column | mean_columns | std_columns

# build a new dataframe of just the desired columns, dimensions are 10299x82 which is correct.
meanstd_subset <- full_dataset[, desired_columns]

# make a nice summary by subject and activity. note that summarizing by both y and activity
# does not create extra groupings, as they are always joined in a one-to-one relationship.
# however, leaving the 'activity' column name specified keeps that column from being
# used in the 'mean' function. resulting dimensions are 180x82, which is correct.
summary_DF <- aggregate(. ~ subject + y + activity, data=meanstd_subset, FUN=mean)
summary_DF <- arrange(summary_DF, subject, y)  # arrange in nice, sorted order

# Finally, save the summary_DF as its own csv
# set working directory to the main directory (it's been in the data directory this whole time)
if (file.exists(output_file)) { file.remove(output_file) } # removing old output, to help in debugging, 
write.table(summary_DF, output_file, row.names=FALSE)
