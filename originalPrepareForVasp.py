### this works with python3, as it uses print(something, end="")

import random
import sys
import os
from random import randint
import re  # Python regular expressions module
import numpy as np

#*******************************************************************************
# This function reads a file and stores the lines in the array "lines"
#*******************************************************************************
def getLines(fileName):
    # store the entire file in lines[]
    lines = [] #Declare an empty list named "lines"

    with open (fileName, 'rt') as f:  # Open file for reading.
        for line in f: # Store each line in a string variable "line"
            lines.append(line)  #add that line to our list of lines.

    return lines;

#*******************************************************************************
# This function returns the index of the head of structures data.
#*******************************************************************************
def getHeadIndex(lines, size):
    wordToSearch = "#tot"
    for i in range(0, size - 1):
        if wordToSearch in lines[i]:
                print("I found the line containing ", wordToSearch)   ## <<<<<<<<<<<<<<<<<<<<<<<< tuve que comentar para que funcione con python2.6
                iHead = i
                return iHead; # stop when the head is found!

#*******************************************************************************
# just save data to a file in a matrix form
#*******************************************************************************
def createMatrixFile(fileMatrix, lines, iFirst, iLast):
        f = open(fileMatrix, "w")
        for i in range(iFirst, iLast + 1):
            f.write(lines[i])
        f.close();

#*******************************************************************************
# This function returns a column of integers from a matrix saved in a file,
# extracting a column of a fileName (without labels in the head!)
#*******************************************************************************
def getIndxHavingNatoms(fileMatrix, colIndx, colNatoms, nAtoms):
        file    = np.loadtxt(fileMatrix)
        lIndx   = file[:, colIndx]
        lNatoms = file[:, colNatoms]
        
        lIndxNatoms = []
        for i in range( 0, len(lIndx) ):
            numberOfAtoms = int( lNatoms[i] )
            indx = int( lIndx[i] )
            if ( numberOfAtoms == nAtoms ):
                lIndxNatoms.append(indx)
        return lIndxNatoms

#*******************************************************************************
# This function returns a new array made up of the elements of the array "lines"
#*******************************************************************************
def getRandomLines(lines, size, nRandomSamples, iHead, nAtoms):
    randomLines = []
    iLast       = size - 1
    iFirst      = iHead + 1
    maxSamples  = iLast - iFirst + 1

    fileMatrix = "matrixDataOfStr.txt"
    colIndx    = 0 # indexes: "123" in bcc123 for example.
    colNatoms  = 6 # column with the number of atoms in a superstructure
    #nAtoms     = 8

    # to avoid repetition of samples in the randomly chose,
    # we must make sure there are enough lines
    if nRandomSamples < maxSamples :
        createMatrixFile(fileMatrix, lines, iFirst, iLast)
        lIndxNatoms  = getIndxHavingNatoms(fileMatrix, colIndx, colNatoms, nAtoms)
        randomInts = random.sample( range(0, len(lIndxNatoms)), nRandomSamples)

        #array of indexes, chosen randomly, which structures have nAtoms.
        randomStrIndx = []
        for i in randomInts:
            indx = int( lIndxNatoms[i] )
            print("Structure indx = ", indx, " is taken from file.")
            randomStrIndx.append(indx)

    else:
        print("nRandom > number of Samples. Stopping...")
        return;

    #print(randomStrIndx)
    return randomStrIndx;

#*******************************************************************************
# this function chooses 200 structures randomly
#*******************************************************************************
def chooseRandom(fileName, nRandomSamples, nAtoms):
    print("choosing  structures randomly...")

    lines = getLines(fileName) # it is an array of lines from the file fileName.
    size  = len(lines)
    iHead = getHeadIndex(lines, size)
    indexLines = getRandomLines(lines, size, nRandomSamples, iHead, nAtoms)

    #print(indexLines)

    return indexLines;

#*******************************************************************************
# this function joins POTCARs of Co,Ni,Ti as asked by vasp file (it could be Co, Ti !!!)
#*******************************************************************************
def getPOTCAR(vaspFile):
    Co_POTCAR_file = "Co_POTCAR "
    Ni_POTCAR_file = "Ni_POTCAR "
    Ti_POTCAR_file = "Ti_POTCAR "

    # print(vaspFile)
    readFile = open(vaspFile)
    lines    = readFile.readlines()
    readFile.close()

    elements = [x.strip() for x in lines[0].split(' ')]

    concat = "cat "
    for i in range(0, len(elements)):
        if   "Co" == str(elements[i]) :
            concat = concat + Co_POTCAR_file
        elif "Ni" == str(elements[i]) :
            concat = concat + Ni_POTCAR_file
        elif "Ti" == str(elements[i]) :
            concat = concat + Ti_POTCAR_file

    concat = concat + " > POTCAR"
    # concat = "cat " + Co_POTCAR_file + Ni_POTCAR_file + Ti_POTCAR_file +  " > POTCAR"

    print(concat)
    os.system(concat)

