# Load necessary packages
library(dplyr)
library(tidyr)
library(data.table)
# Step 1 - Merge training and test data sets
  #load test data
    df_test_X <- read.table("./UCI HAR Dataset/test/X_test.txt", quote="\"", comment.char="")
    df_test_y <- read.table("./UCI HAR Dataset/test/y_test.txt", quote="\"", comment.char="")
    df_test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt", quote="\"", comment.char="")
  #rename subject and activity label columns
    df_test_y<-rename(df_test_y,activityLabel=V1)
    df_test_subject<- rename(df_test_subject,subjectId=V1)
  #load training data
    df_train_X <- read.table("./UCI HAR Dataset/train/X_train.txt", quote="\"", comment.char="")
    df_train_y <- read.table("./UCI HAR Dataset/train/y_train.txt", quote="\"", comment.char="")
    df_train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt", quote="\"", comment.char="")
  #rename subject and activity label columns
    df_train_y<-rename(df_train_y,activityLabel=V1)
    df_train_subject<- rename(df_train_subject,subjectId=V1)
  
  #merge test data
    df_test_all <- bind_cols(df_test_subject,df_test_y,df_test_X)
  #merge training data
    df_train_all <- bind_cols(df_train_subject,df_train_y,df_train_X)
  #combine test and training data
    df_combined <-bind_rows(df_test_all,df_train_all)
  

#Step 2 - Extract mean/standard deviation variables only
  #load features filtering for those that contain the mean or std
    df_features <- tbl_df(read.table("./UCI HAR Dataset/features.txt", quote="\"", comment.char="",stringsAsFactors = FALSE)) %>%
    filter(grepl('mean\\(\\)|std\\(\\)',V2)) %>%
  #and rename V1 values to match column headers from X tables
    mutate(V1=paste0("V",V1))
  #create vector to limit variables chosen from X tables
    v_features_id <- df_features %>% select(V1) %>% collect %>% .[["V1"]]
  #add subjectId and activityLabel values to v_features_id list
    v_features_id <- append(c("subjectId","activityLabel"),v_features_id)
  #select only the columns we want from the combined data and create new data frame
    df_combined_select <-select(df_combined,one_of(v_features_id))
   
#Step 3 - Set descriptive activityLabel values
    #load df_activity_labels and rename values to something readable
      df_activity_labels <- tbl_df(read.table("./UCI HAR Dataset/activity_labels.txt", quote="\"", comment.char=""))
      df_activity_labels <- rename(df_activity_labels,ID=V1,activity=V2)
    #change activityLabel values in combined data to show actual labels
      df_combined_select$activityLabel<-df_activity_labels$activity[match(df_combined_select$activityLabel,df_activity_labels$ID)]
      
#Step 4 - Replace variable names with abbreviated version of features
    #create vector with column names
      v_features_name <- df_features %>% select(V2) %>% collect %>% .[["V2"]]
    #add subjectId and activityLabel values to v_features_name list and convert values to names
      v_features_name<- make.names(append(c("subjectId","activityLabel"),v_features_name))
    #write values to column names
      colnames(df_combined_select) <- v_features_name
    #group observations by subjectId and activityLabel and then summarize each by mean
      df_combined_means <- df_combined_select %>%
        group_by(subjectId,activityLabel) %>%
        summarize_each(funs(mean))

#Step 5 - #write tidy data to txt file
    write.table(df_combined_means,file="meansBySubjectAndActivity.txt",row.names=FALSE)