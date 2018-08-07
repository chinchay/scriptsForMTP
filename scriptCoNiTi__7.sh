
###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir


################################################################################
# SECOND RELAXATION
################################################################################
cd  9_toMTPrelaxWithRelaxedVasp/

cp ../8_trainingWithRelaxedVasp/state.mvs .
cp ../8_trainingWithRelaxedVasp/pot.mtp   .
rm select* # created by ./mlp in previous relaxation.
rm relaxed* #be careful to not delete relax.ini ^^' 

## files to_relax.cfg and relax.ini exist already there from in previous steps.

cat > "jobRelaxAll_2" << FIN
#!/bin/bash
####################################
#SBATCH --time=48:00:00   # walltime
#SBATCH --ntasks=16   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=2048M   # memory per CPU core
#SBATCH -J "jobRelaxAll_2"   # job name
#SBATCH --mail-user=carlos.leon.chinchay@gmail.com   # email address
#SBATCH --mail-type=FAIL
#SBATCH -p physics

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module purge
module load mpi/openmpi-1.8.5_intel-15.0.2
module switch compiler_intel/15.0.2 compiler_intel/2017

##already deleted above!
##rm select*
##echo "selec* deleted. Running mlp..."

mpirun -n 16 $workDir/mlpFolder/mlp relax relax.ini --cfg-filename=to_relax.cfg --save-relaxed=relaxed.cfg

echo "mlp finished. Concatenating..."

cat selected.cfg_*  >  selected.cfg
cat relaxed.cfg_* > relaxed.cfg

echo "I have finished."
####################################
FIN


sbatch jobRelaxAll_2





###

