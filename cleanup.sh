#!/bin/bash

datediff() {
    d1=$(date -d "$today" +%s)
    d2=$(date -d "$fileChanged" +%s)
    echo $(( (d1 - d2) / 86400 ))
}

today=$(date -d 'now')
daysInput=$1

if [ -z $daysInput ];then
  daysInput=180
  echo "set default 180 days retention"
fi

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
                echo $directory "is deleted, it was "$days " days old"
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
