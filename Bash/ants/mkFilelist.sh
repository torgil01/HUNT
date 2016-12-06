#!/bin/bash

i=0
while IFS=, read col1 col2 col3
do
    t1Files[$i]=${col2}/${col3//\"}/brain_t1w.nii.gz
    i=$((i+1))
done < $1
