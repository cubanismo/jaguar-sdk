#!/bin/sh

set -e

SDK_DIR="`dirname "$0"`"
SDK_DIR="`readlink -f "${SDK_DIR}"`"
TARGET_DIR="${SDK_DIR}/tools"
SRC_PATH="tools/src"
SRC_DIR="${SDK_DIR}/${SRC_PATH}"
PATCH_DIR="${SDK_DIR}/tools/patches"

GDB_VERSION="8.1.1"

GDB_SRC_DIR="${SRC_DIR}/gdb/gdb-${GDB_VERSION}"

if [ -d "${GDB_SRC_DIR}" ]; then
	echo "Found existing GDB source dir:"
 	echo ""
 	echo "  '${GDB_SRC_DIR}'?"
 	echo ""
	echo "If not removed, patching may fail."
	RETRY="yes"
	while [ -n "${RETRY}" ]; do
		echo -n "  Remove [yN]: "
		read REMOVE

		case "${REMOVE}" in
		n|N|no|No|NO|nO|"")
			RETRY=""
			;;

		y|Y|yes|yeS|yEs|yES|Yes|YEs|YeS|YES)
			RETRY=""
			rm -r "${GDB_SRC_DIR}"
			;;
		*)
			echo "Please respond 'y' or 'n'."
			;;
		esac
	done
fi

echo "Building tools, Installing in: \"${TARGET_DIR}\""

mkdir -p "${TARGET_DIR}/bin"

echo "Building rmac..."

cd "${SDK_DIR}"
git submodule update --checkout -- "${SRC_PATH}/rmac"
cd "${SRC_DIR}/rmac"
git am "${PATCH_DIR}/rmac-"*
make
strip --strip-unneeded rmac
cp rmac  "${TARGET_DIR}/bin"

echo "Building rln..."

cd "${SDK_DIR}"
git submodule update --checkout -- "${SRC_PATH}/rln"
cd "${SRC_DIR}/rln"
# No outstanding RLN patches at the moment :-)
#git am "${PATCH_DIR}/rln-"*
make
strip --strip-unneeded rln
cp rln  "${TARGET_DIR}/bin"

echo "Building lo_inp..."

cd "${SRC_DIR}/lo_inp"
make
strip --strip-unneeded lo_inp
cp lo_inp  "${TARGET_DIR}/bin"

echo "Building 3dsconv..."

cd "${SRC_DIR}/3dsconv"
make
strip --strip-unneeded 3dsconv
cp 3dsconv  "${TARGET_DIR}/bin"

echo "Building tga2cry..."

cd "${SRC_DIR}/tga2cry"
make
strip --strip-unneeded tga2cry tgainfo
cp tga2cry tgainfo  "${TARGET_DIR}/bin"

echo "Building pc_jagcrypt..."

cd "${SRC_DIR}/pc_jagcrypt"
make
# Jagcrypt is stripped in its own Makefile, and potentially then
# compressed using UPX, so don't attempt to re-strip it here.
cp jagcrypt "${TARGET_DIR}/bin"

echo "Building jcp..."

cd "${SRC_DIR}/jcp/jcp"
make REMOVERS=0
strip --strip-unneeded jcp
cp jcp "${TARGET_DIR}/bin"
make REMOVERS=0 clean

echo "Building rmvjcp..."

cd "${SRC_DIR}/jcp/jcp"
make REMOVERS=1
strip --strip-unneeded jcp
cp jcp "${TARGET_DIR}/bin/rmvjcp"
make REMOVERS=1 clean

case `uname -m` in
	x86_64|i?86)
		echo "Building a.out loader..."
		cd "${SRC_DIR}/kernel-tools/a.out"
		make
		cp aout "${TARGET_DIR}/bin/aout-loader"
		;;
	*)
		echo "Not x86/x86_64 host, so not building the a.out loader"
		echo "Some tools (mac/aln/wdb/rdbjag) will not be usable"
		;;
esac

echo "Building jag_utils..."
cd "${SRC_DIR}/jag_utils"
make
cp allsyms filefix size symval  "${TARGET_DIR}/bin"

echo "Building jdis..."
cd "${SRC_DIR}/jrisc_tools"
make
cp jdis "${TARGET_DIR}/bin"
cd "${SRC_DIR}/jrisc_tools/python"
make PYTHON_EXT_DIR="${TARGET_DIR}/lib/python"

