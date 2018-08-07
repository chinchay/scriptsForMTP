###this script should be in the folder scriptsCoNiTi
 module purge
 module load python/3

scriptsFolder=$PWD



################################################################################
# Compiling code for fixing POSCARs to make it suitable for VASP as it
# will not accept zero-occupation.
# Here, POSCAR is created by makeStr.py, and its newer versions write
# zero occupation. To fix this run fixing_POSCARs.cpp, that was created for
# fixing POSCARs from ./mlp, but now it is also useful.
#################################################################################
cd $scriptsFolder
g++ fixing_POSCARs.cpp # the output is a.out
mv a.out fixing_POSCARs.out


###cp /fslhome/glh43/enumlib/trunk/enum.x .
cd ..

workDir=$PWD
echo "working folder is " $workDir


############ preparing for VASP runnings #######################################
mkdir 1_scfVasp
cd 1_scfVasp/
scfDir=$PWD

for i in {1..3}
do

  if [ $i -eq 1 ]
  then
    cd $scfDir
    mkdir bcc ; cd bcc/
    cp $scriptsFolder/structEnum_all/bcc/struct_enum.in .
    nAtoms=8 
  elif [ $i == 2 ]
  then
    cd $scfDir
    mkdir fcc ; cd fcc
    cp $scriptsFolder/structEnum_all/fcc/struct_enum.in .
    nAtoms=8
  elif [ $i == 3 ]
  then
    cd $scfDir
    mkdir hcp ; cd hcp
    cp $scriptsFolder/structEnum_all/hcp/struct_enum.in .
    nAtoms=4
  fi

  cp $scriptsFolder/CARS/* .
  cp $scriptsFolder/enum.x .
  cp $scriptsFolder/makeStr.py .
  cp $scriptsFolder/prepareForVASP.py .
  cp $scriptsFolder/vaspPotcars/Co/POTCAR Co_POTCAR
  cp $scriptsFolder/vaspPotcars/Ni/POTCAR Ni_POTCAR
  cp $scriptsFolder/vaspPotcars/Ti/POTCAR Ti_POTCAR
  cp $scriptsFolder/getKPoints .
  cp $scriptsFolder/fixing_POSCARs.out .
  mkdir toRunVasp


  
  
  echo "running python... looking for structures with size =" $nAtoms " atoms"
  python3 prepareForVASP.py $nAtoms
  # This will generate POSCAR, POTCAR, and myJob files in each folder








done

################## Submitting to queue #########################################

file="folderNames.txt"

for i in {1..3}
do
  if [ $i == 1 ]
  then
    cd $workDir/1_scfVasp/bcc/
    myPath=$PWD
  elif [ $i == 2 ]
  then
    cd $workDir/1_scfVasp/fcc/
    myPath=$PWD
  elif [ $i == 3 ]
  then
    cd $workDir/1_scfVasp/hcp/
    myPath=$PWD
  fi

  while IFS= read -r line
  do
    cd $myPath/toRunVasp/$line
    # sbatch myJob
  done <"$file"

done

################################################################################
