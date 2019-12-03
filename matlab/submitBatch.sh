#!/bin/bash
#SBATCH --partition=normal
#SBATCH --ntasks=10
#SBATCH --output=stdout.txt
#SBATCH --error=tderr.txt
#SBATCH --time=23:00:00            
#SBATCH --job-name=Obada
#SBATCH --mail-user=obada.alzoubi@ou.edu
#SBATCH --mail-type=ALL
#SBATCH --workdir=/scratch/obadazx3000/data/code
module load MATLAB
matlab -nodisplay -r parallel.m