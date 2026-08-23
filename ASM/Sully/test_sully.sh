#/bin/bash

make wipe
make run

cd Sully_children
for i in {-1..4}
do
	echo diffing $i
	diff Sully_$i.s ../Sully.s
	echo ===========================================================
	echo ===========================================================
done

ls -la | grep Sully | wc -l
