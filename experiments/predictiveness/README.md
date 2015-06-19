#Predictiveness

##Description

	This experiments finds the maximum predictability for the loop PCS after a network has been trained

##Experiment Set up

Before running the experiment script, the asc system must be trained on a certain executable first. To do this:

1. Run the asc system the first time with the executable. 
2. Run the asc system again with the newly created exectuable.net file.
3. Repeat step 2 until the network is sufficiently trained 

##Running the Experiment

To run the experiment, runexper.sh must be run. This script takes four paremeters:

1. A name for the file
2. The executable name (exectuables are located in ../executables)
3. The window size (How many times a certain PC will repeat before the network is trained on it)
4. The file type (Currently only C and basic)

**The parameters must be provided in this order**

To indicate that the file is a C file, for the fourth parameter type "C" or "c". Anything else will r\
esult in the
script interpreting the file as a UBASIC file. The script outputs a data (.txt) file and a plot (.png\
).

##Analyzing the Data

###Multplot.sh
The file multplot.sh groups all plots created from a specific prime number together

To make the plot, the script must be run with the languagename_primenumber

   **The windowsize is omitted because it will take all of them into account in the script**

##Naming Conventions

The files are named as followed:

    languagename_primenumber_windowsize

##Common Errors

##Not training the network first

A neural network must first be established before the experiment is run

###Dividing by zero

If the window size is greater than the number of times the program loops, the program will try to divide by zero, resulting in an error. 