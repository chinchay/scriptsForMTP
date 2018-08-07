
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
python3 $scriptsFolder/makeStr.py 1 79260 -species Co Ni Ti -config t -output=to_relax.cfg
#python3 $scriptsFolder/makeStr.py 1 7482 -species Co Ni Ti -config t -output=to_relax.cfg
# it creates a vasp.() file instead of to_relax.cfg. Ask Wiley :/
# Then you will need to concatenate the vasp.{} files of bcc, fcc, and hcp folders.

## struct_enum.in tells to run from 1 to 10 size cells
cd ../fcc
$scriptsFolder/enum.x
python3 $scriptsFolder/makeStr.py 1 79260 -species Co Ni Ti -config t -output=to_relax.cfg
#python3 $scriptsFolder/makeStr.py 1 7482 -species Co Ni Ti -config t -output=to_relax.cfg

# struct_enum.in tells to run from 1 to 5 size cells
cd ../hcp
$scriptsFolder/enum.x
python3 $scriptsFolder/makeStr.py 1 36963 -species Co Ni Ti -config t -output=to_relax.cfg
#python3 $scriptsFolder/makeStr.py 1 5568 -species Co Ni Ti -config t -output=to_relax.cfg

## being in 3_allStructures folder:
cd $allStructuresDir
cat bcc/vasp.\{\} fcc/vasp.\{\} hcp/vasp.\{\} > tempFile
mv tempFile to_relax.cfg


################################################################################
# relaxing all structures using mlp instead of DFT
################################################################################
cd $workDir
mkdir 4_toRelax
cd 4_toRelax/
toRelaxDir=$PWD

cp $scriptsFolder/toRelax/relax.ini .
cp $workDir/2_myTraining/state.mvs  .
cp $workDir/2_myTraining/pot.mtp    .
cp $allStructuresDir/to_relax.cfg   .

cat > "jobRelaxAll" << FIN
#!/bin/bash
####################################

#SBATCH --time=48:00:00   # walltime
#SBATCH --ntasks=8   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=2048M   # memory per CPU core
#SBATCH -J "jobRelaxAll"   # job name
#SBATCH --mail-user=carlos.leon.chinchay@gmail.com   # email address
#SBATCH --mail-type=FAIL
#SBATCH -p physics

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module purge
module load mpi/openmpi-1.8.5_intel-15.0.2
module switch compiler_intel/15.0.2 compiler_intel/2017

#module purge
#module load compiler_intel/2017
#module load openblas/0.2.15
#
#module load gdb/7.9.1
#module load compiler_gnu/4.9.2
#module load mpi/openmpi-1.8.4_gnu-4.9.2


mpirun -n 8 $workDir/mlpFolder/mlp relax relax.ini --cfg-filename=to_relax.cfg

echo "I finished with relaxation. Concatenating..."

cat selected.cfg_*  >  selected.cfg

## last step would concatenate 16 (for 16processors) files.
####################################
FIN


sbatch jobRelaxAll

