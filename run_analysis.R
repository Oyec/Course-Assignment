# Download and unzip data

url='https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(url,'data.zip')
unzip('data.zip')


# Load activity labels

Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
Labels[,2] <- as.character(Labels[,2])

# Load  features

features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract features of mean and std and make it "tidy"

featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)


# Train data

train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Test data

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge test and train data, add colnames

allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# Transform activities to factors

allData$activity <- factor(allData$activity, levels = Labels[,1], labels = Labels[,2])
allData$subject <- as.factor(allData$subject)

library(reshape2)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

# Write dataset
write.table(allData.mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)