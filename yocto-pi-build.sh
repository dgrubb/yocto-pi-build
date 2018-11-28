#!/bin/bash

################################################################################
#
# yocto-pi-build.sh
#
# Author: dgrubb
# Date: 11/28/2018
#
# Automates steps for checking out and building a Raspberry Pi Linux image
# using Yocto. Based on the steps outlined at:
# https://jumpnowtek.com.rpi/Raspberry-Pi-Systems-with-Yocto.html
#
# Usage:
#   $ ./yocto-pi-build.sh TARGET
#
################################################################################

readonly BUILD_DIR=${HOME}
readonly UPSTREAM_BRANCH="thud"
readonly POKY_DIR="poky-$UPSTREAM_BRANCH"
readonly RPI_DIR="rpi"
readonly USAGE="Usage:\n\n\
    $ ./install-yocto-prerequisites.sh TARGET\n\n\
Where TARGET is one of:\n\n\
    ap-image\n\
    audio-image\n\
    console-basic-image\n\
    console-image\n\
    flask-image\n\
    gumsense-image\n\
    iot-image\n\
    py3qt-image\n\
    qt5-basic-image\n\
    qt5-image"

################################################################################

do_check_shell=y
do_clone_yocto_repos=y
do_clone_rpi_repos=y
do_customise_config=y
do_execute_build=y

################################################################################

msg() {
	echo "[$(date +%Y-%m-%dT%H:%M:%S%z)]: $@" >&2
}

################################################################################

check_shell() {
	if [ $SHELL != "/bin/bash" ]; then
		msg "WARNING: yocto requires BASH shell"
		msg "Run:"
		msg " $ sudo dpkg-reconfigure dash"
		msg "select No and relaunch this script."
		exit 1
	fi
	msg "Verified shell is BASH"
}

################################################################################

clone_yocto_repos() {
	msg "Cloning yocto repositories from upstream branch: $UPSTREAM_BRANCH"
	cd $BUILD_DIR
	git clone -b $UPSTREAM_BRANCH git://git.yoctoproject.org/poky.git $POKY_DIR
	cd $POKY_DIR
	git clone -b $UPSTREAM_BRANCH git://git.openembedded.org/meta-openembedded
	git clone -b $UPSTREAM_BRANCH https://github.com/meta-qt5/meta-qt5
	git clone -b $UPSTREAM_BRANCH git://git.yoctoproject.org/meta-raspberrypi
	cd $BUILD_DIR
}

################################################################################

clone_rpi_repos() {
	msg "Cloning RPI meta repos"
	mkdir $RPI_DIR && cd $RPI_DIR
	git clone -b $UPSTREAM_BRANCH git://github.com/jumpnow/meta-rpi
	cd $BUILD_DIR
}

################################################################################

customise_config() {
	msg "Customing configuration"
	cd $BUILD_DIR
	mkdir -p "$BUILD_DIR/$RPI_DIR/conf"
	source $POKY_DIR/oe-init-build-env $BUILD_DIR/$RPI_DIR/build
	cp $BUILD_DIR/$RPI_DIR/meta-rpi/conf/local.conf.sample $BUILD_DIR/$RPI_DIR/build/conf/local.conf
	cp $BUILD_DIR/$RPI_DIR/meta-rpi/conf/bblayers.conf.sample $BUILD_DIR/$RPI_DIR/build/conf/bblayers.conf
	cd $BUILD_DIR
}

execute_build() {
	msg "Executing build for $target"
	source $BUILD_DIR/$POKY_DIR/oe-init-build-env $BUILD_DIR/$RPI_DIR/build
	bitbake $1
}

################################################################################
# Start execution
################################################################################

case "$1" in

ap-image)
	target=ap-image
	;;

audio-image)
	target=audio-image
	;;

console-basic-image)
	target=console-basic-image
	;;

console-image)
	target=console-image
	;;

flask-image)
	target=flask-image
	;;

gumsense-image)
	target=gumsense-image
	;;

iot-image)
	target=iot-image
	;;

py3qt-image)
	target=py3qt-image
	;;

qt5-basic-image)
	target=qt5-basic-image
	;;

qt5-image)
	target=qt5-image
	;;

*)
	echo -e $USAGE
	exit 1
	;;
esac

msg "Building pi image ( $target ) with yocto under build dir: $BUILD_DIR"
read -p "Press ENTER to continue (c to cancel) ..." entry
if [ ! -z $entry ]; then
	if [ $entry = "c" ]; then
		msg "Build cancelled"
		exit 0
	fi
fi

if [ $do_check_shell = "y" ]; then
	check_shell
fi

if [ $do_clone_yocto_repos = "y" ]; then
	clone_yocto_repos
fi

if [ $do_clone_rpi_repos = "y" ]; then
	clone_rpi_repos
fi

if [ $do_customise_config = "y" ]; then
	customise_config
fi

if [ $do_execute_build = "y" ]; then
	execute_build $target
fi

msg "Build complete!"

exit 0

################################################################################
# End execution
################################################################################
