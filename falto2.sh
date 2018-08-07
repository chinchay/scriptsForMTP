
###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir


module purge
module load mpi/openmpi-1.8.5_intel-15.0.2
module switch compiler_intel/15.0.2 compiler_intel/2017


cd  $workDir/5_afterActiveLearning/

cd justPOSCARs/


# we are in justPOSCARs folder!
while IFS= read -r line
do
  echo "file = " $line
  mkdir ../runVasp/$line/
  cp $line                      ../runVasp/$line/POSCAR
  cp $scriptsFolder/CARS/*      ../runVasp/$line/ # << copy INCAR and PRECALC.
  cp $scriptsFolder/getKPoints  ../runVasp/$line/
  cp $scriptsFolder/vaspPotcars/Co/POTCAR  ../runVasp/$line/Co_POTCAR
  cp $scriptsFolder/vaspPotcars/Ni/POTCAR  ../runVasp/$line/Ni_POTCAR
  cp $scriptsFolder/vaspPotcars/Ti/POTCAR  ../runVasp/$line/Ti_POTCAR

  # a.out is compiled from fixingPOSCARs.cpp to fix the POSCAR and get a POTCAR.
  cp $scriptsFolder/a.out       ../runVasp/$line/

  cd ../runVasp/$line/
    ./getKPoints
    cp POSCAR backupPOSCAR
    ./a.out  # fix the POSCAR (without 0 occupation)
             # and get a suitable POTCAR for VASP
    mv fixedPOSCAR POSCAR
    pwd

cat > "jobVasp" << FIN
#!/bin/bash
####################################
#SBATCH --time=04:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=3072M   # memory per CPU core
#SBATCH -J "VASP_$line"   # job name
#SBATCH --mail-user=carlos.leon.chinchay@gmail.com   # email address
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module purge
module load mpi/openmpi-1.8.5_intel-15.0.2
module switch compiler_intel/15.0.2 compiler_intel/2017

/fslhome/glh43/bin/vasp54s
####################################
FIN

  cd ../../justPOSCARs/ #return to justPOSCARs folder!
done <"foldersToCreate2"


for i in {0..199}
do
  cd $workDir/5_afterActiveLearning/runVasp/POSCAR$i
  sbatch jobVasp
done
