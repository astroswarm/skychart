object Form1: TForm1
  Left = 210
  Top = 84
  Caption = 'Form1'
  ClientHeight = 185
  ClientWidth = 370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 72
    Top = 48
    Width = 75
    Height = 25
    Caption = 'insert'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 32
    Top = 112
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object bsc: TTable
    DatabaseName = 'astrodb'
    TableName = 'BSC'
    Left = 304
    Top = 48
  end
  object Query1: TQuery
    DatabaseName = 'astrodb'
    SQL.Strings = (
      'select id from constelation where abrev = :a')
    Left = 256
    Top = 96
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'a'
        ParamType = ptUnknown
      end>
  end
  object astrodb: TDatabase
    AliasName = 'astrodb'
    DatabaseName = 'astrodb'
    Params.Strings = (
      'USER NAME=STARS')
    SessionName = 'Default'
    Left = 240
    Top = 48
  end
end
