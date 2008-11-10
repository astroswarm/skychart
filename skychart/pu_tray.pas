unit pu_tray;

{$mode objfpc}{$H+}

interface

uses
{$ifdef win32}
  windows,
{$endif}
  u_help, u_translation, u_util, u_constant, u_projection, cu_planet, cu_database, Inifiles,
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Menus, ExtCtrls, StdCtrls, ComCtrls, ColorBox, Spin, dynlibs, Math;

type

  { Tf_tray }

  Tf_tray = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ColorBox1: TColorBox;
    ColorBox2: TColorBox;
    Imagetest: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    PageControl1: TPageControl;
    PopupMenu1: TPopupMenu;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    SpinEdit1: TSpinEdit;
    SysTray: TTrayIcon;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure IconSettingChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure UpdateIcon(Sender: TObject);
  private
    { private declarations }
    icontype, icontextsize, iconinfo : integer;
    iconbg, icontext: TColor;
    bmp:TBitmap;
    language:string;
    WantClose: boolean;
    db,dbhost,dbuser,dbpass,cryptedpwd:string;
    dbport: integer;
    cdcdb:Tcdcdb;
    procedure TrayMsg(txt1,txt2,hint1:string);
    procedure UpdBmp(txt1,txt2:string; itype,isize:integer; ibg,ifg:TColor; ubmp:TBitmap);
    procedure UpdBmpTest(txt1,txt2:string);
    procedure GetAppdir;
    procedure GetLanguage;
    procedure SetLang;
    procedure SaveConfig;
    procedure LoadIcon;
    procedure ConnectDB;
  public
    { public declarations }
    procedure Init;
  end; 

var
  f_tray: Tf_tray;

implementation

uses pu_clock, pu_calendar;

{ Tf_tray }

procedure Tf_tray.SetLang;
begin
ldeg:=rsdeg;
lmin:=rsmin;
lsec:=rssec;
caption:=rsSkychartIcon;
TabSheet1.Caption:=rsAppearance;
RadioGroup2.Caption:=rsIconSize;
Label1.Caption:=rsBackground;
Label2.Caption:=rsText;
Label3.Caption:=rsTextSize;
TabSheet2.Caption:=rsClock;
RadioGroup1.Caption:=rsIconTime;
RadioGroup1.Items[0]:=rsLegal;
RadioGroup1.Items[1]:=rsUT;
RadioGroup1.Items[2]:=rsMeanLocal;
RadioGroup1.Items[3]:=rsTrueSolar;
RadioGroup1.Items[4]:=rsSideral;
Button1.Caption:=rsOK;
Button2.Caption:=rsCancel;
MenuItem1.caption:=rsClock;
MenuItem2.caption:=rsSkyCharts;
MenuItem3.caption:=rsSetup;
MenuItem4.caption:=rsCalendar;
MenuItem5.caption:=rsClose;
pla[1]:=rsMercury;
pla[2]:=rsVenus;
pla[4]:=rsMars;
pla[5]:=rsJupiter;
pla[6]:=rsSaturn;
pla[7]:=rsUranus;
pla[8]:=rsNeptune;
pla[9]:=rsPluto;
pla[10]:=rsSun;
pla[11]:=rsMoon;
pla[31]:=rsSatRing;
pla[32]:=rsEarthShadow;
end;

procedure Tf_tray.Init;
var inif: TMemIniFile;
    section : string;
