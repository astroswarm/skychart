unit uPSI_CheckLst;
{
This file has been generated by UnitParser v0.7, written by M. Knight
and updated by NP. v/d Spek and George Birbilis. 
Source Code from Carlo Kok has been used to implement various sections of
UnitParser. Components of ROPS are used in the construction of UnitParser,
code implementing the class wrapper is taken from Carlo Kok's conv utility

}
interface
 
uses
   SysUtils
  ,Classes
  ,uPSComponent
  ,uPSRuntime
  ,uPSCompiler
  ;
 
type 
(*----------------------------------------------------------------------------*)
  TPSImport_CheckLst = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;
 
 
{ compile-time registration functions }
procedure SIRegister_TCheckListBox(CL: TPSPascalCompiler);
procedure SIRegister_TCustomCheckListBox(CL: TPSPascalCompiler);
procedure SIRegister_CheckLst(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_CheckLst_Routines(S: TPSExec);
procedure RIRegister_TCheckListBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomCheckListBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_CheckLst(CL: TPSRuntimeClassImporter);

procedure Register;

implementation


uses
   Math
  ,LCLProc
  ,LCLType
  ,GraphType
  ,Graphics
  ,LMessages
  ,LResources
  ,Controls
  ,StdCtrls
  ,LCLIntf
  ,CheckLst
  ;
 
 
procedure Register;
begin
  RegisterComponents('Pascal Script', [TPSImport_CheckLst]);
end;

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_TCheckListBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomCheckListBox', 'TCheckListBox') do
  with CL.AddClassN(CL.FindClass('TCustomCheckListBox'),'TCheckListBox') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCustomCheckListBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomListBox', 'TCustomCheckListBox') do
  with CL.AddClassN(CL.FindClass('TCustomListBox'),'TCustomCheckListBox') do
  begin
    RegisterMethod('Procedure Toggle( AIndex : Integer)');
    RegisterMethod('Procedure CheckAll( AState : TCheckBoxState; aAllowGrayed : Boolean; aAllowDisabled : Boolean)');
    RegisterProperty('AllowGrayed', 'Boolean', iptrw);
    RegisterProperty('Checked', 'Boolean Integer', iptrw);
    RegisterProperty('Header', 'Boolean Integer', iptrw);
    RegisterProperty('ItemEnabled', 'Boolean Integer', iptrw);
    RegisterProperty('State', 'TCheckBoxState Integer', iptrw);
    RegisterProperty('Count', 'integer', iptr);
    RegisterProperty('OnClickCheck', 'TNotifyEvent', iptrw);
    RegisterProperty('OnItemClick', 'TCheckListClicked', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_CheckLst(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TCheckListClicked', 'Procedure ( Sender : TObject; Index : integ'
   +'er)');
  SIRegister_TCustomCheckListBox(CL);
  SIRegister_TCheckListBox(CL);
 CL.AddDelphiFunction('Procedure Register');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxOnItemClick_W(Self: TCustomCheckListBox; const T: TCheckListClicked);
begin Self.OnItemClick := T; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxOnItemClick_R(Self: TCustomCheckListBox; var T: TCheckListClicked);
begin T := Self.OnItemClick; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxOnClickCheck_W(Self: TCustomCheckListBox; const T: TNotifyEvent);
begin Self.OnClickCheck := T; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxOnClickCheck_R(Self: TCustomCheckListBox; var T: TNotifyEvent);
begin T := Self.OnClickCheck; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxCount_R(Self: TCustomCheckListBox; var T: integer);
begin
  T := Self.Count;
end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxState_W(Self: TCustomCheckListBox; const T: TCheckBoxState; const t1: Integer);
begin Self.State[t1] := T; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxState_R(Self: TCustomCheckListBox; var T: TCheckBoxState; const t1: Integer);
begin T := Self.State[t1]; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxItemEnabled_W(Self: TCustomCheckListBox; const T: Boolean; const t1: Integer);
begin Self.ItemEnabled[t1] := T; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxItemEnabled_R(Self: TCustomCheckListBox; var T: Boolean; const t1: Integer);
begin T := Self.ItemEnabled[t1]; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxHeader_W(Self: TCustomCheckListBox; const T: Boolean; const t1: Integer);
begin Self.Header[t1] := T; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxHeader_R(Self: TCustomCheckListBox; var T: Boolean; const t1: Integer);
begin T := Self.Header[t1]; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxChecked_W(Self: TCustomCheckListBox; const T: Boolean; const t1: Integer);
begin
  Self.Checked[t1] := T;
end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxChecked_R(Self: TCustomCheckListBox; var T: Boolean; const t1: Integer);
begin
  T := Self.Checked[t1];
end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxAllowGrayed_W(Self: TCustomCheckListBox; const T: Boolean);
begin Self.AllowGrayed := T; end;

(*----------------------------------------------------------------------------*)
procedure TCustomCheckListBoxAllowGrayed_R(Self: TCustomCheckListBox; var T: Boolean);
begin T := Self.AllowGrayed; end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CheckLst_Routines(S: TPSExec);
begin
 S.RegisterDelphiFunction(@Register, 'Register', cdRegister);
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCheckListBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCheckListBox) do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCustomCheckListBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomCheckListBox) do
  begin
    RegisterMethod(@TCustomCheckListBox.Toggle, 'Toggle');
    RegisterMethod(@TCustomCheckListBox.CheckAll, 'CheckAll');
    RegisterPropertyHelper(@TCustomCheckListBoxAllowGrayed_R,@TCustomCheckListBoxAllowGrayed_W,'AllowGrayed');
    RegisterPropertyHelper(@TCustomCheckListBoxChecked_R,@TCustomCheckListBoxChecked_W,'Checked');
    RegisterPropertyHelper(@TCustomCheckListBoxHeader_R,@TCustomCheckListBoxHeader_W,'Header');
    RegisterPropertyHelper(@TCustomCheckListBoxItemEnabled_R,@TCustomCheckListBoxItemEnabled_W,'ItemEnabled');
    RegisterPropertyHelper(@TCustomCheckListBoxState_R,@TCustomCheckListBoxState_W,'State');
    RegisterPropertyHelper(@TCustomCheckListBoxCount_R,nil,'Count');
    RegisterPropertyHelper(@TCustomCheckListBoxOnClickCheck_R,@TCustomCheckListBoxOnClickCheck_W,'OnClickCheck');
    RegisterPropertyHelper(@TCustomCheckListBoxOnItemClick_R,@TCustomCheckListBoxOnItemClick_W,'OnItemClick');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CheckLst(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCustomCheckListBox(CL);
  RIRegister_TCheckListBox(CL);
end;

 
 
{ TPSImport_CheckLst }
(*----------------------------------------------------------------------------*)
procedure TPSImport_CheckLst.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_CheckLst(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_CheckLst.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_CheckLst(ri);
  RIRegister_CheckLst_Routines(CompExec.Exec); // comment it if no routines
end;
(*----------------------------------------------------------------------------*)
 
 
end.
