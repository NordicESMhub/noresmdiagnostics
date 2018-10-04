#!/bin/bash
# clean up links for missing figures
#Yanchun He, 2018.10.04

for fname in $(grep -o 'set[^"]*.png' $1 |uniq); do
    if [[ ! -f $WEBDIR/$fname ]]; then
        text=$(grep -n "$fname" $1)
        ln=$(echo $text |cut -d: -f1)
        #alt=$(echo $text |grep -o 'alt="[[:alnum:]. -]*"' |cut -d'"' -f2)
        #sed -i "${ln}s/.*/    \<TD\>$alt/" $1
        sed -i "${ln}s/.*/    \<TD\>missing/" $1
    fi
done
