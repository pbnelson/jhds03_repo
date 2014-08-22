#Course project for Coursera "Getting and Cleaning Data"    


###Instructions before use, prepration...

Download and extract the contents of the following archive to the folder where
this README.md file and the run_analysis.R script are stored.

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

To be specific, there should be a subdirectory in this directory having
the name "UCI HAR Dataset", and under it should be subdirectories 
"test" and "train", with their respective contents.

### Instructions for use
Change directory to that which contains this script.

execute the run_analysis.R program

### Output

The script takes about 30 seconds to run, and produces a tidy data file,
in this directory, called "subset_means_by_subject_and_activitity.txt"



### Explanation of Transformation ###

Detailed comments are embedded in run_analysis.R. Here is an overview of the
steps followed.

1. Read feature names from features.txt
2. Read activites names from activity_labels.txt
3. Read the test-set subject data
4. Read the test-set X-data, using feature names for column headers
5. Read the test-set Y-data, and join activity names
6. Combine Subject, Y, Activity and all X-features into single test-set dataframe
7. Repeat above steps for training-set
8. Combine both test-set and training-set into a single dataframe
9. Remove all X-feature columns not containing text 'mean' or 'std'
10. Summarize all remaining columns by subject and activity
11. Save the resulting dataframe as subset_means_by_subject_and_activitity.txt
