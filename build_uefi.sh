#!/bin/sh
#
# Usage: bash build_uefi.sh {platform}
#

#BUILD_OPTION=DEBUG
BUILD_OPTION=RELEASE
#AARCH64_GCC=CLANG_3_9
AARCH64_GCC=LINARO_GCC_7_2    # Prefer to use Linaro GCC >= 7.1.1. Otherwise, user may meet some toolchain issues.
#GENERATE_PTABLE=1
#EDK2_PLATFORM=1

# l-loader on hikey and optee need AARCH32_GCC
AARCH32_GCC=/opt/toolchain/gcc-linaro-arm-linux-gnueabihf-4.8-2014.01_linux/bin/
PATH=${AARCH32_GCC}:${PATH} && export PATH

# Setup environment variables that are used in uefi-tools
case "${AARCH64_GCC}" in
"ARNDROID_GCC_4_9")
	AARCH64_GCC_4_9=/opt/toolchain/aarch64-linux-android-4.9.git/bin/
	PATH=${AARCH64_GCC_4_9}:${PATH} && export PATH
	export AARCH64_TOOLCHAIN=GCC49
	CROSS_COMPILE=aarch64-linux-android-
	TOOLCHAIN_FAMILY=gcc
	;;
"LINARO_GCC_7_1")
	AARCH64_GCC_7_1=/opt/toolchain/gcc-linaro-7.1.1-2017.08-x86_64_aarch64-linux-gnu/bin/
	PATH=${AARCH64_GCC_7_1}:${PATH} && export PATH
	export AARCH64_TOOLCHAIN=GCC5
	CROSS_COMPILE=aarch64-linux-gnu-
	TOOLCHAIN_FAMILY=gcc
	;;
"LINARO_GCC_7_2")
	AARCH64_GCC_7_2=/opt/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/
	PATH=${AARCH64_GCC_7_2}:${PATH} && export PATH
	export AARCH64_TOOLCHAIN=GCC5
	CROSS_COMPILE=aarch64-linux-gnu-
	TOOLCHAIN_FAMILY=gcc
	;;
"CLANG_3_9")
	export AARCH64_TOOLCHAIN=CLANG38
	export CC=/usr/bin/clang
	TOOLCHAIN_FAMILY=clang
	;;
*)
	echo "Not supported toolchain:${AARCH64_GCC}"
	exit
	;;
esac

case "$1" in
"hikey")
	PLATFORM=hikey
	;;
"hikey960")
	PLATFORM=hikey960
	;;
"")
	# If $1 is empty, set ${PLATFORM} as hikey960 by default.
	PLATFORM=hikey960
	;;
*)
	echo "Not supported platform:$1"
	exit
	;;
esac

if [ -d "${PWD}/edk2" ] && [ -d "${PWD}/uefi-tools" ] && [ -d "${PWD}/arm-trusted-firmware" ] && [ -d "${PWD}/l-loader" ]; then
	# Check whether source code are available in ${PWD}
	BUILD_PATH=${PWD}
	echo "Find source code in ${PWD}"
elif [ -d "${PWD}/../edk2" ] && [ -d "${PWD}/../uefi-tools" ] && [ -d "${PWD}/../arm-trusted-firmware" ] && [ -d "${PWD}/../l-loader" ]; then
	# Check whether source code are available in parent of ${PWD}
	BUILD_PATH=$(dirname ${PWD})
	echo "Find source code in parent directory of ${PWD}"
else
	echo "Warning: Can't find source code to build."
	exit
fi

# Setup environment variables that are used in uefi-tools
export UEFI_TOOLS_DIR=${BUILD_PATH}/uefi-tools

EDK2_DIR=${BUILD_PATH}/edk2
echo "edk2 dir:${EDK2_DIR}"
export EDK2_DIR

case "$PLATFORM" in
"hikey")
	# Check whether fastboot source code is available in ${BUILD_PATH}
	if [ ! -d "${BUILD_PATH}/atf-fastboot" ]; then
		echo "Warning: Can't find fastboot source code to build"
		exit
	fi
	if [ $EDK2_PLATFORM ]; then
		EDK2_OUTPUT_DIR=${BUILD_PATH}/l-loader/Build/HiKey/${BUILD_OPTION}_${AARCH64_TOOLCHAIN}
	else
		EDK2_OUTPUT_DIR=${EDK2_DIR}/Build/HiKey/${BUILD_OPTION}_${AARCH64_TOOLCHAIN}
	fi
	cd ${BUILD_PATH}
	;;
