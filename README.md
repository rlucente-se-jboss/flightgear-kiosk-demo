# FlightGear Demo with RHEL Image Mode
RHEL Image Mode enables management of edge device systems in a simplified
way by taking advantage of container application infrastructure. By
packaging operating system updates as an OCI container, RHEL Image Mode
simplifies the distribution and deployment of operating systems and
their updates, easing the amount of resources necessary to maintain a
disparate fleet of edge devices.

This demo shows an edge device completely changing it's workload and
filesystem configuration both by switching to a different bootable
container image from the one that's currently running and by patching
a sound issue. This demo illustrates that in a very visual and audible
way where multiple bootable container images are built and then swapped
to the edge device.

To make this interesting, this demo runs the open source FlightGear flight
simulator on an edge device using RHEL Image Mode. The simulator will
run in kiosk mode with a session for an unprivileged user. A privileged
user will also be configured on the edge device to enable switching the
bootable container image.

## Demo Setup
Start with a minimal install of RHEL 9.4 either on baremetal or on a guest
VM. Use UEFI firmware, if able to, when installing your system. Also make
sure there's sufficient disk space on the RHEL 9.4 instance to support the
demo. I typically configure a 128 GiB disk on the guest VM.  During RHEL
installation, configure a regular user with `sudo` privileges on the host.

These instructions assume that this repository is cloned or copied to your
user's home directory on the host (e.g. `~/flightgear-kiosk-demo`). The
instructions below follow that assumption.

