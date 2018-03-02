#!/bin/sh
#
# Usage: bash build_uefi.sh {platform}
#

BUILD_OPTION=DEBUG
#BUILD_OPTION=RELEASE
AARCH64_GCC=LINARO_GCC_7_2    # Prefer to use Linaro GCC >= 7.1.1. Otherwise, user may meet some toolchain issues.
#CLANG=CLANG_5_0               # Prefer to use CLANG >= 3.9. Since LLVMgold.so is missing in CLANG 3.8.
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
	;;
"LINARO_GCC_7_1")
	AARCH64_GCC_7_1=/opt/toolchain/gcc-linaro-7.1.1-2017.08-x86_64_aarch64-linux-gnu/bin/
	PATH=${AARCH64_GCC_7_1}:${PATH} && export PATH
	export AARCH64_TOOLCHAIN=GCC5
	CROSS_COMPILE=aarch64-linux-gnu-
	;;
"LINARO_GCC_7_2")
	AARCH64_GCC_7_2=/opt/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/
	PATH=${AARCH64_GCC_7_2}:${PATH} && export PATH
	export AARCH64_TOOLCHAIN=GCC5
	CROSS_COMPILE=aarch64-linux-gnu-
	;;
*)
	echo "Not supported toolchain:${AARCH64_GCC}"
	exit
	;;
esac

case "${CLANG}" in
"CLANG_3_9")
	export AARCH64_TOOLCHAIN=CLANG38
	export CC=/usr/bin/clang
	;;
"CLANG_5_0")
	export AARCH64_TOOLCHAIN=CLANG38
	export CC=/usr/bin/clang
	;;
"")
	# CLANG is not used.
	export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
	;;
*)
	echo "Not supported CLANG:${CLANG}"
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

if [ -d "${PWD}/edk2" ] && [ -d "${PWD}/arm-trusted-firmware" ] && [ -d "${PWD}/l-loader" ]; then
	# Check whether source code are available in ${PWD}
	BUILD_PATH=${PWD}
	echo "Find source code in ${PWD}"
elif [ -d "${PWD}/../edk2" ] && [ -d "${PWD}/../arm-trusted-firmware" ] && [ -d "${PWD}/../l-loader" ]; then
	# Check whether source code are available in parent of ${PWD}
	BUILD_PATH=$(dirname ${PWD})
	echo "Find source code in parent directory of ${PWD}"
else
	echo "Warning: Can't find source code to build."
	exit
fi

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
	EDK2_OUTPUT_DIR=${BUILD_PATH}/Build/HiKey/${BUILD_OPTION}_${AARCH64_TOOLCHAIN}
	;;
"hikey960")
	EDK2_OUTPUT_DIR=${BUILD_PATH}/Build/HiKey960/${BUILD_OPTION}_${AARCH64_TOOLCHAIN}
	;;
esac

# Always clean build EDK2
rm -f ${BUILD_PATH}/l-loader/l-loader.bin
rm -fr ${BUILD_PATH}/arm-trusted-firmware/build
rm -fr ${BUILD_PATH}/atf-fastboot/build
cd ${EDK2_DIR}/BaseTools
make clean
rm -fr ${BUILD_PATH}/Build/
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
	if [ $CLANG ]; then
		CROSS_COMPILE=aarch64-linux-gnu- PATH=${AARCH64_GCC}:${PATH} make PLAT=${PLATFORM} DEBUG=${BUILD_DEBUG}
	else
		CROSS_COMPILE=aarch64-linux-gnu- make PLAT=${PLATFORM} DEBUG=${BUILD_DEBUG}
	fi
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
	ln -sf ../arm-trusted-firmware/build/${PLATFORM}/$(echo ${BUILD_OPTION,,})/bl1.bin
	ln -sf ../arm-trusted-firmware/build/${PLATFORM}/$(echo ${BUILD_OPTION,,})/bl2.bin
	ln -sf ../arm-trusted-firmware/build/${PLATFORM}/$(echo ${BUILD_OPTION,,})/fip.bin
	if [ -f ${EDK2_OUTPUT_DIR}/FV/BL33_AP_UEFI.fd ]; then
		ln -sf ${EDK2_OUTPUT_DIR}/FV/BL33_AP_UEFI.fd
	fi
}

function do_build()
{
	# Build edk2
	cd ${BUILD_PATH}
	export WORKSPACE=${BUILD_PATH}
	if [ $EDK2_PLATFORM ]; then
		export PACKAGES_PATH=${WORKSPACE}/edk2:${WORKSPACE}/edk2-platforms:${WORKSPACE}/edk2-non-osi
		case "${PLATFORM}" in
		"hikey")
			DSC=Platform/Hisilicon/HiKey/HiKey.dsc
			SCP_BL2=../edk2-non-osi/Platform/Hisilicon/HiKey/mcuimage.bin
			;;
		"hikey960")
			DSC=Platform/Hisilicon/HiKey960/HiKey960.dsc
			SCP_BL2=../edk2-non-osi/Platform/Hisilicon/HiKey960/lpm3.img
			;;
		esac
	else
		export PACKAGES_PATH=${WORKSPACE}/edk2
		case "${PLATFORM}" in
		"hikey")
			DSC=OpenPlatformPkg/Platforms/Hisilicon/HiKey/HiKey.dsc
			SCP_BL2=../edk2/OpenPlatformPkg/Platforms/Hisilicon/HiKey/Binary/mcuimage.bin
			;;
		"hikey960")
			DSC=OpenPlatformPkg/Platforms/Hisilicon/HiKey960/HiKey960.dsc
			SCP_BL2=../edk2/OpenPlatformPkg/Platforms/Hisilicon/HiKey960/Binary/lpm3.img
			;;
		esac
	fi
	source edk2/edksetup.sh
	make -C edk2/BaseTools
	build -a AARCH64 -t ${AARCH64_TOOLCHAIN} -p ${DSC} -b ${BUILD_OPTION}
	# Build OPTEE
	cd ${BUILD_PATH}/optee_os
	CROSS_COMPILE=arm-linux-gnueabihf- CROSS_COMPILE_core=aarch64-linux-gnu- CROSS_COMPILE_ta_arm64=aarch64-linux-gnu- CROSS_COMPILE_ta_arm32=arm-linux-gnueabihf- PATH=${AARCH64_GCC}:${PATH} make PLATFORM=hikey-${PLATFORM} CFG_ARM64_core=y
	# Build ARM Trusted Firmware
	cd ${BUILD_PATH}/arm-trusted-firmware
	BL32=../optee_os/out/arm-plat-hikey/core/tee-pager.bin
	BL33=${EDK2_OUTPUT_DIR}/FV/BL33_AP_UEFI.fd
	CROSS_COMPILE=aarch64-linux-gnu- PATH=${AARCH64_GCC}:${PATH} make PLAT=${PLATFORM} SCP_BL2=${SCP_BL2} SPD=opteed BL32=${BL32} BL33=${BL33} DEBUG=${BUILD_DEBUG} all fip
}

# Build UEFI & ARM Trusted Firmware
do_build
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
