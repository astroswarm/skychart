unit fu_config;
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
 Configuration form for Linux CLX application
}
interface

uses Math, enhedits, u_constant, u_util, cu_zoomimage, passql, pasmysql,
  SysUtils, Classes, QForms,Types, QStyle,
  QStdCtrls, QComCtrls, QControls, QGraphics, QExtCtrls, QGrids, QButtons,
  QDialogs, QMask, QCheckLst;

type
  Tf_config = class(TForm)
    CancelBtn: TButton;
    OKBtn: TButton;
    HelpBtn: TButton;
    FontDialog1: TFontDialog;
    Applyall: TCheckBox;
    TreeView1: TTreeView;
    previous: TButton;
    next: TButton;
    OpenDialog1: TOpenDialog;
    apply: TButton;
    ColorDialog1: TColorDialog;
    topmsg: TPanel;
    PageControl1: TPageControl;
    s_time: TTabSheet;
    pa_time: TPageControl;
    t_time: TTabSheet;
    Panel9: TPanel;
    Label154: TLabel;
    Label158: TLabel;
    Label159: TLabel;
    Label160: TLabel;
    Label161: TLabel;
    Label162: TLabel;
    Label163: TLabel;
    Label164: TLabel;
    BitBtn4: TBitBtn;
    ADBC: TRadioGroup;
    d_year: TSpinEdit;
    d_month: TSpinEdit;
    d_day: TSpinEdit;
    t_hour: TSpinEdit;
    t_min: TSpinEdit;
    t_sec: TSpinEdit;
    Label50: TLabel;
    Label72: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Panel7: TPanel;
    Label131: TLabel;
    Label132: TLabel;
    Label133: TLabel;
    tz: TFloatEdit;
    Panel12: TPanel;
    Label146: TLabel;
    Tdt_Ut: TLabel;
    Label152: TLabel;
    Label153: TLabel;
    CheckBox4: TCheckBox;
    dt_ut: TLongEdit;
    LongEdit2: TLongEdit;
    t_simulation: TTabSheet;
    stepreset: TSpeedButton;
    Label165: TLabel;
    Label167: TLabel;
    Label168: TLabel;
    stepunit: TRadioGroup;
    stepline: TCheckBox;
    Label166: TLabel;
    nbstep: TSpinEdit;
    stepsize: TSpinEdit;
    SimObj: TCheckListBox;
    Label178: TLabel;
    s_observatory: TTabSheet;
    pa_observatory: TPageControl;
    t_observatory: TTabSheet;
    t_horizon: TTabSheet;
    Latitude: TGroupBox;
    Label58: TLabel;
    Label59: TLabel;
    Label60: TLabel;
    hemis: TComboBox;
    latdeg: TLongEdit;
    latmin: TLongEdit;
    latsec: TLongEdit;
    Longitude: TGroupBox;
    Label61: TLabel;
    Label62: TLabel;
    Label63: TLabel;
    long: TComboBox;
    longdeg: TLongEdit;
    longmin: TLongEdit;
    longsec: TLongEdit;
    Altitude: TGroupBox;
    Label70: TLabel;
    altmeter: TFloatEdit;
    timezone: TGroupBox;
    Label81: TLabel;
    timez: TFloatEdit;
    obsname: TGroupBox;
    dbreado: TPanel;
    citylist: TComboBox;
    citysearch: TButton;
    countrylist: TComboBox;
    cityfilter: TEdit;
    newcity: TButton;
    updcity: TButton;
    delcity: TButton;
    refraction: TGroupBox;
    Label82: TLabel;
    pressure: TFloatEdit;
    Label83: TLabel;
    temperature: TFloatEdit;
    Obszp: TButton;
    Obszm: TButton;
    Obsmap: TButton;
    ZoomImage1: TZoomImage;
    HScrollBar: TScrollBar;
    VScrollBar: TScrollBar;
    horizonopaque: TCheckBox;
    hor_l1: TLabel;
    horizonfile: TEdit;
    horizonfileBtn: TBitBtn;
    hor_l2: TLabel;
    s_chart: TTabSheet;
    pa_chart: TPageControl;
    t_chart: TTabSheet;
    t_fov: TTabSheet;
    t_projection: TTabSheet;
    t_filter: TTabSheet;
    t_grid: TTabSheet;
    Label31: TLabel;
    Panel1: TPanel;
    Label134: TLabel;
    Label135: TLabel;
    PMBox: TCheckBox;
    DrawPmBox: TCheckBox;
    lDrawPMy: TLongEdit;
    Panel10: TPanel;
    Label136: TLabel;
    Labelequinox: TLabel;
    equinoxtype: TRadioGroup;
    equinox2: TFloatEdit;
    equinox1: TComboBox;
    Label179: TLabel;
    projectiontype: TRadioGroup;
    ApparentType: TRadioGroup;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label30: TLabel;
    Label96: TLabel;
    Label97: TLabel;
    Label98: TLabel;
    Label99: TLabel;
    Label100: TLabel;
    Label101: TLabel;
    Label102: TLabel;
    Label103: TLabel;
    Label104: TLabel;
    Label105: TLabel;
    Label106: TLabel;
    Label107: TLabel;
    Label114: TLabel;
    fw1: TFloatEdit;
    fw2: TFloatEdit;
    fw3: TFloatEdit;
    fw4: TFloatEdit;
    fw5: TFloatEdit;
    fw6: TFloatEdit;
    fw7: TFloatEdit;
    fw8: TFloatEdit;
    fw9: TFloatEdit;
    fw10: TFloatEdit;
    fw0: TFloatEdit;
    fw00: TFloatEdit;
    Label138: TLabel;
    Label139: TLabel;
    Label57: TLabel;
    fw4b: TFloatEdit;
    fw5b: TFloatEdit;
    Bevel8: TBevel;
    Bevel7: TBevel;
    Label77: TLabel;
    Labelp1: TLabel;
    Labelp2: TLabel;
    Labelp3: TLabel;
    Labelp4: TLabel;
    Label149: TLabel;
    Labelp0: TLabel;
    Labelp5: TLabel;
    Labelp6: TLabel;
    Labelp7: TLabel;
    Labelp8: TLabel;
    Labelp9: TLabel;
    Labelp10: TLabel;
    Label171: TLabel;
    Label172: TLabel;
    Label173: TLabel;
    ComboBox2: TComboBox;
    ComboBox1: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    ComboBox8: TComboBox;
    ComboBox9: TComboBox;
    ComboBox10: TComboBox;
    ComboBox11: TComboBox;
    Label29: TLabel;
    GroupBox2: TGroupBox;
    StarBox: TCheckBox;
    Panel4: TPanel;
    Panel2: TPanel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Label76: TLabel;
    Label78: TLabel;
    Label108: TLabel;
    Label109: TLabel;
    fsmag0: TFloatEdit;
    fsmag1: TFloatEdit;
    fsmag2: TFloatEdit;
    fsmag3: TFloatEdit;
    fsmag4: TFloatEdit;
    fsmag5: TFloatEdit;
    fsmag6: TFloatEdit;
    fsmag7: TFloatEdit;
    fsmag8: TFloatEdit;
    fsmag9: TFloatEdit;
    Panel3: TPanel;
    Label110: TLabel;
    fsmagvis: TFloatEdit;
    StarAutoBox: TCheckBox;
    GroupBox1: TGroupBox;
    NebBox: TCheckBox;
    BigNebBox: TCheckBox;
    Panel5: TPanel;
    Label48: TLabel;
    Label49: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label79: TLabel;
    Label80: TLabel;
    Label111: TLabel;
    Label112: TLabel;
    fmag0: TFloatEdit;
    fmag1: TFloatEdit;
    fmag2: TFloatEdit;
    fmag3: TFloatEdit;
    fmag4: TFloatEdit;
    fmag5: TFloatEdit;
    fmag6: TFloatEdit;
    fdim0: TFloatEdit;
    fdim1: TFloatEdit;
    fdim2: TFloatEdit;
    fdim3: TFloatEdit;
    fdim4: TFloatEdit;
    fdim5: TFloatEdit;
    fdim6: TFloatEdit;
    fmag7: TFloatEdit;
    fmag8: TFloatEdit;
    fmag9: TFloatEdit;
    fdim7: TFloatEdit;
    fdim8: TFloatEdit;
    fdim9: TFloatEdit;
    fBigNebLimit: TLongEdit;
    Label140: TLabel;
    Bevel9: TBevel;
    Label115: TLabel;
    Label130: TLabel;
    Label137: TLabel;
    Label147: TLabel;
    Label148: TLabel;
    Label150: TLabel;
    Label151: TLabel;
    Label155: TLabel;
    Label156: TLabel;
    Label157: TLabel;
    Label169: TLabel;
    Label170: TLabel;
    Label174: TLabel;
    Label175: TLabel;
    Label176: TLabel;
    MaskEdit1: TMaskEdit;
    MaskEdit2: TMaskEdit;
    MaskEdit3: TMaskEdit;
    MaskEdit4: TMaskEdit;
    MaskEdit5: TMaskEdit;
    MaskEdit6: TMaskEdit;
    MaskEdit7: TMaskEdit;
    MaskEdit8: TMaskEdit;
    MaskEdit9: TMaskEdit;
    MaskEdit10: TMaskEdit;
    MaskEdit11: TMaskEdit;
    MaskEdit12: TMaskEdit;
    MaskEdit13: TMaskEdit;
    MaskEdit14: TMaskEdit;
    MaskEdit15: TMaskEdit;
    MaskEdit16: TMaskEdit;
    MaskEdit17: TMaskEdit;
    MaskEdit18: TMaskEdit;
    MaskEdit19: TMaskEdit;
    MaskEdit20: TMaskEdit;
    MaskEdit21: TMaskEdit;
    MaskEdit22: TMaskEdit;
    s_catalog: TTabSheet;
    pa_catalog: TPageControl;
    t_catgen: TTabSheet;
    t_cdcstar: TTabSheet;
    t_obsolete: TTabSheet;
    t_cdcneb: TTabSheet;
    t_external: TTabSheet;
    Label1: TLabel;
    Label37: TLabel;
    AddCat: TBitBtn;
    DelCat: TBitBtn;
    StringGrid3: TStringGrid;
    Label2: TLabel;
    Label65: TLabel;
    Label66: TLabel;
    Label87: TLabel;
    Label16: TLabel;
    Label28: TLabel;
    Label17: TLabel;
    Label27: TLabel;
    Label18: TLabel;
    BSCbox: TCheckBox;
    Fbsc1: TLongEdit;
    Fbsc2: TLongEdit;
    bsc3: TEdit;
    BitBtn9: TBitBtn;
    SKYbox: TCheckBox;
    Fsky1: TLongEdit;
    Fsky2: TLongEdit;
    sky3: TEdit;
    BitBtn10: TBitBtn;
    TY2Box: TCheckBox;
    Fty21: TLongEdit;
    Fty22: TLongEdit;
    ty23: TEdit;
    BitBtn12: TBitBtn;
    GSCFBox: TCheckBox;
    GSCCbox: TCheckBox;
    USNbox: TCheckBox;
    USNBright: TCheckBox;
    fgscf1: TLongEdit;
    fgscc1: TLongEdit;
    fusn1: TLongEdit;
    fusn2: TLongEdit;
    fgscc2: TLongEdit;
    fgscf2: TLongEdit;
    gscf3: TEdit;
    gscc3: TEdit;
    usn3: TEdit;
    BitBtn19: TBitBtn;
    BitBtn17: TBitBtn;
    BitBtn16: TBitBtn;
    Label21: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    dsbasebox: TCheckBox;
    dstycBox: TCheckBox;
    dsgscBox: TCheckBox;
    dsbase1: TLongEdit;
    dstyc1: TLongEdit;
    dsgsc1: TLongEdit;
    dsgsc2: TLongEdit;
    dstyc2: TLongEdit;
    dsbase2: TLongEdit;
    dsbase3: TEdit;
    dstyc3: TEdit;
    dsgsc3: TEdit;
    BitBtn22: TBitBtn;
    BitBtn21: TBitBtn;
    BitBtn20: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn15: TBitBtn;
    wds3: TEdit;
    gcv3: TEdit;
    Fgcv2: TLongEdit;
    Fwds2: TLongEdit;
    Fwds1: TLongEdit;
    Fgcv1: TLongEdit;
    GCVBox: TCheckBox;
    IRVar: TCheckBox;
    WDSbox: TCheckBox;
    Label88: TLabel;
    Label67: TLabel;
    TYCbox: TCheckBox;
    Ftyc1: TLongEdit;
    Ftyc2: TLongEdit;
    tyc3: TEdit;
    BitBtn11: TBitBtn;
    TICbox: TCheckBox;
    Ftic1: TLongEdit;
    Ftic2: TLongEdit;
    tic3: TEdit;
    BitBtn13: TBitBtn;
    GSCbox: TCheckBox;
    fgsc1: TLongEdit;
    fgsc2: TLongEdit;
    gsc3: TEdit;
    BitBtn18: TBitBtn;
    MCTBox: TCheckBox;
    fmct1: TLongEdit;
    fmct2: TLongEdit;
    mct3: TEdit;
    BitBtn32: TBitBtn;
    Label90: TLabel;
    Label91: TLabel;
    Label92: TLabel;
    Label93: TLabel;
    Label94: TLabel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Label3: TLabel;
    Label69: TLabel;
    Label15: TLabel;
    Label116: TLabel;
    Label117: TLabel;
    Label118: TLabel;
    Label119: TLabel;
    NGCbox: TCheckBox;
    ngc3: TEdit;
    SACbox: TCheckBox;
    sac3: TEdit;
    fngc1: TLongEdit;
    fngc2: TLongEdit;
    fsac1: TLongEdit;
    fsac2: TLongEdit;
    BitBtn23: TBitBtn;
    BitBtn24: TBitBtn;
    Bevel5: TBevel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label120: TLabel;
    RC3box: TCheckBox;
    OCLbox: TCheckBox;
    GCMbox: TCheckBox;
    GPNbox: TCheckBox;
    LBNbox: TCheckBox;
    rc33: TEdit;
    lbn3: TEdit;
    ocl3: TEdit;
    gcm3: TEdit;
    gpn3: TEdit;
    PGCBox: TCheckBox;
    pgc3: TEdit;
    flbn1: TLongEdit;
    flbn2: TLongEdit;
    frc31: TLongEdit;
    frc32: TLongEdit;
    fpgc1: TLongEdit;
    fpgc2: TLongEdit;
    focl1: TLongEdit;
    focl2: TLongEdit;
    fgcm1: TLongEdit;
    fgcm2: TLongEdit;
    fgpn1: TLongEdit;
    fgpn2: TLongEdit;
    BitBtn25: TBitBtn;
    BitBtn26: TBitBtn;
    BitBtn27: TBitBtn;
    BitBtn28: TBitBtn;
    BitBtn29: TBitBtn;
    BitBtn30: TBitBtn;
    Label4: TLabel;
    Label52: TLabel;
    Label71: TLabel;
    StringGrid1: TStringGrid;
    Cat1Box: TCheckBox;
    Edit1: TEdit;
    Label64: TLabel;
    Cat2Box: TCheckBox;
    StringGrid2: TStringGrid;
    s_solsys: TTabSheet;
    pa_solsys: TPageControl;
    t_solsys: TTabSheet;
    t_planet: TTabSheet;
    t_asteroid: TTabSheet;
    t_comet: TTabSheet;
    Label12: TLabel;
    PlaParalaxe: TRadioGroup;
    PlanetDir: TEdit;
    Label53: TLabel;
    PlanetDirSel: TBitBtn;
    Label5: TLabel;
    Label89: TLabel;
    PlanetBox: TCheckBox;
    PlanetMode: TRadioGroup;
    PlanetBox2: TCheckBox;
    PlanetBox3: TCheckBox;
    GRS: TFloatEdit;
    BitBtn37: TBitBtn;
    Label177: TLabel;
    Edit2: TEdit;
    ComPageControl: TPageControl;
    comsetting: TTabSheet;
    GroupBox13: TGroupBox;
    Label6: TLabel;
    Label231: TLabel;
    Label232: TLabel;
    comlimitmag: TFloatEdit;
    showcom: TCheckBox;
    comsymbol: TRadioGroup;
    commagdiff: TFloatEdit;
    comdbset: TButton;
    comload: TTabSheet;
    Label233: TLabel;
    GroupBox14: TGroupBox;
    Label234: TLabel;
    comfile: TEdit;
    Loadcom: TButton;
    comfilebtn: TBitBtn;
    MemoCom: TMemo;
    comdelete: TTabSheet;
    Label238: TLabel;
    GroupBox16: TGroupBox;
    comelemlist: TComboBox;
    DelCom: TButton;
    GroupBox17: TGroupBox;
    Label239: TLabel;
    DelComAll: TButton;
    DelComMemo: TMemo;
    Addsinglecom: TTabSheet;
    Label241: TLabel;
    Label242: TLabel;
    Label243: TLabel;
    Label244: TLabel;
    Label245: TLabel;
    Label246: TLabel;
    Label247: TLabel;
    Label248: TLabel;
    Label249: TLabel;
    Label250: TLabel;
    Label251: TLabel;
    Label253: TLabel;
    Label254: TLabel;
    comid: TEdit;
    comh: TEdit;
    comg: TEdit;
    comep: TEdit;
    comperi: TEdit;
    comnode: TEdit;
    comi: TEdit;
    comec: TEdit;
    comq: TEdit;
    comnam: TEdit;
    comeq: TEdit;
    AddCom: TButton;
    comt: TMaskEdit;
    AstPageControl: TPageControl;
    astsetting: TTabSheet;
    GroupBox9: TGroupBox;
    astlimitmag: TFloatEdit;
    Label203: TLabel;
    showast: TCheckBox;
    astsymbol: TRadioGroup;
    Label212: TLabel;
    astmagdiff: TFloatEdit;
    Label213: TLabel;
    astdbset: TButton;
    astload: TTabSheet;
    GroupBox7: TGroupBox;
    Label204: TLabel;
    mpcfile: TEdit;
    astnumbered: TCheckBox;
    LoadMPC: TButton;
    mpcfilebtn: TBitBtn;
    aststoperr: TCheckBox;
    astlimit: TLongEdit;
    astlimitbox: TCheckBox;
    Label215: TLabel;
    MemoMPC: TMemo;
    Label206: TLabel;
    astprepare: TTabSheet;
    GroupBox8: TGroupBox;
    aststrtdate: TMaskEdit;
    Label7: TLabel;
    Label207: TLabel;
    AstCompute: TButton;
    astnummonth: TSpinEdit;
    Label216: TLabel;
    prepastmemo: TMemo;
    Label210: TLabel;
    astdelete: TTabSheet;
    GroupBox10: TGroupBox;
    astelemlist: TComboBox;
    delast: TButton;
    GroupBox11: TGroupBox;
    delallast: TButton;
    Label209: TLabel;
    Label211: TLabel;
    delastMemo: TMemo;
    GroupBox12: TGroupBox;
    astdeldate: TMaskEdit;
    deldateast: TButton;
    Label214: TLabel;
    AddsingleAst: TTabSheet;
    Label217: TLabel;
    astid: TEdit;
    asth: TEdit;
    astg: TEdit;
    astep: TEdit;
    astma: TEdit;
    astperi: TEdit;
    astnode: TEdit;
    asti: TEdit;
    astec: TEdit;
    astax: TEdit;
    astref: TEdit;
    astnam: TEdit;
    asteq: TEdit;
    Label218: TLabel;
    Label219: TLabel;
    Label220: TLabel;
    Label221: TLabel;
    Label222: TLabel;
    Label223: TLabel;
    Label224: TLabel;
    Label225: TLabel;
    Label226: TLabel;
    Label227: TLabel;
    Label228: TLabel;
    Label229: TLabel;
    Label230: TLabel;
    Addast: TButton;
    s_display: TTabSheet;
    pa_display: TPageControl;
    t_list: TTabSheet;
    Label95: TLabel;
    GroupBox5: TGroupBox;
    liststar: TCheckBox;
    listneb: TCheckBox;
    listpla: TCheckBox;
    listvar: TCheckBox;
    listdbl: TCheckBox;
    t_display: TTabSheet;
    t_fonts: TTabSheet;
    t_color: TTabSheet;
    t_skycolor: TTabSheet;
    t_nebcolor: TTabSheet;
    t_lines: TTabSheet;
    t_labels: TTabSheet;
    Label14: TLabel;
    stardisplay: TRadioGroup;
    nebuladisplay: TRadioGroup;
    Bevel10: TBevel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    Label51: TLabel;
    Label121: TLabel;
    Label122: TLabel;
    Label123: TLabel;
    Label124: TLabel;
    Label125: TLabel;
    Label126: TLabel;
    Label127: TLabel;
    Label128: TLabel;
    Label129: TLabel;
    gridfont: TEdit;
    labelfont: TEdit;
    legendfont: TEdit;
    statusfont: TEdit;
    listfont: TEdit;
    prtfont: TEdit;
    Button1: TButton;
    Label235: TLabel;
    symbfont: TEdit;
    Label8: TLabel;
    bg1: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Label181: TLabel;
    Label182: TLabel;
    Label183: TLabel;
    Label184: TLabel;
    Label185: TLabel;
    Label186: TLabel;
    Label187: TLabel;
    Label188: TLabel;
    Label189: TLabel;
    bg2: TPanel;
    Shape8: TShape;
    Shape9: TShape;
    Shape10: TShape;
    Shape11: TShape;
    Shape12: TShape;
    Shape13: TShape;
    Label190: TLabel;
    Label191: TLabel;
    Label192: TLabel;
    Label193: TLabel;
    Label194: TLabel;
    Label195: TLabel;
    bg3: TPanel;
    Shape15: TShape;
    Shape16: TShape;
    Shape17: TShape;
    Shape14: TShape;
    Shape25: TShape;
    Label197: TLabel;
    Label198: TLabel;
    Label199: TLabel;
    Label196: TLabel;
    DefColor: TRadioGroup;
    Label11: TLabel;
    Label256: TLabel;
    Label257: TLabel;
    bg4: TPanel;
    Shape26: TShape;
    Shape27: TShape;
    Label200: TLabel;
    skycolorbox: TRadioGroup;
    Panel6: TPanel;
    Shape18: TShape;
    Shape19: TShape;
    Shape20: TShape;
    Shape21: TShape;
    Shape22: TShape;
    Shape23: TShape;
    Shape24: TShape;
    Label202: TLabel;
    Label205: TLabel;
    Label208: TLabel;
    Button3: TButton;
    Label201: TLabel;
    Bevel6: TBevel;
    Bevel11: TBevel;
    Bevel12: TBevel;
    Label9: TLabel;
    EqGrid: TCheckBox;
    CGrid: TCheckBox;
    Constl: TCheckBox;
    ConstlFile: TEdit;
    Label180: TLabel;
    ConstlFileBtn: TBitBtn;
    Constb: TCheckBox;
    ConstbFile: TEdit;
    Label56: TLabel;
    ConstbfileBtn: TBitBtn;
    ecliptic: TCheckBox;
    galactic: TCheckBox;
    milkyway: TCheckBox;
    fillmilkyway: TCheckBox;
    GridNum: TCheckBox;
    labelcolorStar: TShape;
    labelcolorVar: TShape;
    labelcolorMult: TShape;
    Label10: TLabel;
    Label236: TLabel;
    Label237: TLabel;
    Label240: TLabel;
    Label252: TLabel;
    Label255: TLabel;
    labelsizeStar: TSpinEdit;
    labelmagStar: TSpinEdit;
    showlabelStar: TCheckBox;
    labelsizeVar: TSpinEdit;
    labelmagVar: TSpinEdit;
    showlabelVar: TCheckBox;
    labelsizeMult: TSpinEdit;
    LabelmagMult: TSpinEdit;
    showlabelMult: TCheckBox;
    labelcolorNeb: TShape;
    labelcolorSol: TShape;
    labelcolorMisc: TShape;
    labelcolorConst: TShape;
    labelsizeNeb: TSpinEdit;
    labelmagNeb: TSpinEdit;
    showlabelNeb: TCheckBox;
    labelsizeSol: TSpinEdit;
    labelmagSol: TSpinEdit;
    showlabelSol: TCheckBox;
    labelsizeMisc: TSpinEdit;
    showlabelMisc: TCheckBox;
    showlabelConst: TCheckBox;
    labelsizeConst: TSpinEdit;
    MagLabel: TRadioGroup;
    constlabel: TRadioGroup;
    s_images: TTabSheet;
    s_system: TTabSheet;
    pa_images: TPageControl;
    t_images: TTabSheet;
    Label113: TLabel;
    pa_system: TPageControl;
    t_system: TTabSheet;
    t_server: TTabSheet;
    Label84: TLabel;
    GroupBox6: TGroupBox;
    dbname: TEdit;
    dbport: TLongEdit;
    dbhost: TEdit;
    Label141: TLabel;
    Label142: TLabel;
    Label143: TLabel;
    dbuser: TEdit;
    dbpass: TEdit;
    Label144: TLabel;
    Label145: TLabel;
    chkdb: TButton;
    credb: TButton;
    dropdb: TButton;
    AstDB: TButton;
    CometDB: TButton;
    Label54: TLabel;
    GroupBox3: TGroupBox;
    UseIPserver: TCheckBox;
    ipaddr: TEdit;
    Label55: TLabel;
    Label85: TLabel;
    ipport: TEdit;
    keepalive: TCheckBox;
    GroupBox4: TGroupBox;
    ipstatus: TEdit;
    refreshIP: TButton;
    t_telescope: TTabSheet;
    Label13: TLabel;
    GroupBox15: TGroupBox;
    Label68: TLabel;
    IndiServerHost: TEdit;
    Label86: TLabel;
    IndiServerPort: TEdit;
    IndiAutostart: TCheckBox;
    Label258: TLabel;
    IndiServerCmd: TEdit;
    Label259: TLabel;
    IndiDriver: TEdit;
    IndiDev: TComboBox;
    Label260: TLabel;
    Label261: TLabel;
    IndiPort: TEdit;
    t_circle: TTabSheet;
    t_rectangle: TTabSheet;
    cb1: TCheckBox;
    cb2: TCheckBox;
    cb3: TCheckBox;
    cb4: TCheckBox;
    cb5: TCheckBox;
    cb6: TCheckBox;
    cb7: TCheckBox;
    cb8: TCheckBox;
    cb9: TCheckBox;
    cb10: TCheckBox;
    rb1: TCheckBox;
    rb2: TCheckBox;
    rb3: TCheckBox;
    rb4: TCheckBox;
    rb5: TCheckBox;
    rb6: TCheckBox;
    rb7: TCheckBox;
    rb8: TCheckBox;
    rb9: TCheckBox;
    rb10: TCheckBox;
    Label307: TLabel;
    Label308: TLabel;
    Circlegrid: TStringGrid;
    RectangleGrid: TStringGrid;
    CenterMark1: TCheckBox;
    CenterMark2: TCheckBox;
    GroupBoxDir: TGroupBox;
    Label73: TLabel;
    Label74: TLabel;
    prgdir: TEdit;
    persdir: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure SelectFontClick(Sender: TObject);
    procedure DefaultFontClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FWChange(Sender: TObject);
    procedure CDCStarSelClick(Sender: TObject);
    procedure CDCStarField1Change(Sender: TObject);
    procedure CDCStarField2Change(Sender: TObject);
    procedure CDCStarPathChange(Sender: TObject);
    procedure CDCStarSelPathClick(Sender: TObject);
    procedure StarBoxClick(Sender: TObject);
    procedure StarAutoBoxClick(Sender: TObject);
    procedure NebBoxClick(Sender: TObject);
    procedure BigNebBoxClick(Sender: TObject);
    procedure fsmagvisChange(Sender: TObject);
    procedure fsmagChange(Sender: TObject);
    procedure fmagChange(Sender: TObject);
    procedure fdimChange(Sender: TObject);
    procedure CDCNebSelPathClick(Sender: TObject);
    procedure CDCNebSelClick(Sender: TObject);
    procedure CDCNebField1Change(Sender: TObject);
    procedure CDCNebField2Change(Sender: TObject);
    procedure CDCNebPathChange(Sender: TObject);
    procedure USNBrightClick(Sender: TObject);
    procedure IRVarClick(Sender: TObject);
    procedure GCVBoxClick(Sender: TObject);
    procedure Fgcv1Change(Sender: TObject);
    procedure Fgcv2Change(Sender: TObject);
    procedure WDSboxClick(Sender: TObject);
    procedure Fwds1Change(Sender: TObject);
    procedure Fwds2Change(Sender: TObject);
    procedure gcv3Change(Sender: TObject);
    procedure wds3Change(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn15Click(Sender: TObject);
    procedure stardisplayClick(Sender: TObject);
    procedure nebuladisplayClick(Sender: TObject);
    procedure nextClick(Sender: TObject);
    procedure previousClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure LongEdit2Change(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure tzChange(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure dt_utChange(Sender: TObject);
    procedure fBigNebLimitChange(Sender: TObject);
    procedure StringGrid3DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGrid3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid3SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure StringGrid3SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: WideString);
    procedure AddCatClick(Sender: TObject);
    procedure DelCatClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure equinoxtypeClick(Sender: TObject);
    procedure equinox1Change(Sender: TObject);
    procedure equinox2Change(Sender: TObject);
    procedure PMBoxClick(Sender: TObject);
    procedure DrawPmBoxClick(Sender: TObject);
    procedure lDrawPMyChange(Sender: TObject);
    procedure ProjectionChange(Sender: TObject);
    procedure TimeChange(Sender: TObject; NewValue: Integer);
    procedure DateChange(Sender: TObject; NewValue: Integer);
    procedure DateChange2(Sender: TObject);
    procedure TimeChange2(Sender: TObject);
    procedure DegSpacingChange(Sender: TObject);
    procedure HourSpacingChange(Sender: TObject);
    procedure PlaParalaxeClick(Sender: TObject);
    procedure PlanetBoxClick(Sender: TObject);
    procedure PlanetModeClick(Sender: TObject);
    procedure GRSChange(Sender: TObject);
    procedure PlanetBox2Click(Sender: TObject);
    procedure PlanetBox3Click(Sender: TObject);
    procedure applyClick(Sender: TObject);
    procedure nbstepChanged(Sender: TObject; NewValue: Integer);
    procedure steplineClick(Sender: TObject);
    procedure stepunitClick(Sender: TObject);
    procedure stepsizeChanged(Sender: TObject; NewValue: Integer);
    procedure SimObjClickCheck(Sender: TObject);
    procedure projectiontypeClick(Sender: TObject);
    procedure ConstlFileBtnClick(Sender: TObject);
    procedure ConstlFileChange(Sender: TObject);
    procedure EqGridClick(Sender: TObject);
    procedure CGridClick(Sender: TObject);
    procedure ConstlClick(Sender: TObject);
    procedure ApparentTypeClick(Sender: TObject);
    procedure bgClick(Sender: TObject);
    procedure ShapeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DefColorClick(Sender: TObject);
    procedure skycolorboxClick(Sender: TObject);
    procedure ShapeSkyMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure refreshIPClick(Sender: TObject);
    procedure UseIPserverClick(Sender: TObject);
    procedure ipaddrChange(Sender: TObject);
    procedure ipportChange(Sender: TObject);
    procedure keepaliveClick(Sender: TObject);
    procedure latdegChange(Sender: TObject);
    procedure longdegChange(Sender: TObject);
    procedure altmeterChange(Sender: TObject);
    procedure pressureChange(Sender: TObject);
    procedure temperatureChange(Sender: TObject);
    procedure HScrollBarChange(Sender: TObject);
    procedure VScrollBarChange(Sender: TObject);
    procedure ZoomImage1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZoomImage1Paint(Sender: TObject);
    procedure ZoomImage1PosChange(Sender: TObject);
    procedure ObszpClick(Sender: TObject);
    procedure ObszmClick(Sender: TObject);
    procedure ObsmapClick(Sender: TObject);
    procedure ConstbClick(Sender: TObject);
    procedure ConstbFileChange(Sender: TObject);
    procedure ConstbfileBtnClick(Sender: TObject);
    procedure galacticClick(Sender: TObject);
    procedure eclipticClick(Sender: TObject);
    procedure milkywayClick(Sender: TObject);
    procedure fillmilkywayClick(Sender: TObject);
    procedure GridNumClick(Sender: TObject);
    procedure citysearchClick(Sender: TObject);
    procedure citylistClick(Sender: TObject);
    procedure countrylistClick(Sender: TObject);
    procedure citylistChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure newcityClick(Sender: TObject);
    procedure updcityClick(Sender: TObject);
    procedure delcityClick(Sender: TObject);
    procedure obsnameMouseEnter(Sender: TObject);
    procedure UpdCityList(changecity:boolean);
    procedure horizonfileBtnClick(Sender: TObject);
    procedure horizonopaqueClick(Sender: TObject);
    procedure horizonfileChange(Sender: TObject);
    procedure liststarClick(Sender: TObject);
    procedure listnebClick(Sender: TObject);
    procedure listplaClick(Sender: TObject);
    procedure listvarClick(Sender: TObject);
    procedure listdblClick(Sender: TObject);
    procedure dbnameChange(Sender: TObject);
    procedure dbhostChange(Sender: TObject);
    procedure dbportChange(Sender: TObject);
    procedure dbuserChange(Sender: TObject);
    procedure dbpassChange(Sender: TObject);
    procedure chkdbClick(Sender: TObject);
    procedure credbClick(Sender: TObject);
    procedure dropdbClick(Sender: TObject);
    procedure astdbsetClick(Sender: TObject);
    procedure showastClick(Sender: TObject);
    procedure astlimitmagChange(Sender: TObject);
    procedure astsymbolClick(Sender: TObject);
    procedure mpcfilebtnClick(Sender: TObject);
    procedure LoadMPCClick(Sender: TObject);
    procedure delastClick(Sender: TObject);
    procedure delallastClick(Sender: TObject);
    procedure AstComputeClick(Sender: TObject);
    procedure AstDBClick(Sender: TObject);
    procedure astmagdiffChange(Sender: TObject);
    procedure deldateastClick(Sender: TObject);
    procedure stepresetClick(Sender: TObject);
    procedure AddastClick(Sender: TObject);
    procedure showcomClick(Sender: TObject);
    procedure comsymbolClick(Sender: TObject);
    procedure comlimitmagChange(Sender: TObject);
    procedure commagdiffChange(Sender: TObject);
    procedure comfilebtnClick(Sender: TObject);
    procedure LoadcomClick(Sender: TObject);
    procedure DelComClick(Sender: TObject);
    procedure DelComAllClick(Sender: TObject);
    procedure AddComClick(Sender: TObject);
    procedure CometDBClick(Sender: TObject);
    procedure showlabelClick(Sender: TObject);
    procedure labelmagChanged(Sender: TObject; NewValue: Integer);
    procedure labelcolorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure labelsizeChanged(Sender: TObject; NewValue: Integer);
    procedure PlanetDirSelClick(Sender: TObject);
    procedure PlanetDirChange(Sender: TObject);
    procedure MagLabelClick(Sender: TObject);
    procedure constlabelClick(Sender: TObject);
    procedure IndiServerHostChange(Sender: TObject);
    procedure IndiServerPortChange(Sender: TObject);
    procedure IndiAutostartClick(Sender: TObject);
    procedure IndiServerCmdChange(Sender: TObject);
    procedure IndiDevChange(Sender: TObject);
    procedure IndiDriverChange(Sender: TObject);
    procedure IndiPortChange(Sender: TObject);
    procedure cb1Click(Sender: TObject);
    procedure rb1Click(Sender: TObject);
    procedure CirclegridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: WideString);
    procedure RectangleGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: WideString);
    procedure CenterMark1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Déclarations privées }
    db:TmyDB;
    ObsMapFile:string;
    locktree: boolean;
    procedure EditGCatPath(row : integer);
    procedure DeleteGCatRow(p : integer);
    procedure labelmagChange(Sender: TObject);
    procedure labelsizeChange(Sender: TObject);
  public
    { Déclarations publiques }
    ccat : conf_catalog;
    cshr : conf_shared;
    csc  : conf_skychart;
    cplot : conf_plot;
    cmain : conf_main;
    catalogempty: boolean;
    EarthMapZoom: double;
    Obsposx,Obsposy : integer;
    scrollw, scrollh : integer;
    scrolllock,obslock:boolean;
    astpage,compage,dbpage: integer;
    procedure SetLang(lang:string);
    procedure SetFonts(ctrl:Tedit;num:integer);
    procedure ShowTime;
    procedure ShowChart;
    procedure SetEquinox;
    procedure ShowDisplay;
    procedure ShowFonts;
    procedure SetFieldHint(var lab:Tlabel; n:integer);
    procedure ShowProjection;
    procedure ShowField;
    procedure ShowPlanet;
    procedure ShowFilter;
    procedure ShowGridSpacing;
    procedure ShowGcat;
    procedure ShowCDCStar;
    procedure ShowCDCNeb;
    procedure ShowLine;
    procedure ShowColor;
    procedure ShowSkyColor;
    procedure ShowServer;
    procedure ShowObservatory;
    Procedure SetScrollBar;
    Procedure SetObsPos;
    Procedure ShowObsCoord;
    procedure CenterObs;
    procedure ShowHorizon;
    procedure ShowObjList;
    procedure ShowSYS;
    procedure ShowAsteroid;
    procedure UpdAstList;
    procedure ShowComet;
    procedure UpdComList;
    procedure showlabelcolor;
    procedure showlabel;
    procedure showcircle;
    procedure showrectangle;
    procedure showtelescope;
  end;

