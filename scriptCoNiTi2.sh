
###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir


#################### copying mlp ###############################################
mkdir mlpFolder
cd mlpFolder
  mlpDir=$PWD
  # cp  /fslgroup/fslg_datamining/MTP/readme.txt        .
  # cp  /fslgroup/fslg_datamining/MTP/mlip-dev/bin/mlp  .
   cp  /fslhome/chinchay/fixed_mlip_dev/mlip/bin/mlp     .
  #cp  /fslhome/chinchay/lessMemory_mlip/mlip/bin/mlp     .
  # cp  /fslgroup/fslg_datamining/MTP/moduleListMTP     .
cd ..

########## compiling c++ code to fix diff.cfg files. Used for training ternary Co Ni Ti alloys
cd $workDir/scriptsCoNiTi/
g++ fixing_cfgFiles.cpp  ## will produce a.out


############### CONCATENATING ###########################################
## being in $HOME/compute/CoNiTi/
module purge
module load mpi/openmpi-1.8.5_intel-15.0.2
module switch compiler_intel/15.0.2 compiler_intel/2017

##module load compiler_intel/13.0.1
##module load compiler_intel/2017  #this is for the new mlp
##module load openblas/0.2.15      #this is for the new mlp
##module load gdb/7.9.1
##module load compiler_gnu/4.9.2
##module load mpi/openmpi-1.8.4_gnu-4.9.2
##module load python/3  ## this is for my python scripts, not for mlp

##for i in {1..3}
##do
##
##  if [ $i == 1 ]
##  then
##    cd $workDir/1_scfVasp/bcc/
##    conf="bcc"
##  elif [ $i == 2 ]
##  then
##    cd $workDir/1_scfVasp/fcc/
##    conf="fcc"
##  elif [ $i == 3 ]
##  then
##    cd $workDir/1_scfVasp/hcp/
##    conf="hcp"
##  fi
##
##  myPath=$PWD
##  touch subTraining.cfg
##  file="folderNames.txt"
##  while IFS= read -r line
##  do
##    cd $myPath/toRunVasp/$line
##    $mlpDir/mlp convert-cfg OUTCAR diff.cfg --input-format=vasp-outcar >> outcar.txt
##    # The last step creates a 'diff.cfg' file in each folder,
##
      ##########################################################################
      #### fixing type elements, suitable ofr later training of tri-nary sysytems
      ##########################################################################
##      cp $workDir/scriptsCoNiTi/a.out .
##      ./a.out
##      # this fixes diff.cfg type elements (put 1 1 1 2 3 instead
##      # of 0 0 0 1 2 for example). Suitable for training with ternary elements
##      #rm a.out
##      cp diff.cfg diff_backup.cfg
##      mv diff_fixed.cfg diff.cfg
      ##########################################################################

##    cd $myPath
##    cat subTraining.cfg $myPath/toRunVasp/$line/diff.cfg > tempFile.txt
##    mv tempFile.txt subTraining.cfg
##    echo $line
##  done <"$file"
##  echo "I finished " $conf

## done

## cd $workDir/1_scfVasp/
## myPath=$PWD
## cat $myPath/bcc/subTraining.cfg $myPath/fcc/subTraining.cfg $myPath/hcp/subTraining.cfg > train.cfg


###################### TRAINING ################################################
cd $workDir
mkdir 2_myTraining
cd 2_myTraining
cp $workDir/1_scfVasp/train.cfg .
#### cp /fslgroup/fslg_datamining/MTP/train/pot.mtp .  <<< this pot.mtp is WRONG!!!
cp $workDir/scriptsCoNiTi/pot.mtp .
### this pot.mtp is from Wiley, already corrected and with  species_count = 3 (ternary)
#cp /fslgroup/fslg_datamining/MTP/train/readme.txt .



cat > "jobTraining" << FIN
#!/bin/bash
####################################

#SBATCH --time=03:00:00   # walltime
#SBATCH --ntasks=16   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=1024M   # memory per CPU core
#SBATCH -J "Job_training"   # job name
#SBATCH --mail-user=carlos.leon.chinchay@gmail.com   # email address
#SBATCH --mail-type=FAIL
#SBATCH -p physics


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

###mpirun -n 16 /fslhome/chinchay/fixed_mlip_dev/mlip/bin/mlp train pot.mtp train.cfg > training.txt
mpirun -n 16 $mlpDir/mlp train pot.mtp train.cfg > training.txt

echo "training finished. Moving Trained.mtp_ to pot.mtp..."

mv Trained.mtp_ pot.mtp
$mlpDir/mlp calc-grade pot.mtp train.cfg train.cfg temp1.cfg
#### the last step will create two additional files: state.mvs and temp1.cfg

####################################
FIN



sbatch jobTraining

