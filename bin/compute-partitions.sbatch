#!/bin/bash --login
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --gpus-per-node=p100:1
#SBATCH --cpus-per-gpu=4  
#SBATCH --mem-per-gpu=32G
#SBATCH --partition=batch 
#SBATCH --job-name=compute-partitions
#SBATCH --mail-type=ALL
#SBATCH --output=bin/%x-%j-slurm.out
#SBATCH --error=bin/%x-%j-slurm.err

# whole script fails if any particular line fails
set -e

# define some important environment variables
export PROJECT_DIR="$PWD"
export DATA_DIR="$PROJECT_DIR"/third_party/neuroproof_examples/validation_sample
export ENV_PREFIX="$PROJECT_DIR"/env

# activate the conda environment
module purge
conda activate $ENV_PREFIX

# compute the partitions
python compute_partitions.py \
    --input_volume "$DATA_DIR"/groundtruth.h5:stack \
    --output_volume "$DATA_DIR"/af.h5:af \
    --thresholds 0.025,0.05,0.075,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9 \
    --lom_radius 24,24,24 \
    --min_size 10000
