dataset=mushrooms
for i in 2 4 6 8 10; do
sbatch subSingle.bash
sleep 4
done
