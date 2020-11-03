#!/bin/sh
# Part 1. simulate 671 basins across the contiguous USA in parallel. 
# Author: H., Liu, Nov.03, 2020.

#SBATCH --ntasks=1
#SBATCH --time=00:40:00
#SBATCH --job-name=simulate
#SBATCH --account=hpc_s_geog825
#SBATCH --reservation=geog825_assignment
#SBATCH --error=slurm/slurm_%j.err
#SBATCH --output=slurm/slurm_%j.out

# ----
# Submit with:
# sbatch --array=1-68 part1.submit_all_catchments.sh
# ----

# create slurm and log directories
if [ ! -e logs ]; then mkdir logs; fi
if [ ! -e slurm ]; then mkdir slurm; fi

# define the base directory for the exercise
ex5_base=${HOME}/pbhmCourse_student/5_high_performance_computing

# define the settings file
summa_settings=${ex5_base}/settings/fileManager.txt

# define the executable string 
summa_exe=${ex5_base}/summa.exe

# define the log file
log_file=logs/summa_${SLURM_JOB_ID}_log.txt

# define the summa command
gru_count=10                              # number of GRUs per job
gru_total=671                             # total number of GRUs for simulation
offset=$SLURM_ARRAY_TASK_ID               # jobId used as offset to calculate gru_start
gru_start=$(( 1 + gru_count*(offset-1) )) # start GRU id for the job

# check that we don’t specify too many basins
if [ $(( gru_start+gru_count-1 )) -gt ${gru_total} ]; then
    gru_count=$(( ${gru_total}-${gru_start}+1 ))
fi

# define summa command
summa_command="$summa_exe -g $gru_start $gru_count -m $summa_settings"

# write information to the slurm output file
echo The base directory for exercise 5 is $ex5_base 
echo The summa executable is $summa_exe
echo The summa command is $summa_command
echo The log file is $log_file

# Run as [SUMMA call] > [log file path] 
$summa_command >$log_file
