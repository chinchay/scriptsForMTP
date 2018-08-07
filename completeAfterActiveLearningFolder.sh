###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir


for i in {200..277}
do
  cd $workDir/5_afterActiveLearning/runVasp/POSCAR$i
  sbatch jobVasp
done
