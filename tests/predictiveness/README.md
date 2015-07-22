#Predictiveness

##Description

	This experiments finds the maximum predictability for the loop PCS after a network has been trained

##Experiment Set up

Before running the experiment script, the net_create.sh script must be run. This creates a neural net for each pc at the different window sizes. The nets should then be train (-t flag) around three times before the experiment is run

Use the -h flag on the script for additional information

This experiment provides three outputs
     
     A data file containing the pc's, the predictiveness, the window size, and a count.
     A plot with the PCs vs predictivenss for a certain window size
     A directory called languagename_prime_windowsize that contains the raw data from the asc system


##Running the Experiment

To run the experiment, the script runexper.sh is used. This script can also make a plot of all the data once all window sizes have undergone the experiemtn

Use the -h flag on the script for additional information



##Analyzing the Data

##Naming Conventions

The files are named as followed:

    languagename_primenumber_windowsize

Inside the language's respecitve directories are numbered directories. These correspond to the prime number associated with the executables. Inside of these is a data directory, a plot directory, and a net directory.

       The neural nets corresponding to the language and prime will be places in the nets directory
       The data files from the experiment will be placed in the data directory
       The plots from the experiment will be placed in the plots directory
##Common Errors

###Not training the network first

A neural network must first be established before the experiment is run

###Dividing by zero

If the window size is greater than the number of times the program loops, the program will try to divide by zero, resulting in an error. 
