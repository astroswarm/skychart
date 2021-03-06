#!/bin/bash 

version=3.11

basedir=/tmp/skychart   # Be sure this is set to a non existent directory, it is removed after the run!

builddir=$basedir/Cartes

if [[ -n $1 ]]; then
  configopt="fpc=$1"
fi
if [[ -n $2 ]]; then
  configopt=$configopt" lazarus=$2"
fi

wd=`pwd`

# check if new revision since last run
read lastrev <last.build
currentrev=$(LANG=C svn info . | grep Revision: | sed 's/Revision: //')
if [[ -z $currentrev ]]; then 
 currentrev=$(grep RevisionStr skychart/revision.inc| sed "s/const RevisionStr = '//"| sed "s/';//")
fi
echo $lastrev ' - ' $currentrev
if [[ $lastrev -ne $currentrev ]]; then

# delete old files
  rm skychart-3*.dmg
  rm bin-*.bz2
  rm -rf $basedir

# make x86_64 Mac version
  ./configure $configopt prefix=$builddir target=x86_64-darwin
  if [[ $? -ne 0 ]]; then exit 1;fi
  make clean
  fpcopts="-CX -XX -Xs" make
  if [[ $? -ne 0 ]]; then exit 1;fi
  make install
  if [[ $? -ne 0 ]]; then exit 1;fi
  make install_data
  if [[ $? -ne 0 ]]; then exit 1;fi
  make install_doc
  if [[ $? -ne 0 ]]; then exit 1;fi
  make install_nonfree
  if [[ $? -ne 0 ]]; then exit 1;fi
  # pkg
  sed -i.bak "18s/1.0/$version/"  $builddir/skychart.app/Contents/Info.plist
  sed -i.bak "24s/1.0/$version/"  $builddir/varobs.app/Contents/Info.plist
  rm $builddir/skychart.app/Contents/Info.plist.bak
  rm $builddir/varobs.app/Contents/Info.plist.bak
  macdeployqt $builddir/skychart.app
  macdeployqt $builddir/varobs.app
  cd $builddir/varobs.app/Contents
  rm -rf Frameworks
  ln -s ../../skychart.app/Contents/Frameworks .
  cd - 
  cp system_integration/MacOSX/skychart.packproj $basedir
  cp system_integration/MacOSX/readme.txt $basedir
  cd $basedir
  mv Cartes "Cartes du Ciel"
  freeze -v skychart.packproj
  if [[ $? -ne 0 ]]; then exit 1;fi
  hdiutil create -anyowners -volname skychart-$version-$currentrev-x86_64-macosx -imagekey zlib-level=9 -format UDZO -srcfolder ./build skychart-$version-$currentrev-x86_64-macosx.dmg
  if [[ $? -ne 0 ]]; then exit 1;fi
  mv skychart*.dmg $wd
  if [[ $? -ne 0 ]]; then exit 1;fi
  #debug
  cd $wd
  rm -rf $basedir
  make clean
  fpcopts="-g -gl -Ci -Co -Ct" make
  if [[ $? -ne 0 ]]; then exit 1;fi
  mkdir $basedir
  mkdir $basedir/debug
  cp skychart/cdc $basedir/debug/skychart
  cp varobs/varobs $basedir/debug/
  cd $basedir/debug/
  if [[ $? -ne 0 ]]; then exit 1;fi
  tar cvjf bin-macosx-debug-$currentrev.tar.bz2 *
  if [[ $? -ne 0 ]]; then exit 1;fi
  mv bin-*.tar.bz2 $wd
  if [[ $? -ne 0 ]]; then exit 1;fi

  cd $wd
  rm -rf $basedir

# store revision 
  echo $currentrev > last.build
else
  echo Already build at revision $currentrev
  exit 4
fi

