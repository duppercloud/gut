#!/bin/sh
set -e
# Owner: Ashish Thakwani (athakwani at gmail dot com)
# This script is meant for quick & easy install of dev via:
#   'curl -sSL https://get.dupper.co/dev/index | sh'
# or:
#   'wget -qO- https://get.dupper.co/dev/index | sh'
#

root_url=https://get.dupper.co/dev
dev_version=0.0.1-alpha
dev_binary=dev
dev_install_dir=/usr/local
gut_binary=gut
gut_version=2.5.0
gut_install_dir=$HOME/.guts

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

unsupported() {
    cat >&2 <<-'EOF'
    Error: Unsupported OS. Dev currently only supports Linux/Mac 64-bit OS.
EOF
    exit 1
}

install() {
    os=""
    machine=""
    
    # Check machine arch
    case "$(uname -m)" in
		*64)
            machine=x86_64
            ;;
		*)
            unsupported
            ;;
	esac

    # Check OS
    os="$(uname -s)"
    case $os in
		Darwin)
            ;;
		Linux)
            ;;
		*)
            unsupported
            ;;
	esac

	curl=''
	if command_exists curl; then
		curl='curl -sSL'
	elif command_exists wget; then
		curl='wget -qO-'
	elif command_exists busybox && busybox --list-modules | grep -q wget; then
		curl='busybox wget -qO-'
	fi

    # install dev binaries at /usr/local/bin 
    url="${root_url}/${os}/${machine}/${dev_binary}-${dev_version}.tgz"
    $curl -sSL ${url}  | tar -xvz -C ${dev_install_dir} 

    # install gut binaries at $HOME/.guts/ 
    mkdir -p ${gut_install_dir}
    url="${root_url}/${os}/${machine}/${gut_binary}-${gut_version}.tgz"
    $curl -sSL ${url} | tar -xvz -C ${gut_install_dir} 
    ln -s ${gut_install_dir}/gut-build/libexec/gut-core/* /usr/local/bin/
    
    exit 0
}

# install binary and dependencies
install

