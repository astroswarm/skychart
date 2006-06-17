unit pu_print;
{
Copyright (C) 2006 Patrick Chevalley

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

{$mode objfpc}{$H+}

interface

uses  u_constant, u_util,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls, enhedits;

type

  { Tf_print }

  Tf_print = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LongEdit1: TLongEdit;
    LongEdit2: TLongEdit;
    LongEdit3: TLongEdit;
    LongEdit4: TLongEdit;
    PrinterInfo: TLabel;
    Setup: TButton;
    Print: TButton;
    Cancel: TButton;
    prtcolor: TRadioGroup;
    prtorient: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LongEdit1Change(Sender: TObject);
    procedure LongEdit2Change(Sender: TObject);
    procedure LongEdit3Change(Sender: TObject);
    procedure LongEdit4Change(Sender: TObject);
    procedure prtcolorClick(Sender: TObject);
    procedure prtorientClick(Sender: TObject);
    procedure SetupClick(Sender: TObject);
  private
    { private declarations }
    Procedure ShowPrtInfo;
  public
    { public declarations }
    cm: conf_main;
  end; 

var
  f_print: Tf_print;

implementation

uses pu_printsetup;

procedure Tf_print.FormShow(Sender: TObject);
begin
prtcolor.ItemIndex:=cm.PrintColor;
if cm.PrintLandscape then prtorient.ItemIndex:=1
                     else prtorient.ItemIndex:=0;
LongEdit1.Value:=cm.PrtLeftMargin;
LongEdit2.Value:=cm.PrtRightMargin;
LongEdit3.Value:=cm.PrtTopMargin;
LongEdit4.Value:=cm.PrtBottomMargin;
ShowPrtInfo;
end;

procedure Tf_print.Button1Click(Sender: TObject);
begin
LongEdit1.Value:=0;
LongEdit2.Value:=0;
LongEdit3.Value:=0;
LongEdit4.Value:=0;
end;

procedure Tf_print.Button2Click(Sender: TObject);
begin
LongEdit1.Value:=15;
LongEdit2.Value:=15;
LongEdit3.Value:=10;
LongEdit4.Value:=5;
end;

procedure Tf_print.LongEdit1Change(Sender: TObject);
begin
cm.PrtLeftMargin:=LongEdit1.Value;
end;

procedure Tf_print.LongEdit2Change(Sender: TObject);
begin
cm.PrtRightMargin:=LongEdit2.Value;
end;

procedure Tf_print.LongEdit3Change(Sender: TObject);
begin
cm.PrtTopMargin:=LongEdit3.Value;
end;

procedure Tf_print.LongEdit4Change(Sender: TObject);
begin
cm.PrtBottomMargin:=LongEdit4.Value;
end;

procedure Tf_print.ShowPrtInfo;
var i: integer;
begin
case cm.PrintMethod of
0 : begin
    GetPrinterResolution(cm.prtname,i);
    PrinterInfo.Caption:='Printer: '+cm.prtname+' @ '+inttostr(i)+' DPI';
    end;
1 : begin
    PrinterInfo.Caption:='Postscript @ '+inttostr(cm.PrinterResolution)+' DPI';
    end;
2 : begin
    PrinterInfo.Caption:='Bitmap  @ '+inttostr(cm.PrinterResolution)+' DPI';
    end;
end;
end;

procedure Tf_print.prtcolorClick(Sender: TObject);
begin
if (cm.PrintMethod=0)and(prtcolor.ItemIndex=2) then prtcolor.ItemIndex:=0;
cm.PrintColor:=prtcolor.ItemIndex;
end;

procedure Tf_print.prtorientClick(Sender: TObject);
begin
cm.PrintLandscape:=(prtorient.ItemIndex=1);
end;

procedure Tf_print.SetupClick(Sender: TObject);
begin
f_printsetup.cm:=cm;
formpos(f_printsetup,mouse.cursorpos.x,mouse.cursorpos.y);
if f_printsetup.showmodal=mrOK then begin
 cm:=f_printsetup.cm;
 ShowPrtInfo;
end;
end;

initialization
  {$I pu_print.lrs}

end.

