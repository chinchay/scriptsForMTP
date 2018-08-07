

###this script should be in the folder scriptsCoNiTi

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir

cd ../reducedTest/backUp_1_scfVasp/
copyFromFolder=$PWD

cd $workDir

mkdir 1_scfVasp/
cd 1_scfVasp/


for i in {1..3}
do

  if [ $i == 1 ]
  then
    mkdir bcc/
    cd bcc
    mkdir toRunVasp/
    cp $copyFromFolder/bcc/folderNames.txt .
    conf="bcc"
  elif [ $i == 2 ]
  then
    mkdir fcc
    cd fcc
    mkdir toRunVasp/
    cp $copyFromFolder/fcc/folderNames.txt .
    conf="fcc"
  elif [ $i == 3 ]
  then
    mkdir hcp
    cd hcp
    mkdir toRunVasp/
    cp $copyFromFolder/hcp/folderNames.txt .
    conf="hcp"
  fi

  myPath=$PWD
  file="folderNames.txt"
  while IFS= read -r line
  do
    cd $myPath/toRunVasp/
    mkdir $line/
    cd $myPath/toRunVasp/$line
    cp $copyFromFolder/$conf/toRunVasp/$line/slurm* .
    cp $copyFromFolder/$conf/toRunVasp/$line/POSCAR .
    cp $copyFromFolder/$conf/toRunVasp/$line/OUTCAR .
    echo $line
     
  done <"$file"
  echo "I finished " $conf

  cd $workDir/1_scfVasp/
done

