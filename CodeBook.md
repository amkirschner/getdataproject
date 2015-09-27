CodeBook for Getting and Cleaning Data - Course Project
======

## Project Description
Data used by this analysis comes from accelerometer and gyroscope 3-axial raw signals recorded via Samsung Galaxy S II smartphones worn by 30 subjects performing a number of activities. 

For a fuller understanding of the original dataset, please see `features_info.txt` in the referenced data.

- Source: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
- Description: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones


## Raw Data Collection
Per the README.txt file available from above source:

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

## About the test/train data files
The test and train data sets each contain three separate text files.

1. X_(test|train) - Rows contain feature measurements.
2. y_(test|train) - Contain activity IDs corresponding to each row in X tables; readable values of representing activities are stored in `activity_labels,txt` file.
3. subject_(test|train) - Contain identifier for subject of each measurement/activity in the X and y files.

##Data Loading, Transformation, and Output

###Step 1 - Merge the test/training data to create single data set
1. Data from each test/training file is loaded to individual data frames. Column headers for the y and subject data frames are changed to activityLabel and subjectId, respectively, for readability.
    + X_(test|train) -> df_(test|train)_X
    + y_(test|train) -> df_(test|train)_y
    + subject_(test|train) -> df_(test|train)_subject
2. Data frames for test are combined  using `bind_cols()` into df_test_all, followed by same action for train files into df_train_all.
3. df_test_all and df_train_all are  combined into df_combined using `bind_rows()`.

###Step 2 - Extract mean/standard deviation variables only
1. Features are loaded from `features.txt` into data frame df_features, filtering for those that contain the mean or std using the combined `filter()` and `grep1()` commands.
2. `mutate()` is used to rename values  in first column so they match the variable names in the combined data frame.
3. Vector is created from df_features using `select()` and `collect()` that contains  only mean/standard deviation related variables. subjectId and activityLabel are added to beginning of vector to allow for 1-to-1 match when doing select on df_combined.
4. `select` command is used to extract relevant columns from df_combined; results are  written to new data frame df_combined_select.

###Step 3 - Change activity names to descriptive values
1. `activity_labels.txt` is loaded into df_activity_labels. Columns are renamed ID and activity for match function usage.
2. activityLabel factor in df_combined_select is renamed using `match()` between df_activity_labels\$ID and the df_combined_select\$activityLabel.

###Step 4 - Label variables with descriptive variable names
1. Vector is created containing from df_features using `select()` and `collect()` that contains  only mean/standard deviation related variables. subjectId and activityLabel are added to beginning of vector so they will be placed correctly when df_combined_select's column names are updated.
2. Vector values are written to `colnames(df_combined_select)`.
3. `gsub()` is used to improve readability of variable names.
```
    names(df_combined_select)<-gsub("^t", "time", names(df_combined_select))
    names(df_combined_select)<-gsub("^f", "frequency", names(df_combined_select))
    names(df_combined_select)<-gsub("Acc", "Accelerometer", names(df_combined_select))
    names(df_combined_select)<-gsub("Gyro", "Gyroscope", names(df_combined_select))
    names(df_combined_select)<-gsub("Mag", "Magnitude", names(df_combined_select))
    names(df_combined_select)<-gsub("BodyBody", "Body", names(df_combined_select))
    names(df_combined_select)<-gsub("\\(\\)", "", names(df_combined_select))
```

###Step 5 - Group data, get mean for each variable, and  output to file
1. `group_by(subjectId,activityLabel)` is used on df_combined_select.
2. Above is piped to `summarize_each(funs(mean))` to determine  mean of each function when grouped by subject and activity, which is  then written to new data frame df_combined_means.
3. `write.table()` generates meansBySubjectAndActivity.txt` in working directory.



##Description of tidy data set

Tidy data set is 180 rows by 68 columns,  each row containing:

  * subjectId - Numeric ID representing an individual subject
  * activityLabel - one of six activities performed  by each subject; valid activities are:
    + WALKING
    + WALKING_UPSTAIRS
    + WALKING_DOWNSTAIRS
    + SITTING
    + STANDING
    + LAYING
  * 66 variables (Numeric) measuring representing the overall average of either the mean (variable names containing mean) or standard deviation (variable names containg std) for the specified time domain signal or frequency domain signal when grouped by subjectId and activityLabel. Variables ending with "-XYZ" represent 3-axial signals in the X, Y and Z directions.
  + Explanation of features can be found in `features_info.txt` from source. Names in tidy data set have been expanded per Step 4 above and parentheses have been removed for clarity.