begin
{$ifdef mswindows}
icontype:=0;
iconbg:=clBtnFace;
icontext:=clBtnText;
icontextsize:=7;
iconinfo:=4;
Radiogroup2.enabled:=false;
{$else}
icontype:=1;
iconbg:=clBtnFace;
icontext:=clBtnText;
icontextsize:=8;
iconinfo:=4;
{$endif}
f_clock.cfgsc:=Tconf_skychart.Create;
f_clock.planet:=TPlanet.Create(self);
inif:=TMeminifile.create(configfile);
try
with inif do begin
section:='icon';
icontype:=ReadInteger(section,'Icon_type',icontype);
iconbg:=ReadInteger(section,'Icon_bg',iconbg);
icontext:=ReadInteger(section,'Icon_text',icontext);
icontextsize:=ReadInteger(section,'Icon_textsize',icontextsize);
iconinfo:=ReadInteger(section,'Icon_info',iconinfo);
section:='observatory';
f_clock.cfgsc.ObsLatitude := ReadFloat(section,'ObsLatitude',0 );
f_clock.cfgsc.ObsLongitude := ReadFloat(section,'ObsLongitude',0 );
f_clock.cfgsc.ObsAltitude := ReadFloat(section,'ObsAltitude',0 );
f_clock.cfgsc.ObsTemperature := ReadFloat(section,'ObsTemperature',0);
f_clock.cfgsc.ObsPressure := ReadFloat(section,'ObsPressure',0 );
f_clock.cfgsc.ObsName := Condutf8decode(ReadString(section,'ObsName','' ));
f_clock.cfgsc.ObsCountry := ReadString(section,'ObsCountry','' );
f_clock.cfgsc.ObsTZ := ReadString(section,'ObsTZ','Etc/GMT' );
f_clock.cfgsc.countrytz := ReadBool(section,'countrytz',false);
section:='main';
DBtype:=TDBtype(ReadInteger(section,'dbtype',1));
dbhost:=ReadString(section,'dbhost','localhost');
dbport:=ReadInteger(section,'dbport',3306);
db:=ReadString(section,'db',slash(privatedir)+StringReplace(defaultSqliteDB,'/',PathDelim,[rfReplaceAll]));
dbuser:=ReadString(section,'dbuser','root');
cryptedpwd:=hextostr(ReadString(section,'dbpass',''));
dbpass:=DecryptStr(cryptedpwd,encryptpwd);
end;
finally
inif.Free;
end;
f_clock.cfgsc.tz.LoadZoneTab(ZoneDir+'zone.tab');
f_clock.cfgsc.tz.TimeZoneFile:=ZoneDir+StringReplace(f_clock.cfgsc.ObsTZ,'/',PathDelim,[rfReplaceAll]);
ConnectDB;
LoadIcon;
UpdateIcon(nil);
Timer1.Enabled:=true;
SysTray.Visible:=true;
Plan404:=nil;
Plan404lib:=LoadLibrary(lib404);
if Plan404lib<>0 then begin
  Plan404:= TPlan404(GetProcAddress(Plan404lib,'Plan404'));
end else
  MenuItem4.Enabled:=false; // no calendar
end;

procedure Tf_tray.SaveConfig;
var inif: TMemIniFile;
    section : string;
begin
inif:=TMeminifile.create(configfile);
try
with inif do begin
section:='icon';
WriteInteger(section,'Icon_type',icontype);
WriteInteger(section,'Icon_bg',iconbg);
WriteInteger(section,'Icon_text',icontext);
WriteInteger(section,'Icon_textsize',icontextsize);
WriteInteger(section,'Icon_info',iconinfo);
UpdateFile;
end;
finally
inif.Free;
end;
end;

procedure Tf_tray.UpdBmp(txt1,txt2:string; itype,isize:integer; ibg,ifg:TColor; ubmp:TBitmap);
var h,w,p1,p2,p3 : integer;
begin
ubmp.Canvas.Brush.Color:=ibg;
ubmp.Canvas.Brush.Style:=bsSolid;
ubmp.Canvas.Pen.Color:=ibg;
ubmp.Canvas.Pen.Mode:=pmCopy;
ubmp.Canvas.Rectangle(0,0,ubmp.Width,ubmp.Height);
ubmp.Canvas.Font.Color:=ifg;
ubmp.Canvas.TextStyle.Opaque:=false;
ubmp.Canvas.Brush.Style:=bsClear;
ubmp.Canvas.Pen.Mode:=pmCopy;
ubmp.Canvas.Font.Size:=isize;
h:=ubmp.Canvas.TextHeight('0');
w:=ubmp.Canvas.TextWidth('00');
case itype of
0 : begin
    p1:=(ubmp.Height-round(1.7*h)) div 2;
    p2:=round(0.8*h)+p1-1;
    p3:=(ubmp.Width-w) div 2;
    ubmp.Canvas.TextOut(p3,p1,txt1);
    ubmp.Canvas.TextOut(p3,p2,txt2);
    end;
1 : begin
    p1:=(ubmp.Height-round(1.7*h)) div 2;
    p2:=round(0.8*h)+p1;
    p3:=(ubmp.Width-w) div 2;
    ubmp.Canvas.TextOut(p3,p1,txt1);
    ubmp.Canvas.TextOut(p3,p2,txt2);
    end;
2 : begin
    p1:=(ubmp.Height-h) div 2;
    p3:=(ubmp.Width-round(2.5*w)) div 2;
    ubmp.Canvas.TextOut(p3,p1,txt1+':'+txt2);
    end;
end;
end;

procedure Tf_tray.UpdBmpTest(txt1,txt2:string);
begin
case RadioGroup2.ItemIndex of
  0 : begin
       imagetest.Width:=16;
       Imagetest.Height:=16;
      end;
  1 : begin
       imagetest.Width:=32;
       Imagetest.Height:=32;
      end;
  2 : begin
       imagetest.Width:=64;
       Imagetest.Height:=32;
      end;
