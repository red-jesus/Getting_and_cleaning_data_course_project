# Getting_and_cleaning_data_course_project

The script named 'run_analysis.R' does all the work.

To reach the same result I did, download the dataset per the instructions in the assignment & execute this R code in the
directory named 'UCI HAR Dataset' (don't change the location or names of any of the directories or files within).
Running the 'main' function w/in 'run_analysis.R' will go through all the steps and spit out the .txt file.

Basic flow:

1. Read in data from files titled "{x/y/subject}_{test/train}.txt"
2. Extract relevant columns from x_test.txt & x_train.txt
3. Merge x_test.txt with the subject_test.txt & y_test.txt to create the complete test dataset. In the same step, do the same for
the training data. Then combine these all into a single dataframe
4. Replace activity column's default integer value with the character value (eg walking instead of 1) to create 'tidyDataset'
5. Group 'tidyDataset' based on subject & activity, then calculate mean for each value.
6. Finally, write the data to a .txt file
