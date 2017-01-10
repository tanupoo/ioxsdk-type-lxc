#! /bin/sh

usage() {
	echo "Usage: sh $0 (ie4k-lxc|ir800-lxc) (conf)"
	echo "    e.g."
	echo "    sh $0 ir800-lxc etc/package_config.ini.ir800"
	exit 0
}

WORKDIR=ioxsdk-type-lxc

if [ $# -ne 2 ] ; then
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
if [ ! -f "$2" ] ; then
	echo "ERROR: no such config file. [$2]"
	usage
fi
IOXAPP_CONF="$2"

. ./make.env

tar -xf ${IOXAPP_HOME}/out/${WORKDIR}_${YOCTO_MACHINE}.tar -C ${IOXAPP_PKGDIR}/
tar -zxf ${IOXAPP_PKGDIR}/artifacts.tar.gz -C ${IOXAPP_PKGDIR}/
cp ${IOXAPP_CONF} ${IOXAPP_PKGDIR}/package_config.ini
ioxclient pkg ${IOXAPP_PKGDIR}/
cp ${IOXAPP_PKGDIR}/package.tar out/${IOXAPP_NAME}.${YOCTO_MACHINE}.tar

echo ""
echo "===> Created the package."
echo "===>     out/${IOXAPP_NAME}.${YOCTO_MACHINE}.tar"
echo ""
