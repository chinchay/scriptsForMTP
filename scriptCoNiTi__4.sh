
###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir

################################################################################
# Active learning
################################################################################
cp  9_toMTPrelaxWithRelaxedVasp/selected.cfg  8_trainingWithRelaxedVasp/new.cfg
cd  $workDir/8_trainingWithRelaxedVasp/

# "Active learning:"
# output: diff.cfg
# Wiley Morgan: "What it's doing is comparing all the structures in the
# selected.cfg file to pick the 200 that will best benefit the training set.
# This is essentially building a massive matrix that it’s trying to optimize
# so it can take a while. After the first few iterations it will speed up but
# at first this will be take time because of the number of configurations in
# the setup.cfg file (it is ~1.2GB).

cat > "job_ActiveLearning200" << FIN
#!/bin/bash
####################################
#SBATCH --time=12:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes

#SBATCH --mem-per-cpu=24576M   # memory per CPU core
###### ###SBATCH --mem-per-cpu=61440M   # memory per CPU core

#SBATCH -J "job_ActiveLearning200"   # job name
#SBATCH --mail-user=carlos.leon.chinchay@gmail.com   # email address
#SBATCH --mail-type=FAIL
#SBATCH -p physics

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module purge
module load mpi/openmpi-1.8.5_intel-15.0.2
module switch compiler_intel/15.0.2 compiler_intel/2017
# this serial version of mlp was installed with the default modules loaded by
# the cluster

###module purge
###module load compiler_intel/2017
###module load openblas/0.2.15
###module load gdb/7.9.1
###module load compiler_gnu/4.9.2
###module load mpi/openmpi-1.8.4_gnu-4.9.2


## this will creadte diff.cfg

#mpirun -n 8 $workDir/mlpFolder/mlp select-add pot.mtp train.cfg selected.cfg diff.cfg --selection-limit=200

$workDir/mlpFolder/mlp select-add pot.mtp train.cfg new.cfg diff.cfg

#/fslhome/chinchay/test/stable/mlipStable/bin/mlp select-add pot.mtp train.cfg new.cfg diff.cfg --selection-limit=200

echo "I finished with Active learning."

###cp train.cfg train_1.cfg
###cat train.cfg diff.cfg > temporal.cfg
###mv 8temporal.cfg train.cfg

###echo "I concatenated train.cfg and diff.cfg"


#####################################
FIN

sbatch job_ActiveLearning200

