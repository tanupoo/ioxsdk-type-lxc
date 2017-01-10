#!/bin/sh

usage() {
	echo "Usage: sh $0 (ie4k-lxc|ir800-lxc)"
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

# check YOCTO_MIRROR, just in case
if [ ! -z "$YOCTO_MIRROR" ] ; then
	if [ ! -d "$YOCTO_MIRROR" ] ; then
		echo "ERROR: YOCTO_MIRROR is not a directory. [$YOCTO_MIRROR]"
		usage
	fi
fi

. ./make.env

if [ ! -d "${XC_PATH}" ] ; then
	echo ""
	echo "===> Creating the toolchain for ${XC_TARGET}."
	echo ""
	make

	echo ""
	echo "===> the toolchain for ${XC_TARGET} has been compiled."
	echo "===> You have to type make again to build whole things."
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

echo ""
echo "===> Creating the sysrootfs containing the applications."
echo ""
make
