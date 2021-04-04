#!/bin/bash

# script should fail if any particular line fails
set -e

# script should be run from the project root directory
export PROJECT_DIR="$PWD"

# first stage of the pipeline computes the partitions
COMPUTE_PARTITIONS_JOBID=$(sbatch \
  --parsable "$PROJECT_DIR"/bin/compute-partitions.sbatch \
)

# second stage of the pipeline builds the coordinates
BUILD_COORDINATES_JOBID=$(sbatch \
  --parsable \
  --dependency=afterok:$COMPUTE_PARTITIONS_JOBID \
  --kill-on-invalid-dep=yes \
  "$PROJECT_DIR"/bin/build-coordinates.sbatch \
)

# third stage of the pipeline is the training
TRAIN_JOBID=$(sbatch \
  --parsable \
  --dependency=afterok:$BUILD_COORDINATES_JOBID \
  --kill-on-invalid-dep=yes \
  "$PROJECT_DIR"/bin/train.sbatch \
)

# final stage of the pipeline is the inference
sbatch \
  --dependency=afterok:$TRAIN_JOBID \
  --kill-on-invalid-dep=yes \
  "$PROJECT_DIR"/bin/run-inference.sbatch 

