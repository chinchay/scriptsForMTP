###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cp /fslhome/glh43/enumlib/trunk/enum.x .
cd ..

workDir=$PWD
echo "working folder is " $workDir

################## Submitting to queue #########################################
min=1
max=200
one=1
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

  j=0
  while IFS= read -r line
  do
    j=$(( j + one ))
    if [ "$min" -le $j ] && [ $j -le "$max" ]
    then
      echo $j
      cd $myPath/toRunVasp/$line
      pwd
      sbatch myJob
    fi
  done <"$file"

done

################################################################################

