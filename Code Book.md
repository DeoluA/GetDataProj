Code Book
===================
**subject**

The experiments were carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each unique numeric value (from 1 to 30) represents a particular volunteer.

**activity**

Each person performed six activities, designated as:
- *WALKING*
- *WALKING_UPSTAIRS*
- *WALKING_DOWNSTAIRS*
- *SITTING*
- *STANDING*
- *LAYING*


Using an embedded accelerometer and gyroscope in a smartphone (Samsung Galaxy S II) worn by the volunteers, various readings along 3-axial linear acceleration and 3-axial angular velocity were captured at a constant rate of 50Hz.

All observations were then averaged across a variable for each activity per subject, and the resulting average value per activity for that variable in the **tidyDataset** is designated by the prefix '**avg**'

Furthermore:
- **avgMean**: average of all mean values of the variable for that activity and subject
- **avgStd**: average of all standard deviations of the variable for that activity and subject

**Average mean and standard deviation values were summarised for the following**: the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.
- tBodyAcc-XYZ
- tGravityAcc-XYZ
- tBodyAccJerk-XYZ
- tBodyGyro-XYZ
- tBodyGyroJerk-XYZ
- tBodyAccMag
- tGravityAccMag
- tBodyAccJerkMag
- tBodyGyroMag
- tBodyGyroJerkMag
- fBodyAcc-XYZ
- fBodyAccJerk-XYZ
- fBodyGyro-XYZ
- fBodyAccMag
- fBodyAccJerkMag
- fBodyGyroMag
- fBodyGyroJerkMag
- angle(): Angle between to vectors.


Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

- gravityMean
- tBodyAccMean
- tBodyAccJerkMean
- tBodyGyroMean
- tBodyGyroJerkMean
