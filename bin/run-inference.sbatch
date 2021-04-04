#!/bin/bash --login
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --gpus-per-node=p100:1
#SBATCH --cpus-per-gpu=4  
#SBATCH --mem-per-gpu=32G 
#SBATCH --partition=batch
#SBATCH --job-name=run-inference
#SBATCH --mail-type=ALL
#SBATCH --output=bin/%x-%j-slurm.out
#SBATCH --error=bin/%x-%j-slurm.err

# entire script fails if single command fails
set -e

# define project environment variables
PROJECT_DIR="$PWD"
ENV_PREFIX="$PROJECT_DIR"/env

# activate the conda environment
module purge
conda activate $ENV_PREFIX

# use srun to launch NVDashboard server in order to reserve a port
srun --resv-ports=1 "$PROJECT_DIR"/bin/launch-nvdashboard-server.srun &
NVDASHBOARD_PID=$!

# launch the inference script
python run_inference.py \
    --inference_request="$(cat configs/inference_training_sample2.pbtxt)" \
    --bounding_box 'start { x:0 y:0 z:0 } size { x:250 y:250 z:250 }'

# shutdown the NVDashboard server
kill $NVDASHBOARD_PID
