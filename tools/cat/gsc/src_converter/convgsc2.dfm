object Form1: TForm1
  Left = 185
  Top = 79
  Caption = 'Convertion-GSC'
  ClientHeight = 193
  ClientWidth = 423
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 48
    Width = 82
    Height = 13
    Caption = 'Directory Source '
  end
  object Label2: TLabel
    Left = 8
    Top = 88
    Width = 68
    Height = 13
    Caption = 'Fichier Source'
  end
  object Label3: TLabel
    Left = 8
    Top = 16
    Width = 334
    Height = 16
    Caption = 'Convertion d'#39'un fichier du GSC en format binaire '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 8
    Top = 128
    Width = 98
    Height = 13
    Caption = 'Directory Destination'
  end
  object Button1: TButton
    Left = 112
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Convertion'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 112
    Top = 48
    Width = 225
    Height = 21
    TabOrder = 1
    Text = '.'
  end
  object Edit2: TEdit
    Left = 112
    Top = 88
    Width = 225
    Height = 21
    TabOrder = 2
    Text = '0908.gsc'
  end
  object Edit3: TEdit
    Left = 112
    Top = 120
    Width = 225
    Height = 21
    TabOrder = 3
    Text = '.'
  end
  object Button2: TButton
    Left = 240
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Sortie'
    TabOrder = 4
    OnClick = Button2Click
  end
end
