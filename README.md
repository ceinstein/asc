# UBASIC EXPERIMENTS

Welcome to the UBasic Experiements (could also be experience) repo! This 
repository is to share files to be tested on the ASC system.

There are a number of experiments and statistics included. Each experiment
has a seperate README so it is important to read those in order to understand
and be able to run the experiments


#EXPERIMENTS

So far there are two experiments:

PC_COUNT
	This experiment plots PCs with their associated excited bit counts.
This is located in './experiments/pc_count'.

PREDICTIVENESS
	This experiment plots PCS with their associated predictivness for the
given program. Predictivness is measured by the amount of hits divided by the
total amount of rounds. In other words, it's the percentage of rounds that
yielded a hit. This is located in './experiments/predictivness'.

#STATISTICS

	Not much has been done with this yet. Currently, there are statistics
from two runs of the rsa program. the 'result*' files are the results of the
program executing one loop. The 'results2' files are the results of the program
executing two loops.

	  This data was gathered to identify the PCs the occured at the same 
frequency as the loop. The theory is that these PCs will provide a good
hyperplane from which to predict the future computation.

#Enjoy!

If there is anything that is missing, or that should be added email me at
einstein@bu.edu