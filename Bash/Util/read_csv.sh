#!/bin/bash

i=0
# must include all cols 
while IFS=, read col1 col2 col3 col4
do
    ID[$i]=${col2}
    i=$((i+1))
done < ${1}

for id in ${ID[@]}; do
    echo $id
done


