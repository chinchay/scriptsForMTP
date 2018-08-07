
###this script should be in the folder scriptsCoNiTi

#module purge
module load python/3

scriptsFolder=$PWD
cd ..

workDir=$PWD
echo "working folder is " $workDir

################################################################################
# generating all strcuture combinatinos of Co, Ni, and Ti
################################################################################

mkdir 3_allStructures
cd 3_allStructures
allStructuresDir=$PWD
mkdir bcc
mkdir fcc
mkdir hcp


cp $scriptsFolder/structEnum_all/bcc/struct_enum.in  bcc/
cp $scriptsFolder/structEnum_all/fcc/struct_enum.in  fcc/
cp $scriptsFolder/structEnum_all/hcp/struct_enum.in  hcp/

# struct_enum.in tells to run from 1 to 10 size cells
cd bcc
# it will show 79260 structures from 1 to 10 unit cells:
$scriptsFolder/enum.x
# makeStr joins all the POTCARs in the same vasp.{} file, using the struct_enum.out
# from last step:
#python3 $scriptsFolder/makeStr.py 1 79260 -species Co Ni Ti -config t -output=to_relax.cfg
python3 $scriptsFolder/makeStr.py 1 7482 -species Co Ni Ti -config t -output=to_relax.cfg
# it creates a vasp.() file instead of to_relax.cfg. Ask Wiley :/
# Then you will need to concatenate the vasp.{} files of bcc, fcc, and hcp folders.


## struct_enum.in tells to run from 1 to 10 size cells
cd ../fcc
$scriptsFolder/enum.x
#python3 $scriptsFolder/makeStr.py 1 79260 -species Co Ni Ti -config t -output=to_relax.cfg
python3 $scriptsFolder/makeStr.py 1 7482 -species Co Ni Ti -config t -output=to_relax.cfg

# struct_enum.in tells to run from 1 to 5 size cells
cd ../hcp
$scriptsFolder/enum.x
#python3 $scriptsFolder/makeStr.py 1 36963 -species Co Ni Ti -config t -output=to_relax.cfg
python3 $scriptsFolder/makeStr.py 1 5568 -species Co Ni Ti -config t -output=to_relax.cfg



## being in 3_allStructures folder:
cd $allStructuresDir
cat bcc/vasp.\{\} fcc/vasp.\{\} hcp/vasp.\{\} > tempFile
mv tempFile to_relax.cfg


