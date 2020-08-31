#!/bin/sh
dateVAR=$(date +%s)
#docker build --build-arg THREADS=$(grep processor /proc/cpuinfo | wc -l) -t linux-efi-linuxversion:$dateVAR - < Dockerfile-linuxVERSION
#docker run --rm -v $(pwd):/buildout-env linux-efi-linuxversion:$dateVAR sh get-version.sh /buildout-env
./get-version.sh
# FIXME quoteing for eval
eval $(pwd)/buildout-env/EOF.env 
docker build --build-arg THREADS=$(grep processor /proc/cpuinfo | wc -l) KERNEL_VERSION=$linuxVERSION -t linux-efi:$dateVAR .
docker run --rm -v $(pwd):/buildout linux-efi:$dateVAR /dump.sh
