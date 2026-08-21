#/bin/bash

echo looping $1 times
echo 
echo 


for ((i=0; i<$1; i++))
do
	echo remaining $(($1 - i)) sec.
	make run && ./Grace && diff Grace.s Grace_kid.s > diffg.s
	sleep 1
done
