#!/bin/bash --login
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --gpus-per-node=p100:1
#SBATCH --cpus-per-gpu=4  
#SBATCH --mem-per-gpu=32G 
#SBATCH --partition=batch
#SBATCH --job-name=train
#SBATCH --mail-type=ALL
#SBATCH --output=bin/%x-%j-slurm.out
#SBATCH --error=bin/%x-%j-slurm.err

# entire script fails if single command fails
set -e

# activate the conda environment
module purge
conda activate $ENV_PREFIX

# use srun to launch NVDashboard server in order to reserve a port
srun --resv-ports=1 "$PROJECT_DIR"/bin/launch-nvdashboard-server.srun &
NVDASHBOARD_PID=$!

# launch the training script
python train.py \
    --train_coords "$DATA_DIR"/fib_flyem_validation1_label_lom24_24_24_part14_wbbox_coords-*-of-00025.gz \
    --data_volumes validation1:"$DATA_DIR"/grayscale_maps.h5:raw \
    --label_volumes validation1:"$DATA_DIR"/groundtruth.h5:stack \
    --model_name convstack_3d.ConvStack3DFFNModel \
    --model_args "{\"depth\": 12, \"fov_size\": [33, 33, 33], \"deltas\": [8, 8, 8]}" \
    --image_mean 128 \
    --image_stddev 33

# shutdown the NVDashboard server
kill $NVDASHBOARD_PID

