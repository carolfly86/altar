#!/bin/bash
DBNAME=$1
FILES="graph/$DBNAME/*x.out"
for f in $FILES
do
	xfile=$(basename "$f")
	SCRIPT=${xfile%$'-x.out'}
	echo $SCRIPT
	python lib/python/id3-training.py $DBNAME $SCRIPT
done

