{
Copyright (C) 2002 Patrick Chevalley

http://www.astrosurf.com/astropc
pch@freesurf.ch

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}
{
 Cross-platform common code for Chart form.
}

procedure Tf_chart.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure Tf_chart.FormCreate(Sender: TObject);
begin
 sc:=Tskychart.Create(self);
 // set initial value
 sc.cfgsc.racentre:=1.4;
 sc.cfgsc.decentre:=0;
 sc.cfgsc.fov:=1;
 sc.cfgsc.theta:=0;
 sc.cfgsc.projtype:='A';
 sc.cfgsc.ProjPole:=Equat;
 sc.cfgsc.FlipX:=1;
 sc.cfgsc.FlipY:=1;
 sc.plot.cnv:=Image1.canvas;
 sc.InitChart;
 sc.plot.init(Image1.width,Image1.height);
 movefactor:=4;
 zoomfactor:=2;
 lastundo:=0;
 validundo:=0;
end;

procedure Tf_chart.FormDestroy(Sender: TObject);
begin
 sc.free;
end;

procedure Tf_chart.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
CKeyDown(Key,Shift);
end;

procedure Tf_chart.Image1Click(Sender: TObject);
begin
// to restore focus to the chart that as no text control
// it is also mandatory to keep the keydown and mousewheel
// event to the main form.
{$ifdef linux}
f_main.activecontrol:=nil;
{$endif}
{$ifdef mswindows}
f_main.quicksearch.Enabled:=false;
f_main.quicksearch.Enabled:=true;
f_main.setfocus;
{$endif}
end;

procedure Tf_chart.AutoRefresh;
begin
if f_main.cfgm.locked then exit;
if (not sc.cfgsc.TrackOn)and(sc.cfgsc.Projpole=Altaz) then begin
  sc.cfgsc.TrackOn:=true;
  sc.cfgsc.TrackType:=4;
end;
Refresh;
end;

procedure Tf_chart.Refresh;
begin
try
if f_main.cfgm.locked then exit;
 screen.cursor:=crHourGlass;
 identlabel.visible:=false;
 Image1.width:=clientwidth;
 Image1.height:=clientheight;
 Image1.Picture.Bitmap.Width:=Image1.width;
 Image1.Picture.Bitmap.Height:=Image1.Height;
 sc.plot.init(Image1.width,Image1.height);
 sc.Refresh;
 inc(lastundo); inc(validundo);
 if lastundo>maxundo then lastundo:=1;
 undolist[lastundo]:=sc.cfgsc;
 curundo:=lastundo;
 Identlabel.color:=sc.plot.cfgplot.color[0];
 Identlabel.font.color:=sc.plot.cfgplot.color[11];
 Panel1.color:=sc.plot.cfgplot.color[0];
 if sc.cfgsc.FindOk then ShowIdentLabel;
finally
 screen.cursor:=crDefault;
end;
end;

procedure Tf_chart.UndoExecute(Sender: TObject);
var i,j : integer;
begin
if f_main.cfgm.locked then exit;
i:=curundo-1;
j:=lastundo+1;
if i<1 then i:=maxundo;
if j>maxundo then j:=1;
if (i<=validundo)and(i<>lastundo)and((i<lastundo)or(i>=j)) then begin
  curundo:=i;
  sc.cfgsc:=undolist[curundo];
  sc.plot.init(Image1.width,Image1.height);
  sc.Refresh;
end;
end;

procedure Tf_chart.RedoExecute(Sender: TObject);
var i,j : integer;
begin
if f_main.cfgm.locked then exit;
i:=curundo+1;
j:=lastundo+1;
if i>maxundo then i:=1;
if j>maxundo then j:=1;
if (i<=validundo)and(i<>j)and((i<=lastundo)or(i>j)) then begin
  curundo:=i;
  sc.cfgsc:=undolist[curundo];
  sc.plot.init(Image1.width,Image1.height);
  sc.Refresh;
end;
end;

procedure Tf_chart.FormResize(Sender: TObject);
begin
if f_main.cfgm.locked then exit;
RefreshTimer.Enabled:=false;
RefreshTimer.Enabled:=true;
Image1.Picture.Bitmap.Width:=Image1.width;
Image1.Picture.Bitmap.Height:=Image1.Height;
if sc<>nil then sc.plot.init(Image1.width,Image1.height);
end;

procedure Tf_chart.RefreshTimerTimer(Sender: TObject);
begin
RefreshTimer.Enabled:=false;
if f_main.cfgm.locked then exit;
{ maximize a new window now to avoid a Kylix bug
  if WindowState is set to wsMaximized at creation }
if maximize then begin
 { beware to pass here only for the first refresh to avoid to loop}
 maximize:=false;
 windowstate:=wsMaximized;
 setfocus;
end;
Image1.Picture.Bitmap.Width:=Image1.width;
Image1.Picture.Bitmap.Height:=Image1.Height;
if sc<>nil then sc.plot.init(Image1.width,Image1.height);
Refresh;
end;

procedure Tf_chart.PrintChart(Sender: TObject);
var savecolor: Starcolarray;
    savesplot,savenplot,savepplot,savebgcolor: integer;
    saveskycolor: boolean;
