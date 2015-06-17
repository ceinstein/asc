#PC_Count

##Description

	This experiment finds the maximum PC count for the loop PCs.

##Running the Experiment

To run the experiment, the runexper.sh must be run. This script takes four parameters
   
1. A name for the file
2. The executable name (exectuables are located in ../executables)
3. The window size (How many times a certain PC will repeat before the network is trained on it)
4. The file type (Currently only C and basic)

To indicate that the file is a C file, for the fourth parameter type "C" or "c". Anything else will result in the
script interpreting the file as a UBASIC file. The script outputs a data (.txt) file and a plot (.png).

##Naming Convenctions

The files are named as followed:

    languagename_primenumber_windowsize