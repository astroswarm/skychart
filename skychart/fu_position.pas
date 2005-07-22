unit fu_position;

interface

uses u_constant, u_projection, u_util,
  SysUtils, Classes, Variants, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QExtCtrls, QButtons, QMask, cu_radec, enhedits;

type
  Tf_position = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    coord1: TLabel;
    coord2: TLabel;
    long: TRaDec;
    lat: TRaDec;
    coord: TLabel;
    Panel2: TPanel;
    eq1: TLabel;
    eq2: TLabel;
    Ra: TRaDec;
    De: TRaDec;
    Equinox: TLabel;
    Panel3: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Fov: TRaDec;
    rot: TFloatEdit;
    procedure FormShow(Sender: TObject);
    procedure EqChange(Sender: TObject);
    procedure CoordChange(Sender: TObject);
  private
    { Private declarations }
    lock: boolean;
  public
    { Public declarations }
    AzNorth: boolean;
    cfgsc: conf_skychart;
  end;

var
  f_position: Tf_position;

implementation

{$R *.xfm}

{$include i_position.pas}

end.
