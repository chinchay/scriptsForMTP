#This script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir

cd mlpFolder/
mlpDir=$PWD

########## compiling c++ code to fix diff.cfg files. Used for training ternary Co Ni Ti alloys
cd $scriptsFolder
g++ fixing_cfgFiles.cpp  ## will produce a.out

############### CONCATENATING ###########################################
## being in $HOME/compute/CoNiTi/
module purge
module load mpi/openmpi-1.8.5_intel-15.0.2
module switch compiler_intel/15.0.2 compiler_intel/2017

##module load compiler_intel/13.0.1
##module load compiler_intel/2017  #this is for the new mlp
##module load openblas/0.2.15    #this is for the new mlp
##module load gdb/7.9.1
##module load compiler_gnu/4.9.2
##module load mpi/openmpi-1.8.4_gnu-4.9.2
##module load python/3  ## this is for my python scripts, not for mlp



cd $workDir/7_MTPRelaxedPoscarsInConvexHull/vaspRuns/
vaspRun=$PWD

touch subTraining.cfg

file="folderNames"
while IFS= read -r line
do
   cd $vaspRun/$line
   
   $mlpDir/mlp convert-cfg OUTCAR diff.cfg --input-format=vasp-outcar >> outcar.txt
   # The last step creates a 'diff.cfg' file in each folder,

   ##########################################################################
   #### fixing type elements, suitable for later training of trin-ary systems
   ##########################################################################
   cp $scriptsFolder/a.out .
   ./a.out
   # this fixes diff.cfg type elements (put 1 1 1 2 3 instead
   # of 0 0 0 1 2 for example). Suitable for training with
   # ternary elements
   #rm a.out
   cp diff.cfg diff_backup.cfg
   mv diff_fixed.cfg diff.cfg
   ##########################################################################
   
   cd $vaspRun
   cat subTraining.cfg $vaspRun/$line/diff.cfg > tempFile.txt
   mv tempFile.txt subTraining.cfg
   echo $line
done < "$file"
echo "I've finished."


