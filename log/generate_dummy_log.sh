#!/bin/bash 
outputfile=$1

# loop for simulating log generation -- we don't really care about the timestamp -- the format is the expected one
for i in {1..150000}
do 
    if ! (( $i % 5 ))
    then
        # simulating some multiline log
         echo -e "2024-03-04 01:29:09.533811 INFO Message multiline $i\n subline $i - 1 \n subline $i - 2" >> $outputfile
    else
         echo "2024-03-04 01:29:09.533811 INFO Message line $i" >> $outputfile

    fi

done