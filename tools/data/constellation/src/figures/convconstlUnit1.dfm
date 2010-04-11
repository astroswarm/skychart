object Form1: TForm1
  Left = 574
  Top = 100
  Width = 243
  Height = 319
  Caption = 'Constellation Figures'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 16
    Top = 224
    Width = 75
    Height = 25
    Hint = 'Run the convertion program'
    Caption = 'Conversion'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 8
    Width = 185
    Height = 65
    Hint = 'Select here your modified constellation figure file.'
    Caption = 'Input File'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object FilenameEdit1: TEdit
      Left = 24
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
      Text = 'FilenameEdit1'
    end
  end
  object GroupBox2: TGroupBox
    Left = 16
    Top = 80
    Width = 185
    Height = 65
    Hint = 
      'Do not change this value if you want your constellation figure t' +
      'o be used directly with Cartes du Ciel'
    Caption = 'Output File'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object FilenameEdit2: TEdit
      Left = 24
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
      Text = 'FilenameEdit2'
    end
  end
  object BitBtn2: TBitBtn
    Left = 124
    Top = 224
    Width = 75
    Height = 25
    Hint = 'Exit without running the program'
    Caption = 'Close'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = BitBtn2Click
  end
  object GroupBox3: TGroupBox
    Left = 16
    Top = 152
    Width = 185
    Height = 57
    Hint = 
      'Backup the constellation figure file actually used by Cartes du ' +
      'Ciel'
    Caption = 'Options'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    object CheckBox1: TCheckBox
      Left = 16
      Top = 24
      Width = 129
      Height = 17
      Caption = 'Backup existing file'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
  end
  object ProgressBar1: TProgressBar
    Left = 16
    Top = 264
    Width = 185
    Height = 13
    Hint = 'Convertion progress indicator'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
  end
end
