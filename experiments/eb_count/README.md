#PC_Count

##Description

	This experiment finds the maximum PC count for the loop PCs.

##Running the Experiment

To run the experiment, runexper.sh must be run. This script takes four parameters:
   
1. A name for the file
2. The executable name (exectuables are located in ../executables)
3. The window size (How many times a certain PC will repeat before the network is trained on it)
4. The file type (Currently only C and basic)

**The parameters must be provided in this order**

To indicate that the file is a C file, for the fourth parameter type "C" or "c". Anything else will result in the
script interpreting the file as a UBASIC file. The script outputs a data (.txt) file and a plot (.png).

##Analyzing the Data

###Multplot.sh
The file multplot.sh groups all plots created from a specific prime number together

To make the plot, the script must be run with the languagename_primenumber
   
   **The windowsize is omitted because it will take all of them into account in the script**

##Naming Conventions

The files are named as followed:

    languagename_primenumber_windowsize