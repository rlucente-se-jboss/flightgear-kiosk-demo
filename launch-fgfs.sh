#!/usr/bin/env bash

# source aircraft model, scenery, and location parameters
. $HOME/fgdemo.conf

# setup environment variables for FlightGear
export FG_HOME=~/.fgfs
export FG_AIRCRAFT=$FG_HOME/Aircraft/org.flightgear.fgaddon.stable_2020/Aircraft

# FlightGear tabula rasa
rm -fr $FG_HOME
mkdir -p $FG_AIRCRAFT $FG_HOME/Scenery

# setup aircraft and scenery cache
CACHEDIR=$HOME/Downloads
mkdir -p $CACHEDIR

# add aircraft model to FlightGear
echo "Add aircraft $AIRCRAFT_MODEL to FlightGear"
unzip -q $CACHEDIR/$AIRCRAFT_MODEL.zip -d $FG_AIRCRAFT

# add scenery files to FlightGear
for i in ${SCENERY[@]}
do
    TARFILE=$i.tgz

    echo "Add scenery $i to FlightGear"
    tar zxf $CACHEDIR/$TARFILE -C $FG_HOME/Scenery
done

# run FlightGear
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

sleep 1.0
exec "$0" "$@"
