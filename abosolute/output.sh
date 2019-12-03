#!/bin/bash
#SBATCH --partition=normal
#SBATCH --ntasks=12
#SBATCH --mem=24000
#SBATCH --output=/home/obadazx3000/HeSNN/slurm_output/%J_s.txt
#SBATCH --error=/home/obadazx3000/HeSNN/slurm_output/%J_t.txt
#SBATCH --time=24:30:00
#SBATCH --job-name=aloi
#SBATCH --mail-user=obada.alzoubi@ou.edu
#SBATCH --mail-type=ALL
#SBATCH --workdir=/home/obadazx3000/HeSNN/
module load MATLAB
matlab -nodisplay -r "parWorkersScript=12;nWorkersScript=12;dat='aloi';fOutput='aloi';trainBatchSizeRatioScript = 0; testBatchSizeScript=0; testGrid"
