#/bin/bash

make wipe
make run
for i in {-1..4}
do
	echo diffing $i
	diff Sully_children/Sully_$i.c Sully.c
	echo ===========================================================
	echo ===========================================================
done