The open source FlightGear flight simulator is not normally available
for RHEL 9 so I had to custom build eight RPMs in addition to using EPEL
for other dependencies. You can find instructions on how to do that
[here](https://github.com/rlucente-se-jboss/build-flightgear-rpms)
but it's far easier, after cloning this repo, to download the custom built
[FlightGear RPMs](https://drive.google.com/drive/folders/112i4mOfHXXEoZNdSln_xWgMdx3ssWHtz?usp=drive_link)
and copy the `fg-rpms.tgz` file to the local copy of this repository
(e.g. `~/flightgear-kiosk-demo`).

The scenery data for FlightGear is quite extensive and downloads from the
official site are throttled. To speed this up, please download the [scenery
cache](https://drive.google.com/drive/folders/112i4mOfHXXEoZNdSln_xWgMdx3ssWHtz?usp=drive_link)
and copy the `SceneryCache.tgz` file to the local copy of this repository
(e.g. `~/flightgear-kiosk-demo`).

Login to the host and then run the following commands to create an SSH
keypair that you'll use later to access the edge device. Even though you
really should set a passphrase, skip that when prompted to make the demo
a little easier to run.

    cd ~/flightgear-kiosk-demo
    ssh-keygen -t rsa -f ~/.ssh/id_core

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
| HOSTIP           | The IP address of the local container registry |
| REGISTRYPORT     | The port for the local container registry |
| CONTAINER_REPO   | The fully qualified name for your bootable container repository |
| REGISTRYINSECURE | Boolean for whether the registry requires TLS |

Make sure to download the RHEL 9.4 `BOOT_ISO` file, e.g. [rhel-9.4-x86_64-boot.iso](https://access.redhat.com/downloads/content/rhel)
to the local copy of this repository on your RHEL instance
(e.g. ~/flightgear-kiosk-demo).

Run the following script to register with Red Hat and update the system.

    sudo ./register-and-update.sh
    sudo reboot

After the system reboots, run the following script to install container
and ISO image tools.

    cd ~/flightgear-kiosk-demo
    sudo ./config-bootc.sh

You can use a publicly accessible registry like [Quay](https://quay.io)
but if you want to run this demo disconnected, you can also optionally
set up a local container registry using the following script.

    cd ~/flightgear-kiosk-demo
    sudo ./config-registry.sh

NB: If you set up an insecure registry on another RHEL instance,
please make sure to copy the `999-local-registry.conf` file to the
`~/flightgear-kiosk-demo` and `/etc/containers/registries.conf.d`
directories on this RHEL instance that will build the bootable container
images.

Login to Red Hat's container registry using your Red Hat customer portal
credentials and then pull the container image for the base bootable
container.

    podman login registry.redhat.io
    podman pull registry.redhat.io/rhel9/rhel-bootc:9.4

At this point, setup is complete.

## Build the base container image
Use the following command to build the `base` bootable container
image. This image contains the Firefox browser running in kiosk mode.

    cd ~/flightgear-kiosk-demo
    . demo.conf
    podman build -f BaseContainerfile -t $CONTAINER_REPO:base \
        --build-arg DEMO_USER=$DEMO_USER

Push the image to the registry.

    podman push $CONTAINER_REPO:base

## Review the FlightGear scenario files
Each FlightGear scenario is defined in a parameter file following
the naming convention `fgdemo<n>.conf`, where n is simply an integer
(e.g. `fgdemo1.conf`, `fgdemo2.conf`, etc). These files define the area
of operation for scenery, starting location for the aircraft, and various
other parameters such as altitude, speed, flight dynamics model, etc.

Several example scenarios are included in this repo but it's easy to add
more. The included scenarios are:

* F-35B above Langley AFB in Virginia (`fgdemo1.conf`)
* F-22A above Edwards AFB in California (`fgdemo2.conf`)
* B-52F above Barksdale AFB in Louisiana (`fgdemo3.conf`)
* UH-60 on the tarmac at Reagan National Airport in DC (`fgdemo4.conf`)

There's an extensive set of FlightGear [aircraft models](https://mirrors.ibiblio.org/flightgear/ftp/Aircraft-2020)
that you can use.

## Refresh the scenario content for FlightGear
The FlightGear scenery is quite detailed and bulk downloads are throttled
to avoid overloading the servers. Normally, the simulator pulls scenery
on-demand using a feature called `terrasync`, but for disconnected use
cases, the scenery snapshot (`SceneryCache.tgz`) that you downloaded
earlier seeds scenery for flight over defined geographic areas.

The following commands prepare the scenery cache and then refresh the
data with any changes since the scenery data was last synced. How long
this takes depends on the extent of changes that are necessary. The
`update-data-cache.sh` script will also download the aircraft data
defined in the scenario parameter files.

    cd ~/flightgear-kiosk-demo
    mkdir -p AircraftCache SceneryCache
    tar zxf SceneryCache.tgz -C SceneryCache
    ./update-data-cache.sh

After this command runs, both the `AircraftCache` and the `SceneryCache`
directories should be up to date.

## Build the intermediate FlightGear container image
Use the following command to build the `fgfs` container image that
installs the FlightGear flight simulator and its extensive scenery
files. This image will be quite large.

    cd ~/flightgear-kiosk-demo
    . demo.conf
    podman build -f FGBaseContainerfile -t $CONTAINER_REPO:fgfs \
        --build-arg CONTAINER_REPO=$CONTAINER_REPO

Push the intermediate FlightGear container to the registry.

    podman push $CONTAINER_REPO:fgfs

## Build the FlightGear scenario container images
You are now ready to build a bootable container image for each
scenario. Use the following commands:

    cd ~/flightgear-kiosk-demo
    . demo.conf

    podman build -f FGDemoContainerfile -t $CONTAINER_REPO:f35-fixed \
        --build-arg CONTAINER_REPO=$CONTAINER_REPO \
        --build-arg DL_SCENARIO=AircraftCache/F-35B/ \
        --build-arg FGDEMO_CONF=fgdemo1.conf

    podman build -f FGDemoContainerfile -t $CONTAINER_REPO:f22-fixed \
        --build-arg CONTAINER_REPO=$CONTAINER_REPO \
        --build-arg DL_SCENARIO=AircraftCache/Lockheed-Martin-FA-22A-Raptor/ \
        --build-arg FGDEMO_CONF=fgdemo2.conf

    podman build -f FGDemoContainerfile -t $CONTAINER_REPO:b52-fixed \
        --build-arg CONTAINER_REPO=$CONTAINER_REPO \
        --build-arg DL_SCENARIO=AircraftCache/B-52F/ \
        --build-arg FGDEMO_CONF=fgdemo3.conf

    podman build -f FGDemoContainerfile -t $CONTAINER_REPO:uh60-fixed \
        --build-arg CONTAINER_REPO=$CONTAINER_REPO \
        --build-arg DL_SCENARIO=AircraftCache/UH-60/ \
        --build-arg FGDEMO_CONF=fgdemo4.conf

Push the FlightGear bootable containers to the registry. These container
images all include working sound. We'll use an issue with sound to
illustrate patching.

    podman push $CONTAINER_REPO:f35-fixed
    podman push $CONTAINER_REPO:f22-fixed
    podman push $CONTAINER_REPO:b52-fixed
    podman push $CONTAINER_REPO:uh60-fixed

Next, build the container images that do not have sound. The
`FGNoSoundContainerFile` removes the sound libraries from the base images
to prevent sound from working on the target device.

    cd ~/flightgear-kiosk-demo
    . demo.conf

    podman build -f FGNoSoundContainerfile -t $CONTAINER_REPO:f35-broken \
        --build-arg CONTAINER_BASE_TAG=$CONTAINER_REPO:f35-fixed

    podman build -f FGNoSoundContainerfile -t $CONTAINER_REPO:f22-broken \
        --build-arg CONTAINER_BASE_TAG=$CONTAINER_REPO:f22-fixed

    podman build -f FGNoSoundContainerfile -t $CONTAINER_REPO:b52-broken \
        --build-arg CONTAINER_BASE_TAG=$CONTAINER_REPO:b52-fixed

    podman build -f FGNoSoundContainerfile -t $CONTAINER_REPO:uh60-broken \
        --build-arg CONTAINER_BASE_TAG=$CONTAINER_REPO:uh60-fixed

Push the FlightGear bootable containers to the registry. These container
images all include broken sound.

    podman push $CONTAINER_REPO:f35-broken
    podman push $CONTAINER_REPO:f22-broken
    podman push $CONTAINER_REPO:b52-broken
    podman push $CONTAINER_REPO:uh60-broken

## Deploy the image using an ISO file
Run the following command to generate an installable ISO file for your
bootable container. This command prepares a kickstart file to pull
the bootable container image from the registry and install that to the
filesystem on the target system. This kickstart file is then injected
into the standard RHEL boot ISO you downloaded earlier. It's important to
note that the content for the target system is actually in the bootable
container image in the registry. This ISO merely contains enough to start
the system and then use the kickstart file to pull the operating system
content from the container registry.

    sudo ./gen-iso.sh

The generated file is named `bootc-flightgear.iso`. Use that file to boot
a physical edge device or virtual guest. Ensure that you use the UEFI
firmware option for a virtual guest or install to a physical edge device
that supports UEFI. Make sure this system is able to access your public
registry to pull down the bootable container image.

You may see a core dump with FlightGear when running in a guest VM if
memory is low. I've successfully tested running the bootable containers
on a laptop with 16GB of memory and a 512GB SDD.

Test the deployment by verifying that the kiosk user automatically logs
into a desktop where only the web browser is available with no other
desktop controls.

## Switching between operating system images
Three bootable container images have been built where all of them will
run in kiosk mode once installed.

* Firefox browsing to the RHEL Image Mode landing page.
* FlightGear with an F-35B flying over Langley AFB in VA.
* FlightGear with an F-22A flying over Edwards AFB in CA.
* FlightGear with a B-52F flying over Barksdale AFB in LA.
* FlightGear with a UH-60 on the tarmac at Reagan National Airport in DC.

Once the `base` image is installed, it's very simple to switch between
them. The target device will auto-login to the unprivileged user `kiosk`
at startup and render the browser in full screen and kiosk mode. No
other desktop controls are available to the `kiosk` user.

To switch the bootable container operating system, login as the
`EDGE_USER` defined in the `demo.conf` file earlier using ssh and the
`id_core` private key created earlier.

    ssh -i ~/.ssh/id_core core@IP_ADDRESS

where `IP_ADDRESS` is the address of the edge device.

Then type the following commands to switch to the F-22 flight simulation.

    sudo bootc switch HOSTIP:REGISTRYPORT/bootc-flightgear:f35-broken
    sudo reboot

where `HOSTIP` and `REGISTRYPORT` match the values in the `demo.conf`
file. The other possibilities are:

    HOSTIP:REGISTRYPORT/bootc-flightgear:base
    HOSTIP:REGISTRYPORT/bootc-flightgear:f35-fixed
    HOSTIP:REGISTRYPORT/bootc-flightgear:f22-broken
    HOSTIP:REGISTRYPORT/bootc-flightgear:f22-fixed
    HOSTIP:REGISTRYPORT/bootc-flightgear:b52-broken
    HOSTIP:REGISTRYPORT/bootc-flightgear:b52-fixed
    HOSTIP:REGISTRYPORT/bootc-flightgear:uh60-broken
    HOSTIP:REGISTRYPORT/bootc-flightgear:uh60-fixed

You can demonstrate patching by switching from a `broken` tagged image
to a `fixed` tagged image.