mkdir -p "${SRC_DIR}/gcc"
cd "${SRC_DIR}/gcc"

echo "Building jserve..."
cd "${SRC_DIR}/jserve"
make
# XXX Don't install for now. Needs to be next to jdb.cof

mkdir -p "${SRC_DIR}/gcc"
cd "${SRC_DIR}/gcc"

wget -N https://ftpmirror.gnu.org/binutils/binutils-2.16.1a.tar.bz2
wget -N https://ftpmirror.gnu.org/gcc/gcc-3.4.6/gcc-3.4.6.tar.bz2

echo -n "Extracting bintuils..."
tar jxf binutils-2.16.1a.tar.bz2
echo "Done"

cd binutils-2.16.1

# Apply patches:
# - Fix for *** buffer overflow detected ***: m68k-aout-ar terminated:
#     https://github.com/stuartatpeasy/m68k-system/blob/master/doc/toolchain_problems
# - Switch m68k default processor from m68020 to m68000
patch -p1 < "${PATCH_DIR}/binutils-2.16.1a-fixes.diff"

# Update the config.guess and config.sub scripts to support aarch64 and any
# other "new" architectures introduced after ~2004
wget -O config.guess "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" && chmod +x config.guess
wget -O config.sub "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" && chmod +x config.sub

./configure --prefix="${TARGET_DIR}" --target=m68k-aout
make -j`nproc`
make install
cd ..

echo -n "Extracting gcc..."
tar jxf gcc-3.4.6.tar.bz2
echo "Done"

# Apply patches:
# - Fix open() with O_CREAT and missing "mode" parameter
# - Fix for https://gcc.gnu.org/bugzilla/show_bug.cgi?id=28911 :
#     https://gcc.gnu.org/git/?p=gcc.git&a=commit;h=ab1e659cf766a49fe1923fefc9cbacbd4e320fc4
# - Switch m68k default processor from m68020 to m68000
cd gcc-3.4.6
patch -p1 < "${PATCH_DIR}/gcc-3.4.6-fixes.diff"

# Update the config.guess and config.sub scripts to support aarch64 and any
# other "new" architectures introduced after ~2004
wget -O config.guess "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" && chmod +x config.guess
wget -O config.sub "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" && chmod +x config.sub
cd ..

mkdir -p gcc-build
cd gcc-build
PATH="${TARGET_DIR}/bin:${PATH}" \
	../gcc-3.4.6/configure \
	--prefix="${TARGET_DIR}" \
	--target=m68k-aout \
	--disable-multilib \
	--enable-languages=c
PATH="${TARGET_DIR}/bin:${PATH}" make -j`nproc`
PATH="${TARGET_DIR}/bin:${PATH}" make install

mkdir -p "${SRC_DIR}/gdb"
cd "${SRC_DIR}/gdb"
wget -N https://ftpmirror.gnu.org/gdb/gdb-${GDB_VERSION}.tar.xz

echo -n "Extracting gdb..."
tar Jxf gdb-${GDB_VERSION}.tar.xz
echo "Done"

# Apply patches:
# - Disable installation of documentation to avoid makeinfo requirement
cd gdb-${GDB_VERSION}
for P in "${PATCH_DIR}"/gdb-*.patch; do
	echo "Applying '`basename "$P"`'"
	patch -p1 < "${P}"
done
cd ..

mkdir -p gdb-build
cd gdb-build
PATH="${TARGET_DIR}/bin:${PATH}" \
	../gdb-${GDB_VERSION}/configure \
	--prefix="${TARGET_DIR}" \
	--disable-docs \
	--enable-obsolete \
	--target=m68k-coff \
	--enable-targets=m68k-aout,m68k-elf \
	--enable-tui \
	--with-python=python3
PATH="${TARGET_DIR}/bin:${PATH}" make -j`nproc`
PATH="${TARGET_DIR}/bin:${PATH}" make install

# Strip binaries
cd "${TARGET_DIR}"/bin
# strip complains about this script not being a binary, and no one upstream is
# fixing bugs against this version of GCC anyway. Just delete it.
rm m68k-aout-gccbug
strip --strip-unneeded * || true
cd "${TARGET_DIR}"/m68k-aout/bin
strip --strip-unneeded * || true

# Remove documentation
cd "${TARGET_DIR}"
rm -rf info man
