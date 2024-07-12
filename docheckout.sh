#!/bin/bash
d=`dirname $1`
echo "*** $d ***"
cd $d && git checkout l4t/l4t-r32.7.5-4.9 || git checkout l4t/l4t-r32.7.5 || git checkout l4t/l4t-r32.7.5-v2020.04 # || git checkout tegra-l4t-r32.7.5
exit 0

    
