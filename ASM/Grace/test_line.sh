#/bin/sh

make run && cat -n  Grace_kid.s | head -n $1 && echo &&echo ----------------- && echo "$(head -$1 Grace_kid.s)" > d1 && echo  "$(head -$1 Grace.s)" > d2 && diff  d2 d1 &&echo -----------------------
 