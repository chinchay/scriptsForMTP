

###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir


cd mlpFolder
  mlpDir=$PWD

########## compiling c++ code to fix diff.cfg files. Used for training ternary Co Ni Ti alloys
cd $workDir/scriptsCoNiTi/
g++ fixing_cfgFiles.cpp  ## will produce a.out


############### CONCATENATING ###########################################
## being in $HOME/compute/CoNiTi/
module purge
module load mpi/openmpi-1.8.5_intel-15.0.2
module switch compiler_intel/15.0.2 compiler_intel/2017

cd $workDir/test/convertToCFG/
prototypesFolder=$PWD

ls > 0_fileNames

# in the first line, the name "0_fileNames" was also displayed, so
# I cut the first line:
sed -i '1d' 0_fileNames

file="$prototypesFolder/0_fileNames"

$mlpDir/mlp convert-cfg OUTCAR diff.cfg --input-format=vasp-outcar >> outcar.txt

while IFS= read -r line
do
   echo "file = " $line


done <"$file"


