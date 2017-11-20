#!/bin/bash
echo "Start Finding CREA Pic dir........"
crearoot="/disk2/crea"
outfile="/tmp/creadir"
cd  $crearoot/Ontario
ls -f >$outfile
cd  $crearoot/Alberta
ls  -f>>$outfile
cd  $crearoot/NovaScotia
ls -f >>$outfile
cd  $crearoot/NewfoundlandLabrador
ls -f >>$outfile
cd  $crearoot/NewBrunswick
ls -f >>$outfile
cd  $crearoot/BritishColumbia
ls  -f >>$outfile
cd  $crearoot/PrinceEdwardIsland
ls -f  >>$outfile
echo "End Finding CREA Pic dir"


