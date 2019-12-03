#!/bin/bash
#SBATCH --partition=normal
#SBATCH --ntasks=12
#SBATCH --mem=20000
#SBATCH --output=%J_stdout.txt
#SBATCH --error=%J_tderr.txt
#SBATCH --time=14:10:00            
#SBATCH --job-name=susy_shorter
#SBATCH --mail-user=obada.alzoubi@ou.edu
#SBATCH --mail-type=ALL
#SBATCH --workdir=/home/obadazx3000/HeSNN/code/
module load MATLAB
matlab -nodisplay -r "parWorkersScript=12;nWorkersScript=400;dat='SUSY';fOutput='SUSY';parallel"

