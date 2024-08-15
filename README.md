# WIP Nothing to see here
# FlightGear Demo with RHEL Image Mode
This demo is intended to run the open source FlightGear flight simulator
on a edge device using RHEL Image Mode. The simulator will run in kiosk
mode with a session for an unprivileged user. A privileged user will
also be configured on the edge device.

## Demo Setup
Start with a minimal install of RHEL 9.4 either on baremetal or on a guest
VM. Use UEFI firmware, if able to, when installing your system. Also make
sure there's sufficient disk space on the RHEL 9.4 instance to support the
demo. I typically configure a 128 GiB disk on the guest VM.  During RHEL
installation, configure a regular user with `sudo` privileges on the host.

These instructions assume that this repository is cloned or copied to your
user's home directory on the host (e.g. `~/flightgear-kiosk-demo`). The
below instructions follow that assumption.

After cloning this repo, download the custom built [FlightGear RPMs](https://drive.google.com/drive/folders/112i4mOfHXXEoZNdSln_xWgMdx3ssWHtz?usp=drive_link)
and copy the `fg-rpms.tgz` file to the local copy of this repository
(e.g. `~/flightgear-kiosk-demo`).

Login to the host and then run the following commands to create an SSH
keypair that you'll use later to access the edge device. Even though you
really should set a passphrase, skip that when prompted to make the demo
a little easier to run.

    cd ~/flightgear-kiosk-demo
    ssh-keygen -t rsa -f ~/.ssh/id_core
    ln -s ~/.ssh/id_core.pub .

Edit the `demo.conf` file and make sure the settings are correct. At a
minimum, you should adjust the credentials for simple content access.
The full list of options in the `demo.conf` file are shown here.

| Option           | Description |
| -----------------| ----------- |
| SCA_USER         | Your username for Red Hat Simple Content Access |
| SCA_PASS         | Your password for Red Hat Simple Content Access |
| EPEL_URL         | The Extra Packages for Enterprise Linux URL |
| EDGE_USER        | The name of a user on the target edge device |
| EDGE_PASS        | The plaintext password for the user on the target edge device |
| DEMO_USER        | Unprivileged user on the edge device in kiosk mode |
| BOOT_ISO         | Minimal boot ISO used to create a custom ISO with a custom kickstart file |
| EDGE_HASH        | A SHA-512 hash of the EDGE_PASS parameter |
| SSH_PUB_KEY      | The SSH public key of a user on the target edge device |
| HOSTIP           | The routable IP address to the host |
| REGISTRYPORT     | The port for the local container registry |
| CONTAINER_REPO   | The fully qualified name for your bootable container repository |
| REGISTRYINSECURE | Boolean for whether the registry requires TLS |

Make sure to download the `BOOT_ISO` file, e.g. [rhel-9.4-x86_64-boot.iso](https://access.redhat.com/downloads/content/rhel)
to the local copy of this repository on your RHEL instance
(e.g. ~/flightgear-kiosk-demo). Run the following script to update
the system.

    sudo ./register-and-update.sh
    sudo reboot

After the system reboots, run the following script to install container
and ISO image tools.

    cd ~/flightgear-kiosk-demo
    sudo ./config-bootc.sh

To ensure you can run this demo disconnected, set up a local container
registry.

    cd ~/flightgear-kiosk-demo
    sudo ./config-registry.sh

Login to Red Hat's container registry using your Red Hat customer portal
credentials and then pull the container image for the base bootable
container.

    podman login registry.redhat.io
    podman pull registry.redhat.io/rhel9/rhel-bootc:latest

The conversion container runs as root, so you'll need to login
as root to `registry.redhat.io` using your [Red Hat customer portal](https://access.redhat.com)
credentials to pull the tools to transform into other image types.

    sudo podman login registry.redhat.io
    sudo podman pull registry.redhat.io/rhel9/bootc-image-builder

At this point, setup is complete.

## Build the base container image
Use the following command to build the `base` bootable container image.

    cd ~/flightgear-kiosk-demo
    . demo.conf
    podman build -f BaseContainerfile -t $CONTAINER_REPO:base

Tag the base image as `prod` for production and then push both image
tags to the registry.

    podman tag $CONTAINER_REPO:base $CONTAINER_REPO:prod
    podman push $CONTAINER_REPO:base
    podman push $CONTAINER_REPO:prod

# Review the FlightGear scenario files
Each FlightGear scenario is defined in a parameter file following the
naming convention `fgdemo<n>.conf` files, where n is simply an integer
(e.g. `fgdemo1.conf`, `fgdemo2.conf`, etc). These files define the scenery
tiles to download, starting location for the aircraft, and various other
parameters such as altitude, speed, flight dynamics model, etc.

Two example scenarios are included in this repo but it's easy to add
more. The included scenarios are:

* F-35B at cruise above Langley AFB in Virginia (`fgdemo1.conf`)
* F-22A at cruise above Edwards AFB in California (`fgdemo2.conf`)

There's an extensive set of FlightGear [aircraft models](https://mirrors.ibiblio.org/flightgear/ftp/Aircraft-2020)
as well as downloadable [scenery files](https://mirrors.ibiblio.org/flightgear/ftp/Scenery-v2.12).

# Download scenario content for FlightGear
Use the scenario configuration files to download the aircraft model and
scenery files for each FlightGear scenario. The below command uses the
parameters found in the scenario configuration files to download the
needed data.

    ./download-content.sh

# Build the FlightGear scenario container images
Once the content is downloaded, you can build a bootable container image
for each scenario. Use the following commands:

    cd ~/flightgear-kiosk-demo
    . demo.conf
    
    podman build -f FGDemoContainerfile -t $CONTAINER_REPO:f35 \
        --build-arg CONTAINER_REPO=$CONTAINER_REPO \
        --build-arg FGDEMO_CONF=fgdemo1.conf \
        --build-arg DL_SCENARIO=F-35B/

    podman build -f FGDemoContainerfile -t $CONTAINER_REPO:f22 \
        --build-arg CONTAINER_REPO=$CONTAINER_REPO \
        --build-arg FGDEMO_CONF=fgdemo2.conf \
        --build-arg DL_SCENARIO=Lockheed-Martin-FA-22A-Raptor/

Push the FlightGear bootable containers to the registry.

    podman push $CONTAINER_REPO:f35
    podman push $CONTAINER_REPO:f22

## Deploy the image using an ISO file
Run the following command to generate an installable ISO file for your
bootable container. This command prepares a kickstart file to pull
the bootable container image from the registry and install that to the
filesystem on the target system. This kickstart file is then injected
into the standard RHEL boot ISO you downloaded earlier. It's important to
note that the content for the target system is actually in the bootable
container image in the registry.

    sudo ./gen-iso.sh

The generated file is named `bootc-flightgear.iso`. Use that file to boot
a physical edge device or virtual guest. Ensure that you use the UEFI
firmware option for a virtual guest or install to a physical edge device
that supports UEFI. Make sure this system is able to access your public
registry to pull down the bootable container image.

Test the deployment by logging into the graphical user interface. The
kiosk user should automatically log into a desktop where only the web
browser is available with no other desktop controls.

** LEFT OFF HERE **

## Download the aircraft models
For running FlightGear locally and experimenting with command line
options with FlightGear, please do the following:

    cd ~/flightgear-kiosk-demo
    curl -O https://mirrors.ibiblio.org/flightgear/ftp/Aircraft/F-35B.zip
    curl -O https://mirrors.ibiblio.org/flightgear/ftp/Aircraft/Lockheed-Martin-FA-22A-Raptor.zip

    ./launch-fgfs.sh

## Launch a F35B Lightning from the command line 
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
