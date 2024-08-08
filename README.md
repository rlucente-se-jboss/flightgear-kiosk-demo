## WIP Nothing to see here ##

After cloning this repo, download the custom built [FlightGear RPMs](https://drive.google.com/file/d/1_ySCwcSw4gtu8k8FoCAbMcBheAKRoV8G/view?usp=drive_link)
and copy the `flightgear-rpms.tgz` file to the `flightgear-kiosk-demo`
folder.

Install RHEL 9.4 minimal

Copy this repo to RHEL 9.4 instance

Edit demo.conf to make sure parameters are correct

    cd ~/flightgear-kiosk-demo
    sudo ./register-and-update.sh
    sudo ./add-epel-repo.sh
    sudo reboot

Install the FlightGear RPMs and the minimal graphical environment

    cd ~/flightgear-kiosk-demo
    tar zxf flightgear-rpms.tgz
    sudo dnf -y install flightgear-rpms/* gnome-shell

Switch to the graphical target

    sudo systemctl set-default graphical.target
    sudo reboot

### Launch a F35B Lightning from the command line 
- Launch Flightgear into the launcher
- Click "Aircraft" on the left hand menu
- Click "Browse" at the top of the page
- Search Lockheed
- Install the model named "Lockheed Martin F35B Lightning II (YASim)

Now you can run the following command from the terminal and launch into a fullscreen session of the F35B on an airstrip in the Grand Canyon
```
fgfs --prop:/nasal/local_weather/enabled=false --metar=XXXX 012345Z 15003KT 19SM FEW072 FEW350 25/07 Q1028 NOSIG --prop:/environment/weather-     
scenario=Core high pressure region --disable-rembrandt --prop:/sim/rendering/shaders/skydome=true --prop:/sim/rendering/texture-cache/cache- 
enabled=false --enable-fullscreen --enable-terrasync --enable-sentry --aircraft=org.flightgear.fgaddon.stable_2020.F-35B-yasim --airport=KGCN -- 
runway=21 --fg-aircraft=/home/redhat/.fgfs/Aircraft/org.flightgear.fgaddon.stable_2020/Aircraft
```
