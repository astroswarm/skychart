object f_info: Tf_info
  Left = 235
  Top = 233
  Width = 460
  Height = 354
  VertScrollBar.Range = 30
  ActiveControl = PageControl1
  AutoScroll = False
  Caption = 'Info'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 452
    Height = 297
    ActivePage = TabSheet1
    Align = alClient
    TabIndex = 0
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'TCP/IP Connection'
      object StringGrid1: TStringGrid
        Left = 0
        Top = 0
        Width = 444
        Height = 239
        Align = alClient
        ColCount = 1
        DefaultColWidth = 800
        DefaultRowHeight = 22
        FixedCols = 0
        RowCount = 10
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowSelect]
        PopupMenu = PopupMenu1
        ScrollBars = ssVertical
        TabOrder = 0
        OnMouseDown = StringGrid1MouseDown
      end
      object Panel2: TPanel
        Left = 0
        Top = 239
        Width = 444
        Height = 30
        Align = alBottom
        TabOrder = 1
        object Button2: TButton
          Left = 12
          Top = 3
          Width = 75
          Height = 25
          Caption = 'Refresh'
          TabOrder = 0
          OnClick = Button2Click
        end
        object CheckBox1: TCheckBox
          Left = 136
          Top = 2
          Width = 100
          Height = 25
          Caption = 'AutoRefresh'
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = CheckBox1Click
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 297
    Width = 452
    Height = 30
    Align = alBottom
    TabOrder = 1
    object Button1: TButton
      Left = 16
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 112
    Top = 64
    object closeconnection: TMenuItem
      Caption = 'Close Connection'
      OnClick = closeconnectionClick
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer1Timer
    Left = 64
    Top = 64
  end
end
