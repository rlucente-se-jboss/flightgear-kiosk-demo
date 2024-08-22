# FlightGear Demo with RHEL Image Mode
RHEL Image Mode enables an edge device to completely change it's operating
system image by switching to a different bootable container image from
the one that's currently running. This demo illustrates that in a very
visual way where three bootable container images are built and then easily
swapped out on an edge device. To make this interesting, this demo runs
the open source FlightGear flight simulator on a edge device using RHEL
Image Mode. The simulator will run in kiosk mode with a session for an
unprivileged user. A privileged user will also be configured on the edge
device to enable switching the bootable container image.

## Demo Setup
Start with a minimal install of RHEL 9.4 either on baremetal or on a guest
VM. Use UEFI firmware, if able to, when installing your system. Also make
sure there's sufficient disk space on the RHEL 9.4 instance to support the
demo. I typically configure a 128 GiB disk on the guest VM.  During RHEL
installation, configure a regular user with `sudo` privileges on the host.

These instructions assume that this repository is cloned or copied to your
user's home directory on the host (e.g. `~/flightgear-kiosk-demo`). The
below instructions follow that assumption.

The open source FlightGear flight simulator is not normally available
for RHEL 9 so I had to custom build eight RPMs in addition to using EPEL
for other dependencies. How those RPMs were built is beyond the scope of
this repo. After cloning this repo, download the custom built [FlightGear
RPMs](https://drive.google.com/drive/folders/112i4mOfHXXEoZNdSln_xWgMdx3ssWHtz?usp=drive_link)
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
| HOSTIP           | The IP address of the local container registry |
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

Run the following command to create a placeholder registry configuration
file to support the later bootable container build.

    cd ~/flightgear-kiosk-demo
    touch 999-local-registry.conf

You can use a publicly accessible registry like [Quay](https://quay.io)
but if you want to run this demo disconnected, you can also optionally
set up a local container registry using the following script.

    cd ~/flightgear-kiosk-demo
    sudo ./config-registry.sh

If you set up an insecure registry on another RHEL instance,
please make sure to copy the `999-local-registry.conf` file to the
`~/flightgear-kiosk-demo` and `/etc/containers/registries.conf.d`
directories on the RHEL instance building the bootable container images.

Login to Red Hat's container registry using your Red Hat customer portal
credentials and then pull the container image for the base bootable
container.

    podman login registry.redhat.io
    podman pull registry.redhat.io/rhel9/rhel-bootc:latest

At this point, setup is complete.

## Build the base container image
Use the following command to build the `base` bootable container image.

    cd ~/flightgear-kiosk-demo
    . demo.conf
    podman build -f BaseContainerfile -t $CONTAINER_REPO:base \
        --build-arg DEMO_USER=$DEMO_USER

Push the image to the registry.

    podman push $CONTAINER_REPO:base

## Review the FlightGear scenario files
Each FlightGear scenario is defined in a parameter file following the
naming convention `fgdemo<n>.conf`, where n is simply an integer
(e.g. `fgdemo1.conf`, `fgdemo2.conf`, etc). These files define the scenery
tiles to download, starting location for the aircraft, and various other
parameters such as altitude, speed, flight dynamics model, etc.

Two example scenarios are included in this repo but it's easy to add
more. The included scenarios are:

* F-35B at cruise above Langley AFB in Virginia (`fgdemo1.conf`)
* F-22A at cruise above Edwards AFB in California (`fgdemo2.conf`)

There's an extensive set of FlightGear [aircraft models](https://mirrors.ibiblio.org/flightgear/ftp/Aircraft-2020)
as well as downloadable [scenery files](https://mirrors.ibiblio.org/flightgear/ftp/Scenery-v2.12).

## Download scenario content for FlightGear
Use the scenario configuration files to download the aircraft model and
scenery files for each FlightGear scenario. The below command uses the
parameters found in the scenario configuration files to download the
needed data.

    ./download-content.sh

## Build the FlightGear scenario container images
Once the content is downloaded, you can build a bootable container image
for each scenario. Use the following commands:

    cd ~/flightgear-kiosk-demo
    . demo.conf
    
    podman build -f FGDemoContainerfile -t $CONTAINER_REPO:f35 \
        --build-arg CONTAINER_REPO=$CONTAINER_REPO \
        --build-arg FGDEMO_CONF=fgdemo1.conf \
        --build-arg DEMO_USER=$DEMO_USER \
        --build-arg DL_SCENARIO=F-35B/

    podman build -f FGDemoContainerfile -t $CONTAINER_REPO:f22 \
        --build-arg CONTAINER_REPO=$CONTAINER_REPO \
        --build-arg FGDEMO_CONF=fgdemo2.conf \
        --build-arg DEMO_USER=$DEMO_USER \
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

FlightGear requires extensive resources so you may see a core dump in
a guest VM if memory is low. I've only tested running the bootable
containers on a laptop with 64GB of memory and a 512GB SDD.

Test the deployment by verifying that the kiosk user automatically logs
into a desktop where only the web browser is available with no other
desktop controls.

## Switching between operating system images
Three bootable container images have been built where all of them will
run in kiosk mode once installed.

* Firefox browsing to the RHEL Image Mode landing page.
* FlightGear with an F-35B flying over Langley AFB in VA.
* FlightGear with an F-22A flying over Edwards AFB in CA.

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

    sudo bootc switch HOSTIP:REGISTRYPORT/bootc-flightgear:f22
    sudo reboot

where `HOSTIP` and `REGISTRYPORT` match the values in the `demo.conf`
file. The other possibilities are:

    HOSTIP:REGISTRYPORT/bootc-flightgear:base
    HOSTIP:REGISTRYPORT/bootc-flightgear:f35
