#!/usr/bin/bash

export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1

if [ -z "$REQUIRED_NEOS_VERSION" ]; then
  export REQUIRED_NEOS_VERSION="19.1"
fi

if [ -z "$AGNOS_VERSION" ]; then
  export AGNOS_VERSION="4"
fi

if [ -z "$PASSIVE" ]; then
  export PASSIVE="1"
fi

export STAGING_ROOT="/data/safe_staging"

# Set system date equal to last date of recording, in case of no network to sync time

ls /data/media/0/realdata/ > /tmp/rec_list.tmp

# Considering at least 3 directory because of /boot and /crash
if [ `wc -l < /tmp/rec_list.tmp` -ge 3 ]
  then
   last_day=`cat /tmp/rec_list.tmp | tail -3 | head -1 | awk -F"--" '{print $1}'`
   last_time=`cat /tmp/rec_list.tmp | tail -3 | head -1 | awk -F"--" '{print $2}' | sed -r 's/-/:/g'`
   date --set $last_day" "$last_time
fi

# Clean oldest recording day if disk space is less than 20GB

df -h | grep "/data" | awk '{print $4}' > /tmp/part_space.tmp
space=`sed -e 's/G//' /tmp/part_space.tmp`
# rm /tmp/part_space.tmp

if [ $space -lt 20 ]
then
 old_day=`sed -n '1p' /tmp/rec_list.tmp | awk -F"--" '{print $1}'`
 for file in `ls /data/media/0/realdata/ | grep $old_day`
 do
  rm -rf "/data/media/0/realdata/"$file
 done
 echo $old_day >> /tmp/last_clean.tmp
 df -h | grep "/data" | awk '{print $4}' > /tmp/part_space.tmp
fi

rm /tmp/rec_list.tmp
