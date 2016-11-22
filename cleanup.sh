#!/bin/bash

datediff() {
    d1=$(date -d "$today" +%s)
    d2=$(date -d "$fileChanged" +%s)
    echo $(( (d1 - d2) / 86400 ))
}

today=$(date)

daysInput=180
buildsToKeep=15

if [ -n "$3" ]; then
    if [ \( "$3" = "-r" \) -o \( "$3" = "-R" \) ]; then
      if [[ $4 =~ ^[0-9]+$ ]]; then
        echo "setting retention to ${4} days"
        daysInput=$4
      else
        echo 'input for retention needs to be a number'
        exit
      fi
    elif [ \( "$3" = "-b" \) -o \( "$3" = "-B" \) ]; then
      if [[ $4 =~ ^[0-9]+$ ]]; then
        echo "setting minimum builds to keep to ${4} builds"
        buildsToKeep=$4
      else
        echo 'input for builds to keep needs to be a number'
        exit
      fi
    else
        echo "3: invalid input, please use -h option for help"
        exit
    fi
fi

if [ -n "$1" ]; then
    if [ "$1" = "-h" ]; then
      echo "use without parameters to run with default parameters, 180 days retention and minimum of 15 builds to keep"
      echo "-r      retention, set amount of days retention"
      echo "-b      builds, set minimum amount of builds to keep"
      echo "example use: ./cleanup.sh -r 90 -b 10"
      echo "this will cleanup any builds older than 90 days but won't delete anything when there is"
      echo "10 builds or less from a pipeline"
      exit
    elif [ \( "$1" = "-r" \) -o \( "$1" = "-R" \) ]; then
      if [[ $2 =~ ^[0-9]+$ ]]; then
        echo "setting retention to ${2} days"
        daysInput=$2
      else
        echo 'input for retention needs to be a number'
        exit
      fi
    elif [ \( "$1" = "-b" \) -o \( "$1" = "-B" \) ]; then
      if [[ $2 =~ ^[0-9]+$ ]]; then
        echo "setting minimum builds to keep to ${2} builds"
        buildsToKeep=$2
      else
        echo 'input for builds to keep needs to be a number'
        exit
      fi
    else
        echo "1: invalid input, please use -h option for help"
        exit
    fi
else
    echo "setting defaults: 180 days retention, minimum of 15 builds to keep"
fi

echo "starting script with ${daysInput} days retention"
echo "won't delete any pipelines if there is ${buildsToKeep} builds or less (left) in a pipeline."

basedir="/var/lib/go-server/artifacts/pipelines"
cd "${basedir}"

pipelines=$(ls -la | awk '{if($9 > 0) print $9}')

for pipeline in $pipelines;
do
  cd "${pipeline}"

  buildsCount=$(ls -la | awk '{if( $9 > 0 ) print $9}' | grep -c $)
  echo ${buildsCount} " builds in " $(pwd)

  allBuilds=$(ls -lart | awk '{if($9 > "0") print $9}')
  #only start if there is more than 15 builds in the pipeline
  if [ $buildsCount -gt 15 ]; then
    for directory in $allBuilds;
    do
      #evaluate build count in each iteration
      if [ $buildsCount -gt 15 ]; then

        fileChanged=$(stat -c %y $directory)
        days=$(datediff)

        if [ ${days} -gt ${daysInput} ]; then

            if [ "$(pwd)" = "${basedir}/${pipeline}" ]; then
                rm -r $directory
                echo $directory "is deleted, it was " $days " days old"
                #update build count after deleting 1
                buildsCount=$(( $buildsCount - 1 ))
            else
                echo "not in the correct direcotry, aborting job"
                exit
            fi

       fi
     else
       echo "15 builds or less left in this pipeline, not deleting anymore"
       break
     fi
   done
  else
   echo "15 builds or less in pipeline, not deleting anything"
  fi
# pop back up one level into ../pipelines before cd'ing into the next pipeline in the loop
 cd ..
done
