#!/bin/bash
echo "Start Finding CREA Pic dir........"
prefix="/disk2/crea"
out="/tmp/creadir"
find $prefix/Ontario -type d >$out
find $prefix/Alberta -type d >>$out
find $prefix/NovaScotia -type d >>$out
find $prefix/NewfoundlandLabrador -type d >>$out
find $prefix/NewBrunswick -type d >>$out
find $prefix/BritishColumbia -type d >>$out
find $prefix/PrinceEdwardIsland -type d >>$out
echo "End Finding CREA Pic dir"

