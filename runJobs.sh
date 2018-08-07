#!/bin/bash



myPath=`pwd`
file="folderNames.txt"

# cd toRun
# ls > $file
# pwd
# mv $file ../
# cd ..


# filetemp="filetemporal"
# cp $file $filetemp
# sed '$ d' $filetemp > $file
# rm -f $filetemp



while IFS= read -r line
do
        # display $line or do somthing with $line
  # printf '%s\n' "$line"
  cd $myPath/toRun/$line
  sbatch myJob
done <"$file"
