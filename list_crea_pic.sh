#!/bin/bash
echo "Start Finding CREA Pic dir........"
crearoot="/disk2/crea"
outfile="/tmp/creadir"
cd  $crearoot/Ontario
ls  >$outfile
cd  $crearoot/Alberta
ls  >>$outfile
cd  $crearoot/NovaScotia
ls  >>$outfile
cd  $crearoot/NewfoundlandLabrador
ls  >>$outfile
cd  $crearoot/NewBrunswick
ls  >>$outfile
cd  $crearoot/BritishColumbia
ls  >>$outfile
cd  $crearoot/PrinceEdwardIsland
ls  >>$outfile
echo "End Finding CREA Pic dir"


