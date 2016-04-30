##  Merge the training and the test sets to create one data set.

##  Read data from the files.
features = read.table('./features.txt',header=FALSE);
activity_labels = read.table('./activity_labels.txt',header=FALSE);
subject_train = read.table('./train/subject_train.txt',header=FALSE);
x_train = read.table('./train/x_train.txt',header=FALSE);
y_train = read.table('./train/y_train.txt',header=FALSE);

##  Assign column names.
colnames(activity_labels) = c('activity_id','activity_labels');
colnames(subject_train) = "subject_id";
colnames(x_train) = features[,2]; 
colnames(y_train) = "activity_id";

##  Merge training and test sets to create one data set.
training_master = cbind(y_train,subject_train,x_train);

##  Read test data.
subject_test = read.table('./test/subject_test.txt',header=FALSE);
x_test = read.table('./test/x_test.txt',header=FALSE);
y_test = read.table('./test/y_test.txt',header=FALSE);

##  Assign column names.
colnames(subject_test) = "subject_id";
colnames(x_test) = features[,2]; 
colnames(y_test) = "activity_id";

##  Create final test set.
test_data = cbind(y_test,subject_test,x_test);

## Combine training and test data to create a master data set.
master_data = rbind(training_master,test_data);

##  Create a vector for the column names from master_data, which will be used
##  to select the mean & stddev columns.
col_Names  = colnames(master_data); 

##  Extract only the measurements on the mean and standard deviation for each measurement. 

##  Create a Vector that contains TRUE values for the ID, mean and stddev columns and FALSE for others.
extractvector = (grepl("activity..",col_Names) | grepl("subject..",col_Names) | grepl("-mean..",col_Names) & !grepl("-meanFreq..",col_Names) & !grepl("mean..-",col_Names) | grepl("-std..",col_Names) & !grepl("-std()..-",col_Names));
master_data = master_data[extractvector==TRUE];

##  Use descriptive activity names to name the activities in the data set.

##  Merge master_data with the acitivityType table to include descriptive activity names.
master_data = merge(master_data,activity_labels,by='activity_id',all.x=TRUE);

##  Update the col_Names vector to include the new column labels.
col_Names  = colnames(master_data); 

##  Label the data set with descriptive activity names.
for (i in 1:length(col_Names)) 
{
        col_Names[i] = gsub("\\()","",col_Names[i])
        col_Names[i] = gsub("-std$","StdDev",col_Names[i])
        col_Names[i] = gsub("-mean","Mean",col_Names[i])
        col_Names[i] = gsub("^(t)","Time",col_Names[i])
        col_Names[i] = gsub("^(f)","Freq",col_Names[i])
        col_Names[i] = gsub("([Gg]ravity)","Gravity",col_Names[i])
        col_Names[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",col_Names[i])
        col_Names[i] = gsub("[Gg]yro","Gyro",col_Names[i])
        col_Names[i] = gsub("AccMag","Acc_Magnitude",col_Names[i])
        col_Names[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerk_Magnitude",col_Names[i])
        col_Names[i] = gsub("JerkMag","Jerk_Magnitude",col_Names[i])
        col_Names[i] = gsub("GyroMag","Gyro_Magnitude",col_Names[i])
};

colnames(master_data) = col_Names;

##  Create a second, independent tidy data set with the average of each variable for each activity and each subject. 

masterdata_non = master_data[,names(master_data) != 'activity_labels'];
tidy_data = aggregate(masterdata_non[,names(masterdata_non) != c('activity_id','subject_id')],by=list(activity_id=masterdata_non$activity_id,subject_id = masterdata_non$subject_id),mean);
tidy_data = merge(tidy_data,activity_labels,by='activity_id',all.x=TRUE);

##  Write the tidy_data set. 
write.table(tidy_data, './tidy_data.txt',row.names=TRUE,sep='\t')