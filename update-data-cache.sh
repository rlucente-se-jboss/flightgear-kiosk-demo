#!/usr/bin/env bash

##
## The fgdemo*.conf files are used to supply parameters to download
## aircraft and scenery data. This script uses the terrasync utility
## to download and update scenery data in the current cache.
##

[[ $EUID -eq 0 ]] && printf "\nERROR: Must NOT run as root\n\n" && exit

pushd $(dirname $0)

SCENERY_MIRROR=https://de2mirror.flightgear.org/ts
SCENERYCACHE=$(pwd)/SceneryCache
AIRCRAFTCACHE=$(pwd)/AircraftCache
mkdir -p $AIRCRAFTCACHE

CONFDIR=$(pwd)

# get the terrasync utility
if [ ! -d flightgear ]
then
    git clone https://git.code.sf.net/p/flightgear/flightgear
else
    pushd flightgear
    git pull
    popd
fi

# use the terrasync utility
pushd flightgear/scripts/python/TerraSync

for i in $(ls $CONFDIR/fgdemo*.conf)
do
    echo $i

    # source aircraft and scenery parameters
    . $i

    # setup aircraft-specific model cache
    CACHEDIR=$AIRCRAFTCACHE/$AIRCRAFT_MODEL
    mkdir -p $CACHEDIR
    
    # cache aircraft model
    BASE_AIRCRAFT_URL=https://mirrors.ibiblio.org/flightgear/ftp/Aircraft-2020

    if [ ! -f $CACHEDIR/$AIRCRAFT_MODEL.zip ]; then
        echo "Downloading $AIRCRAFT_MODEL"
        curl -so $CACHEDIR/$AIRCRAFT_MODEL.zip $BASE_AIRCRAFT_URL/$AIRCRAFT_MODEL.zip
    fi
    
    # calculate limits of scenery from aircraft position (+/-5 degrees)
    CENTER_LAT=$(echo $LAT_DEGREES | cut -d. -f1)
    CENTER_LON=$(echo $LON_DEGREES | cut -d. -f1)

    TOP=$(($CENTER_LAT+5))
    BOTTOM=$(($CENTER_LAT-5))
    LEFT=$(($CENTER_LON-5))
    RIGHT=$(($CENTER_LON+5))

    # sync the scenery data
    ./terrasync.py \
        --url $SCENERY_MIRROR \
        --target $SCENERYCACHE \
        --top $TOP \
        --bottom $BOTTOM \
        --left $LEFT \
        --right $RIGHT
done

popd
popd