var
  f_config: Tf_config;

implementation

uses fu_main, fu_directory, u_projection;

var
   SetDirectory : function(dir:pchar): integer; stdcall;
   ReadCountryFile: function (country:pchar; var City: PCities; var cfile:array of char): integer; stdcall;
   AddCity: function(City: PCity): integer; stdcall;
   ModifyCity: function(index: integer; City: PCity): integer; stdcall;
   RemoveCity: function(index: integer; City: PCity): integer; stdcall;
   ReleaseCities: function(): integer; stdcall;
   SearchCity: function(str: pchar): integer; stdcall;
   libCities : THandle;

var c : Pcities;
    total,first: integer;
    actual_country: string;
    autoprocess: boolean;

{$R *.xfm}

// include all cross-platform common code.
// you can temporarily copy the file content here
// to use the IDE facilities

{$include i_config.pas }

// end of common code

// Specific Linux CLX code:

procedure Tf_config.nbstepChanged(Sender: TObject; NewValue: Integer);
begin
csc.Simnb:=nbstep.value;
end;

procedure Tf_config.stepsizeChanged(Sender: TObject; NewValue: Integer);
begin
stepunitClick(Sender);
end;

procedure Tf_config.labelmagChanged(Sender: TObject; NewValue: Integer);
begin
labelmagChange(Sender);
end;

procedure Tf_config.labelsizeChanged(Sender: TObject; NewValue: Integer);
begin
labelSizeChange(Sender);
end;
// End of Linux specific CLX code:


end.



