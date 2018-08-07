
###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir


###################### TRAINING ################################################
cd $workDir
mkdir 2_myTraining
cd 2_myTraining
cp $workDir/1_scfVasp/train.cfg .
#### cp /fslgroup/fslg_datamining/MTP/train/pot.mtp .  <<< this pot.mtp is WRONG!!!
cp $workDir/scriptsCoNiTi/pot.mtp .
### this pot.mtp is from Wiley, already corrected and with  species_count = 3 (ternary)
###cp /fslgroup/fslg_datamining/MTP/train/readme.txt .



cat > "jobTraining" << FIN
#!/bin/bash
####################################

#SBATCH --time=08:00:00   # walltime
#SBATCH --ntasks=16   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=1024M   # memory per CPU core
#SBATCH -J "Job_training"   # job name
#SBATCH --mail-user=carlos.leon.chinchay@gmail.com   # email address
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module purge
module load mpi/openmpi-1.8.5_intel-15.0.2
module switch compiler_intel/15.0.2 compiler_intel/2017

##module purge
##module load compiler_intel/2017
##module load openblas/0.2.15
##module load gdb/7.9.1
##module load compiler_gnu/4.9.2
##module load mpi/openmpi-1.8.4_gnu-4.9.2

mpirun -n 16 /fslhome/chinchay/newMLPparallel/mlip/bin/mlp train pot.mtp train.cfg > training.txt
###$mlpDir/mlp train pot.mtp train.cfg > training.txt

mv Trained.mtp_ pot.mtp
/fslhome/chinchay/newMLPparallel/mlip/bin/mlp calc-grade pot.mtp train.cfg train.cfg temp1.cfg
#### the last step will create two additional files: state.mvs and temp1.cfg

####################################
FIN

sbatch jobTraining

