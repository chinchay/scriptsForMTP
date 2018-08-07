/*****************************************************************************
* Program:
* fixing_cfgFiles.cpp
*
* Author:
*    Carlos Leon
*
* Summary:
*
*     This program fixes the error in the types of diff.cfg files. If a
*     POSCAR file have the element types Ti and Ni, 4 atoms of both in every
*     unit cell, and the .cfg file has types  0 0 0 0 1 1 1 1, then the Program
*     should replace it by 1 1 1 1 2 2 2 2.
*
*****************************************************************************/

#include <iostream>
#include <fstream>      // input and output of files
#include <iomanip>      // we will use setw() in this code
#include <sstream>      //  used for  strinstream
#include <string>
using namespace std;

/*****************************************************************************
* Struct of atomic cell data
*****************************************************************************/
struct AtomData
{
   int id;
   int type;
   string cartes_x;
   string cartes_y;
   string cartes_z;
   string fx;
   string fy;
   string fz;
};

/*****************************************************************************
* The configuration file is not prompted.
*****************************************************************************/
// void getFileName(string &fileName)
// {
   // fileName = "diff.cfg";
   // return;
// }

/*****************************************************************************
* This funcion just gets the first lines to copy later in the file fixed.
*****************************************************************************/
void getHead(string head[], int linesHead, string &fileName)
{
   ifstream fin(fileName.c_str());

   // if (fin.fail())
      // throw "the file could no be oppened.";

   for (int i = 0; i < linesHead; i++)
   {
      getline(fin, head[i]);
      // cout << head[i] << endl;
   }

   fin.close();

   return;
}

/*****************************************************************************
* This funcion gets the number of lines in the file *.cfg
*****************************************************************************/
int getNumberOfLines(const string &fileName)
{
   ifstream fin(fileName.c_str());

   // if (fin.fail())
      // throw "the file could no be oppened.";

   char line[256];

   int numberOfLines = 0;
   while (fin.getline(line,256))
   {
      numberOfLines++;
   }

   fin.close();

   return numberOfLines;
}

/*****************************************************************************
* This funcion just gets the last lines to copy later in the fixed file.
*****************************************************************************/
void getTail(string tail[8], int linesHead, int numberOfAtoms, int linesTail, string fileName)
{
   ifstream fin(fileName.c_str());

   // if (fin.fail())
      // throw "the file could no be oppened.";
   int linestoSkip = linesHead + numberOfAtoms;
   // int readTillHere = numberOfLines - linesRemaining;

   char line[256];
   // for (int i = 0; i < readTillHere; i++)
   for (int i = 0; i < linestoSkip; i++)
   {
      fin.getline(line,256);

   }

   for (int i = 0; i < linesTail; i++)
   {
      getline(fin, tail[i]);
      // cout << tail[i] << endl;
   }

   fin.close();

   return;
}

/*****************************************************************************
* This funcion gets the atomic data cell of the *.cfg file.
*****************************************************************************/
void getAtomData(AtomData data[], int linesHead, int numberOfAtoms, string fileName)
{
   ifstream fin(fileName.c_str());;

   char line[256];
   for (int i = 0; i < linesHead; i++)
   {
      fin.getline(line,256);
   }

   for (int i = 0; i < numberOfAtoms; i++)
   {
      fin.getline(line,256);

      stringstream buffer(line);
      buffer >> data[i].id;
      buffer >> data[i].type;
      buffer >> data[i].cartes_x;
      buffer >> data[i].cartes_y;
      buffer >> data[i].cartes_z;
      buffer >> data[i].fx;
      buffer >> data[i].fy;
      buffer >> data[i].fz;

      // cout << setw(14) << data[i].id;
      // cout << setw(5)  << data[i].type;
      // cout << setw(15) << data[i].cartes_x;
      // cout << setw(14) << data[i].cartes_y;
      // cout << setw(14) << data[i].cartes_z;
      // cout << setw(13) << data[i].fx;
      // cout << setw(12) << data[i].fy;
      // cout << setw(12) << data[i].fz << endl;
   }

   fin.close();

   return;
}

/*****************************************************************************
* this funcion will tell you if the type atoms in diff.cfg are ordered. If
* they are not ordered this program would need changes, or you would need to
* take care of the conversion types manually. Sorry :-/
*****************************************************************************/
bool areTypesOrdered(AtomData data[], int numberOfAtoms)
{
   int tipo0;
   int tipo;

   for (int i = 0; i < numberOfAtoms; i++)
   {
      if (i == 0)
      {
         tipo0 = data[i].type;
      }
      else
      {
         tipo = data[i].type;
         if (tipo0 <= tipo)
         {
            tipo0 = tipo;
         }
         else
         {
            cout << "type numbers are non ordered!!!\n";
            cout << "you should need to handle with diff.cfg manually.\n\n";
            return false;
         }
      }
   }
   return true;
}

/*****************************************************************************
* This funcion gets how many times a type element appears in the *.cfg file.
*****************************************************************************/
void getOccupation(AtomData data[], int numberOfAtoms, int occupation[])
{
   int tipo;
   int j = 0;
   occupation[0] = 0;
   occupation[1] = 0;
   occupation[2] = 0;

   for (int i = 0; i < numberOfAtoms; i++)
   {
      if (i == 0)
      {
         tipo = data[i].type;
         occupation[j] = 1;
      }
      else
      {
         if (tipo == data[i].type)
            occupation[j]++;
         else
         {
            tipo = data[i].type;
            j++;
            occupation[j] = 1;
         }
      }
   }

   return;
}