"hikey960")
	if [ $EDK2_PLATFORM ]; then
		EDK2_OUTPUT_DIR=${BUILD_PATH}/l-loader/Build/HiKey960/${BUILD_OPTION}_${AARCH64_TOOLCHAIN}
	else
		EDK2_OUTPUT_DIR=${EDK2_DIR}/Build/HiKey960/${BUILD_OPTION}_${AARCH64_TOOLCHAIN}
	fi
	cd ${BUILD_PATH}
	;;
esac

# Fip.bin is produced in ${EDK2_OUTPUT_DIR}. And ${EDK2_OUTPUT_DIR} is local environment variable.
echo $EDK2_OUTPUT_DIR

# Always clean build EDK2
rm -f ${BUILD_PATH}/l-loader/l-loader.bin
rm -fr ${BUILD_PATH}/arm-trusted-firmware/build
rm -fr ${BUILD_PATH}/atf-fastboot/build
cd ${EDK2_DIR}/BaseTools
make clean
rm -fr ${EDK2_DIR}/Build/
rm -f ${EDK2_OUTPUT_DIR}/FV/bl1.bin
rm -f ${EDK2_OUTPUT_DIR}/FV/fip.bin
rm -f ${EDK2_OUTPUT_DIR}/FV/BL33_AP_UEFI.fd
sync

echo "Start to build ${PLATFORM} Bootloader..."

case "${BUILD_OPTION}" in
"DEBUG")
	echo "Debug build"
	BUILD_DEBUG=1
	;;
"RELEASE")
	echo "Release build"
	BUILD_DEBUG=0
	;;
* )
	echo "Invalid build mode"
	exit
	;;
esac

# Build fastboot for HiKey
case "${PLATFORM}" in
"hikey")
	cd ${BUILD_PATH}/atf-fastboot
	case "${TOOLCHAIN_FAMILY}" in
	"gcc")
		CROSS_COMPILE=aarch64-linux-gnu- make PLAT=${PLATFORM} DEBUG=${BUILD_DEBUG}
		;;
	"clang")
		CROSS_COMPILE=aarch64-linux-gnu- PATH=/opt/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/:${PATH} make CC=/usr/bin/clang PLAT=${PLATFORM} DEBUG=${BUILD_DEBUG}
		;;
	*)
		echo "Invalid toolchain family: ${TOOLCHAIN_FAMILY}"
		exit
		;;
	esac
	if [ $? != 0 ]; then
		echo "Fail to build fastboot ($?)"
		exit
	fi
	# Convert "DEBUG"/"RELEASE" to "debug"/"release"
	if [ -f ${BUILD_PATH}/atf-fastboot/build/${PLATFORM}/$(echo ${BUILD_OPTION,,})/bl1.bin ]; then
		cd ${BUILD_PATH}/l-loader
		ln -sf ${BUILD_PATH}/atf-fastboot/build/${PLATFORM}/$(echo ${BUILD_OPTION,,})/bl1.bin fastboot.bin
	else
		echo "ERROR: Can't find fastboot binary"
		exit
	fi
	;;
esac

function do_symlink()
{
	# Locate output files of UEFI & Arm Trust Firmware
	cd ${BUILD_PATH}/l-loader
	if [ $EDK2_PLATFORM ]; then
		echo "BUILD_OPTION:$BUILD_OPTION"
		ln -sf ../arm-trusted-firmware/build/${PLATFORM}/$(echo ${BUILD_OPTION,,})/bl1.bin
		ln -sf ../arm-trusted-firmware/build/${PLATFORM}/$(echo ${BUILD_OPTION,,})/bl2.bin
		ln -sf ../arm-trusted-firmware/build/${PLATFORM}/$(echo ${BUILD_OPTION,,})/fip.bin
	else
		ln -sf ${EDK2_OUTPUT_DIR}/FV/bl1.bin
		ln -sf ${EDK2_OUTPUT_DIR}/FV/bl2.bin
		ln -sf ${EDK2_OUTPUT_DIR}/FV/fip.bin
	fi
	if [ -f ${EDK2_OUTPUT_DIR}/FV/BL33_AP_UEFI.fd ]; then
		ln -sf ${EDK2_OUTPUT_DIR}/FV/BL33_AP_UEFI.fd
	fi
}

