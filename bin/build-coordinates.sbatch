#!/bin/bash --login
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --gpus-per-node=p100:1
#SBATCH --cpus-per-gpu=4  
#SBATCH --mem-per-gpu=32G
#SBATCH --partition=batch 
#SBATCH --job-name=build-partitions
#SBATCH --mail-type=ALL
#SBATCH --output=bin/%x-%j-slurm.out
#SBATCH --error=bin/%x-%j-slurm.err

# activate the conda environment
module purge
conda activate $ENV_PREFIX

# build coordinates
python build_coordinates.py \
     --partition_volumes validation1:"$DATA_DIR"/af.h5:af \
     --coordinate_output "$DATA_DIR"/tf_record_file \
     --margin 24,24,24
