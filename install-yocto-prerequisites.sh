#!/bin/bash

################################################################################
#
# install-yocto-prerequisites.sh
#
# Author: dgrubb
# Date: 11/28/2018
#
# Checks whether yocto's prerequisites are already installed. If packages are
# missing they are installed via apt-get.
#
# Usage: Launch as root (or with root permissions):
#   $ sudo ./install-yocto-prerequisites.sh
#
################################################################################

readonly REQUIRED_PACKAGES=(
	chrpath
	build-essential
	diffstat
	gawk
	libcurses5-dev
	texinfo
)

################################################################################

do_update_base=n
do_install_required_packages=y

################################################################################

msg() {
	echo "[$(date +%Y-%m-%dT%H:%M:%S%z)]: $@" >&2
}

################################################################################

update_base() {
	msg "Updating platform base OS"
	apt-get --yes --force-yes update
	apt-get --yes --force-yes upgrade
}

################################################################################

install_packages() {
	msg "Installing required packages"
	apt-get --yes --force-yes install $@
}

################################################################################

install_required_packages() {
	msg "Checking for installed packages"
	local reqinstalled=true
	local missing=()
	for i in "${REQUIRED_PACKAGES[@]}"
	do
		reqinstalled=$(dpkg-query -W --showformat='${Status}\n' $i | grep "install ok installed")
		if [ "" == "$reqinstalled" ]; then
			missing+=($i)
		fi
	done
	if [ ! ${#missing[@]} -eq 0 ]; then
		install_packages ${missing[@]}
	fi
}

################################################################################
# Start execution
################################################################################

msg "Installing yocto prerequisites"
read -p "Press ENTER to continue (c to cancel) ..." entry
if [ ! -z $entry ]; then
	if [ $entry = "c" ]; then
		msg "Install cancelled"
		exit 0
	fi
fi

if [ $do_update_base = "y" ]; then
	update_base
fi

if [ $do_install_required_packages = "y" ]; then
	install_required_packages
fi

msg "Installation complete"

exit 0

################################################################################
# End execution
################################################################################