end;
imagetest.Picture.Bitmap.Width:=imagetest.Width;
Imagetest.Picture.Bitmap.Height:=Imagetest.Height;
UpdBmp(txt1,txt2,RadioGroup2.ItemIndex,SpinEdit1.Value,ColorBox1.Selected,ColorBox2.Selected,Imagetest.Picture.Bitmap);
end;

procedure Tf_tray.TrayMsg(txt1,txt2,hint1:string);
begin
UpdBmp(txt1,txt2,icontype,icontextsize,iconbg,icontext,bmp);
Systray.Icon.FreeImage;
SysTray.Icon.Canvas.Draw(0,0,bmp);
Systray.Icon.FreeImage; // yep two time is better
SysTray.Icon.Canvas.Draw(0,0,bmp);
Systray.Hint:=hint1;
end;

procedure Tf_tray.Button1Click(Sender: TObject);
begin
  icontype:=RadioGroup2.ItemIndex;
  iconbg:=ColorBox1.Selected;
  icontext:=ColorBox2.Selected;
  icontextsize:=SpinEdit1.Value;
  iconinfo:=RadioGroup1.ItemIndex;
  SaveConfig;
  Hide;
  LoadIcon;
  UpdateIcon(nil);
end;

procedure Tf_tray.Button2Click(Sender: TObject);
begin
  Hide
end;

procedure Tf_tray.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not WantClose then CloseAction:=caHide;
end;

procedure Tf_tray.IconSettingChange(Sender: TObject);
begin
  UpdBmpTest('22','22');
end;

procedure Tf_tray.LoadIcon;
begin
  SysTray.Icon.FreeImage;
  case icontype of
   0 : SysTray.Icon.LoadFromLazarusResource('black16x16');
   1 : SysTray.Icon.LoadFromLazarusResource('black32x32');
   2 : SysTray.Icon.LoadFromLazarusResource('black32x64');
  end;
  bmp.Width:=SysTray.Icon.Width;
  bmp.Height:=SysTray.Icon.Height;
end;

procedure Tf_tray.FormCreate(Sender: TObject);
begin
  WantClose:=false;
  bmp:=TBitmap.Create;
  SysTray.PopUpMenu:=PopupMenu1;
  GetAppDir;
  GetLanguage;
  lang:=u_translation.translate(language);
  u_help.Translate(lang);
  SetLang;
end;

procedure Tf_tray.FormDestroy(Sender: TObject);
begin
  SysTray.Hide;
  bmp.free;
  if (f_clock<>nil)then begin
    if (f_clock.cfgsc<>nil) then f_clock.cfgsc.Free;
    if (f_clock.planet<>nil) then f_clock.planet.Free;
  end;
  if f_calendar<>nil then f_calendar.Free;
  if cdcdb<>nil then cdcdb.Free;
end;

procedure Tf_tray.MenuItem1Click(Sender: TObject);
begin
if f_clock.Visible then begin
  f_clock.Hide;
end else begin
  UpdateIcon(nil);
  FormPos(f_clock,SysTray.GetPosition.X+SysTray.Icon.Width,SysTray.GetPosition.Y);
  f_clock.Show;
end;
end;

procedure Tf_tray.MenuItem2Click(Sender: TObject);
begin
  ExecNoWait(CdC+' --unique');
end;

procedure Tf_tray.MenuItem3Click(Sender: TObject);
begin
  RadioGroup2.ItemIndex:=icontype;
  ColorBox1.Selected:=iconbg;
  ColorBox2.Selected:=icontext;
  SpinEdit1.Value:=icontextsize;
  RadioGroup1.ItemIndex:=iconinfo;
  UpdBmptest('22','22');
  FormPos(Self,SysTray.GetPosition.X,SysTray.GetPosition.Y);
  Show;
end;

procedure Tf_tray.MenuItem4Click(Sender: TObject);
var y,m,d:word;
    u,p : double;
const ratio = 0.99664719;
      H0 = 6378140.0 ;
