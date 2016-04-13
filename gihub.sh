#!/bin/bash

bdate=`date +%Y%m%d%H`

#git-push
comment="autobackup freelifescript $bdate"
git add -A
git commit -m "$comment"
git push
