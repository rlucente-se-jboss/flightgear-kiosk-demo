#!/usr/bin/env bash

. $(dirname $0)/demo.conf

[[ $EUID -eq 0 ]] && exit_on_error "Must NOT run as root"

export FG_HOME=~/.fgfs

rm -fr $FG_HOME
mkdir -p $FG_HOME/Aircraft/org.flightgear.fgaddon.stable_2020/Aircraft
unzip -q $(dirname $0)/F-35B.zip -d $FG_HOME/Aircraft/org.flightgear.fgaddon.stable_2020/Aircraft


fgfs \
    --prop:/nasal/local_weather/enabled=false \
    --metar=XXXX 012345Z 15003KT 19SM FEW072 FEW350 25/07 Q1028 NOSIG \
    --prop:/environment/weather-scenario=Core high pressure region \
    --disable-rembrandt \
    --prop:/sim/rendering/shaders/skydome=true \
    --prop:/sim/rendering/texture-cache/cache-enabled=false \
    --enable-fullscreen \
    --enable-terrasync \
    --enable-sentry \
    --aircraft=org.flightgear.fgaddon.stable_2020.F-35B-yasim \
    --airport=KGCN \
    --runway=21 \
    --fg-aircraft=$FG_HOME/Aircraft/org.flightgear.fgaddon.stable_2020/Aircraft
