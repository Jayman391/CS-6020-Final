#!/bin/sh

for user_growth_rate in {0.5..2..0.5}; do
    for interaction_threshold in {0.2..1..0.2}; do
        for new_group_rate in {0.1..0.5..0.1}; do
            for new_community_rate in {0.05..0.25..0.05}; do
                sbatch choice_model_batch.sh $user_growth_rate $interaction_threshold $new_group_rate $new_community_rate
            done
        done
    done
done