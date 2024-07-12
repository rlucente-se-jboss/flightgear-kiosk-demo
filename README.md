## WIP Nothing to see here ##

After cloning this repo, download the custom built [FlightGear RPMs](https://drive.google.com/file/d/1Ud-s--0o4A95WMxjAdRR8Ix0T_K4G5Dm/view?usp=drive_link)
and copy the `flightgear-rpms.zip` file to the `flightgear-kiosk-demo`
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
    unzip flightgear-rpms.zip
    sudo dnf -y install flightgear-rpms/* gnome-shell

Switch to the graphical target

    sudo systemctl set-default graphical.target
    sudo reboot
