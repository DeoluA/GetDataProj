library(dplyr, quietly=TRUE)

#download the dataset
download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile="getdata-projectfiles-UCI HAR Dataset.zip")
#unzip it
unzip(zipfile="getdata-projectfiles-UCI HAR Dataset.zip",
      exdir = "getdata-projectfiles-UCI HAR Dataset")


#labels
labels <- read.table("getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/activity_labels.txt",stringsAsFactors = FALSE)
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

##transform the y datasets from numbers to their respective label activities
for (i in 1:nrow(y_train))
{
  y_train$activity[i]<-labels$activity[labels$id==y_train$activity[i]]
}

for (i in 1:nrow(y_test))
{
  y_test$activity[i]<-labels$activity[labels$id==y_test$activity[i]]
}

##column bind subject, y and x to obtain a complete dataset
#all train
initial<-cbind(subject_train,y_train,x_train)
#change to a tbl_df
train<-tbl_df(initial)
#all test
initial<-cbind(subject_test,y_test,x_test)
#change to a tbl_df
test<-tbl_df(initial)

##finally, merge train and test to form one complete dataset
data<-rbind(train,test)

##retrieving the specified 'mean' and 'standard deviation' values
reqcol<-names(data)
#decided to search for 'mean' instead of '-mean', because the readMe indicates some means were taking but recorded within another 'angle' variable name
m<-grep("*([M,m]ean)",reqcol)
#searching for std values
s<-grep("*-([s,s]td)",reqcol)
#sorting results
mylist<-sort(c(m,s))

##selecting only required column indexes, '1' being 'subject' and '2' being 'activity'
data<-data[,c(1,2,mylist)]

##grouping the resultant dataset by 'subject' and 'activity', in that order.
by_acyr<-data %>% group_by(subject,activity)

##resultant dataset, with the mean (average) value of all columns
#when grouped and summarised, resulting dataset is automatically sorted in ascending order
avgValues <- by_acyr %>% summarise_each(funs(mean))

##a little name editing; appending 'Avg' in front of each variable to properly designate
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
##some house cleaning
rm(i,initial,x_test,y_test,x_train,y_train,subject_test,subject_train,train,test,labels,features,l,temp,m,s,mylist,data,by_acyr,reqcol)
##view the first few lines of the new, tidy dataset
avgValues
write.table(avgValues,file="tidyDataset.txt", row.name=FALSE)