#!/bin/sh
#SBATCH --partition=bluemoon
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=25:00:00
#SBATCH --mem=64G
#SBATCH --job-name=MOCS_SIM
#SBATCH --output=output/%x_%j.out
#SBATCH --mail-type=FAIL

user_growth_rate=$1
interaction_threshold=$2
new_group_rate=$3
new_community_rate=$4

for run in {01..50}; do
    python3 choice-model.py $user_growth_rate $interaction_threshold $new_group_rate $new_community_rate $run
done