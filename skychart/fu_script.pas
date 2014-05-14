unit fu_script;

{$mode objfpc}{$H+}

interface

uses  u_translation, u_constant, pu_edittoolbar, pu_scripteditor, u_util,
  ActnList, Menus, Classes, SysUtils,
  FileUtil, Forms, Controls, ExtCtrls, StdCtrls, ComCtrls, Buttons;

type

  { Tf_script }

  Tf_script = class(TFrame)
    ButtonEditTB: TBitBtn;
    ButtonEditSrc: TBitBtn;
    BottomPanel: TPanel;
    Label1: TLabel;
    MainPanel: TPanel;
    PanelTitle: TPanel;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    procedure ButtonEditTBClick(Sender: TObject);
    procedure ButtonEditSrcClick(Sender: TObject);
  private
    { private declarations }
    fedittoolbar: Tf_edittoolbar;
    fscripteditor: Tf_scripteditor;
    FImageNormal: TImageList;
    FContainerPanel: TPanel;
    FToolButtonMouseUp,FToolButtonMouseDown: TMouseEvent;
    FActionListFile,FActionListEdit,FActionListSetup,
    FActionListView,FActionListChart,FActionListTelescope,FActionListWindow: TActionList;
    FMagPanel: TPanel;
    Fquicksearch: TComboBox;
    FTimeValPanel: Tpanel;
    FTimeU: TComboBox;
    FToolBarFOV: Tpanel;
    FMainmenu: TMenu;
    FExecuteCmd: TExecuteCmd;
    FConfigToolbar1,FConfigToolbar2,FConfigScriptButton,FConfigScript: TStringList;
    procedure ApplyScript(Sender: TObject);
    procedure SetExecuteCmd(value:TExecuteCmd);
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure Init;
    property ImageNormal: TImageList read FImageNormal  write FImageNormal ;
    property ContainerPanel: TPanel read FContainerPanel  write FContainerPanel ;
    property ToolButtonMouseUp: TMouseEvent read FToolButtonMouseUp  write FToolButtonMouseUp ;
    property ToolButtonMouseDown: TMouseEvent read FToolButtonMouseDown  write FToolButtonMouseDown ;
    property ActionListFile: TActionList read FActionListFile  write FActionListFile ;
    property ActionListEdit: TActionList read  FActionListEdit write FActionListEdit ;
    property ActionListSetup: TActionList read FActionListSetup  write FActionListSetup ;
    property ActionListView: TActionList read FActionListView  write FActionListView ;
    property ActionListChart: TActionList read FActionListChart  write FActionListChart ;
    property ActionListTelescope: TActionList read FActionListTelescope  write FActionListTelescope ;
    property ActionListWindow: TActionList read FActionListWindow  write FActionListWindow ;
    property MagPanel: TPanel read FMagPanel  write FMagPanel ;
    property quicksearch: TComboBox read Fquicksearch  write Fquicksearch ;
    property TimeValPanel: Tpanel read FTimeValPanel  write FTimeValPanel ;
    property TimeU: TComboBox read FTimeU  write FTimeU ;
    property ToolBarFOV: Tpanel read FToolBarFOV  write FToolBarFOV ;
    property Mainmenu: TMenu read FMainmenu  write FMainmenu;
    property ConfigToolbar1: TStringList read FConfigToolbar1 write FConfigToolbar1;
    property ConfigToolbar2: TStringList read FConfigToolbar2 write FConfigToolbar2;
    property ConfigScriptButton: TStringList read FConfigScriptButton write FConfigScriptButton;
    property ConfigScript: TStringList read FConfigScript write FConfigScript;
    property ExecuteCmd: TExecuteCmd read FExecuteCmd write SetExecuteCmd;
  end;

implementation

{$R *.lfm}

{ Tf_script }
constructor Tf_script.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fedittoolbar:=Tf_edittoolbar.Create(self);
  fedittoolbar.ButtonMini.Visible:=false;
  fedittoolbar.ButtonStd.Visible:=false;
  FConfigToolbar1:=TStringList.Create;
  FConfigToolbar2:=TStringList.Create;
  FConfigScriptButton:=TStringList.Create;
  FConfigScript:=TStringList.Create;
end;

destructor Tf_script.Destroy;
begin
  fedittoolbar.Free;
  FConfigToolbar1.Free;
  FConfigToolbar2.Free;
  FConfigScriptButton.Free;
  FConfigScript.Free;
  if fscripteditor<>nil then fscripteditor.Free;
  inherited Destroy;
