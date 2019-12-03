#!/bin/bash
python createBatch.py 'SUSY' 10 400 24000 08:00:00 'SUSY.csv' 0.3 300 
sleep 3
sbatch output.sh
python createBatch.py 'SUSY' 10 400 24000 08:00:00 'SUSY.csv' 0.5 300 
sleep 3
sbatch output.sh
python createBatch.py 'SUSY' 10 400 24000 08:00:00 'SUSY.csv' 0.7 300 
sleep 3
sbatch output.sh
python createBatch.py 'HIGGS' 10 400 24000 10:00:00 'HIGGS.csv' 0.3 300
sleep 3
sbatch output.sh
python createBatch.py 'HIGGS' 10 400 24000 10:00:00 'HIGGS.csv' 0.5 300 
sleep 3
sbatch output.sh
python createBatch.py 'HIGGS' 10 400 24000 10:00:00 'HIGGS.csv' 0.7 300
sleep 3
sbatch output.sh
