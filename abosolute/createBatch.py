# -*- coding: utf-8 -*-
"""
Created on Thu Feb 02 09:58:40 2017

@author: oalzoubi
"""
import sys
str(sys.argv)
dataset = str(sys.argv[1])
parWorkers = str(sys.argv[2])
nWorkers = str(sys.argv[3])
mem = str(sys.argv[4])
tim = str(sys.argv[5])
output = str(sys.argv[6])
batchTrainRatio = str(sys.argv[7]) #Batch size for training data - 0 in case all batch size- should be [0,1]
batchTestSize = str(sys.argv[8]) # Batch size for testing  -0 full batch size form testing data - [1, inf] 
nameJ = dataset+parWorkers+batchTrainRatio
text_file = open("output.sh","w")
text_file.write("#!/bin/bash\n")
text_file.write("#SBATCH --partition=normal\n")
text_file.write("#SBATCH --ntasks=%d\n" % int(parWorkers) )
text_file.write("#SBATCH --mem=%d\n" % int(mem))
text_file.write("#SBATCH --output=/home/obadazx3000/HeSNN/slurm_output/%J_s.txt\n")
text_file.write("#SBATCH --error=/home/obadazx3000/HeSNN/slurm_output/%J_t.txt\n")
text_file.write("#SBATCH --time=%s\n" % tim)
text_file.write("#SBATCH --job-name=%s\n" % nameJ )
text_file.write("#SBATCH --mail-user=obada.alzoubi@ou.edu\n")
text_file.write("#SBATCH --mail-type=ALL\n")
text_file.write("#SBATCH --workdir=/home/obadazx3000/HeSNN/\n")
text_file.write("module load MATLAB\n")
text_file.write("matlab -nodisplay -r \"parWorkersScript=%d;nWorkersScript=%d;dat='%s';fOutput='%s';trainBatchSizeRatioScript = %0.2f; testBatchSizeScript=%d; parallel_f2\"\n" % (int(parWorkers), int(nWorkers), dataset, output, float(batchTrainRatio), int(batchTestSize)))
text_file.close()

