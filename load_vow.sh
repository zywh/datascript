#!/bin/bash

echo "`date`: dowload VOW data and picture start" >>$mlslog


cd /home/ubuntu/script/treb

#load idx all ml_num
echo "`date`: Start dowload IDX ML_NUM" >>$mlslog
sudo php download_idx_avail.php
count=`wc -l /tmp/idx.ml|awk '{print $1}'`
echo "`date`: End download IDX ML_NUM $count" >>$mlslog

#download vow all active ml_num
echo "`date`: Start dowload VOW ML_NUM" >>$mlslog
sudo php download_vow_avail.php
echo "`date`: End dowload VOW ML_NUM" >>$mlslog

#load vow data and picture
echo "`date`: Start dowload VOW Data and Pictures" >>$mlslog
#sudo php  download_vow_data.php
sudo php  download_vow_data.php 25 $VOW_USER $VOW_PASS
echo "`date`: End dowload VOW Data and Pictures" >>$mlslog

