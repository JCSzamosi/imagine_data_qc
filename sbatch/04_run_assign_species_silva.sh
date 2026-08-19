#!/bin/bash

#SBATCH --cpus-per-task=30
#SBATCH --mem=100G
#SBATCH --output=logs/%x_slurm_%j.log
#SBATCH --error=logs/%x_slurm_%j.log
#SBATCH --job-name=04_assign_spc_silva
#SBATCH --time=05:00:00
#SBATCH --account=rrg-surette

echo module load r/4.5.0
module load r/4.5.0

echo Rscript ./scripts/01_assign_tax_asvs.R -d silva
Rscript ./scripts/04_assign_species.R -d silva
