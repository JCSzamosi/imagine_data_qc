#!/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=30G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=02_make_ps_full
#SBATCH --time=00:45:00
#SBATCH --account=rrg-surette

echo module load r/4.5.0
module load r/4.5.0

echo Rscript ./scripts/02_make_ps_full.R
Rscript ./scripts/02_make_ps_full.R