begin
 // save current state
 savecolor:=sc.plot.cfgplot.color;
 savesplot:=sc.plot.cfgplot.starplot;
 savenplot:=sc.plot.cfgplot.nebplot;
 savepplot:=sc.plot.cfgplot.plaplot;
 saveskycolor:=sc.plot.cfgplot.autoskycolor;
 savebgcolor:=sc.plot.cfgplot.bgColor;
try
 // force line drawing
 sc.plot.cfgplot.starplot:=0;
 sc.plot.cfgplot.nebplot:=0;
 if sc.plot.cfgplot.plaplot=2 then sc.plot.cfgplot.plaplot:=1;
 // ensure white background
 sc.plot.cfgplot.autoskycolor:=false;
 if f_main.cfgm.printcolor then begin
   sc.plot.cfgplot.color[0]:=clWhite;
   sc.plot.cfgplot.color[11]:=clBlack;
 end else begin
   sc.plot.cfgplot.color:=DfWBColor;
 end;
 sc.plot.cfgplot.bgColor:=sc.plot.cfgplot.color[0];
 // set orientation
 if f_main.cfgm.PrintLandscape then Printer.Orientation:=poLandscape
                               else Printer.Orientation:=poPortrait;
 // print
 Printer.BeginDoc;
 sc.plot.cnv:=Printer.canvas;
 sc.plot.cfgchart.onprinter:=true;
 sc.plot.init(Printer.pagewidth,Printer.pageheight);
 sc.Refresh;
 Printer.EndDoc;
finally
 // restore state
 sc.plot.cfgplot.color:=savecolor;
 sc.plot.cfgplot.starplot:=savesplot;
 sc.plot.cfgplot.nebplot:=savenplot;
 sc.plot.cfgplot.plaplot:=savepplot;
 sc.plot.cfgplot.autoskycolor:=saveskycolor;
 sc.plot.cfgplot.bgColor:=savebgcolor;
 // redraw to screen
 sc.plot.cnv:=Image1.canvas;
 sc.plot.cfgchart.onprinter:=false;
 Image1.Picture.Bitmap.Width:=Image1.width;
 Image1.Picture.Bitmap.Height:=Image1.Height;
 sc.plot.init(Image1.width,Image1.height);
 sc.Refresh;
end;
end;

procedure Tf_chart.FormShow(Sender: TObject);
begin
{ update the chart after it is show a first time (part of the wsMaximized bug bypass) }
RefreshTimer.enabled:=true;
end;

procedure Tf_chart.FormActivate(Sender: TObject);
begin
f_main.updatebtn(sc.cfgsc.flipx,sc.cfgsc.flipy);
end;

procedure Tf_chart.FlipxExecute(Sender: TObject);
begin
 sc.cfgsc.FlipX:=-sc.cfgsc.FlipX;
 f_main.updatebtn(sc.cfgsc.flipx,sc.cfgsc.flipy);
 Refresh;
end;

procedure Tf_chart.FlipyExecute(Sender: TObject);
begin
 sc.cfgsc.FlipY:=-sc.cfgsc.FlipY;
 f_main.updatebtn(sc.cfgsc.flipx,sc.cfgsc.flipy);
 Refresh;
end;

procedure Tf_chart.rot_plusExecute(Sender: TObject);
begin
 sc.cfgsc.theta:=sc.cfgsc.theta+deg2rad*15;
 Refresh;
end;

procedure Tf_chart.rot_minusExecute(Sender: TObject);
begin
 sc.cfgsc.theta:=sc.cfgsc.theta-deg2rad*15;
 Refresh;
end;

procedure Tf_chart.GridEQExecute(Sender: TObject);
begin
 sc.cfgsc.ShowEqGrid := not sc.cfgsc.ShowEqGrid;
 Refresh;
end;

procedure Tf_chart.GridAzExecute(Sender: TObject);
begin
 sc.cfgsc.ShowAzGrid := not sc.cfgsc.ShowAzGrid;
 Refresh;
end;

procedure Tf_chart.zoomplusExecute(Sender: TObject);
begin
sc.zoom(zoomfactor);
Refresh;
end;

procedure Tf_chart.zoomminusExecute(Sender: TObject);
begin
sc.zoom(1/zoomfactor);
Refresh;
end;

procedure Tf_chart.zoomplusmoveExecute(Sender: TObject);
begin
sc.zoom(zoomfactor);
sc.MovetoXY(xcursor,ycursor);
Refresh;
end;

procedure Tf_chart.zoomminusmoveExecute(Sender: TObject);
begin
sc.zoom(1/zoomfactor);
sc.MovetoXY(xcursor,ycursor);
Refresh;
end;


procedure Tf_chart.MoveWestExecute(Sender: TObject);
begin
 sc.MoveChart(0,-1,movefactor);
 Refresh;
end;

procedure Tf_chart.MoveEastExecute(Sender: TObject);
begin
 sc.MoveChart(0,1,movefactor);
 Refresh;
end;

procedure Tf_chart.MoveNorthExecute(Sender: TObject);
begin
 sc.MoveChart(1,0,movefactor);
 Refresh;
