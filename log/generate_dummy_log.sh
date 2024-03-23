#!/bin/bash
outputfile=$1
nbr_line=${2:-10}
offset=$(date +%s)
# loop for simulating log generation -- we don't really care about the timestamp -- the format is the expected one
for i in $(seq 1 $nbr_line);
do
    tsp=$(date +"%Y-%m-%d %H:%M:%S.%6N")
    idline="${offset}_${i}"
    if ! (( $i % 5 ))
    then
        # simulating some multiline log
         echo -e "${tsp} ERROR Message multiline error ${idline}\n subline ${idline} - 1 \n subline ${idline} - 2" >> $outputfile
    else
         echo "${tsp} INFO Message line ${idline}" >> $outputfile
    fi
done