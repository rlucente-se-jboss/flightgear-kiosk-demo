#!/usr/bin/env bash

##
## The fgdemo*.conf files are used to supply parameters to download
## aircraft and scenery data. Each set is downloaded to an aircraft
## specific directory under ~/Downloads (e.g. ~/Downloads/F-35B/)
##

pushd $(dirname $0)

[[ $EUID -eq 0 ]] && printf "\nERROR: Must NOT run as root\n\n" && exit

for i in $(ls fgdemo*.conf)
do
    # source aircraft and scenery parameters
    . $i

    # setup aircraft-specific model and scenery cache
    CACHEDIR=$AIRCRAFT_MODEL
    mkdir -p $CACHEDIR
    
    # cache aircraft model
    BASE_AIRCRAFT_URL=https://mirrors.ibiblio.org/flightgear/ftp/Aircraft-2020

    if [ ! -f $CACHEDIR/$AIRCRAFT_MODEL.zip ]; then
        echo "Downloading $AIRCRAFT_MODEL"
        curl -so $CACHEDIR/$AIRCRAFT_MODEL.zip $BASE_AIRCRAFT_URL/$AIRCRAFT_MODEL.zip
    fi
    
    # cache scenery tiles
    BASE_SCENERY_URL=https://mirrors.ibiblio.org/flightgear/ftp/Scenery-v2.12
    
    for i in ${SCENERY[@]}
    do
        TARFILE=$i.tgz
        if [ ! -f $CACHEDIR/$TARFILE ]; then
            echo "Downloading $i scenery"
            curl -so $CACHEDIR/$TARFILE $BASE_SCENERY_URL/$TARFILE
        fi
    done
done

echo
echo "Scenarios for aircraft available at:"
echo
for i in $(ls fgdemo*.conf)
do
	. $i
	echo "	$(pwd)/$AIRCRAFT_MODEL"
done
echo

popd
