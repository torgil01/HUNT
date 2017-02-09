#!/bin/bash
# condor wrapper for antsRegistrationSyN.sh
# INPUT args <template> <mask> <output_stem>
# NOTE: Use only filename, not extension for output image
export ANTSPATH=/usr/share/ANTS
TEMPLATE=$1
MASK=$2
img=$3
outName=$4
startDir=`pwd`
dn=`dirname $img`
cd $dn
$ANTSPATH/antsRegistrationSyN.sh -d 3 -t s -f $TEMPLATE -x $MASK -m $img -n 1 -p d -o $outName
cd $startDir