#*******************************************************************************
# this function creates toRunVasp/i folders
#*******************************************************************************
def createFolder_i(i):
        path = "toRunVasp/" + str(i)
        os.makedirs( path ) # create directory "i"

#*******************************************************************************
# this function just copy files into toRunVasp/i folder
#*******************************************************************************
def copyCARS(vaspFile, path,i):
        run = "cp myJob " +  path + "/"
        os.system(run)
        os.system("rm myJob")

        run = "cp " + vaspFile + "  " + path + "/POSCAR"
        # print(run)
        os.system(run)

        run = "cp POTCAR " +  path + "/"
        os.system(run)

        run = "cp INCAR "  + path + "/"
        os.system(run)

        run = "cp PRECALC " + path + "/"
        os.system(run)

        run = "cp getKPoints " + path + "/"
        os.system(run)

#*******************************************************************************
# this function deletes vasp.i file
#*******************************************************************************
def deleteVaspFile(i):
        run = "rm vasp." + str(i)
        os.system(run)


def getKPoints(path,i):
        run = "cd " + path + "; pwd; ./getKPoints ; cd ../.. "
        os.system(run)

def getJob(i):
        jobID = '\"v' + str(i) + '\"'

        file = open ("myJob", "w")

        file.write("#!/bin/bash\n\n")
        file.write("#SBATCH --time=03:00:00   # walltime\n\n")
        file.write("#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)\n\n")
        file.write("#SBATCH --nodes=1   # number of nodes\n\n")
        file.write("#SBATCH --mem-per-cpu=6144M   # memory per CPU core\n\n")
        file.write("#SBATCH -J " )
        # file.write(" \"job\"  ")
        file.write(jobID)
        file.write("# job name\n\n")
        file.write("#SBATCH -p physics\n\n")
        file.write("#SBATCH --mail-user=carlos.leon.chinchay@gmail.com #email address\n\n")
        file.write("#SBATCH --mail-type=FAIL\n\n")
        #file.write("# Set the max number of threads to use for programs using ")
        #file.write("OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.\n")
        #file.write("export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE\n\n")
        file.write("# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE\n")
        file.write("module purge\n")
        file.write("module load compiler_intel/13.0.1\n")
        file.write("module load gdb/7.9.1\n")
        file.write("module load compiler_gnu/4.9.2\n")
        file.write("module load mpi/openmpi-1.8.4_gnu-4.9.2\n")
        #file.write("/fslhome/glh43/vasp")
        file.write("/fslhome/glh43/bin/vasp54s")

        file.close()


def getFolderNames():
    run = "cd toRunVasp; ls > folderNames.txt ; cp folderNames.txt ../ ; rm folderNames.txt"
    os.system(run)

    myFile = "folderNames.txt"

    # se removio la ultima linea proque estava el nombre del mismo archivo, ^^'
    readFile = open(myFile)
    lines = readFile.readlines()
    readFile.close()

    w = open(myFile,'w')
    w.writelines([item for item in lines[:-1]])
    w.close()


#*******************************************************************************
# Main
#*******************************************************************************
import sys
#for bcc and fcc: nAtoms = 8. For hcp: nAtoms=4
nAtoms = sys.argv[1] #first argument
nAtoms = int(nAtoms)

#x = nAtoms + 1
#print (str(x))
#print (nAtoms)


run = "./enum.x"
os.system(run)

fileName = "struct_enum.out"
nRandomSamples = 10
indexLines = chooseRandom(fileName, nRandomSamples, nAtoms)

for i in indexLines:
    # run = "python3 /Users/chinchay/Documents/2_codes/enumlib/aux_src/makeStr.py " + str(i) + " -species Co Ni Ti"
    #run = "python3 makeStr_1b.py " + str(i) + " -species Co Ni Ti"
    run = "python3 makeStr.py " + str(i) + " -species Co Ni Ti"
    os.system(run)

    path     = "toRunVasp/" + str(i)
    vaspFile = "vasp."  + str(i)

    createFolder_i(i)
    getJob(i) # create file "myJob"
    getPOTCAR(vaspFile)
    copyCARS(vaspFile,path,i)
    deleteVaspFile(i)
    getKPoints(path,i)

    getFolderNames()

    # os.chdir( str(i))
    # os.chdir("../")




run = "...end."
print(run)