end;

procedure Tf_chart.MoveSouthExecute(Sender: TObject);
begin
 sc.MoveChart(-1,0,movefactor);
 Refresh;
end;

procedure Tf_chart.MoveNorthWestExecute(Sender: TObject);
begin
 sc.MoveChart(1,-1,movefactor);
 Refresh;
end;

procedure Tf_chart.MoveNorthEastExecute(Sender: TObject);
begin
 sc.MoveChart(1,1,movefactor);
 Refresh;
end;

procedure Tf_chart.MoveSouthWestExecute(Sender: TObject);
begin
 sc.MoveChart(-1,-1,movefactor);
 Refresh;
end;

procedure Tf_chart.MoveSouthEastExecute(Sender: TObject);
begin
 sc.MoveChart(-1,1,movefactor);
 Refresh;
end;

procedure Tf_chart.CKeyDown(var Key: Word; Shift: TShiftState);
var ok:boolean;
begin
if Shift = [ssShift] then begin
   movefactor:=8;
   zoomfactor:=1.5;
end;
if Shift = [ssCtrl] then begin
   movefactor:=2;
   zoomfactor:=3;
end;
ok:=true;
case key of
key_upright   : MoveNorthWest.execute;
key_downright : MoveSouthWest.execute;
key_downleft  : MoveSouthEast.execute;
key_upleft    : MoveNorthEast.execute;
key_left      : MoveEast.execute;
key_up        : MoveNorth.execute;
key_right     : MoveWest.execute;
key_down      : MoveSouth.execute;
key_plus      : Zoomplus.execute;
key_minus     : Zoomminus.execute;
else ok:=false;
end;
if ok then key:=0;
movefactor:=4;
zoomfactor:=2;
end;

procedure Tf_chart.PopupMenu1Popup(Sender: TObject);
begin
 xcursor:=ScreenToClient(mouse.cursorpos).x;
 ycursor:=ScreenToClient(mouse.cursorpos).y;
end;

procedure Tf_chart.CentreExecute(Sender: TObject);
begin
  sc.MovetoXY(xcursor,ycursor);
  Refresh;
end;

