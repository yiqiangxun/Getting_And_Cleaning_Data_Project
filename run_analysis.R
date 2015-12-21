getwd()

##Merges the training and the test sets to create one data set.

#Download Data
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(url, 'getdata-projectfiles-UCI HAR Dataset.zip')
unzip('getdata-projectfiles-UCI HAR Dataset.zip')

#Read Files
folderpath <- file.path("UCI HAR Dataset")
Ytest <- read.table(file.path(folderpath, "test", "Y_test.txt"), header = FALSE)
Ytrain <- read.table(file.path(folderpath, "train", "Y_train.txt"), header = FALSE)
Xtest <- read.table(file.path(folderpath, "test", "X_test.txt"), header = FALSE)
Xtrain <- read.table(file.path(folderpath, "train", "X_train.txt"), header = FALSE)
Subjecttest <- read.table(file.path(folderpath, "test", "subject_test.txt"), header = FALSE)
Subjecttrain <- read.table(file.path(folderpath, "train", "subject_train.txt"), header = FALSE)

#Merge Rows
subject <- rbind(Subjecttrain, Subjecttest)
activity <- rbind(Ytrain, Ytest)
features <- rbind(Xtrain, Xtest)

#Merge to one file
names(subject) <- c("subject")
names(activity) <- c("activity")
featurename <- read.table(file.path(folderpath, "features.txt"), head=FALSE)
names(features) <- featurename$V2

SubAct <- cbind(subject, activity)
OneData <- cbind(features, SubAct)


##Extracts only the measurements on the mean and standard deviation for each measurement.

meanstd <- featurename$V2[grep("mean\\(\\)|std\\(\\)", featurename$V2)]
selectedNames <- c(as.character(meanstd), "subject", "activity")
OneData <- subset(OneData, select = selectedNames)

##Uses descriptive activity names to name the activities in the data set

activityType = read.table(file.path(folderpath, "activity_labels.txt") ,header=FALSE)
colnames(activityType)  = c('activity','activityType')
OneData = merge(OneData,activityType,by= 'activity', all.x=TRUE)
colNames  = colnames(OneData)

##Appropriately labels the data set with descriptive variable names. 

names(OneData) <- gsub("^t", "time", names(OneData))
names(OneData) <- gsub("^f", "frequency", names(OneData))
names(OneData) <- gsub("Acc", "Accelerometer", names(OneData))
names(OneData) <- gsub("Gyro", "Gyroscope", names(OneData))
names(OneData) <- gsub("Mag", "Magnitude", names(OneData))
names(OneData) <- gsub("BodyBody", "Body", names(OneData))
names(OneData) <- gsub("-std$","StdDev",names(OneData))
names(OneData) <- gsub("-mean","Mean",names(OneData))

##From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr)
tidydata <- aggregate(. ~subject + activity, OneData, mean)
tidydata <- tidydata[order(tidydata$subject,tidydata$activity),]
write.table(tidydata, file = "tidydata.txt",row.names=FALSE,sep=',')