begin
  if f_calendar=nil then begin
    f_calendar:=Tf_calendar.Create(self);
    f_calendar.planet:=f_clock.planet;
    f_calendar.cdb:=cdcdb;
    f_calendar.eclipsepath:=slash(appdir)+slash('data')+slash('eclipses');
    f_calendar.AzNorth:=true;
  end;
  f_calendar.config.Assign(f_clock.cfgsc);
  DecodeDate(Now,y,m,d);
  f_calendar.config.CurYear:=y;
  f_calendar.config.CurMonth:=m;
  f_calendar.config.CurDay:=d;
  f_calendar.config.CurTime:=frac(now)*24;
  f_calendar.config.JDChart:=jd(y,m,d,0);
  f_calendar.config.CurJD:=f_calendar.config.JDChart;
  f_calendar.config.PlanetParalaxe:=true;
  f_calendar.config.ApparentPos:=true;
  f_calendar.config.e:=ecliptic(f_calendar.config.JdChart);
  nutation(f_calendar.config.CurJd,f_calendar.config.nutl,f_calendar.config.nuto);
  f_calendar.planet.sunecl(f_calendar.config.CurJd,f_calendar.config.sunl,f_calendar.config.sunb);
  PrecessionEcl(jd2000,f_calendar.config.CurJd,f_calendar.config.sunl,f_calendar.config.sunb);
  aberration(f_calendar.config.CurJd,f_calendar.config.abe,f_calendar.config.abp);

  p:=deg2rad*f_calendar.config.ObsLatitude;
  u:=arctan(ratio*tan(p));
  f_calendar.config.ObsRoSinPhi:=ratio*sin(u)+(f_calendar.config.ObsAltitude/H0)*sin(p);
  f_calendar.config.ObsRoCosPhi:=cos(u)+(f_calendar.config.ObsAltitude/H0)*cos(p);
  f_calendar.config.ObsRefractionCor:=1;
  f_calendar.config.EquinoxName:=rsDate;
  f_calendar.config.Force_DT_UT:=false;
  f_calendar.config.DT_UT:=DTminusUT(y,f_calendar.config);
  formpos(f_calendar,SysTray.GetPosition.X,SysTray.GetPosition.Y);
  f_calendar.show;
  f_calendar.bringtofront;
end;

procedure Tf_tray.MenuItem5Click(Sender: TObject);
begin
  WantClose:=true;
  Close;
end;

procedure Tf_tray.UpdateIcon(Sender: TObject);
var buf1,buf2: string;
begin
  if not f_clock.Timer1.Enabled then f_clock.UpdateClock;
  case iconinfo of
  0 : begin
        buf1:=f_clock.clock1.Caption;
        buf2:=f_clock.label1.Caption;
      end;
  1 : begin
        buf1:=f_clock.clock2.Caption;
        buf2:=f_clock.label2.Caption;
      end;
  2 : begin
        buf1:=f_clock.clock3.Caption;
        buf2:=f_clock.label3.Caption;
      end;
  3 : begin
        buf1:=f_clock.clock4.Caption;
        buf2:=f_clock.label4.Caption;
      end;
  4 : begin
        buf1:=f_clock.clock5.Caption;
        buf2:=f_clock.label5.Caption;
      end;
  end;
  TrayMsg(copy(buf1,1,2),copy(buf1,4,2),buf2+blank+buf1);
end;

Procedure Tf_tray.GetAppDir;
var inif: TMemIniFile;
    buf: string;
    startdir: string;
{$ifdef darwin}
    i: integer;
{$endif}
{$ifdef win32}
    PIDL : PItemIDList;
    Folder : array[0..MAX_PATH] of Char;
const CSIDL_PERSONAL = $0005;
{$endif}
begin
startdir:=ExtractFilePath(ParamStr(0));
{$ifdef darwin}
appdir:=getcurrentdir;
if not DirectoryExists(slash(appdir)+slash('data')+slash('planet')) then begin
   appdir:=ExtractFilePath(ParamStr(0));
   i:=pos('.app/',appdir);
   if i>0 then begin
     appdir:=ExtractFilePath(copy(appdir,1,i));
   end;
end;
{$else}
appdir:=getcurrentdir;
{$ifdef trace_debug}
 debugln('appdir='+appdir);
{$endif}
{$endif}
privatedir:=DefaultPrivateDir;
{$ifdef unix}
appdir:=expandfilename(appdir);
privatedir:=expandfilename(PrivateDir);
configfile:=expandfilename(Defaultconfigfile);
{$endif}
{$ifdef win32}
SHGetSpecialFolderLocation(0, CSIDL_PERSONAL, PIDL);
SHGetPathFromIDList(PIDL, Folder);
privatedir:=slash(Folder)+privatedir;
configfile:=slash(privatedir)+Defaultconfigfile;
{$endif}

if fileexists(configfile) then begin
  inif:=TMeminifile.create(configfile);
  try
  buf:=inif.ReadString('main','AppDir',appdir);
  if Directoryexists(buf) then appdir:=buf;
  privatedir:=inif.ReadString('main','PrivateDir',privatedir);
  finally
   inif.Free;
  end;
