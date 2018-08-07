###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir

################## Submitting to queue #########################################
for i in {0..118} ## mlp just chosed, in this case, 119 structures
do
  cd $workDir/5_afterActiveLearning/runVasp/POSCAR$i
  sbatch jobVasp
done

