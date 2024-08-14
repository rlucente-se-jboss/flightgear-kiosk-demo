#!/usr/bin/env bash

WORKDIR=$(pushd $(dirname $0) > /dev/null && pwd && popd > /dev/null)
. $WORKDIR/demo.conf

[[ $EUID -eq 0 ]] && exit_on_error "Must NOT run as root"

# define aircraft model and scenery tiles
AIRCRAFT_MODEL=F-35B

# Langley AFB lat/lon
LAT_DEGREES=37.0835
LON_DEGREES=-76.3592

# Scenery around Langley AFB where coordinates refer to the lower
# left-hand corner of the tile
SCENERY=( \
    Airports \
    w090n40 w080n40 w070n40 \
    w090n30 w080n30 w070n30 \
    w090n20 w080n20 w070n20 \
)

# setup environment variables for FlightGear
export FG_HOME=~/.fgfs
export FG_AIRCRAFT=$FG_HOME/Aircraft/org.flightgear.fgaddon.stable_2020/Aircraft

# FlightGear tabula rasa
rm -fr $FG_HOME
mkdir -p $FG_AIRCRAFT $FG_HOME/Scenery

# setup downloaded aircraft and scenery cache
CACHEDIR=$WORKDIR/cache
mkdir -p $CACHEDIR

# download and cache aircraft model
BASE_AIRCRAFT_URL=https://mirrors.ibiblio.org/flightgear/ftp/Aircraft-2020

if [ ! -f $CACHEDIR/$AIRCRAFT_MODEL.zip ]; then
    echo "Downloading $AIRCRAFT_MODEL"
    curl -so $CACHEDIR/$AIRCRAFT_MODEL.zip $BASE_AIRCRAFT_URL/$AIRCRAFT_MODEL.zip
fi

echo "Add aircraft $AIRCRAFT_MODEL to FlightGear"
unzip -q $CACHEDIR/$AIRCRAFT_MODEL.zip -d $FG_AIRCRAFT

# download and cache scenery tiles
BASE_SCENERY_URL=https://mirrors.ibiblio.org/flightgear/ftp/Scenery-v2.12

for i in ${SCENERY[@]}
do
    TARFILE=$i.tgz
    if [ ! -f $CACHEDIR/$TARFILE ]; then
        echo "Downloading $i scenery"
        curl -so $CACHEDIR/$TARFILE $BASE_SCENERY_URL/$TARFILE
    fi

    echo "Add scenery $i to FlightGear"
    tar zxf $CACHEDIR/$TARFILE -C $FG_HOME/Scenery
done

fgfs \
    --enable-hud-3d \
    --enable-random-objects \
    --enable-random-vegetation \
    --enable-random-buildings \
    --enable-ai-models \
    --enable-ai-traffic \
    --disable-rembrandt \
    --fog-nicest \
    --enable-distance-attenuation \
    --enable-horizon-effect \
    --enable-specular-highlight \
    --enable-fullscreen \
    --shading-smooth \
    --aircraft=org.flightgear.fgaddon.stable_2020.F-35B-yasim \
    --in-air \
    --enable-auto-coordination \
    --timeofday=afternoon \
    --season=summer \
    --lat=$LAT_DEGREES \
    --lon=$LON_DEGREES \
    --altitude=20000 \
    --heading=0 \
    --roll=0 \
    --pitch=0 \
    --vc=670 \
    --metar='XXXX 012345Z 15003KT 19SM FEW072 FEW350 25/07 Q1028 NOSIG' \
    --disable-real-weather-fetch \
    --enable-clouds3d \
    --disable-terrasync \
    --fg-scenery=$FG_HOME/Scenery \
    --prop:/engines/engine[0]/running=true
