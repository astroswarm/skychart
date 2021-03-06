#!/bin/bash 

version=3.9

builddir=/tmp/skychart  # Be sure this is set to a non existent directory, it is removed after the run!
innosetup="C:\Program Files\Inno Setup 5\ISCC.exe"  # Install under Wine from http://www.jrsoftware.org/isinfo.php
wine_build="Z:\tmp\skychart" # Change to match builddir, Z: is defined in ~/.wine/dosdevices

extratarget=",x86_64-linux"

# For win32 and win64 target you must also install the corresponding mingw-w64 to build the C library
mingw32=/opt/mingw-w32/bin/

if [[ -n $1 ]]; then
  configopt="fpc=$1"
fi
if [[ -n $2 ]]; then
  configopt=$configopt" lazarus=$2"
  lazdir=$2
fi

save_PATH=$PATH
wd=`pwd`

currentrev=$(LANG=C svn info . | grep Revision: | sed 's/Revision: //')

# delete old files
  rm cdcvaldereuil*.zip
  rm cdcvaldereuil*.exe
  rm -rf $builddir

  rsync -a --exclude=.svn system_integration/Windows/installer/skychart/* $builddir
  export PATH=$mingw32:$save_PATH
  ./configure $configopt prefix=$builddir/Data target=i386-win32$extratarget
  if [[ $? -ne 0 ]]; then exit 1;fi
  make OS_TARGET=win32 CPU_TARGET=i386 clean
  make OS_TARGET=win32 CPU_TARGET=i386
  if [[ $? -ne 0 ]]; then exit 1;fi
  cd -
  ##
  make install_win
  if [[ $? -ne 0 ]]; then exit 1;fi
  make install_win_data
  if [[ $? -ne 0 ]]; then exit 1;fi
  make install_win_doc
  if [[ $? -ne 0 ]]; then exit 1;fi
  make install_win_nonfree
  if [[ $? -ne 0 ]]; then exit 1;fi
  # install astrolabe
  destdir=$builddir/Data
  install -v -m 644 skychart/sample_client/astrolabe/astrolabe.png  $destdir/
  install -v -m 644 skychart/sample_client/astrolabe/skychart_valdereuil.ini  $destdir/
  install -v -m 644 skychart/sample_client/astrolabe/symbols/symbol{1..11}.png $destdir/data/planet/
  install -v -m 644 skychart/sample_client/astrolabe/symbols/symbol11_n.png $destdir/data/planet/
  install -v -m 644 skychart/sample_client/astrolabe/symbols/symbol11_f.png $destdir/data/planet/
  install -v -m 644 skychart/sample_client/astrolabe/symbols/symbol11_fq.png $destdir/data/planet/
  install -v -m 644 skychart/sample_client/astrolabe/symbols/symbol11_lq.png $destdir/data/planet/
  #
  # zip
  cd $builddir/Data
  zip -r  cdcvaldereuil-$version-$currentrev-windows.zip *
  if [[ $? -ne 0 ]]; then exit 1;fi
  mv cdcvaldereuil*.zip $wd
  # exe
  cd $builddir
  sed -i "/AppVerName/ s/V3/V$version/" cdcvaldereuil.iss
  sed -i "/OutputBaseFilename/ s/windows/$version-$currentrev-windows/" cdcvaldereuil.iss
  wine "$innosetup" "$wine_build\cdcvaldereuil.iss"
  if [[ $? -ne 0 ]]; then exit 1;fi
  mv $builddir/cdcvaldereuil*.exe $wd

  cd $wd
  rm -rf $builddir

