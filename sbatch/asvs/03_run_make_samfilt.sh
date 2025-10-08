#!/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=60G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=03_make_samfilt
#SBATCH --time=00:30:00
#SBATCH --account=rrg-surette

echo module load r/4.5.0
module load r/4.5.0

echo Rscript ./scripts/asvs/03_make_samfilt.R
Rscript ./scripts/asvs/03_make_samfilt.R
