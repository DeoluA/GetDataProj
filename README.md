README
===================
Used the following libraries
```r
library(dplyr, quietly=TRUE)
```

Decided to automate the entire download and loading process, to make it machine reproducible
```r
#download the dataset
download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile="getdata-projectfiles-UCI HAR Dataset.zip")
#unzip it
unzip(zipfile="getdata-projectfiles-UCI HAR Dataset.zip",
      exdir = "getdata-projectfiles-UCI HAR Dataset")
```

Load the respective files into dataframes
```r
#labels
labels <- read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/activity_labels.txt",
                     stringsAsFactors = FALSE)
#give the labels names
names(labels)<-c("id","activity")

#features
features <- read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/features.txt")

#X train and test datasets
x_train<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/X_train.txt")
x_test<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/X_test.txt")

#names for the X group are the 2nd column of 'feature'
names(x_train)<-features$V2; names(x_test)<-features$V2

#y train and test datasets
y_train<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/y_train.txt")
y_test<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/y_test.txt")

#the y sets are numbers assigned for the activities undertaken in 'label'
names(y_train)<-"activity";names(y_test)<-"activity"

#subject, accounting for the persons who performed the activities
subject_train<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/subject_train.txt")
subject_test<-read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/subject_test.txt")

#assign name 'subject'
names(subject_train)<-"subject"; names(subject_test)<-"subject"
```

Transform the ```y_test``` and ```y_train``` datasets from numbers to their respective label activities

```r
for (i in 1:nrow(y_train))
{
  y_train$activity[i]<-labels$activity[labels$id==y_train$activity[i]]
}

for (i in 1:nrow(y_test))
{
  y_test$activity[i]<-labels$activity[labels$id==y_test$activity[i]]
}
```

Column-bind ```subject```, ```y``` and ```x``` to obtain a complete dataset

```r
#all train
initial<-cbind(subject_train,y_train,x_train)
#change to a tbl_df
train<-tbl_df(initial)
#all test
initial<-cbind(subject_test,y_test,x_test)
#change to a tbl_df
test<-tbl_df(initial)
```

Finally, merge ```train``` and ```test``` by row-binding to form one complete dataset

```r
data<-rbind(train,test)
```
Observed that some column names were repeated, but didn't matter in the end because the ones we're interested in weren't.

Retrieving the specified 'mean' and 'standard deviation' values

```r
reqcol<-names(data)
#decided to search for 'mean' instead of '-mean',
#because the readMe of original exercise data indicates some means were taken
#but recorded within another 'angle' variable name
m<-grep("*([M,m]ean)",reqcol)
#searching for std values
s<-grep("*-([s,s]td)",reqcol)
#sorting results
mylist<-sort(c(m,s))
```

Selecting only required column indexes, '1' being 'subject' and '2' being 'activity'

```r
data<-data[,c(1,2,mylist)]
```

Grouping the resultant dataset by ```subject``` and ```activity```, in that order.

```r
by_acyr<-data %>% group_by(subject,activity)
```
Resultant dataset, with the mean (average) value of all columns

```r
#when grouped and summarised, resulting dataset is automatically sorted in ascending order
avgValues <- by_acyr %>% summarise_each(funs(mean))
```

A little name editing; prefixing 'Avg' in front of each variable to properly designate

```r
temp<-NULL
for (i in 3:length(names(avgValues)))
{
  #Prefix 'Avg' in front of all variable names
  l<-paste("Avg",names(avgValues)[i], sep="-")
  temp<-c(temp,l)
}
#initially find everywhere 'mean' occurs
m<-grep("*-([M,m]ean)",temp)
#then remove '-mean()' from everywhere
temp<-gsub("-mean()","",temp)
#also, remove 'Avg' precisely where '-mean()' initally occured
temp[m]<-gsub("Avg-","",temp[m])

#initially find everywhere '-std()' occurs
s<-grep("*-([S,s]td)",temp)
#then remove '-std()' from everywhere
temp<-gsub("-std()","",temp)
#also, remove 'Avg' precisely where '-std()' initally occured
temp[s]<-gsub("Avg-","",temp[s])

for (i in 1:length(temp))
{
  #prefix 'avgMean' for '-mean()' values
  temp[m[i]]<-paste("avgMean",temp[m[i]], sep="-")
  #prefix 'avgStd' for '-std()' values
  temp[s[i]]<-paste("avgStd",temp[s[i]], sep="-")
}
#replace variable names with edited ones
names(avgValues)[-c(1,2)]<-temp
```

Some house cleaning

```r
rm(i,initial,x_test,y_test,x_train,y_train,subject_test,subject_train,train,test,
   labels,features,l,temp,m,s,mylist,data,by_acyr,reqcol)
```

View the first few lines of the new, tidy dataset

```r
avgValues
```

