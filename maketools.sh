#!/bin/sh

set -e

SDK_DIR="`dirname "$0"`"
SDK_DIR="`readlink -f "${SDK_DIR}"`"
TARGET_DIR="${SDK_DIR}/tools"
SRC_DIR="${SDK_DIR}/tools/src"
PATCH_DIR="${SDK_DIR}/tools/patches"

echo "Building tools, Installing in: \"${TARGET_DIR}\""

mkdir -p "${TARGET_DIR}/bin"

cd "${SRC_DIR}/rmac"
make
strip --strip-unneeded rmac
cp rmac  "${TARGET_DIR}/bin"

cd "${SRC_DIR}/rln"
make
strip --strip-unneeded rln
cp rln  "${TARGET_DIR}/bin"

cd "${SRC_DIR}/lo_inp"
make
strip --strip-unneeded lo_inp
cp lo_inp  "${TARGET_DIR}/bin"

cd "${SRC_DIR}/3dsconv"
make
strip --strip-unneeded 3dsconv
cp 3dsconv  "${TARGET_DIR}/bin"

cd "${SRC_DIR}/tga2cry"
make
strip --strip-unneeded tga2cry tgainfo
cp tga2cry tgainfo  "${TARGET_DIR}/bin"

cd "${SRC_DIR}/pc_jagcrypt"
make
# Jagcrypt is stripped in its own Makefile, and potentially then
# compressed using UPX, so don't attempt to re-strip it here.
cp jagcrypt "${TARGET_DIR}/bin"

mkdir -p "${SRC_DIR}/gcc"
cd "${SRC_DIR}/gcc"

wget https://ftpmirror.gnu.org/binutils/binutils-2.16.1a.tar.bz2
wget https://ftpmirror.gnu.org/gcc/gcc-3.4.6/gcc-3.4.6.tar.bz2

echo -n "Extracting bintuils..."
tar jxf binutils-2.16.1a.tar.bz2
echo "Done"

cd binutils-2.16.1

# Apply patches:
# - Fix for *** buffer overflow detected ***: m68k-aout-ar terminated:
#     https://github.com/stuartatpeasy/m68k-system/blob/master/doc/toolchain_problems
# - Switch m68k default processor from m68020 to m68000
patch -p1 < "${PATCH_DIR}/binutils-2.16.1a-fixes.diff"

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

# Strip binaries
cd "${TARGET_DIR}"/bin
strip --strip-unneeded * || true
cd "${TARGET_DIR}"/m68k-aout/bin
strip --strip-unneeded * || true

# Remove documentation
cd "${TARGET_DIR}"
rm -rf info man
