unit cu_radec;
{                                        
Copyright (C) 2005 Patrick Chevalley

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}
{
 RA - DEC input.
}

{$mode objfpc}{$H+}

interface

Uses Controls, Classes, ComCtrls, SysUtils, LResources, GraphType, ExtCtrls, StdCtrls;

type 
  Tradeckind=( RA, DE, Az, Alt );

type

  TMouseUpDown=class(TUpDown)
  protected
    procedure UpDownMouseWheel(Sender: TObject; Shift: TShiftState;WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; Override;
  end;

  TRaDec = class(TCustomPanel)
  protected
    { Private declarations }
    EditDeg, EditMin, EditSec : TEdit;
    ArrowDeg, ArrowMin, ArrowSec : TMouseUpDown;
    LabelDeg, LabelMin, LabelSec : TLabel;
    Fkind : Tradeckind;
    FOnChange: TNotifyEvent;
    procedure Paint; override;
    procedure SetValue(Val: Double);
    function ReadValue: Double;
    function ReadText: String;
    procedure SetKind(Val: Tradeckind);
    procedure EditChange(Sender: TObject);
    procedure SetEnabled(value:boolean); override;
    function GetEnabled: boolean; override;
  public
    { Public declarations }
     lockchange: boolean;
     constructor Create(Aowner:Tcomponent); override;
     destructor Destroy; override;
  published
    { Published declarations }
     property kind: Tradeckind read Fkind write SetKind;
     property value : double Read ReadValue write SetValue;
     property text  : string Read ReadText;
     property Enabled: boolean Read GetEnabled Write SetEnabled;
     property OnChange: TNotifyEvent read FOnChange write FOnChange;
     property Font;
     property Hint;
     property ParentColor;
     property ParentFont;
     property ParentShowHint;
     property PopupMenu;
     property ShowHint;
     property TabOrder;
     property TabStop;
     property Visible;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('CDC', [TRaDec]);
  RegisterComponents('CDC', [TMouseUpDown]);
end;

//////////////////////////////////////////////////////////
Function sgn(x:Double):Double ;
begin
// sign function with zero positive
if x<0 then
   sgn:= -1
else
   sgn:=  1 ;
end ;

Procedure ARToStr(ar: Double; out d,m,s : string);
var dd,min1,min,sec: Double;
begin
    dd:=Int(ar);
    min1:=abs(ar-dd)*60;
    if min1>=59.999 then begin
       dd:=dd+sgn(ar);
       min1:=0.0;
    end;
    min:=Int(min1);
    sec:=(min1-min)*60;
    if sec>=59.95 then begin
       min:=min+1;
       sec:=0.0;
    end;
    str(dd:2:0,d);
    if abs(dd)<10 then d:='0'+trim(d);
    str(min:2:0,m);
    if abs(min)<10 then m:='0'+trim(m);
    str(sec:2:0,s);
    if abs(sec)<9.95 then s:='0'+trim(s);
end;

Function StrToAR(dms : string) : double;
var s,p : integer;
    t : string;
begin
try
dms:=trim(dms);
if copy(dms,1,1)='-' then s:=-1 else s:=1;
p:=pos('h',dms);
t:=stringreplace((copy(dms,1,p-1)),' ','',[rfReplaceAll]); delete(dms,1,p);
if t='' then t:='0';
result:=strtoint(t);
p:=pos('m',dms);
t:=trim(copy(dms,1,p-1)); delete(dms,1,p);
if t='' then t:='0';
result:=result+ s * strtoint(t) / 60;
p:=pos('s',dms);
t:=trim(copy(dms,1,p-1));
if t='' then t:='0';
result:=result+ s * strtoint(t) / 3600;
except
result:=0;
end;
end;

Procedure DEToStr(de: Double; out d,m,s : string);
var dd,min1,min,sec: Double;
begin
    dd:=Int(de);
    min1:=abs(de-dd)*60;
    if min1>=59.99 then begin
       dd:=dd+sgn(de);
       min1:=0.0;
    end;
    min:=Int(min1);
    sec:=(min1-min)*60;
    if sec>=59.5 then begin
       min:=min+1;
       sec:=0.0;
    end;
    str(abs(dd):2:0,d);
    if abs(dd)<10 then d:='0'+trim(d);
    if de<0 then d:='-'+d else d:='+'+d;
    str(min:2:0,m);
    if abs(min)<10 then m:='0'+trim(m);
    str(sec:2:0,s);
    if abs(sec)<9.5 then s:='0'+trim(s);
end;

Function StrToDE(dms : string) : double;
var s,p : integer;
    t : string;
begin
try
dms:=trim(dms);
if copy(dms,1,1)='-' then s:=-1 else s:=1;
p:=pos('d',dms);
t:=stringreplace((copy(dms,1,p-1)),' ','',[rfReplaceAll]); delete(dms,1,p);
if t='' then t:='0';
result:=strtoint(t);
p:=pos('m',dms);
t:=trim(copy(dms,1,p-1)); delete(dms,1,p);
if t='' then t:='0';
result:=result+ s * strtoint(t) / 60;
p:=pos('s',dms);
t:=trim(copy(dms,1,p-1));
if t='' then t:='0';
result:=result+ s * strtoint(t) / 3600;
except
result:=0;
end;
end;

Procedure AzToStr(de: Double; out d,m,s : string);
var dd,min1,min,sec: Double;
begin
    dd:=Int(de);
    min1:=abs(de-dd)*60;
    if min1>=59.99 then begin
       dd:=dd+sgn(de);
       min1:=0.0;
    end;
    min:=Int(min1);
    sec:=(min1-min)*60;
    if sec>=59.5 then begin
       min:=min+1;
       sec:=0.0;
    end;
    str(abs(dd):2:0,d);
    if abs(dd)<10 then d:='00'+trim(d)
     else if abs(dd)<100 then d:='0'+trim(d);
    if de<0 then d:='-'+d;
    str(min:2:0,m);
    if abs(min)<10 then m:='0'+trim(m);
    str(sec:2:0,s);
    if abs(sec)<9.5 then s:='0'+trim(s);
end;

Procedure AltToStr(de: Double; out d,m,s : string);
var dd,min1,min,sec: Double;
begin
    dd:=Int(de);
    min1:=abs(de-dd)*60;
    if min1>=59.99 then begin
       dd:=dd+sgn(de);
       min1:=0.0;
    end;
    min:=Int(min1);
    sec:=(min1-min)*60;
    if sec>=59.5 then begin
       min:=min+1;
       sec:=0.0;
    end;
    str(abs(dd):2:0,d);
    if abs(dd)<10 then d:='0'+trim(d);
    if de<0 then d:='-'+d else d:='+'+d;
    str(min:2:0,m);
    if abs(min)<10 then m:='0'+trim(m);
    str(sec:2:0,s);
    if abs(sec)<9.5 then s:='0'+trim(s);
end;

//////////////////////////////////////////////////////////

constructor TMouseUpDown.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 OnMouseWheel:=@UpDownMouseWheel;
end;

destructor TMouseUpDown.Destroy;
begin
  inherited destroy;
end;

procedure TMouseUpDown.UpDownMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var FCanChangePos: integer;
    FCanChangeDir: TUpDownDirection;
    bt:TUDBtnType;
    FCanChange: Boolean;
begin
FCanChangePos:=0;FCanChangeDir:=updNone; bt:=btPrev;
if sender is TUpDown then
  with sender as TUpDown do begin
    if WheelDelta<0 then
        begin
          bt:=btPrev;
          FCanChangeDir:=updDown;
          if Position - Increment >= Min then
            FCanChangePos := Position - Increment
          else
            if Wrap then
              FCanChangePos := Max + (Position - Increment - Min) + 1
          else
            FCanChangePos := Min;
        end
    else
        begin
          bt:=btNext;
          FCanChangeDir:=updUp;
          if Position + Increment <= Max then
            FCanChangePos := Position + Increment
          else
            If Wrap then
              FCanChangePos := Min + (Position + Increment - Max) - 1
          else
            FCanChangePos := Max;
        end;
    end;
    FCanChange:=true;
    if Assigned(OnChangingEx) then OnChangingEx(self,FCanChange,FCanChangePos,FCanChangeDir);
    if not FCanChange then Exit;
    Position := FCanChangePos;
    if Assigned(OnClick) then OnClick(self,bt);
end;          

//////////////////////////////////////////////////////////

constructor TRaDec.Create(Aowner:Tcomponent);
var dsize,msize, lsize: Integer;
begin
inherited create(Aowner);
lockchange:=true;
Caption:='';
BevelOuter:=bvNone;
Fkind:=RA;
dsize:=40; //Canvas.TextWidth('+000')+2;
msize:=30; //Canvas.TextWidth('00')+2;
lsize:=20; //Canvas.TextWidth('M')+2;
EditDeg := TEdit.Create(self);
EditMin := TEdit.Create(self);
EditSec := TEdit.Create(self);
LabelDeg := TLabel.Create(self);
LabelMin := TLabel.Create(self);
LabelSec := TLabel.Create(self);
ArrowDeg := TMouseUpDown.Create(self);
ArrowDeg.Max:=360;
ArrowMin := TMouseUpDown.Create(self);
ArrowSec := TMouseUpDown.Create(self);
EditDeg.Parent:=self;
EditMin.Parent:=self;
EditSec.Parent:=self;
LabelDeg.Parent:=self;
LabelMin.Parent:=self;
LabelSec.Parent:=self;
ArrowDeg.Parent:=self;
ArrowMin.Parent:=self;
ArrowSec.Parent:=self;
EditDeg.ParentFont:=true;
EditMin.ParentFont:=true;
EditSec.ParentFont:=true;
LabelDeg.ParentFont:=true;
LabelMin.ParentFont:=true;
LabelSec.ParentFont:=true;
ArrowDeg.Associate:=EditDeg;
ArrowMin.Associate:=EditMin;
ArrowSec.Associate:=EditSec;
EditDeg.Text:='0';
EditDeg.Top:=0;
EditDeg.Left:=0;
EditDeg.Width:=dsize;
ArrowDeg.Left:=EditDeg.Left+EditDeg.Width;
LabelDeg.Caption:='h';
LabelDeg.Top:=(EditDeg.Height-LabelDeg.Height) div 2;
LabelDeg.Left:=ArrowDeg.Left+ArrowDeg.Width+2;
EditMin.Text:='0';
EditMin.Top:=0;
EditMin.Left:=LabelDeg.Left+lsize;
EditMin.Width:=msize;
ArrowMin.Left:=EditMin.Left+EditMin.Width;
LabelMin.Caption:='m';
LabelMin.Top:=LabelDeg.Top;
LabelMin.Left:=ArrowMin.Left+ArrowMin.Width+2;
EditSec.Text:='0';
EditSec.Top:=0;
EditSec.Left:=LabelMin.Left+lsize;
EditSec.Width:=msize;
ArrowSec.Left:=EditSec.Left+EditSec.Width;
LabelSec.Caption:='s';
LabelSec.Top:=LabelDeg.Top;
LabelSec.Left:=ArrowSec.Left+ArrowSec.Width+2;
Height:=EditDeg.Height;
Width:=LabelSec.Left+lsize;
EditDeg.OnChange:=@EditChange;
EditMin.OnChange:=@EditChange;
EditSec.OnChange:=@EditChange;
lockchange:=false;
end;

destructor TRaDec.Destroy;
begin
lockchange:=true;
EditDeg.Free;
EditMin.Free;
EditSec.Free;
LabelDeg.Free;
LabelMin.Free;
LabelSec.Free;
inherited destroy;
end;

procedure TRaDec.SetKind(Val: Tradeckind);
begin
Fkind:=Val;
case Fkind of
 RA: LabelDeg.Caption:='h';
 DE: LabelDeg.Caption:='d';
 Az: LabelDeg.Caption:='d';
 Alt: LabelDeg.Caption:='d';
end;
Invalidate;
end;

procedure TRaDec.SetValue(Val: Double);
var d,m,s: string;
begin
case Fkind of
 RA: begin
     ARToStr(Val,d,m,s);
     end;
 DE: begin
     DEToStr(Val,d,m,s);
     end;
 Az: begin
     AzToStr(Val,d,m,s);
     end;
 Alt:begin
     AltToStr(Val,d,m,s);
     end;
 else begin d:='';m:='';s:='';end;
end;
EditDeg.Text:=d;
EditMin.Text:=m;
EditSec.Text:=s;
end;

function FixNum(txt: string; maxl:integer): string;
var i:integer;
    c:string;
begin
result:='';
for i:=1 to length(txt) do begin
  c:=copy(txt,i,1);
  if ((c>='0')and(c<='9')) or
     (c='-') or
     (c='+')
     then result:=result+c;
  if length(result)>=maxl then break;
end;
end;

function TRaDec.ReadValue: Double;
var val: string;
begin
try
result:=0;
lockchange:=true;
try
EditMin.Text:=FixNum(EditMin.Text,2);
EditSec.Text:=FixNum(EditSec.Text,2);
case Fkind of
 RA: begin
     EditDeg.Text:=FixNum(EditDeg.Text,2);
     val:=trim(EditDeg.Text)+'h'+trim(EditMin.Text)+'m'+trim(EditSec.Text)+'s';
     result:=StrToAR(val);
     end;
 DE: begin
     EditDeg.Text:=FixNum(EditDeg.Text,3);
     val:=trim(EditDeg.Text)+'d'+trim(EditMin.Text)+'m'+trim(EditSec.Text)+'s';
     result:=StrToDE(val);
     end;
 Az: begin
     EditDeg.Text:=FixNum(EditDeg.Text,4);
     val:=trim(EditDeg.Text)+'d'+trim(EditMin.Text)+'m'+trim(EditSec.Text)+'s';
     result:=StrToDE(val);
     end;
 Alt:begin
     EditDeg.Text:=FixNum(EditDeg.Text,3);
     val:=trim(EditDeg.Text)+'d'+trim(EditMin.Text)+'m'+trim(EditSec.Text)+'s';
     result:=StrToDE(val);
     end;
end;
except
beep;
end;
finally
lockchange:=false;
end;
end;

function TRaDec.ReadText: string;
begin
try
result:='';
lockchange:=true;
try
EditMin.Text:=FixNum(EditMin.Text,2);
EditSec.Text:=FixNum(EditSec.Text,2);
case Fkind of
 RA: begin
     EditDeg.Text:=FixNum(EditDeg.Text,2);
     result:=trim(EditDeg.Text)+'h'+trim(EditMin.Text)+'m'+trim(EditSec.Text)+'s';
     end;
 DE: begin
     EditDeg.Text:=FixNum(EditDeg.Text,3);
     result:=trim(EditDeg.Text)+'d'+trim(EditMin.Text)+'m'+trim(EditSec.Text)+'s';
     end;
 Az: begin
     EditDeg.Text:=FixNum(EditDeg.Text,4);
     result:=trim(EditDeg.Text)+'d'+trim(EditMin.Text)+'m'+trim(EditSec.Text)+'s';
     end;
 Alt:begin
     EditDeg.Text:=FixNum(EditDeg.Text,3);
     result:=trim(EditDeg.Text)+'d'+trim(EditMin.Text)+'m'+trim(EditSec.Text)+'s';
     end;
end;
except
beep;
end;
finally
lockchange:=false;
end;
end;

procedure TRaDec.Paint;
begin
caption:='';
inherited Paint;
end;

procedure TRaDec.EditChange(Sender: TObject);
begin
if (not lockchange) and assigned(FOnChange) then FOnChange(self);
end;

procedure TRaDec.SetEnabled(value:boolean);
begin
EditDeg.Enabled:=value;
EditMin.Enabled:=value;
EditSec.Enabled:=value;
LabelDeg.Enabled:=value;
LabelMin.Enabled:=value;
LabelSec.Enabled:=value;
end;

function TRaDec.GetEnabled: boolean;
begin
result:=EditDeg.Enabled;
end;


//////////////////////////////////////////////////////////
initialization
  {$I radec.lrs}

end.