end;

procedure Tf_script.Init;
begin
  ToolBar1.Images:=FImageNormal;
  ToolBar2.Images:=FImageNormal;
  fedittoolbar.Images:=FImageNormal;
  fedittoolbar.DisabledContainer:=FContainerPanel;
  fedittoolbar.TBOnMouseUp:=FToolButtonMouseUp;
  fedittoolbar.TBOnMouseDown:=FToolButtonMouseDown;
  fedittoolbar.ClearAction;
  fedittoolbar.DefaultAction:=rsFile;
  fedittoolbar.AddAction(FActionListFile,rsFile);
  fedittoolbar.AddAction(FActionListEdit,rsEdit);
  fedittoolbar.AddAction(FActionListSetup,rsSetup);
  fedittoolbar.AddAction(FActionListView,rsView);
  fedittoolbar.AddAction(FActionListChart,rsChart);
  fedittoolbar.AddAction(FActionListTelescope,rsTelescope);
  fedittoolbar.AddAction(FActionListWindow,rsWindow);
  fedittoolbar.ClearControl;
  fedittoolbar.AddOtherControl(FMagPanel, rsStarAndNebul, rsFilter2, rsChart, 99);
  fedittoolbar.AddOtherControl(Fquicksearch, rsSearchBox, rsSearch, rsEdit, 102);
  fedittoolbar.AddOtherControl(FTimeValPanel, rsEditTimeIncr, rsAnimation,  rsChart, 103);
  fedittoolbar.AddOtherControl(FTimeU, rsSelectTimeUn, rsAnimation, rsChart, 104);
  fedittoolbar.ClearToolbar;
  fedittoolbar.DefaultToolbar:=ToolBar1.Caption;
  fedittoolbar.AddToolbar(ToolBar1);
  fedittoolbar.AddToolbar(ToolBar2);
  fedittoolbar.ProcessActions;
  fedittoolbar.LoadToolbar(0,ConfigToolbar1);
  fedittoolbar.LoadToolbar(1,ConfigToolbar2);
  fedittoolbar.ActivateToolbar;
  ToolBar1.Visible:=(VisibleControlCount(ToolBar1)>0);
  ToolBar2.Visible:=(VisibleControlCount(ToolBar2)>0);
  if FConfigScriptButton.Count>0 then begin
     if fscripteditor=nil then begin
        fscripteditor:=Tf_scripteditor.Create(self);
        fscripteditor.editsurface:=MainPanel;
        fscripteditor.onApply:=@ApplyScript;
        fscripteditor.ExecuteCmd:=FExecuteCmd;
     end;
     fscripteditor.Load(FConfigScriptButton, FConfigScript);
  end;
end;

procedure Tf_script.ButtonEditTBClick(Sender: TObject);
begin
  fedittoolbar.LoadToolbar(0,ConfigToolbar1);
  fedittoolbar.LoadToolbar(1,ConfigToolbar2);
  FormPos(fedittoolbar,mouse.cursorpos.x,mouse.cursorpos.y);
  fedittoolbar.ShowModal;
  if fedittoolbar.ModalResult=mrOK then begin
     fedittoolbar.SaveToolbar(0,ConfigToolbar1);
     fedittoolbar.SaveToolbar(1,ConfigToolbar2);
     ToolBar1.Visible:=(VisibleControlCount(ToolBar1)>0);
     ToolBar2.Visible:=(VisibleControlCount(ToolBar2)>0);
  end;
end;

procedure Tf_script.ButtonEditSrcClick(Sender: TObject);
begin
  if fscripteditor=nil then begin
     fscripteditor:=Tf_scripteditor.Create(self);
     fscripteditor.editsurface:=MainPanel;
     fscripteditor.onApply:=@ApplyScript;
     fscripteditor.ExecuteCmd:=FExecuteCmd;
  end;
  fscripteditor.Show;
end;

procedure Tf_script.ApplyScript(Sender: TObject);
begin
 fscripteditor.Save(FConfigScriptButton, FConfigScript);
end;

procedure Tf_script.SetExecuteCmd(value:TExecuteCmd);
begin
 FExecuteCmd:=value;
 if fscripteditor<>nil then fscripteditor.ExecuteCmd:=FExecuteCmd;
end;

end.

