unit pu_main;
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
 Main form for Windows VCL application 
}

interface

uses cu_catalog, u_constant, u_util,
  Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, IniFiles;

type
  Tf_main = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CopyItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    ActionList1: TActionList;
    EditCopy1: TEditCopy;
    FileNew1: TAction;
    FileExit1: TAction;
    FileOpen1: TAction;
    FileSaveAs1: TAction;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowArrangeAll1: TWindowArrange;
    WindowMinimizeAll1: TWindowMinimizeAll;
    HelpAbout1: TAction;
    FileClose1: TWindowClose;
    WindowTileVertical1: TWindowTileVertical;
    WindowTileItem2: TMenuItem;
    ImageList1: TImageList;
    Print1: TAction;
    Print2: TMenuItem;
    FilePrintSetup1: TFilePrintSetup;
    starshape: TImage;
    OpenConfig: TAction;
    Configuration1: TMenuItem;
    Configurerlimpression1: TMenuItem;
    N2: TMenuItem;
    Setup1: TMenuItem;
    HelpContents1: THelpContents;
    Search1: TAction;
    PanelLeft: TPanel;
    ToolBar2: TToolBar;
    ToolButton7: TToolButton;
    PanelRight: TPanel;
    ToolBar3: TToolBar;
    ToolButton6: TToolButton;
    PanelBottom: TPanel;
    PPanels0: TPanel;
    LPanels0: TLabel;
    PPanels1: TPanel;
    LPanels1: TLabel;
    PanelTop: TPanel;
    ToolBar1: TToolBar;
    ToolButton9: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton15: TToolButton;
    ToolButton3: TToolButton;
    ToolButton8: TToolButton;
    ToolButton11: TToolButton;
    ToolButton5: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ViewBar: TAction;
    zoomplus: TAction;
    zoomminus: TAction;
    quicksearch: TComboBox;
    FlipX: TAction;
    FlipY: TAction;
    FlipButtonX: TToolButton;
    FlipButtonY: TToolButton;
    ToolButton4: TToolButton;
    ToolButton10: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ViewToolsBar1: TMenuItem;
    SaveDialog: TSaveDialog;
    ViewStatus: TAction;
    ViewStatusBar1: TMenuItem;
    View1: TMenuItem;
    SaveConfiguration: TAction;
    SaveConfigurationNow1: TMenuItem;
    SaveConfigOnExit: TAction;
    SaveConfigurationOnExit1: TMenuItem;
    N3: TMenuItem;
    ToolButton18: TToolButton;
    Undo: TAction;
    Redo: TAction;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ChangeProj: TAction;
    Autorefresh: TTimer;
    ToolButton23: TToolButton;
    ToolButton24: TToolButton;
    rot_plus: TAction;
    rot_minus: TAction;
    ToolBar4: TToolBar;
    ToolButton25: TToolButton;
    ToolButton26: TToolButton;
    ToolButton27: TToolButton;
    GridEQ: TAction;
    GridAZ: TAction;
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Print1Execute(Sender: TObject);
    procedure OpenConfigExecute(Sender: TObject);
    procedure ViewBarExecute(Sender: TObject);
    procedure zoomplusExecute(Sender: TObject);
    procedure zoomminusExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure quicksearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure quicksearchClick(Sender: TObject);
    procedure FlipXExecute(Sender: TObject);
    procedure FlipYExecute(Sender: TObject);
    procedure SetFOVExecute(Sender: TObject);
    procedure FileSaveAs1Execute(Sender: TObject);
    procedure ViewStatusExecute(Sender: TObject);
    procedure SaveConfigurationExecute(Sender: TObject);
    procedure SaveConfigOnExitExecute(Sender: TObject);
    procedure UndoExecute(Sender: TObject);
    procedure RedoExecute(Sender: TObject);
    procedure ChangeProjExecute(Sender: TObject);
    procedure AutorefreshTimer(Sender: TObject);
    procedure rot_plusExecute(Sender: TObject);
    procedure rot_minusExecute(Sender: TObject);
    procedure GridEQExecute(Sender: TObject);
    procedure GridAZExecute(Sender: TObject);
  private
    { Private declarations }
    function CreateMDIChild(const Name: string; copyactive: boolean; cfg1 : conf_skychart; cfgp : conf_plot):boolean;
    Procedure RefreshAllChild(applydef:boolean);
    procedure CopySCconfig(c1:conf_skychart;var c2:conf_skychart);
  public
    { Public declarations }
    cfgm : conf_main;
    def_cfgsc : conf_skychart;
    def_cfgplot : conf_plot;
    catalog : Tcatalog;
    procedure ReadChartConfig(filename:string; usecatalog:boolean; var cplot:conf_plot ;var csc:conf_skychart);
    procedure ReadPrivateConfig(filename:string);
    procedure ReadDefault;
    procedure SavePrivateConfig(filename:string);
    procedure SaveQuickSearch(filename:string);
    procedure SaveChartConfig(filename:string);
    procedure SaveDefault;
    procedure SetDefault;
    Procedure InitFonts;
    Procedure SetLPanel1(txt:string);
    Procedure SetLPanel0(txt:string);
    procedure updatebtn(fx,fy:integer);
    Procedure FormPos(form : Tform; x,y : integer);
  end;

var
  f_main: Tf_main;

implementation

{$R *.dfm}

uses pu_chart, pu_about, pu_config, u_projection ;

// include all cross-platform common code.
{$include i_main.pas}


end.