# Build UEFI & ARM Trusted Firmware
if [ $EDK2_PLATFORM ]; then
	# Must not build in edk2 directory. Otherwise, we'll meet build failure.
	cd ${BUILD_PATH}/l-loader
	case "${TOOLCHAIN_FAMILY}" in
	"gcc")
		${UEFI_TOOLS_DIR}/edk2-build.sh -b $BUILD_OPTION -a ../arm-trusted-firmware -s ../optee_os -e ../edk2 -p ../edk2-platforms -n ../edk2-non-osi -T $TOOLCHAIN_FAMILY $PLATFORM
		;;
	"clang")
		# Build edk2
		${UEFI_TOOLS_DIR}/edk2-build.sh -b $BUILD_OPTION -e ../edk2 -p ../edk2-platforms -n ../edk2-non-osi -T $TOOLCHAIN_FAMILY $PLATFORM
		# Build OPTEE
		# Can't support thumb
		#cd ${BUILD_PATH}/optee_os
		#CROSS_COMPILE=arm-linux-gnueabihf- CROSS_COMPILE_core=aarch64-linux-gnu- CROSS_COMPILE_ta_arm64=aarch64-linux-gnu- CROSS_COMPILE_ta_arm32=arm-linux-gnueabihf- PATH=/opt/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/:${PATH} make CC=/usr/bin/clang PLATFORM=hikey-hikey960 CFG_ARM_core=y
		# Build ARM Trusted Firmware
		cd ${BUILD_PATH}/arm-trusted-firmware
		#CROSS_COMPILE=aarch64-linux-gnu- PATH=/opt/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/:${PATH} make CC=/usr/bin/clang PLAT=$PLATFORM SPD=opteed BL32=../optee_os/out/arm-plat-hikey/core/tee-pager.bin BL33=${EDK2_OUTPUT_DIR}/FV/BL33_AP_UEFI.fd DEBUG=$BUILD_DEBUG all
		CROSS_COMPILE=aarch64-linux-gnu- PATH=/opt/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/:${PATH} make CC=/usr/bin/clang PLAT=$PLATFORM BL33=${EDK2_OUTPUT_DIR}/FV/BL33_AP_UEFI.fd DEBUG=$BUILD_DEBUG all fip
		;;
	esac
else
	cd ${EDK2_DIR}
	${UEFI_TOOLS_DIR}/uefi-build.sh -b $BUILD_OPTION -a ../arm-trusted-firmware $PLATFORM
	#${UEFI_TOOLS_DIR}/uefi-build.sh -b $BUILD_OPTION -a ../arm-trusted-firmware -s ../optee_os $PLATFORM
fi
if [ $? != 0 ]; then
	echo "Fail to build UEFI & ARM Trusted Firmware ($?)"
	exit
fi

do_symlink

case "${PLATFORM}" in
"hikey")
	# Patch aarch64 mode on bl1.bin. Then bind it with fastboot.
	make -f ${PLATFORM}.mk recovery.bin
	# Patch aarch64 mode on bl2.bin
	make -f ${PLATFORM}.mk l-loader.bin

	# Generate partition table
	if [ $GENERATE_PTABLE ]; then
		PTABLE=aosp-8g SECTOR_SIZE=512 bash -x generate_ptable.sh
	fi

	;;
"hikey960")
	# Bind bl1.bin with BL33
	make -f ${PLATFORM}.mk recovery.bin
	# Use bl2.bin as l-loader
	make -f ${PLATFORM}.mk l-loader.bin

	# Generate partition table with a patched sgdisk to force
	# default alignment (2048) and sector size (4096)
	if [ $GENERATE_PTABLE ]; then
		PTABLE=aosp-32g SECTOR_SIZE=4096 SGDISK=./sgdisk bash -x generate_ptable.sh
	fi
	;;
esac
