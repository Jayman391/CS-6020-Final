#!/bin/sh
#SBATCH --partition=bluemoon
#SBATCH --nodes=10
#SBATCH --ntasks=10
#SBATCH --time=25:00:00
#SBATCH --mem=512G
#SBATCH --job-name=MOCS_SIM
#SBATCH --output=output/%x_%j.out
#SBATCH --mail-type=FAIL

for run in {1..50}; do
  for user_growth_rate in {5..20..5}; do
      for interaction_threshold in {2..10..2}; do
          for new_group_rate in {1..5..1}; do
              for new_community_rate in {1..5..1}; do
                  sleep 2
                  srun python choice-model.py $user_growth_rate $interaction_threshold $new_group_rate $new_community_rate $run &
              done
          done
      done
  done
done