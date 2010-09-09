; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=Cartes du Ciel DSO catalog
AppVerName=Cartes du Ciel DSO catalog v3
AppPublisherURL=http://www.ap-i.net/skychart
AppSupportURL=http://www.ap-i.net/skychart
AppUpdatesURL=http://www.ap-i.net/skychart
DefaultDirName={reg:HKCU\Software\Astro_PC\Ciel,Install_Dir|{pf}\Ciel}
UsePreviousAppDir=no
DefaultGroupName=Cartes du Ciel V3.0
AllowNoIcons=yes
InfoBeforeFile=Presetup\readme.txt
OutputDir=.\
OutputBaseFilename=skychart-data-dso-windows
Compression=lzma
SolidCompression=true
Uninstallable=true
UninstallLogMode=append
DirExistsWarning=no
AppID={{A261F28E-6053-4414-9B84-AA8FE5F47AD4}

[Files]
Source: "Data\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
