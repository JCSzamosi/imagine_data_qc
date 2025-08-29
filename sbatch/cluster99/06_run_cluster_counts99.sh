#!/bin/bash

#SBATCH --cpus-per-task=5
#SBATCH --mem=200G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=06_cluster_counts99
#SBATCH --time=00:30:00
#SBATCH --account=rrg-surette

echo module load r/4.5.0
module load r/4.5.0

echo module load gcc/13.3
module load gcc/13.3

echo export R_LIBS=~/R/x86_64-pc-linux-gnu-library/4.5/
export R_LIBS=~/R/x86_64-pc-linux-gnu-library/4.5/

echo export NODESLIST=$(echo $(srun hostname | cut -f 1 -d '.'))
export NODESLIST=$(echo $(srun hostname | cut -f 1 -d '.'))

echo Rscript ./scripts/cluster99/06_cluster_counts99.R
Rscript ./scripts/cluster99/06_cluster_counts99.R