```
## Source: local data frame [180 x 88]
## Groups: subject
## 
##    subject           activity avgMean-tBodyAcc()-X avgMean-tBodyAcc()-Y
## 1        1             LAYING            0.2215982         -0.040513953
## 2        1            SITTING            0.2612376         -0.001308288
## 3        1           STANDING            0.2789176         -0.016137590
## 4        1            WALKING            0.2773308         -0.017383819
## 5        1 WALKING_DOWNSTAIRS            0.2891883         -0.009918505
## 6        1   WALKING_UPSTAIRS            0.2554617         -0.023953149
## 7        2             LAYING            0.2813734         -0.018158740
## 8        2            SITTING            0.2770874         -0.015687994
## 9        2           STANDING            0.2779115         -0.018420827
## 10       2            WALKING            0.2764266         -0.018594920
## ..     ...                ...                  ...                  ...
## Variables not shown: avgMean-tBodyAcc()-Z (dbl), avgStd-tBodyAcc()-X
##   (dbl), avgStd-tBodyAcc()-Y (dbl), avgStd-tBodyAcc()-Z (dbl),
##   avgMean-tGravityAcc()-X (dbl), avgMean-tGravityAcc()-Y (dbl),
##   avgMean-tGravityAcc()-Z (dbl), avgStd-tGravityAcc()-X (dbl),
##   avgStd-tGravityAcc()-Y (dbl), avgStd-tGravityAcc()-Z (dbl),
##   avgMean-tBodyAccJerk()-X (dbl), avgMean-tBodyAccJerk()-Y (dbl),
##   avgMean-tBodyAccJerk()-Z (dbl), avgStd-tBodyAccJerk()-X (dbl),
##   avgStd-tBodyAccJerk()-Y (dbl), avgStd-tBodyAccJerk()-Z (dbl),
##   avgMean-tBodyGyro()-X (dbl), avgMean-tBodyGyro()-Y (dbl),
##   avgMean-tBodyGyro()-Z (dbl), avgStd-tBodyGyro()-X (dbl),
##   avgStd-tBodyGyro()-Y (dbl), avgStd-tBodyGyro()-Z (dbl),
##   avgMean-tBodyGyroJerk()-X (dbl), avgMean-tBodyGyroJerk()-Y (dbl),
##   avgMean-tBodyGyroJerk()-Z (dbl), avgStd-tBodyGyroJerk()-X (dbl),
##   avgStd-tBodyGyroJerk()-Y (dbl), avgStd-tBodyGyroJerk()-Z (dbl),
##   avgMean-tBodyAccMag() (dbl), avgStd-tBodyAccMag() (dbl),
##   avgMean-tGravityAccMag() (dbl), avgStd-tGravityAccMag() (dbl),
##   avgMean-tBodyAccJerkMag() (dbl), avgStd-tBodyAccJerkMag() (dbl),
##   avgMean-tBodyGyroMag() (dbl), avgStd-tBodyGyroMag() (dbl),
##   avgMean-tBodyGyroJerkMag() (dbl), avgStd-tBodyGyroJerkMag() (dbl),
##   avgMean-fBodyAcc()-X (dbl), avgMean-fBodyAcc()-Y (dbl),
##   avgMean-fBodyAcc()-Z (dbl), avgStd-fBodyAcc()-X (dbl),
##   avgStd-fBodyAcc()-Y (dbl), avgStd-fBodyAcc()-Z (dbl),
##   avgMean-fBodyAccFreq()-X (dbl), avgMean-fBodyAccFreq()-Y (dbl),
##   avgMean-fBodyAccFreq()-Z (dbl), avgMean-fBodyAccJerk()-X (dbl),
##   avgMean-fBodyAccJerk()-Y (dbl), avgMean-fBodyAccJerk()-Z (dbl),
##   avgStd-fBodyAccJerk()-X (dbl), avgStd-fBodyAccJerk()-Y (dbl),
##   avgStd-fBodyAccJerk()-Z (dbl), avgMean-fBodyAccJerkFreq()-X (dbl),
##   avgMean-fBodyAccJerkFreq()-Y (dbl), avgMean-fBodyAccJerkFreq()-Z (dbl),
##   avgMean-fBodyGyro()-X (dbl), avgMean-fBodyGyro()-Y (dbl),
##   avgMean-fBodyGyro()-Z (dbl), avgStd-fBodyGyro()-X (dbl),
##   avgStd-fBodyGyro()-Y (dbl), avgStd-fBodyGyro()-Z (dbl),
##   avgMean-fBodyGyroFreq()-X (dbl), avgMean-fBodyGyroFreq()-Y (dbl),
##   avgMean-fBodyGyroFreq()-Z (dbl), avgMean-fBodyAccMag() (dbl),
##   avgStd-fBodyAccMag() (dbl), avgMean-fBodyAccMagFreq() (dbl),
##   avgMean-fBodyBodyAccJerkMag() (dbl), avgStd-fBodyBodyAccJerkMag() (dbl),
##   avgMean-fBodyBodyAccJerkMagFreq() (dbl), avgMean-fBodyBodyGyroMag()
##   (dbl), avgStd-fBodyBodyGyroMag() (dbl), avgMean-fBodyBodyGyroMagFreq()
##   (dbl), avgMean-fBodyBodyGyroJerkMag() (dbl),
##   avgStd-fBodyBodyGyroJerkMag() (dbl), avgMean-fBodyBodyGyroJerkMagFreq()
##   (dbl), Avg-angle(tBodyAccMean,gravity) (dbl),
##   Avg-angle(tBodyAccJerkMean),gravityMean) (dbl),
##   Avg-angle(tBodyGyroMean,gravityMean) (dbl),
##   Avg-angle(tBodyGyroJerkMean,gravityMean) (dbl), Avg-angle(X,gravityMean)
##   (dbl), Avg-angle(Y,gravityMean) (dbl), Avg-angle(Z,gravityMean) (dbl)
```

Variables in the tidy dataset are named with a preceding 'Avg', for 'Average', as the resultant data set is the mean (average value) of the original dataset across all observations for a certain subject.

Output the tidy dataset to file.

```r
write.table(avgValues,file="tidyDataset.txt", row.name=FALSE)
```

*Code Book describing variable names can be found in the repo as well.*