/*****************************************************************************
* This funcion just initializes the array listType with -1's.
*****************************************************************************/
void initialize(int listType[], int numberOfAtoms)
{
   for (int i = 0; i < numberOfAtoms; i++)
      listType[i] = -1;

   return;
}

/*****************************************************************************
* This funcion reads which elements (Co, Ni or Ti) are in the POSCAR file. The
* listType array is built by knowing the occupation of each atom. For example,
* if the elements in the POSCAR are Ni and Ti, and the occupation are 3 and 5,
* then the listType would be = 1 1 1 2 2 2 2 2, where '1' refers to Ni, and
* '2' refers to Ti.
*****************************************************************************/
void getListType(int listType[], int occupation[])
{
   string poscarFile = "POSCAR";
   string type;

   int idType[3] = {-1, -1, -1};

   ifstream fin(poscarFile.c_str());

   for (int i = 0; i < 3; i++)
   {
      fin >> type;

      if (type == "Co")
      {
         // cout << "Cobalto  ";
         idType[i] = 0;
      }
      else if (type == "Ni")
      {
         // cout << "Niquel  ";
         idType[i] = 1;
      }

      else if (type == "Ti")
      {
         // cout << "Titanium  ";
         idType[i] = 2;
      }
   }

   fin.close();
   //cout << occupation[0] << "-" << occupation[1] << "-" << occupation[2] << endl;

   int k = 0;
   for (int i = 0; i < 3; i++)
   {
      for (int j = 0; j < occupation[i]; j++)
      {
         listType[k] = idType[i];
         k++;
      }
   }

   for (int i = 0; i < 8; i++)
   {
      // cout << listType[i] << endl;
   }


   return;
}

/*****************************************************************************
* This funcion replaces the data.type's by the listType array, so it fixes
* the types.
*****************************************************************************/
void fixTypeElement(AtomData data[], int listType[], int numberOfAtoms)
{
   for (int i = 0; i < numberOfAtoms; i++)
   {
      data[i].type = listType[i];
   }

   return;
}

/*****************************************************************************
* This funcion writes head, struct data, and tail into the fixed file.
*****************************************************************************/
void writeNewCfg(AtomData data[], int numberOfAtoms, string head[], string tail[])
{
   string fixedFile = "diff_fixed.cfg";
   ofstream fout(fixedFile.c_str());

   for (int i = 0; i < 8; i++)
      fout << head[i] << endl;


   for (int i = 0; i < numberOfAtoms; i++)
   {
            fout << setw(14) << data[i].id;
            fout << setw(5)  << data[i].type;
            fout << setw(15) << data[i].cartes_x;
            fout << setw(14) << data[i].cartes_y;
            fout << setw(14) << data[i].cartes_z;
            fout << setw(13) << data[i].fx;
            fout << setw(12) << data[i].fy;
            fout << setw(12) << data[i].fz << endl;
   }

   for (int i = 0; i < 6; i++)
   {
      fout << tail[i] << endl;
   }

   fout.close();

   return;

}

/**********************************************************************
 * Function: main
 * Purpose: This is the entry point and driver for the program.
 ***********************************************************************/
int main()
{
   string fileName = "diff.cfg";
   int const linesHead = 8;
   int const numberOfAtoms = 8;
   int const linesTail = 6;
   int numberOfLines = getNumberOfLines(fileName);

   string head[linesHead];
   AtomData data[numberOfAtoms];
   string tail[linesTail];

   // try
   // {
      getHead(head, linesHead, fileName);

   // }
   // catch (string message)
   // {
      // cout << "Error" << message << endl;
   // }

   getTail(tail, linesHead, numberOfAtoms, linesTail, fileName);

   getAtomData(data, linesHead, numberOfAtoms, fileName);

   bool areOrdered = areTypesOrdered(data, numberOfAtoms);

   if (areOrdered)
   {
      int occupation[3];
      getOccupation(data, numberOfAtoms, occupation);

      int listType[numberOfAtoms];
      initialize(listType, numberOfAtoms);

      getListType(listType, occupation);

      fixTypeElement(data, listType, numberOfAtoms);


      writeNewCfg(data, numberOfAtoms, head, tail);
   }
   else
   {
      cout << "Because types are not ordered, ";
      cout << "you should order diff.cfg manually. \n\n";
   }

   return 0;
}

/***********************************************************************
* The *.cfg file has the following face:

BEGIN_CFG
 Size
    8
 Supercell
        -2.870000      0.000000      2.870000
         0.000000     -5.740000      0.000000
         4.305000     -1.435000      1.435000
 AtomData:  id type       cartes_x      cartes_y      cartes_z           fx          fy          fz
             1    0       0.000000      0.000000      0.000000    -0.061748   -0.141426   -0.061748
             2    0       1.435000     -1.435000      1.435000    -0.003687   -0.012858   -0.003687
             3    0       0.000000     -2.870000      2.870000     0.232110    0.368754    0.232110
             4    1      -1.435000     -1.435000      1.435000    -0.105045    0.366426   -0.105045
             5    1       1.435000     -4.305000      1.435000    -0.041126   -0.188016   -0.041126
             6    1      -1.435000     -4.305000      1.435000     0.138471   -0.368570    0.138471
             7    1       0.000000     -5.740000      2.870000    -0.154100   -0.210589   -0.154100
             8    2       0.000000     -2.870000      0.000000    -0.004875    0.186281   -0.004875
 Energy
        -50.565676610000
 PlusStress:  xx          yy          zz          yz          xz          xy
        -5.07408    -5.00971    -5.07408     0.00534    -0.23650     0.00534
 Feature   EFS_by       VASP
END_CFG
*************************************************************************/
