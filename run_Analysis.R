library(dplyr)

main <- function() {
	# does all the work. call main, and it will do everything the assignment requires.
	# this is location dependent - see readme.md for details
		
	# only execute code if in the correct directory
	if(grepl("UCI HAR Dataset",getwd(),)){
			
	# Read in values from all relevant files ("{x/y/subject}_{test/train}.txt")
	# Pulled in & stored as a list with 6 elements
	# Each element is named after the file it's pulled from:
	# eg, x_test.txt -> rawValueList$xTest, y_train.txt -> rawValueList$yTrain
	rawValueList <- getRawValues()
	
	# Extract the relevant columns from data sourced from "x_{test/train}.txt"
	# Store processed data as elements in a list, divvied up by file of origin
	# eg rawValueList$xTest -> processedXFiles$xTrain
	processedXFiles <- getMeanAndStdColumnsFromXFiles(xTest=rawValueList$xTest, xTrain=rawValueList$xTrain)
	
	# Consolidate the separate data into a single data frame
	# Values for test data are consolidated into one data frame
	# Values for train data are consolidated into another data frame
	# These two data frames are then consolidated to form one, unified, consistent data frame
	# A new variable, mergedDataset$dataset, has been created to track any difference between
	# training & test data later on, if necessary
	mergedDataset <- createMergedDatasets(xTest=processedXFiles$xTest, yTest=rawValueList$yTest,
										  subjectTest=rawValueList$subjectTest,
										  xTrain=processedXFiles$xTrain,
										  yTrain=rawValueList$yTrain,
										  subjectTrain=rawValueList$subjectTrain)
	
	# insert activity names in place of activity numbers
	tidyDataset <- replaceActivityNumbersWithActivityNames(mergedDataset)
	
	# remove 'dataset' column
	tidyDataset <- select(tidyDataset, -dataset)
	# find mean for each subject/activity
	finalDataset <- findMeans(tidyDataset)
	
	# write data to txt files, per instructions
	write.table(finalDataset, file="final_dataset.txt", row.names=FALSE)
}


readXTestValues <- function(fileName="test/X_test.txt"){
	# reads in data from "test/X_test/txt"
	
	# read in data
	xTest <- read.table(file=fileName, stringsAsFactors=FALSE)
	return(xTest)
}

readYTestValues <- function(fileName="test/y_test.txt"){
	# reads in data from "test/y_test.txt"
	
	# read in data
	yTest <- read.table(file=fileName, stringsAsFactors=FALSE)
	# rename column
	yTest <- select(yTest, activityNumber=V1)
	
	return(yTest)
}

readSubjectTestValues <- function(fileName="test/subject_test.txt"){
	# reads in data from "test/subject_test.txt"
	
	# read in data
	subjectTest <- read.table(file=fileName, stringsAsFactors=FALSE)
	# rename column
	subjectTest <- select(subjectTest, subject=V1)

	return(subjectTest)
}

readXTrainValues <- function(fileName="train/X_train.txt"){
	# reads in data from "train/X_train.txt"
	
	# read in data
	xTrain <- read.table(file=fileName, stringsAsFactors=FALSE)
	return(xTrain)
}

readYTrainValues <- function(fileName="train/y_train.txt"){
	# reads in data from "train/y_train.txt"
	
	# read in data
	yTrain <- read.table(file=fileName, stringsAsFactors=FALSE)
	# rename column
	yTrain <- select(yTrain, activityNumber=V1)
	
	return(yTrain)
}

readSubjectTrainValues <- function(fileName="train/subject_train.txt"){
	# reads in data from "train/subject_train.txt"
	
	# read in data
	subjectTrain <- read.table(file=fileName, stringsAsFactors=FALSE)
	# rename column
	subjectTrain <- select(subjectTrain, subject=V1)
		
	return(subjectTrain)
}

readFeatures <- function(fileName="features.txt"){
	# reads in data from "features.txt"
	
	# read in data
	features <- read.table(file=fileName, stringsAsFactors=FALSE)
	
	# these features correspond to column names in xTest and xTrain
	# they're read in as a data frame
	# the second column of this data frame contains the actual column names
	# store & return these column names in a vector
	features <- features$V2
	return(features)
}

readActivityLabels <- function(fileName="activity_labels.txt"){
	
	# read in data
	activities <- read.table(file=fileName, stringsAsFactors=FALSE)
	
	# rename columns
	activities <- rename(activities, activityNumber=V1, activity=V2)
	
	return(activities)
}

getRawValues <- function(){
	# read in raw data
	xTest <- readXTestValues()
	yTest <- readYTestValues()
	subjectTest <- readSubjectTestValues()
	xTrain <- readXTrainValues()
	yTrain <- readYTrainValues()
	subjectTrain <- readSubjectTrainValues()
	
	rawValuesList <- list(xTest=xTest, yTest=yTest, subjectTest=subjectTest, xTrain=xTrain,
							 yTrain=yTrain, subjectTrain=subjectTrain)
	
	return(rawValuesList)
}

getMeanAndStdColumnsFromXFiles <- function(xTest, xTrain){
	# This function takes raw input from "test/x_test.txt" and "train/x_train.txt"
	# It then selects the mean & std columns only and renames all columns appropriately
	# These are stored in separate dataframes & returns as a list w/ named elements
	
	# read in vector of features
	features <- readFeatures()
	
	# search features for matches on 'mean' and 'std'
	meanColumnIndices <- grep("mean",tolower(features))
	stdColumnIndices <- grep("std",tolower(features))
	
	# combine into a single vector & sort
	meanAndStdColumnIndices <- sort(c(meanColumnIndices, stdColumnIndices))
	# extract column names using the features vector & selected column indices
	meanAndStdColumnNames <- features[meanAndStdColumnIndices]

	# pull out these columns
	xTest <- xTest[,meanAndStdColumnIndices]
	xTrain <- xTrain[,meanAndStdColumnIndices]
	
	# insert names
	names(xTest) <- features[meanAndStdColumnIndices]
	names(xTrain) <- features[meanAndStdColumnIndices]
	
	# insert these values into a list & return
	xValueList <- list(xTest=xTest, xTrain=xTrain)
	return(xValueList)
}

createMergedDatasets <- function(xTest, yTest, subjectTest, xTrain, yTrain, subjectTrain) {
	# Merges together the datasets into a single dataframe
	# NOTE - xTest and xTrain MUST have been processed by function "getMeanAndStdColumnsFromXFiles"
	# before passing in here
	
	# first merge all the separate test files & create new variable to show it's the test dataset
	xTest <- data.frame(dataset=rep("test",length(yTest)), subject=subjectTest, activityNumber=yTest, xTest)
	# next do the same for the separate train files
	xTrain <- data.frame(dataset=rep("train",length(yTrain)), subject=subjectTrain, activityNumber=yTrain, xTrain)
	# merge them together
	mergedDataset <- rbind(xTest, xTrain)
	
	# convert activities to actual names
	
	return(mergedDataset)
}

replaceActivityNumbersWithActivityNames <- function(mergedDataset){
	# Inserts activity names in place of the activity numbers
	
	# read in activity names
	activities <- readActivityLabels()
	
	# merged activity names & dataset
	mergedDataset <- merge(mergedDataset, activities, by.x="activityNumber", by.y="activityNumber", all=TRUE)
	
	# overwrite activityNumber column
	mergedDataset$activityNumber <- mergedDataset$activity
	
	# drop activity column
	mergedDataset <- select(mergedDataset, -activity)
	
	# rename activityNumber column as activity
	tidyDataset <- rename(mergedDataset, activity=activityNumber)
	
	return(tidyDataset)	
}

findMeans <- function(tidyDataset){
	# Find the actual means of each value in the tidyDataset

	# group the tidyDataset
	tidyDataset <- group_by(tidyDataset, subject, activity)
	
	# then pick the column names we need to actually calculate mean values for
	targetColumnNames <- names(tidyDataset[!(names(tidyDataset) %in% c("subject","activity"))])
	
	# now calculate the actual means
	finalDataset <- summarise_each_(tidyDataset, funs(mean), targetColumnNames)
	
	return(finalDataset)
}
}