procedure Tf_chart.CMouseWheel(Shift: TShiftState;WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
handled:=true;
lock_TrackCursor:=true;
if wheeldelta>0 then sc.Zoom(1.25)
                else sc.Zoom(0.8);
Refresh;
end;

procedure Tf_chart.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var ra,dec,a,h:double;
    txt:string;
begin
if f_main.cfgm.locked then exit;
{show the coordinates}
sc.GetCoord(x,y,ra,dec,a,h);
case sc.cfgsc.projpole of
AltAz: begin
       txt:='Az:'+deptostr(rad2deg*a)+' '+deptostr(rad2deg*h);
       end;
Equat: begin
       ra:=rmod(ra+pi2,pi2);
       txt:='Ra:'+arptostr(rad2deg*ra/15)+' '+deptostr(rad2deg*dec);
       end;
end;
f_main.SetLpanel0(txt);
end;


Procedure Tf_chart.ShowIdentLabel;
var x,y : integer;
begin
if f_main.cfgm.locked then exit;
if sc.cfgsc.FindOK then begin
   identlabel.Visible:=false;
   identlabel.font.name:=sc.plot.cfgplot.fontname[2];
   identlabel.font.size:=sc.plot.cfgplot.LabelSize[1];
   identlabel.caption:=trim(sc.cfgsc.FindName);
   sc.GetLabPos(sc.cfgsc.FindRA,sc.cfgsc.FindDec,sc.cfgsc.FindSize/2,identlabel.Width,identlabel.Height,x,y);
   identlabel.left:=x;
   identlabel.top:=y;
   identlabel.Visible:=true;
end
else identlabel.Visible:=false;
end;

function Tf_chart.IdentXY(X, Y: Integer):boolean;
var ra,dec,a,h,dx:double;
begin
result:=false;
if f_main.cfgm.locked then exit;
sc.GetCoord(x,y,ra,dec,a,h);
ra:=rmod(ra+pi2,pi2);
dx:=2/sc.cfgsc.BxGlb; // search a 2 pixel radius
result:=sc.FindatRaDec(ra,dec,dx);
if (not result) then result:=sc.FindatRaDec(ra,dec,3*dx);  //else 6 pixel
ShowIdentLabel;
f_main.SetLpanel1(sc.cfgsc.FindDesc,caption);
end;

procedure Tf_chart.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button=mbLeft then IdentXY(x,y);
end;

procedure Tf_chart.identlabelClick(Sender: TObject);
{$ifdef mswindows}
var st : TMemoryStream;
    ss : string;
{$endif}
begin
{$ifdef linux}
 f_detail.memo.text:=FormatDesc;
{$endif}
{$ifdef mswindows}
 // cannot write rich text directly to the Text property
 ss:=FormatDesc;
 st:=TMemoryStream.create;
 try
 st.write(ss[1],length(ss));
 st.Position := 0;
 f_detail.memo.lines.loadfromstream(st);
 finally
 st.free;
 end;
{$endif}
formpos(f_detail,mouse.cursorpos.x,mouse.cursorpos.y);
f_detail.show;
f_detail.setfocus;
end;

function Tf_chart.FormatDesc:string;
var desc,buf,objtype: string;
    i,n,p : integer;
    ra,dec,a,h :double;
function Bold(s:string):string;
var k:integer;
begin
  k:=pos(':',s);
  if k>0 then begin
     insert(htms_b,s,k+1);
     result:=html_b+s;
  end
  else result:=s;
end;
begin
desc:=sc.cfgsc.FindDesc;
result:=html_h;
p:=length(ldeg)+length(lmin)+length(lsec);
buf:=trim(copy(desc,25+p,3));
objtype:=trim(buf);
buf:=LongLabelObj(buf);
result:=result+html_h2+buf+htms_h2;
buf:=trim(copy(desc,28+p,999));
i:=pos(':',buf);
while i>0 do begin
  n:=1;
  repeat
    inc(n);
    i:=i-1;
    if buf[i]=' ' then break;
  until i=1;
  if i>1 then begin
    if copy(buf,1,5)='desc:' then buf:=stringreplace(buf,';',html_br,[rfReplaceAll]);
    result:=result+bold(LongLabel(copy(buf,1,i)))+html_br;
    delete(buf,1,i);
  end;
  i:=pos(':',copy(buf,n,999));
  if i>0 then i:=i+n;
end;
i:=pos(';',buf);
if i=0 then result:=result+bold(LongLabel(buf))+html_br
else begin
   result:=result+bold(LongLabel(copy(buf,1,i-1)))+html_br;
   result:=result+LongLabel(copy(buf,i+1,999))+html_br;
end;
result:=result+html_br+html_ffx;
result:=result+html_b+sc.cfgsc.EquinoxName+html_sp+'RA: '+htms_b+arptostr(rad2deg*sc.cfgsc.FindRA/15)+'   DE:'+deptostr(rad2deg*sc.cfgsc.FindDec)+html_br;
if (sc.cfgsc.EquinoxName<>'J2000') then begin
   ra:=sc.cfgsc.FindRA;
   dec:=sc.cfgsc.FindDec;
   precession(sc.cfgsc.JDChart,jd2000,ra,dec);
   result:=result+html_b+'J2000'+' RA: '+htms_b+arptostr(rad2deg*ra/15)+'   DE:'+deptostr(rad2deg*dec)+html_br;
end;
if (sc.cfgsc.EquinoxName<>'Date ') then begin
   ra:=sc.cfgsc.FindRA;
   dec:=sc.cfgsc.FindDec;
   precession(sc.cfgsc.JDChart,sc.cfgsc.CurJD,ra,dec);
   result:=result+html_b+'Date '+html_sp+'RA: '+htms_b+arptostr(rad2deg*ra/15)+'   DE:'+deptostr(rad2deg*dec)+html_br;
end;
if (sc.cfgsc.EquinoxName='Date ')and(sc.catalog.cfgshr.EquinoxChart<>'J2000')and(sc.cfgsc.EquinoxName<>sc.catalog.cfgshr.EquinoxChart) then begin
   ra:=sc.cfgsc.FindRA;
   dec:=sc.cfgsc.FindDec;
   precession(sc.cfgsc.JDChart,sc.catalog.cfgshr.DefaultJDchart,ra,dec);
   result:=result+html_b+sc.catalog.cfgshr.EquinoxChart+' RA: '+htms_b+arptostr(rad2deg*ra/15)+'   DE:'+deptostr(rad2deg*dec)+html_br;
end;
result:=result+htms_f+html_br;
result:=result+sc.cfgsc.ObsName+' '+YearADBC(sc.cfgsc.CurYear)+'-'+inttostr(sc.cfgsc.curmonth)+'-'+inttostr(sc.cfgsc.curday)+' '+ArToStr3(sc.cfgsc.Curtime)+'  ( TU + '+ArmtoStr(sc.cfgsc.TimeZone)+' )'+html_br;
result:=result+html_ffx;
ra:=sc.cfgsc.FindRA;
dec:=sc.cfgsc.FindDec;
precession(sc.cfgsc.JDChart,sc.cfgsc.CurJD,ra,dec);
Eq2Hz(sc.cfgsc.CurSt-ra,dec,a,h,sc.cfgsc) ;
if sc.catalog.cfgshr.AzNorth then a:=Rmod(a+pi,pi2);
result:=result+html_b+copy(sc.catalog.cfgshr.llabel[99]+blank15,1,17)+':'+htms_b+armtostr(rmod(rad2deg*sc.cfgsc.CurSt/15+24,24))+html_br;
result:=result+html_b+copy(sc.catalog.cfgshr.llabel[100]+blank15,1,17)+':'+htms_b+armtostr(rmod(rad2deg*(sc.cfgsc.CurSt-ra)/15+24,24))+html_br;
result:=result+html_b+copy(sc.catalog.cfgshr.llabel[91]+blank15,1,17)+':'+htms_b+demtostr(rad2deg*a)+html_br;
result:=result+html_b+copy(sc.catalog.cfgshr.llabel[92]+blank15,1,17)+':'+htms_b+demtostr(rad2deg*h)+html_br;
result:=result+html_br;
// here the rise/set time 
if pos('PA:',f_main.LPanels0.caption)>0
   then result:=result+html_b+sc.catalog.cfgshr.llabel[98]+' : '+htms_b+f_main.LPanels0.caption+html_br;
buf:=sc.cfgsc.FindNote;
i:=pos(':',buf);
while i>0 do begin
  n:=1;
  repeat
    inc(n);
    i:=i-1;
    if buf[i]=' ' then break;
  until i=0;
  if i>0 then begin
    result:=result+bold(copy(buf,1,i))+html_br;
    buf:=copy(buf,i+1,9999);
  end
  else break;
  i:=pos(':',copy(buf,n,9999));
  if i>0 then i:=i+n;
end;
result:=result+htms_f+html_br+htms_h;
end;

function Tf_chart.LongLabelObj(txt:string):string;
begin
if txt='OC' then txt:=sc.catalog.cfgshr.llabel[45]
else if txt='Gb' then txt:=sc.catalog.cfgshr.llabel[46]
else if txt='Gx' then txt:=sc.catalog.cfgshr.llabel[47]
else if txt='Nb' then txt:=sc.catalog.cfgshr.llabel[48]
else if txt='Pl' then txt:=sc.catalog.cfgshr.llabel[49]
else if txt='C+N' then txt:=sc.catalog.cfgshr.llabel[50]
else if txt='*' then txt:=sc.catalog.cfgshr.llabel[51]
else if txt='**' then txt:=sc.catalog.cfgshr.llabel[52]
else if txt='***' then txt:=sc.catalog.cfgshr.llabel[53]
else if txt='D*' then txt:=sc.catalog.cfgshr.llabel[54]
else if txt='V*' then txt:=sc.catalog.cfgshr.llabel[55]
else if txt='Ast' then txt:=sc.catalog.cfgshr.llabel[56]
else if txt='Kt' then txt:=sc.catalog.cfgshr.llabel[57]
else if txt='?' then txt:=sc.catalog.cfgshr.llabel[58]
else if txt='' then txt:=sc.catalog.cfgshr.llabel[59]
else if txt='-' then txt:=sc.catalog.cfgshr.llabel[60]
else if txt='PD' then txt:=sc.catalog.cfgshr.llabel[61]
else if txt='P' then txt:=sc.catalog.cfgshr.llabel[62]
else if txt='As' then txt:=sc.catalog.cfgshr.llabel[63]
else if txt='Cm' then txt:=sc.catalog.cfgshr.llabel[64]
else if txt='C1' then txt:=sc.catalog.cfgshr.llabel[65]
else if txt='C2' then txt:=sc.catalog.cfgshr.llabel[66];
result:=txt;
end;

function Tf_chart.LongLabel(txt:string):string;
var key,value : string;
    i : integer;
const d=': ';
begin
i:=pos(':',txt);
if i>0 then begin
  key:=uppercase(trim(copy(txt,1,i-1)));
  value:=copy(txt,i+1,9999);
  if key='MB' then result:=sc.catalog.cfgshr.llabel[1]+d+value
  else if key='MV' then result:=sc.catalog.cfgshr.llabel[2]+d+value
  else if key='MR' then result:=sc.catalog.cfgshr.llabel[3]+d+value
  else if key='M' then result:=sc.catalog.cfgshr.llabel[4]+d+value
  else if key='BT' then result:=sc.catalog.cfgshr.llabel[5]+d+value
  else if key='VT' then result:=sc.catalog.cfgshr.llabel[6]+d+value
  else if key='B-V' then result:=sc.catalog.cfgshr.llabel[7]+d+value
  else if key='SP' then result:=sc.catalog.cfgshr.llabel[8]+d+value
  else if key='PM' then result:=sc.catalog.cfgshr.llabel[9]+d+value
  else if key='CLASS' then result:=sc.catalog.cfgshr.llabel[10]+d+value
  else if key='N' then result:=sc.catalog.cfgshr.llabel[11]+d+value
  else if key='T' then result:=sc.catalog.cfgshr.llabel[12]+d+value
  else if key='P' then result:=sc.catalog.cfgshr.llabel[13]+d+value
  else if key='BAND' then result:=sc.catalog.cfgshr.llabel[14]+d+value
  else if key='PLATE' then result:=sc.catalog.cfgshr.llabel[15]+d+value
  else if key='MULT' then result:=sc.catalog.cfgshr.llabel[16]+d+value
  else if key='FIELD' then result:=sc.catalog.cfgshr.llabel[17]+d+value
  else if key='Q' then result:=sc.catalog.cfgshr.llabel[18]+d+value
  else if key='S' then result:=sc.catalog.cfgshr.llabel[19]+d+value
  else if key='DIM' then result:=sc.catalog.cfgshr.llabel[20]+d+value
  else if key='CONST' then result:=sc.catalog.cfgshr.llabel[21]+d+longlabelconst(value)
  else if key='SBR' then result:=sc.catalog.cfgshr.llabel[22]+d+value
  else if key='DESC' then result:=sc.catalog.cfgshr.llabel[23]+d+value
  else if key='RV' then result:=sc.catalog.cfgshr.llabel[24]+d+value
  else if key='SURFACE' then result:=sc.catalog.cfgshr.llabel[25]+d+value
  else if key='COLOR' then result:=sc.catalog.cfgshr.llabel[26]+d+value
  else if key='BRIGHT' then result:=sc.catalog.cfgshr.llabel[27]+d+value
  else if key='TR' then result:=sc.catalog.cfgshr.llabel[28]+d+value
  else if key='DIST' then result:=sc.catalog.cfgshr.llabel[29]+d+value
  else if key='M*' then result:=sc.catalog.cfgshr.llabel[30]+d+value
  else if key='N*' then result:=sc.catalog.cfgshr.llabel[31]+d+value
  else if key='AGE' then result:=sc.catalog.cfgshr.llabel[32]+d+value
  else if key='RT' then result:=sc.catalog.cfgshr.llabel[33]+d+value
  else if key='RH' then result:=sc.catalog.cfgshr.llabel[34]+d+value
  else if key='RC' then result:=sc.catalog.cfgshr.llabel[35]+d+value
  else if key='MHB' then result:=sc.catalog.cfgshr.llabel[36]+d+value
  else if key='C*B' then result:=sc.catalog.cfgshr.llabel[37]+d+value
  else if key='C*V' then result:=sc.catalog.cfgshr.llabel[38]+d+value
  else if key='DIAM' then result:=sc.catalog.cfgshr.llabel[39]+d+value
  else if key='ILLUM' then result:=sc.catalog.cfgshr.llabel[40]+d+value
  else if key='PHASE' then result:=sc.catalog.cfgshr.llabel[41]+d+value
  else if key='QL' then result:=sc.catalog.cfgshr.llabel[42]+d+value
  else if key='EL' then result:=sc.catalog.cfgshr.llabel[43]+d+value
  else if key='RSOL' then result:=sc.catalog.cfgshr.llabel[44]+d+value
  else if key='D1' then result:=sc.catalog.cfgshr.llabel[23]+' 1'+d+value
  else if key='D2' then result:=sc.catalog.cfgshr.llabel[23]+' 2'+d+value
  else if key='D3' then result:=sc.catalog.cfgshr.llabel[23]+' 3'+d+value
  else if key='FL' then result:=sc.catalog.cfgshr.llabel[67]+d+value
  else if key='BA' then result:=sc.catalog.cfgshr.llabel[68]+d+LongLabelGreek(value)
  else if key='PX' then result:=sc.catalog.cfgshr.llabel[69]+d+value
  else if key='PA' then result:=sc.catalog.cfgshr.llabel[70]+d+value
  else if key='PMRA' then result:=sc.catalog.cfgshr.llabel[71]+d+value
  else if key='PMDE' then result:=sc.catalog.cfgshr.llabel[72]+d+value
  else if key='MMAX' then result:=sc.catalog.cfgshr.llabel[73]+d+value
  else if key='MMIN' then result:=sc.catalog.cfgshr.llabel[74]+d+value
  else if key='MEPOCH' then result:=sc.catalog.cfgshr.llabel[75]+d+value
  else if key='RISE' then result:=sc.catalog.cfgshr.llabel[76]+d+value
  else if key='M1' then result:=sc.catalog.cfgshr.llabel[77]+d+value
  else if key='M2' then result:=sc.catalog.cfgshr.llabel[78]+d+value
  else if key='SEP' then result:=sc.catalog.cfgshr.llabel[79]+d+value
  else if key='DATE' then result:=sc.catalog.cfgshr.llabel[80]+d+value
  else if sc.catalog.cfgshr.llabel[85]='?' then result:=txt
  else if key='POLEINCL' then result:=sc.catalog.cfgshr.llabel[85]+d+value
  else if key='SUNINCL' then result:=sc.catalog.cfgshr.llabel[86]+d+value
  else if key='CM' then result:=sc.catalog.cfgshr.llabel[87]+d+value
  else if key='CMI' then result:=sc.catalog.cfgshr.llabel[87]+' I'+d+value
  else if key='CMII' then result:=sc.catalog.cfgshr.llabel[87]+' II'+d+value
  else if key='CMIII' then result:=sc.catalog.cfgshr.llabel[87]+' III'+d+value
  else if key='GRSTR' then result:=sc.catalog.cfgshr.llabel[88]+d+value
  else if key='LLAT' then result:=sc.catalog.cfgshr.llabel[89]+d+value
  else if key='LLON' then result:=sc.catalog.cfgshr.llabel[90]+d+value
  else result:=txt;
end
else result:=txt;
end;

Function Tf_chart.LongLabelConst(txt : string) : string;
var i : integer;
begin
txt:=uppercase(trim(txt));
for i:=1 to ConstelNum do begin
  if txt=UpperCase(sc.catalog.cfgshr.ConstelName[i,2]) then begin
     txt:=sc.catalog.cfgshr.ConstelName[i,1];
     break;
   end;
end;
result:=txt;
end;

Function Tf_chart.LongLabelGreek(txt : string) : string;
var i : integer;
begin
txt:=uppercase(trim(txt));
for i:=1 to 24 do begin
  if txt=UpperCase(trim(greek[2,i])) then begin
     txt:=greek[1,i];
     break;
   end;
end;
result:=txt;
end;

procedure Tf_chart.switchstarExecute(Sender: TObject);
begin
sc.plot.cfgplot.starplot:=abs(sc.plot.cfgplot.starplot-1);
sc.plot.cfgplot.nebplot:=abs(sc.plot.cfgplot.nebplot-1);
Refresh;
end;

procedure Tf_chart.switchbackgroundExecute(Sender: TObject);

begin
sc.plot.cfgplot.autoskycolor:=not sc.plot.cfgplot.autoskycolor;
Refresh;
end;


function Tf_Chart.cmd_SetCursorPosition(x,y:integer) :string;

begin

if (x>=0)and(x<=image1.width)and(y>=0)and(y<=image1.height) then begin

  xcursor:=x;

  xcursor:=y;

  result:='OK';

end else result:='Bad position.';

end;


function Tf_Chart.cmd_SetGridEQ(onoff:string):string;

begin

 sc.cfgsc.ShowEqGrid := (uppercase(onoff)='ON');

 Refresh;

 result:='OK';

end;

function Tf_Chart.cmd_SetGridAZ(onoff:string):string;
begin

 sc.cfgsc.ShowAzGrid := (uppercase(onoff)='ON');

 Refresh;

 result:='OK';

end;


function Tf_chart.cmd_SetStarMode(i:integer):string;

begin
if (i>=0)and(i<=1) then begin
  sc.plot.cfgplot.starplot:=i;
  result:='';
  Refresh;
  result:='OK';
end else result:='Bad star mode.';
end;

function Tf_chart.cmd_SetNebMode(i:integer):string;
begin
if (i>=0)and(i<=1) then begin
  sc.plot.cfgplot.nebplot:=i;
  result:='';
  Refresh;
  result:='OK';
end else result:='Bad nebula mode.';
end;

function Tf_chart.cmd_SetSkyMode(onoff:string):string;
begin
sc.plot.cfgplot.autoskycolor:=(uppercase(onoff)='ON');
Refresh;
result:='OK';
end;

function Tf_chart.cmd_SetProjection(proj:string):string;
begin
result:='OK';
proj:=uppercase(proj);
if proj='ALTAZ' then sc.cfgsc.projpole:=altaz
  else if proj='EQUAT' then sc.cfgsc.projpole:=equat
  else result:='Bad projection name.';
sc.cfgsc.FindOk:=false;
Refresh;
end;

function Tf_chart.cmd_SetFov(fov:string):string;
var f : double;
    p : integer;
begin
result:='Bad format!';
try
fov:=trim(fov);
p:=pos('d',fov);
f:=strtofloat(copy(fov,1,p-1));
fov:=copy(fov,p+1,999);
p:=pos('m',fov);
f:=f+strtofloat(copy(fov,1,p-1))/60;
fov:=copy(fov,p+1,999);
p:=pos('s',fov);
f:=f+strtofloat(copy(fov,1,p-1))/3600;
sc.setfov(deg2rad*f);
Refresh;
result:='OK';
except
exit;
end;
end;

function Tf_chart.cmd_SetRaDec(param:string):string;
var buf : string;
    p : integer;
    s,ar,de : double;
begin
result:='Bad coordinates format!';
try
p:=pos('RA:',param);
if p=0 then exit;
buf:=copy(param,p+3,999);
p:=pos('h',buf);
ar:=strtofloat(copy(buf,1,p-1));
buf:=copy(buf,p+1,999);
p:=pos('m',buf);
ar:=ar+strtofloat(copy(buf,1,p-1))/60;
buf:=copy(buf,p+1,999);
p:=pos('s',buf);
ar:=ar+strtofloat(copy(buf,1,p-1))/3600;
p:=pos('DEC:',param);
if p=0 then exit;
buf:=copy(param,p+4,999);
p:=pos('d',buf);
de:=strtofloat(copy(buf,1,p-1));
s:=sgn(de);
buf:=copy(buf,p+1,999);
p:=pos('m',buf);
de:=de+s*strtofloat(copy(buf,1,p-1))/60;
buf:=copy(buf,p+1,999);
p:=pos('s',buf);
de:=de+s*strtofloat(copy(buf,1,p-1))/3600;
sc.MovetoRaDec(deg2rad*ar*15,deg2rad*de);
Refresh;
result:='OK';
except
exit;
end;
end;

function Tf_chart.cmd_SetDate(dt:string):string;
var p,y,m,d,h,n,s : integer;
begin
result:='Bad date format!';
try
dt:=trim(dt);
p:=pos('-',dt);
if p=0 then exit;
y:=strtoint(trim(copy(dt,1,p-1)));
dt:=copy(dt,p+1,999);
p:=pos('-',dt);
if p=0 then exit;
m:=strtoint(trim(copy(dt,1,p-1)));
dt:=copy(dt,p+1,999);
p:=pos('T',dt);
if p=0 then exit;
d:=strtoint(trim(copy(dt,1,p-1)));
dt:=copy(dt,p+1,999);
p:=pos(':',dt);
if p=0 then exit;
h:=strtoint(trim(copy(dt,1,p-1)));
dt:=copy(dt,p+1,999);
p:=pos(':',dt);
if p=0 then exit;
n:=strtoint(trim(copy(dt,1,p-1)));
dt:=copy(dt,p+1,999);
s:=strtoint(trim(dt));
sc.cfgsc.UseSystemTime:=false;
sc.cfgsc.CurYear:=y;
sc.cfgsc.CurMonth:=m;
sc.cfgsc.CurDay:=d;
sc.cfgsc.CurTime:=h+n/60+s/3600;
Refresh;
result:='OK';
except
exit;
end;
end;

function Tf_chart.cmd_SetObs(obs:string):string;
var n,buf : string;
    p : integer;
    s,la,lo,al : double;
begin
result:='Bad observatory format!';
try
p:=pos('LAT:',obs);
if p=0 then exit;
buf:=copy(obs,p+4,999);
p:=pos('d',buf);
la:=strtofloat(copy(buf,1,p-1));
s:=sgn(la);
buf:=copy(buf,p+1,999);
p:=pos('m',buf);
la:=la+s*strtofloat(copy(buf,1,p-1))/60;
buf:=copy(buf,p+1,999);
p:=pos('s',buf);
la:=la+s*strtofloat(copy(buf,1,p-1))/3600;
p:=pos('LON:',obs);
if p=0 then exit;
buf:=copy(obs,p+4,999);
p:=pos('d',buf);
lo:=strtofloat(copy(buf,1,p-1));
s:=sgn(lo);
buf:=copy(buf,p+1,999);
p:=pos('m',buf);
lo:=lo+s*strtofloat(copy(buf,1,p-1))/60;
buf:=copy(buf,p+1,999);
p:=pos('s',buf);
lo:=lo+s*strtofloat(copy(buf,1,p-1))/3600;
p:=pos('ALT:',obs);
if p=0 then exit;
buf:=copy(obs,p+4,999);
p:=pos('m',buf);
al:=strtofloat(copy(buf,1,p-1));
p:=pos('TZ:',obs);
if p>0 then begin
  buf:=copy(obs,p+3,999);
  p:=pos('h',buf);
  sc.cfgsc.ObsTZ:=strtofloat(copy(buf,1,p-1));
end;
p:=pos('OBS:',obs);
if p=0 then n:='obs?'
       else n:=trim(copy(obs,p+4,999));
sc.cfgsc.ObsLatitude := la;
sc.cfgsc.ObsLongitude := lo;
sc.cfgsc.ObsAltitude := al;
sc.cfgsc.ObsName := n;
Refresh;
result:='OK';
except
exit;
end;
end;

function Tf_chart.cmd_IdentCursor:string;
begin
if identxy(xcursor,ycursor) then result:='OK'
   else result:='No object found!';
end;

function Tf_chart.cmd_SaveImage(format,fn,quality:string):string;
var i : integer;
begin
i:=strtointdef(quality,75);
if SaveChartImage(format,fn,i) then result:='OK'
   else result:='Failed!';
end;

function Tf_chart.ExecuteCmd(arg:Tstringlist):string;
var i,n : integer;
    cmd : string;
begin
cmd:=trim(uppercase(arg[0]));
n:=-1;
for i:=1 to numcmd do
   if cmd=cmdlist[i,1] then begin
      n:=strtointdef(cmdlist[i,2],-1);
      break;
   end;
result:='OK';
case n of
 1 : zoomplusExecute(self);
 2 : zoomminusExecute(self);
 3 : MoveEastExecute(self);
 4 : MoveWestExecute(self);
 5 : MoveNorthExecute(self);
 6 : MoveSouthExecute(self);
 7 : MoveNorthEastExecute(self);
 8 : MoveNorthWestExecute(self);
 9 : MoveSouthEastExecute(self);
 10 : MoveSouthWestExecute(self);
 11 : FlipxExecute(self);
 12 : FlipyExecute(self);
 13 : result:=cmd_SetCursorPosition(strtointdef(arg[1],-1),strtointdef(arg[2],-1));
 14 : CentreExecute(self);
 15 : zoomplusmoveExecute(self);
 16 : zoomminusmoveExecute(self);
 17 : rot_plusExecute(self);
 18 : rot_minusExecute(self);
 19 : result:=cmd_SetGridEQ(arg[1]);
 20 : result:=cmd_SetGridAZ(arg[1]);
 21 : result:=cmd_SetStarMode(strtointdef(arg[1],-1));
 22 : result:=cmd_SetNebMode(strtointdef(arg[1],-1));
 23 : result:=cmd_SetSkyMode(arg[1]);
 24 : UndoExecute(self);
 25 : RedoExecute(self);
 26 : result:=cmd_SetProjection(arg[1]);
 27 : result:=cmd_SetFov(arg[1]);
 28 : result:=cmd_SetRaDec(arg[1]);
 29 : result:=cmd_SetDate(arg[1]);
 30 : result:=cmd_SetObs(arg[1]);
 31 : result:=cmd_IdentCursor;
 32 : result:=cmd_SaveImage(arg[1],arg[2],arg[3]);
else result:='Bad command name';
end;

end;