end;
Tempdir:=slash(privatedir)+DefaultTmpDir;
{$ifdef trace_debug}
 debugln('appdir='+appdir);
{$endif}
// Be sur the data directory exists
if (not directoryexists(slash(appdir)+slash('data')+'constellation')) then begin
  // try under the current directory
  buf:=GetCurrentDir;
  {$ifdef trace_debug}
   debugln('Try '+buf);
  {$endif}
  if (directoryexists(slash(buf)+slash('data')+'constellation')) then
     appdir:=buf
  else begin
     // try under the program directory
     buf:=ExtractFilePath(ParamStr(0));
    {$ifdef trace_debug}
     debugln('Try '+buf);
    {$endif}
     if (directoryexists(slash(buf)+slash('data')+'constellation')) then
        appdir:=buf
     else begin
         // try share directory under current location
         buf:=ExpandFileName(slash(GetCurrentDir)+SharedDir);
          {$ifdef trace_debug}
           debugln('Try '+buf);
          {$endif}
         if (directoryexists(slash(buf)+slash('data')+'constellation')) then
            appdir:=buf
         else begin
            // try share directory at the same location as the program
            buf:=ExpandFileName(slash(ExtractFilePath(ParamStr(0)))+SharedDir);
            {$ifdef trace_debug}
             debugln('Try '+buf);
            {$endif}
            if (directoryexists(slash(buf)+slash('data')+'constellation')) then
               appdir:=buf
            else begin
               MessageDlg('Could not found the application data directory.'+crlf
                   +'Please edit the file .cartesduciel.ini'+crlf
                   +'and indicate at the line Appdir= where you install the data.',
                   mtError, [mbAbort], 0);
               Halt;
            end;
         end;
     end;
  end;
end;
{$ifdef trace_debug}
 debugln('appdir='+appdir);
 debugln('privatedir='+privatedir);
{$endif}
{$ifdef win32}
tracefile:=slash(privatedir)+'tray_'+tracefile;
{$endif}
VarObs:=slash(startdir)+DefaultVarObs;     // varobs normally at same location as skychart
if not FileExists(VarObs) then VarObs:=DefaultVarObs; // if not try in $PATH
CdC:=slash(startdir)+DefaultCdC;
if not FileExists(CdC) then CdC:=DefaultCdC;
helpdir:=slash(appdir)+slash('doc');
SampleDir:=slash(appdir)+slash('data')+'sample';
// Be sure zoneinfo exists in standard location or in skychart directory
ZoneDir:=slash(appdir)+slash('data')+slash('zoneinfo');
{$ifdef trace_debug}
 debugln('ZoneDir='+ZoneDir);
{$endif}
buf:=slash('')+slash('usr')+slash('share')+slash('zoneinfo');
{$ifdef trace_debug}
 debugln('Try '+buf);
{$endif}
if (FileExists(slash(buf)+'zone.tab')) then
     ZoneDir:=slash(buf)
else begin
  buf:=slash('')+slash('usr')+slash('lib')+slash('zoneinfo');
  {$ifdef trace_debug}
   debugln('Try '+buf);
  {$endif}
  if (FileExists(slash(buf)+'zone.tab')) then
      ZoneDir:=slash(buf)
  else begin
     if (not FileExists(slash(ZoneDir)+'zone.tab')) then begin
       MessageDlg('zoneinfo directory not found!'+crlf
         +'Please install the tzdata package.'+crlf
         +'If it is not installed at a standard location create a logical link zoneinfo in skychart data directory.',
         mtError, [mbAbort], 0);
       Halt;
     end;
  end;
end;
{$ifdef trace_debug}
 debugln('ZoneDir='+ZoneDir);
{$endif}
end;

Procedure Tf_tray.GetLanguage;
var inif: TMemIniFile;
begin
language:='';
if fileexists(configfile) then begin
  inif:=TMeminifile.create(configfile);
  try
  language:=inif.ReadString('main','language','');
  finally
   inif.Free;
  end;
end;
end;

procedure Tf_tray.ConnectDB;
var dbpath:string;
begin
try
    if ((DBtype=sqlite) and not Fileexists(db)) then begin
       cdcdb:=nil;
       exit;
    end;
    cdcdb:=Tcdcdb.create(self);
    if (cdcdb.ConnectDB(dbhost,db,dbuser,dbpass,dbport)
       and cdcdb.CheckDB) then begin
         {$ifdef trace_debug}
          WriteTrace('DB connected');
         {$endif}
    end else begin
       cdcdb.free;
       cdcdb:=nil;
    end;
except
cdcdb:=nil;
end;
end;

initialization
  {$I pu_tray.lrs}
  {$I blankicon.lrs}
end.

