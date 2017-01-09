#!/bin/sh

usage() {
	echo "Usage: sh $0 (ie4k-lxc|ir800-lxc) [mirror]"
	exit 0
}

if [ $# -eq 0 ] ; then
	usage
fi
case "$1" in
ie4k-lxc|ir800-lxc)
	export YOCTO_MACHINE=$1
	;;
*)
	echo "ERROR: invalid machine. [$1]"
	usage
	;;
esac
if [ ! -z "$2" ] ; then
	if [ ! -d "$2" ] ; then
		echo "ERROR: no such directory. [$2]"
		usage
	fi
	export YOCTO_MIRROR="$2"
fi

. ./make.env

if [ ! -d "${XC_PATH}" ] ; then
	make
	echo ""
	echo "===> the toolchain for $has been compiled."
	echo "===> You have to type make again to build whole application."
	echo ""
	exit 0
fi

echo ""
echo "===> compiling applications."
echo ""

if [ ! -d "${CURL_BASE}" ] ; then
	echo "ERROR: you have to get ${CURL_BASE}"
	exit 1
fi
(cd ${CURL_BASE} && \
	export CPPFLAGS="-I${XC_BASE}/usr/include -I${CURL_BASE}/include" && \
	export LDFLAGS="-L${XC_BASE}/usr/lib" && \
	./configure --target=${XC_TARGET} --host=${XC_TARGET} && \
	make clean & make)

if [ ! -d "${IOXAPP_DIR}" ] ; then
	echo "ERROR: you have to clone ${IOXAPP_DIR}"
	exit 1
fi
(cd ${IOXAPP_DIR} && \
	export CPPFLAGS="-I${XC_BASE}/usr/include -I${CURL_BASE}/include" && \
	export LDFLAGS="-L${XC_BASE}/usr/lib -L${CURL_BASE}/lib/.libs -L./ioxutil" && \
	make clean & make)

make
