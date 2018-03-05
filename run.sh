#!/bin/bash

#SBATCH -A iPlant-Collabs
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 02:00:00
#SBATCH -p development
#SBATCH -J launchit

# 
# The TACC Launcher is available as a module. Once loaded, you
# will have $TACC_LAUNCHER_DIR in your environment. The "paramrun"
# program is located in this directory. You will use LAUNCHER_*
# environment variables to pass your arguments to the launcher, the
# most important of which is the LAUNCHER_JOB_FILE which is a text
# file of the commands you wish to have run.
# 
module load launcher

PARAMRUN="$TACC_LAUNCHER_DIR/paramrun"
export LAUNCHER_PLUGIN_DIR="$TACC_LAUNCHER_DIR/plugins"
export LAUNCHER_WORKDIR="$PWD"
export LAUNCHER_RMI="SLURM"
export LAUNCHER_SCHED="interleaved"

set -u

#
# Make list of jobs
#
PARAM=$(mktemp)
for i in $(seq 1 10); do
    echo "echo \"$i\" host \"\$(hostname)\" task \"\$LAUNCHER_TSK_ID\"" >> "$PARAM"
done

#
# I often run some code to check that I have jobs to run. Obviously the
# above code *should* run fine, so I'm just showing here how I check
# the number of jobs in my $PARAM file.
#
NJOBS=$(wc -l "$PARAM" | awk '{print $1}')

#
# Launch the jobs
#
if [[ $NJOBS -gt 0 ]]; then
   export LAUNCHER_JOB_FILE=$PARAM

   #
   # If there were only a few jobs, then it's pointless to have
   # 16 Processes Per Node, so I set $LAUNCHER_PPN to $NJOBS
   #
   if [[ $NJOBS -gt 16 ]]; then
       LAUNCHER_PPN=16
   else
       LAUNCHER_PPN=$NJOBS
   fi

   export LAUNCHER_PPN

   echo "Starting launcher on $NJOBS jobs"
   $PARAMRUN
   echo "Finished launcher"
else
   echo "No jobs for launcher (something went wobbly)"
fi
