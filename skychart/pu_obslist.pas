unit pu_obslist;
{
Copyright (C) 2013 Patrick Chevalley

http://www.ap-i.net
pch@ap-i.net

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
 Observing list
}

{$mode objfpc}{$H+}

interface

uses  u_translation, u_constant, u_util, u_projection, cu_planet,
  Math, Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, Grids, EditBtn, StdCtrls, Menus, ComCtrls;

type

  TSelectObject = procedure(obj:string; ra,de:double) of object;
  TGetObjectCoord = procedure(obj:string; var lbl:string; var ra,de:double) of object;

  { Tf_obslist }

  Tf_obslist = class(TForm)
    HourAngleCombo: TComboBox;
    ButtonSave: TButton;
    ButtonClear: TButton;
    Button5: TButton;
    Button6: TButton;
    AirmassCombo: TComboBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    Edit1: TEdit;
    FileNameEdit1: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MenuDelete: TMenuItem;
    MenuView: TMenuItem;
    MenuUpdcoord: TMenuItem;
    MenuTitle: TMenuItem;
    PageControl1: TPageControl;
    PanelBot: TPanel;
    PanelTop: TPanel;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure AirmassComboChange(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure CheckBox5Change(Sender: TObject);
    procedure HourAngleComboChange(Sender: TObject);
    procedure MenuDeleteClick(Sender: TObject);
    procedure FileNameEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuUpdcoordClick(Sender: TObject);
    procedure MenuViewClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure StringGrid1ColRowMoved(Sender: TObject; IsColumn: Boolean;
      sIndex, tIndex: Integer);
    procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid1Resize(Sender: TObject);
    procedure StringGrid1ValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
  private
    { private declarations }
    title,FDefaultList: string;
    Faltitude: double;
    gridchanged, limitairmass,limittransit: boolean;
    ClickCol,ClickRow: integer;
    FSelectObject: TSelectObject;
    FGetObjectCoord: TGetObjectCoord;
    FObjLabelChange: TNotifyEvent;
    FObjLabels,FEmptyObjLabels: TStringList;
    function GetRowcount : integer;
  public
    { public declarations }
    cfgsc: Tconf_skychart;
    planet : Tplanet;
    procedure SetLang;
    procedure Newlist;
    procedure Add(obj: string; ra,de:double);
    procedure LoadObsList;
    procedure SaveObsList;
    procedure SelectRow(r: integer);
    procedure FirstObj;
    procedure LastObj;
    procedure NextObj;
    procedure PrevObj;
    procedure ComputeLimits;
    procedure ComputeAirmassTime;
    procedure ComputeTransitTime;
    procedure UpdateLabels;
    procedure SetVisibleRows;
    procedure Refresh;
    property RowCount: integer read GetRowcount;
    property DefaultList: string read FDefaultList;
    property ObjLabels: TStringList read FObjLabels;
    property EmptyObjLabels: TStringList read FEmptyObjLabels;
    property onSelectObject: TSelectObject read FSelectObject write FSelectObject;
    property onGetObjectCoord: TGetObjectCoord read FGetObjectCoord write FGetObjectCoord;
    property onObjLabelChange: TNotifyEvent read FObjLabelChange write FObjLabelChange;
  end;

var
  f_obslist: Tf_obslist;

implementation

const objl=32;
      radecl=10;

{$R *.lfm}

{ Tf_obslist }

procedure Tf_obslist.SetLang;
begin
  Caption:=rsObservingLis;
  StringGrid1.Cells[0,0]:='';
  StringGrid1.Cells[1,0]:=rsObject;
  StringGrid1.Cells[2,0]:=rsRA;
  StringGrid1.Cells[3,0]:=rsDEC;
  StringGrid1.Cells[4,0]:=rsStart;
  StringGrid1.Cells[5,0]:=rsEnd;
  StringGrid1.Cells[6,0]:=rsDescription;
  StringGrid1.Cells[7,0]:=rsLabel2;
  AirmassCombo.Items[6]:=rsHorizon;
  ButtonSave.Caption:=rsSave;
  ButtonClear.Caption:=rsClear;
  TabSheet1.Caption:=rsAirmass;
  Label1.Caption:=rsLimit;
  CheckBox1.Caption:=rsOnlyObjectsW;
  CheckBox2.Caption:=rsOnlyObjectsW2;
  CheckBox3.Caption:=rsMarkObjectsO;
  TabSheet2.Caption:=rsTransit;
  Label1.Caption:=rsLimit;
  Label3.Caption:=rsLimit;
  Label4.Caption:=rsHours;
  CheckBox4.Caption:=rsOnlyObjectsW3;
  CheckBox5.Caption:=rsOnlyObjectsW4;
  MenuView.Caption:=rsViewOnChart;
  MenuUpdcoord.Caption:=rsUpdateCoordi;
  MenuDelete.Caption:=rsDelete;
end;

procedure Tf_obslist.Newlist;
var buf: string;
begin
  StringGrid1.RowCount:=1;
  Edit1.Text:=rsTitle;
  buf:=ExtractFilePath(FileNameEdit1.FileName);
  if buf<>'' then buf:=slash(buf);
  gridchanged:=false;
  FileNameEdit1.FileName:=buf+DefaultList;
  UpdateLabels;
end;

procedure Tf_obslist.Add(obj: string; ra,de:double);
var buf: string;
begin
if obj<>'' then begin
  gridchanged:=true;
  StringGrid1.RowCount:=StringGrid1.RowCount+1;
  StringGrid1.Cells[1,StringGrid1.RowCount-1]:=obj;
  StringGrid1.Cells[7,StringGrid1.RowCount-1]:=obj;
  buf:=FormatFloat(f5,ra);
  StringGrid1.Cells[2,StringGrid1.RowCount-1]:=buf;
  buf:=FormatFloat(f5,de);
  StringGrid1.Cells[3,StringGrid1.RowCount-1]:=buf;
  StringGrid1.Cells[6,StringGrid1.RowCount-1]:='';
  UpdateLabels;
end;
end;

procedure Tf_obslist.LoadObsList;
var f: textfile;
    obj,lbl,desc,buf,buf1: string;
    ra,de: double;
begin
if FileExists(FileNameEdit1.FileName) then begin
  StringGrid1.RowCount:=1;
  gridchanged:=false;
  try
  AssignFile(f,FileNameEdit1.FileName);
  reset(f);
  readln(f,title);
  while not eof(f) do begin
    StringGrid1.RowCount:=StringGrid1.RowCount+1;
    readln(f,buf);
    buf1:=copy(buf,1,objl);
    obj:=buf1;
    StringGrid1.Cells[1,StringGrid1.RowCount-1]:=buf1;
    delete(buf,1,objl);
    buf1:=trim(copy(buf,1,radecl));
    ra:=strtofloatdef(buf1,-999);
    if ra<-900 then desc:=buf else desc:='';
    delete(buf,1,radecl);
    buf1:=trim(copy(buf,1,radecl));
    de:=strtofloatdef(buf1,-999);
    delete(buf,1,radecl);
    if ((ra<-900)or(de<-900)) and assigned(FGetObjectCoord) then begin
      FGetObjectCoord(obj,lbl,ra,de);
      if ra<0 then begin
        ra:=-999;
        de:=-999;
      end;
      StringGrid1.Cells[7,StringGrid1.RowCount-1]:=lbl;
    end else begin
      buf1:=trim(copy(buf,1,objl));
      StringGrid1.Cells[7,StringGrid1.RowCount-1]:=buf1;
      delete(buf,1,objl);
    end;
    if ra>-900 then begin
      buf1:=FormatFloat(f5,ra);
      StringGrid1.Cells[2,StringGrid1.RowCount-1]:=buf1;
      buf1:=FormatFloat(f5,de);
      StringGrid1.Cells[3,StringGrid1.RowCount-1]:=buf1;
    end else begin
      StringGrid1.Cells[2,StringGrid1.RowCount-1]:='';
      StringGrid1.Cells[3,StringGrid1.RowCount-1]:='';
    end;
    StringGrid1.Cells[4,StringGrid1.RowCount-1]:='';
    StringGrid1.Cells[5,StringGrid1.RowCount-1]:='';
    if desc='' then desc:=buf;
    StringGrid1.Cells[6,StringGrid1.RowCount-1]:=desc;
  end;
  CloseFile(f);
  edit1.Text:=title;
  Refresh;
  Application.ProcessMessages;
  gridchanged:=false;
  except
    on E: Exception do begin
      if visible then ShowMessage('Error: '+E.Message);
    end;
  end;
end;
end;

procedure Tf_obslist.SaveObsList;
var f: textfile;
    buf,bl: string;
    i:integer;
begin
  try
  bl:=blank15+blank15+blank15;
  AssignFile(f,FileNameEdit1.FileName);
  Rewrite(f);
  writeln(f,edit1.Text);
  for i:=1 to StringGrid1.RowCount-1 do begin
    buf:=copy(StringGrid1.Cells[1,i]+bl,1,objl);
    buf:=buf+copy(StringGrid1.Cells[2,i]+bl,1,radecl);
    buf:=buf+copy(StringGrid1.Cells[3,i]+bl,1,radecl);
    buf:=buf+copy(StringGrid1.Cells[7,i]+bl,1,objl);
    buf:=buf+StringGrid1.Cells[6,i];
    writeln(f,buf);
  end;
  CloseFile(f);
  gridchanged:=false;
  except
    on E: Exception do begin
      if visible then ShowMessage('Error: '+E.Message);
    end;
  end;
end;

function Tf_obslist.GetRowcount : integer;
var i: integer;
begin
result:=0;
for i:=1 to StringGrid1.RowCount-1 do
   if StringGrid1.RowHeights[i]>0 then inc(result);
end;

procedure Tf_obslist.SelectRow(r: integer);
var buf: string;
    ra,de: double;
begin
StringGrid1.Row:=r;
buf:=trim(StringGrid1.Cells[1,r]);
ra:=StrToFloatDef(trim(StringGrid1.Cells[2,r]),-1);
de:=StrToFloatDef(trim(StringGrid1.Cells[3,r]),0);
if (ra>=0) and assigned(FSelectObject) then FSelectObject(buf,ra,de);
end;

procedure Tf_obslist.FirstObj;
begin
  StringGrid1.Row:=1;
  if StringGrid1.RowHeights[StringGrid1.Row]>0 then
    SelectRow(StringGrid1.Row)
  else
    NextObj;
end;

procedure Tf_obslist.LastObj;
begin
  StringGrid1.Row:=StringGrid1.RowCount-1;
  if StringGrid1.RowHeights[StringGrid1.Row]>0 then
    SelectRow(StringGrid1.Row)
  else
    PrevObj;
end;

procedure Tf_obslist.NextObj;
var ok,ko : boolean;
    i:integer;
begin
ok:=false;
ko:=false;
i:=StringGrid1.Row;
repeat
  inc(i);
  ko:=(i>=(StringGrid1.RowCount-1));
  ok:=StringGrid1.RowHeights[i]>0;
until ok or ko;
if ok then begin
  StringGrid1.Row:=i;
  SelectRow(StringGrid1.Row);
end;
end;

procedure Tf_obslist.PrevObj;
var ok,ko : boolean;
    i:integer;
begin
ok:=false;
ko:=false;
i:=StringGrid1.Row;
repeat
  dec(i);
  ko:=(i<=1);
  ok:=StringGrid1.RowHeights[i]>0;
until ok or ko;
if ok then begin
  StringGrid1.Row:=i;
  SelectRow(StringGrid1.Row);
end;
end;

procedure Tf_obslist.SetVisibleRows;
var ok: boolean;
    i: integer;
    cr1,cr2,t1,t2: double;
    astrom,nautm,civm,cive,naute,astroe: double;
begin
 if (limitairmass and CheckBox1.Checked) or (limittransit and CheckBox4.Checked) then begin
   planet.Twilight(cfgsc.jd0,cfgsc.ObsLatitude,cfgsc.ObsLongitude,astrom,nautm,civm,cive,naute,astroe);
   if abs(astrom)<90 then begin
     cr1:=rmod(astroe+cfgsc.TimeZone+24,24);
     cr2:=rmod(astrom+cfgsc.TimeZone+24,24);
   end
   else if astrom>0 then begin
     cr1:=-99;            // summer polar day, no "tonight"
     cr2:=-99;
   end
   else begin
     cr1:=0;             // winter polar night, always "tonight"
     cr2:=24;
   end;
 end;
 if (limitairmass and CheckBox2.Checked) or (limittransit and CheckBox5.Checked) then begin
   cr1:=cfgsc.CurTime;
   cr2:=cr1;
 end;
 for i:=1 to StringGrid1.RowCount-1 do begin
     if (limitairmass and (CheckBox1.Checked or CheckBox2.Checked)) or (limittransit and (CheckBox4.Checked or CheckBox5.Checked)) then begin
       if cr1<0 then
            ok:=false
       else begin
         ok:=((StringGrid1.Cells[4,i]<>rsNever) and (StringGrid1.Cells[4,i]<>'N/A'));
         if ok and (StringGrid1.Cells[4,i]<>rsAlways) then begin
           t1:=StrToTim(StringGrid1.Cells[4,i],':');
           t2:=StrToTim(StringGrid1.Cells[5,i],':');
           if cr1<=cr2 then begin
             if (t1<t2) then
               ok:=((t1>=cr1)and(t2<=cr2)) or
                   ((t1<=cr1)and(t2>=cr1)) or
                   ((t1<=cr2)and(t2>=cr2))
             else
               ok:= (t2>=cr1)or(t1<=cr2);
           end else begin
             if (t1<t2) then
                ok:=(t1<cr2)or(t2>cr1)
             else
                ok:=true;
           end;
         end;
       end;
     end
       else ok:=true;
     if ok then StringGrid1.RowHeights[i]:=StringGrid1.DefaultRowHeight
           else StringGrid1.RowHeights[i]:=0;
 end;
 UpdateLabels;
end;

procedure Tf_obslist.UpdateLabels;
var i: integer;
    lbl:string;
begin
FObjLabels.Clear;
if CheckBox3.Checked then begin
  FObjLabels.Sorted:=False;
  for i:=1 to StringGrid1.RowCount-1 do begin
     if StringGrid1.RowHeights[i]>0 then begin
       lbl:=trim(StringGrid1.Cells[7,i]);
       if lbl<>'' then FObjLabels.Add(uppercase(trim(wordspace(lbl))));
     end;
  end;
  FObjLabels.Sorted:=True;
end;
if CheckBox3.Checked and Assigned(FObjLabelChange) then FObjLabelChange(self);
end;

procedure Tf_obslist.ComputeLimits;
var i: integer;
begin
case PageControl1.ActivePageIndex of
  0: ComputeAirmassTime;
  1: ComputeTransitTime;
  else begin
    for i:=1 to StringGrid1.RowCount-1 do begin
      StringGrid1.Cells[4, i]:='';
      StringGrid1.Cells[5, i]:='';
    end;
  end;
end;
end;

procedure Tf_obslist.Refresh;
begin
ComputeLimits;
SetVisibleRows;
end;

procedure Tf_obslist.ComputeAirmassTime;
var i: integer;
    ra,de,am: double;
    t1,t2: double;
begin
limitairmass:=true;
limittransit:=false;
am:=StrToFloatDef(trim(AirmassCombo.Text),-99);
if am<0 then begin
  Faltitude:=-0.5;
  label2.Caption:=rsAltitude+': '+rsHorizon;
end else begin
  if am<1 then am:=1;
  Faltitude:=90-rad2deg*arccos(1/am);
  label2.Caption:=rsAltitude+': '+formatfloat('0',Faltitude)+rsdeg;
end;
for i:=1 to StringGrid1.RowCount-1 do begin
  ra:=StrToFloatDef(trim(StringGrid1.Cells[2,i]),-1);
  de:=StrToFloatDef(trim(StringGrid1.Cells[3,i]),0);
  if ra>=0 then begin
    ra:=deg2rad*ra;
    de:=deg2rad*de;
    Precession(jd2000,cfgsc.JDChart,ra,de);
    Time_Alt(cfgsc.jd0,ra,de,Faltitude,t1,t2,cfgsc.ObsLatitude,cfgsc.ObsLongitude);
    if abs(t1)<90 then StringGrid1.Cells[4,i]:=TimToStr(rmod(t1+cfgsc.TimeZone+24,24),':',false)
       else begin
         if t1>0 then StringGrid1.Cells[4, i]:=rsAlways
                 else StringGrid1.Cells[4, i]:=rsNever
       end;
    if abs(t2)<90 then StringGrid1.Cells[5,i]:=TimToStr(rmod(t2+cfgsc.TimeZone+24,24),':',false)
       else begin
         if t2>0 then StringGrid1.Cells[5,i]:=rsAlways
                 else StringGrid1.Cells[5,i]:=rsNever
       end;
  end else begin
    StringGrid1.Cells[4,i]:='N/A';
    StringGrid1.Cells[5,i]:='N/A';
  end;
end;
end;

procedure Tf_obslist.ComputeTransitTime;
var i,irc: integer;
    ha,ra,de: double;
    hr,ht,hs,azr,azs:double;
begin
limitairmass:=false;
limittransit:=true;
 ha:=StrToFloatDef(trim(HourAngleCombo.Text),-99);
 if ha<0 then ha:=1;
 if ha>12 then ha:=12;
 for i:=1 to StringGrid1.RowCount-1 do begin
   ra:=StrToFloatDef(trim(StringGrid1.Cells[2,i]),-1);
   de:=StrToFloatDef(trim(StringGrid1.Cells[3,i]),0);
   if ra>=0 then begin
     ra:=deg2rad*ra;
     de:=deg2rad*de;
     Precession(jd2000,cfgsc.JDChart,ra,de);
     RiseSet(1,cfgsc.jd0,ra,de,hr,ht,hs,azr,azs,irc,cfgsc);
     if irc=2 then begin
       StringGrid1.Cells[4, i]:=rsNever;
       StringGrid1.Cells[5, i]:=rsNever;
     end else begin
       StringGrid1.Cells[4,i]:=TimToStr(rmod(ht-ha+24,24),':',false);
       StringGrid1.Cells[5,i]:=TimToStr(rmod(ht+ha+24,24),':',false);
     end;
   end else begin
     StringGrid1.Cells[4,i]:='N/A';
     StringGrid1.Cells[5,i]:='N/A';
   end;
 end;
end;

procedure Tf_obslist.FormCreate(Sender: TObject);
begin
  FObjLabels:=TStringList.Create;
  FEmptyObjLabels:=TStringList.Create;
  FDefaultList:='NewObsList.txt';
  StringGrid1.AllowOutboundEvents:=true;
  StringGrid1.ColWidths[0]:=32;
  StringGrid1.ColWidths[1]:=200;
  StringGrid1.ColWidths[2]:=80;
  StringGrid1.ColWidths[3]:=80;
  StringGrid1.ColWidths[4]:=80;
  StringGrid1.ColWidths[5]:=80;
  StringGrid1.ColWidths[6]:=StringGrid1.ClientWidth-StringGrid1.ColWidths[0]-StringGrid1.ColWidths[1]-StringGrid1.ColWidths[2]-StringGrid1.ColWidths[3]-8;
  Newlist;
  gridchanged:=false;
end;

procedure Tf_obslist.FormDestroy(Sender: TObject);
begin
  if gridchanged then begin
    if MessageDlg(Format(rsTheObserving, [FileNameEdit1.FileName])+crlf+rsDoYouWantToS2,
       mtConfirmation, [mbYes, mbNo], 0) = mrYes
       then SaveObsList;
  end;
  FObjLabels.Free;
  FEmptyObjLabels.Free;
end;

procedure Tf_obslist.FormShow(Sender: TObject);
begin
  SetLang;
  Refresh;
end;

procedure Tf_obslist.MenuUpdcoordClick(Sender: TObject);
var buf,buf1,lbl: string;
    ra,de: double;
begin
  buf:=trim(StringGrid1.Cells[1,ClickRow]);
  FGetObjectCoord(buf,lbl,ra,de);
  if ra>=0 then begin
    buf1:=FormatFloat(f5,ra);
    StringGrid1.Cells[2,ClickRow]:=buf1;
    buf1:=FormatFloat(f5,de);
    StringGrid1.Cells[3,ClickRow]:=buf1;
    StringGrid1.Cells[7,ClickRow]:=lbl;
    UpdateLabels;
    gridchanged:=true;
  end;
end;

procedure Tf_obslist.MenuViewClick(Sender: TObject);
begin
SelectRow(ClickRow);
end;

procedure Tf_obslist.PageControl1Change(Sender: TObject);
begin
  Refresh;
end;

procedure Tf_obslist.MenuDeleteClick(Sender: TObject);
begin
  StringGrid1.DeleteRow(ClickRow);
  UpdateLabels;
  gridchanged:=true;
end;

procedure Tf_obslist.PopupMenu1Popup(Sender: TObject);
begin
 MenuTitle.Caption:=StringGrid1.Cells[1,ClickRow];
end;

procedure Tf_obslist.StringGrid1ColRowMoved(Sender: TObject; IsColumn: Boolean;
  sIndex, tIndex: Integer);
begin
  gridchanged:=true;
end;

procedure Tf_obslist.StringGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  StringGrid1.MouseToCell(X, Y, ClickCol,ClickRow);
end;

procedure Tf_obslist.StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var aCol,aRow: integer;
begin
  StringGrid1.MouseToCell(X, Y, aCol,aRow);
  if (ClickCol=0)and(aCol=ClickCol)and(aRow=ClickRow) then SelectRow(ClickRow);
end;

procedure Tf_obslist.StringGrid1Resize(Sender: TObject);
begin
  StringGrid1.ColWidths[6]:=StringGrid1.ClientWidth-StringGrid1.ColWidths[0]-StringGrid1.ColWidths[1]-StringGrid1.ColWidths[2]-StringGrid1.ColWidths[3]-8;
end;

procedure Tf_obslist.StringGrid1ValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
if aCol in [0,4,5,7] then NewValue:=OldValue
  else if OldValue<>NewValue then gridchanged:=true;
end;

procedure Tf_obslist.FileNameEdit1Change(Sender: TObject);
begin
  if assigned(cfgsc) then LoadObsList;
end;

procedure Tf_obslist.ButtonSaveClick(Sender: TObject);
begin
  SaveObsList;
end;

procedure Tf_obslist.AirmassComboChange(Sender: TObject);
var h:double;
    buf:string;
begin
buf:=trim(AirmassCombo.Text);
if (buf='')or(buf='.') then exit;
if buf<>rsHorizon then begin
  h:=StrToFloatDef(buf,-99);
  if h=-99 then begin
    AirmassCombo.ItemIndex:=-1;
    AirmassCombo.ItemIndex:=2;  // default 1.5
  end
  else if h>15 then begin
    AirmassCombo.ItemIndex:=-1;
    AirmassCombo.ItemIndex:=6; // horizon
  end;
end;
Refresh;
end;


procedure Tf_obslist.HourAngleComboChange(Sender: TObject);
var ha:double;
    buf:string;
begin
buf:=trim(HourAngleCombo.Text);
if (buf='')or(buf='.') then exit;
ha:=StrToFloatDef(buf,-99);
if ha<0 then begin
  HourAngleCombo.ItemIndex:=-1;
  HourAngleCombo.ItemIndex:=1;  // default 2.0
end
else if ha>12 then begin
  HourAngleCombo.Text:='12.0';
end;
Refresh;
end;

procedure Tf_obslist.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

procedure Tf_obslist.ButtonClearClick(Sender: TObject);
begin
  Newlist;
end;

procedure Tf_obslist.Button5Click(Sender: TObject);
begin
 PrevObj;
end;

procedure Tf_obslist.Button6Click(Sender: TObject);
begin
 NextObj;
end;

procedure Tf_obslist.CheckBox1Change(Sender: TObject);
begin
 if CheckBox1.Checked then CheckBox2.Checked:=false;
 SetVisibleRows;
end;

procedure Tf_obslist.CheckBox2Change(Sender: TObject);
begin
 if CheckBox2.Checked then CheckBox1.Checked:=false;
 SetVisibleRows;
end;

procedure Tf_obslist.CheckBox3Change(Sender: TObject);
begin
  UpdateLabels;
end;

procedure Tf_obslist.CheckBox4Change(Sender: TObject);
begin
 if CheckBox4.Checked then CheckBox5.Checked:=false;
 SetVisibleRows;
end;

procedure Tf_obslist.CheckBox5Change(Sender: TObject);
begin
 if CheckBox5.Checked then CheckBox4.Checked:=false;
 SetVisibleRows;
end;

end.

