/*****************************************************************************
* Program:
* fixing_POSCARs.cpp
*
* Author:
*    Carlos Leon
*
* Summary:
*
*     This program fixes the error in the POSCAR files generated by mlp. This
*     code make POSCAR suitable for VASP, deleting zero occupations. If the
*     occupation was 1 0 4 (ternary alloy) it would be replaced by 1 4, and a
*     corresponding POTCAR (containing only Co and Ti, with no Ni) is also
*     generated.
*
*****************************************************************************/

#include <iostream>
#include <fstream>      // input and output of files
#include <iomanip>      // we will use setw() in this code
#include <sstream>      //  used for  strinstream
#include <string>

#include <stdio.h>
#include <stdlib.h>


using namespace std;

/*****************************************************************************
* The configuration file is not prompted.
*****************************************************************************/
// void getFileName(string &fileName)
// {
   // fileName = "POSCAR";
   // return;
// }

/*****************************************************************************
* This funcion just gets the first lines to copy later in the file fixed.
*****************************************************************************/
void getHead(string head[], int nLinesHead, string &fileName)
{
   ifstream fin(fileName.c_str());

   // if (fin.fail())
      // throw "the file could no be oppened.";

   for (int i = 0; i < nLinesHead; i++)
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
void getTail(string tail[], string fileName, int numberOfLines, int nLinesTail)
{
   ifstream fin(fileName.c_str());

   // if (fin.fail())
      // throw "the file could no be oppened.";

   int readTillHere = numberOfLines - nLinesTail;

   char line[256];
   for (int i = 0; i < readTillHere; i++)
   {
      fin.getline(line,256);

   }

   for (int i = 0; i < nLinesTail; i++)
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
void getOccupation(int listOccupation[], string fileName, int nLinesHead)
{
   ifstream fin(fileName.c_str());

   int linestoSkip = nLinesHead;

   char line[256];
   for (int i = 0; i < linestoSkip; i++)
   {
      fin.getline(line,256);
   }

   fin.getline(line,256);

   // cout << line << endl;

   stringstream buffer(line);

   buffer >> listOccupation[0];

   if ( !(buffer >> listOccupation[1]) )
   {
      listOccupation[1] = 0;
   }

   if ( !(buffer >> listOccupation[2]) )
   {
      listOccupation[2] = 0;
   }
   // buffer >> listOccupation[1]; // Niquel
   // buffer >> listOccupation[2]; // Titanium
   // cout << listOccupation[0] <<" " << listOccupation[1] << " "<< listOccupation[2];
   fin.close();

   return;
}

/*****************************************************************************
* This funcion will replace the ./mlp head first line: "MLIP output to VASP" by
* a line containing the elements in the crystal, like makeStr2.py does.
* Here, we consider that ./mlp not necessarily returns the occupation of
* every atom: if it were Co,Ti then mlp would have written n1 0 n2. However,
* if it were Co,Ni then mlp would have written n1 n2.
*****************************************************************************/
void getNewFirstLineHead(int listOccupation[], string head[])
{
   string atomsLine = "";
   if (listOccupation[0] > 0)
   {
      atomsLine += "Co ";
   }

   if(listOccupation[1] > 0)
   {
      atomsLine += "Ni ";
   }

   if(listOccupation[2] > 0)
   {
      atomsLine += "Ti ";
   }
   // cout << listOccupation[0] << "---" << listOccupation[1] << "---" << listOccupation[2] << endl;
   string previousLine = head[0];
   head[0] = atomsLine + "      # # # # # orginal head: " + previousLine;

   if ( atomsLine != "Co Ni Ti ")
   {
      cout << ">>>>>>> Here we had a 0 concentration but I fixed it." << endl;
   }

   return;
}


/*****************************************************************************
* This function creates the new occupation list, in a string format, suitable
* for the version of VASP in the FSL cluster.
*****************************************************************************/
void getNewListOccupation(int listOccupation[], string newListOccupation[])
{

   for (int i = 0; i < 3; i++)
   {
      ostringstream convert;  // definiendo, para la parte en que int se convierte a string.
      convert << listOccupation[i]; // APPENDing datos a "convert" << be careful, this APPENDS!!
      // cout << convert.str() << endl;
      newListOccupation[i] =
      (listOccupation[i] > 0) ? convert.str() : string(""); // convirtiendo a string
      // (listOccupation[i] > 0) ? to_string(listOccupation[i]) : string(""); // convirtiendo a string

   }
   return;
}

/*****************************************************************************
* This function creates the new occupation list, in a string format, suitable
* for the version of VASP in the FSL cluster.
*****************************************************************************/
void getPOTCAR(int listOccupation[])
{
   string Co_POTCAR_file = "Co_POTCAR ";
   string Ni_POTCAR_file = "Ni_POTCAR ";
   string Ti_POTCAR_file = "Ti_POTCAR ";

   string listPOTCARs[3] = {Co_POTCAR_file, Ni_POTCAR_file, Ti_POTCAR_file};

   string concat = "cat ";

   for(int i = 0; i < 3; i++)
   {
      concat = concat +
               ( (listOccupation[i] > 0) ? listPOTCARs[i] : string("") );
   }

   concat = concat +  " > POTCAR";

   // cout << concat;

   system(concat.c_str());

   return;
}

/*****************************************************************************
* This funcion writes head, struct data, and tail into the fixed file.
*****************************************************************************/
void writeNewPOSCAR(string head[], string newListOccupation[], string tail[],
                    int nLinesHead, int nLinesTail)
{
   string fixedFile = "fixedPOSCAR";
   ofstream fout(fixedFile.c_str());

   for (int i = 0; i < nLinesHead; i++)
      fout << head[i] << endl;

   fout << newListOccupation[0] << " ";
   fout << newListOccupation[1] << " ";
   fout << newListOccupation[2] << "\n";

   for (int i = 0; i < nLinesTail; i++)
      fout << tail[i] << endl;

   fout.close();

   return;

}

/**********************************************************************
 * Function: main
 * Purpose: This is the entry point and driver for the program.
 ***********************************************************************/
int main()
{
   string fileName = "POSCAR";

   int nLinesHead = 5;
   string head[nLinesHead];

   int listOccupation[3];
   string newListOccupation[3];

   int numberOfLines = getNumberOfLines(fileName);

   int nLinesTail = numberOfLines - nLinesHead - 1; // '1' from the occupation line
   string tail[nLinesTail];


   // try
   // {
      getHead(head, nLinesHead, fileName);
   // }
   // catch (string message)
   // {
      // cout << "Error" << message << endl;
   // }

   getOccupation(listOccupation, fileName, nLinesHead);

   getNewFirstLineHead(listOccupation, head);
   // cout << head[0] << endl;


   getTail(tail, fileName, numberOfLines, nLinesTail);

   getNewListOccupation(listOccupation, newListOccupation);

   writeNewPOSCAR(head, newListOccupation, tail, nLinesHead, nLinesTail);

   getPOTCAR(listOccupation);

   return 0;
}

/***********************************************************************
* The POSCAR had the following face:
MLIP output to VASP
1
            1.365         1.365             0
           -1.365         1.365             0
                0             0          5.46
 2 0 2
cart
                0             0             0
                0         1.365         1.365
                0             0          2.73
                0         1.365         4.095
*************************************************************************/
