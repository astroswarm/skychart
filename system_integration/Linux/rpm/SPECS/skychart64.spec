Summary: Skychart / Cartes du Ciel planetarium software
Name: skychart
Version: 3
Release: 1
Group: Sciences/Astronomy
License: GPL
URL: http://skychart.sourceforge.net
Packager: Patrick Chevalley
BuildRoot: %_topdir/%{name}
BuildArch: x86_64
Provides: skychart libplan404.so
Requires: gtk2 glib2 pango libjpeg libpng libsqlite3.so.0
AutoReqProv: no

%description
Planetarium software for the advanced amateur astronomer.

%files
%defattr(-,root,root)
/usr/bin/skychart
/usr/bin/cdcicon
/usr/bin/varobs
/usr/bin/varobs_lpv_bulletin
/usr/lib64/libplan404.so
/usr/lib64/libgetdss.so
/usr/share/applications/skychart.desktop
/usr/share/pixmaps/skychart.xpm
/usr/share/doc/skychart
/usr/share/skychart

