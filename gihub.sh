#!/bin/bash
cd /home/ubuntu/script

bdate=`date +%Y%m%d%H`

#git-push
comment="autobackup freelifescript $bdate"
git add -A
git commit -m "$comment"
git push
