object SeatalkerForm: TSeatalkerForm
  Left = 192
  Top = 152
  Width = 858
  Height = 354
  Caption = 'Seatalk Remote Control'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ComLed1: TComLed
    Left = 88
    Top = 32
    Width = 25
    Height = 25
    ComPort = SeaTalk
    LedSignal = lsConn
    Kind = lkGreenLight
  end
  object ComLed2: TComLed
    Left = 112
    Top = 32
    Width = 25
    Height = 25
    ComPort = SeaTalk
    LedSignal = lsRx
    Kind = lkYellowLight
  end
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 842
    Height = 2
    Align = alTop
    Shape = bsTopLine
  end
  object OpenPortButton: TButton
    Left = 8
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = OpenPortButtonClick
  end
  object SendButton: TButton
    Left = 8
    Top = 224
    Width = 75
    Height = 25
    Caption = 'Send'
    TabOrder = 10
    OnClick = SendButtonClick
  end
  object Minus1: TButton
    Tag = 1
    Left = 8
    Top = 64
    Width = 75
    Height = 25
    Caption = '-1'
    TabOrder = 2
    OnClick = Minus1Click
  end
  object Plus1: TButton
    Tag = 2
    Left = 88
    Top = 64
    Width = 75
    Height = 25
    Caption = '+1'
    TabOrder = 3
    OnClick = Minus1Click
  end
  object Minues10: TButton
    Tag = 10
    Left = 8
    Top = 96
    Width = 75
    Height = 25
    Caption = '-10'
    TabOrder = 4
    OnClick = Minus1Click
  end
  object plus10: TButton
    Tag = 11
    Left = 88
    Top = 96
    Width = 75
    Height = 25
    Caption = '+10'
    TabOrder = 5
    OnClick = Minus1Click
  end
  object Standby: TBitBtn
    Tag = 30
    Left = 8
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Standby'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnClick = Minus1Click
  end
  object Auto: TBitBtn
    Tag = 31
    Left = 88
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Auto'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    OnClick = Minus1Click
  end
  object ClosePortButton: TButton
    Left = 8
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 12
    OnClick = ClosePortButtonClick
  end
  object DatagramEdit: TEdit
    Left = 8
    Top = 192
    Width = 153
    Height = 21
    TabOrder = 11
    Text = '30 00 0C'
  end
  object LampOnButton: TButton
    Left = 8
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Lamp On'
    TabOrder = 8
    OnClick = LampOnButtonClick
  end
  object LampOffButton: TButton
    Left = 88
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Lamp Off'
    TabOrder = 9
    OnClick = LampOffButtonClick
  end
  object ComComboBox1: TComComboBox
    Left = 8
    Top = 8
    Width = 153
    Height = 21
    ComPort = SeaTalk
    ComProperty = cpPort
    AutoApply = True
    Text = 'COM1'
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 1
  end
  object STCommands: TListBox
    Left = 304
    Top = 16
    Width = 121
    Height = 97
    ExtendedSelect = False
    ItemHeight = 13
    Items.Strings = (
      '00=Depth'
      '01=ID Power on'
      '05=Engine'
      '10=Wind Angle Apparent'
      '11=Wind Speed Apparent'
      '20=Log Speed #1'
      '21=Log Trip'
      '22=Log Total'
      '23=Water Temp #1'
      '24=Log Units'
      '25=Log Trip and Total'
      '26=Log Speed #2'
      '27=Water Temp #2'
      '30=Lamp #1'
      '36=MOB Cancel'
      '38=Codelock'
      '50=Position Lat'
      '51=Position Long'
      '52=SOG'
      '53=Heading COG'
      '54=Time'
      '55=Key GPS'
      '56=Date'
      '57=GPS sat info'
      '58=Position'
      '59=Timer set'
      '61=Initialisation E80'
      '65=Depth units Fathom'
      '66=Alarm Wind'
      '68=Alarm Ack'
      '6C=ID #1'
      '6E=MOB'
      '70=KEY ST60 Maxiview Remote'
      '80=Lamp #2'
      '81=Config Course Computer #1'
      '82=Waypoint Name'
      '83=Course computer failure'
      '84=Heading Compass AP #1'
      '85=Navigation'
      '86=Key'
      '87=Config Set response level'
      '88=Config Autopilot #1'
      '89=Heading Compass'
      '90=ID #2'
      '91=Rudder gain'
      '92=Config Autopilot #2'
      '93=Config Autopilot enter'
      '95=Heading Compass AP #2'
      '99=Heading Var'
      '9A=Version'
      '9C=Heading Compass and Rudder'
      '9E=Waypoint Definition'
      'A1=Waypoint name'
      'A2=Waypoint Arrival'
      'A3=Rudder'
      'A4=ID discover devices'
      'A5=GPS Info'
      'A7=GPS unk'
      'A8=Alarm'
      'AC=Waypoint XTE')
    Sorted = True
    TabOrder = 13
    Visible = False
  end
  object LogListBox: TListBox
    Left = 176
    Top = 16
    Width = 121
    Height = 97
    ItemHeight = 13
    Items.Strings = (
      'IIGLL,5046.142,N,00122.747,W,105000,A,A*43'
      'SEATALK:10 01 00 4C '
      'SEATALK:26 04 8A 02 8A 02 D1 '
      'SEATALK:52 01 3B 00 '
      'SEATALK:53 90 22 '
      'SEATALK:9C 51 27 00 '
      'IIMTW,+17.5,C*3B'
      'IIMWV,038,R,20.7,N,A*1D'
      'IIMWV,057,T,15.6,N,A*15'
      'IIRMB,A,0.29,L,,WINMON  ,,,,,002.50,210,03.7,V,A*7E'
      'IIRMC,105000,A,5046.142,N,00122.747,W,06.0,158,030809,03,W,A*06'
      'SEATALK:82 05 9F 60 07 F8 FF 00 '
      'SEATALK:85 D6 01 CA A3 0F 17 00 '
      'SEATALK:E8 '
      'SEATALK:84 D6 66 9B 00 00 00 00 '
      'SEATALK:00 '
      'IIVHW,,,,,06.9,N,,*16'
      'IIVLW,02350,N,004.0,N*53'
      'IIVWR,037,R,20.2,N,,,,*65'
      'SEATALK:10 01 00 4A '
      'SEATALK:26 04 B2 02 B2 02 D1 '
      'SEATALK:52 01 3C 00 '
      'SEATALK:53 10 22 '
      'IIDPT,005.9,-1.0,*4C'
      'IIGLL,5046.141,N,00122.747,W,105001,A,A*41'
      'IIMTW,+17.5,C*3B'
      'IIMWV,037,R,20.2,N,A*17'
      'SEATALK:9C 91 25 00 '
      'IIMWV,054,T,15.8,N,A*18'
      'IIRMC,105001,A,5046.141,N,00122.747,W,06.0,158,030809,03,W,A*04'
      'SEATALK:82 05 9F 60 07 F8 FF 00 '
      'SEATALK:85 D6 01 CA A3 0F 17 00 '
      'SEATALK:E8 '
      'SEATALK:84 56 62 8A 00 00 00 00 '
      'SEATALK:00 '
      'IIVHW,,,,,06.9,N,,*16'
      'IIVLW,02350,N,004.0,N*53'
      'IIVWR,038,R,20.3,N,,,,*6B'
      'SEATALK:10 01 00 4C '
      'SEATALK:26 04 B2 02 B2 02 D1 '
      'SEATALK:52 01 3C 00 '
      'IIDPT,005.9,-1.0,*4C'
      'IIGLL,5046.138,N,00122.747,W,105002,A,A*4C'
      'IIMTW,+17.5,C*3B'
      'IIMWV,038,R,20.3,N,A*19'
      'SEATALK:53 10 22 '
      'SEATALK:9C D1 25 00 '
      'IIMWV,053,T,15.1,N,A*16'
      'IIRMB,A,0.29,L,,WINMON  ,,,,,002.50,210,05.7,V,A*78'
      'SEATALK:82 05 9F 60 07 F8 FF 00 '
      'SEATALK:85 D6 01 CA A3 0F 17 00 '
      'SEATALK:E8 '
      'SEATALK:84 16 64 92 00 00 00 00 '
      'SEATALK:00 '
      'IIRMB,A,0.00,L,,ALPHA   ,,,,,000.10,246,06.7,V,A*1D'
      'IIRMC,135427,A,5046.335,N,00117.967,W,06.8,258,030809,03,W,A*07'
      'SEATALK:82 05 11 EE FC 03 FF 00 '
      'SEATALK:85 06 00 4A A8 00 17 00 '
      'SEATALK:E8 '
      'SEATALK:84 26 AA A7 00 00 00 00 '
      'SEATALK:00 '
      'IIVHW,,,,,06.0,N,,*1F'
      'IIVLW,02368,N,022.2,N*5E'
      'IIVWR,038,L,16.3,N,,,,*70'
      'SEATALK:10 01 02 84 '
      'IIDPT,018.3,-1.0,*4A'
      'IIGLL,5046.334,N,00117.969,W,135428,A,A*49'
      'IIMTW,+18.0,C*31'
      'IIMWV,322,R,16.3,N,A*14'
      'SEATALK:26 04 58 02 58 02 D1 '
      'SEATALK:52 01 44 00 '
      'SEATALK:53 20 27 '
      'SEATALK:9C 61 2A 00 '
      'IIMWV,303,T,12.2,N,A*14'
      'IIRMC,135428,A,5046.334,N,00117.969,W,06.8,258,030809,03,W,A*07'
      'SEATALK:82 05 11 EE FC 03 FF 00 '
      'SEATALK:85 06 00 4A A8 00 17 00 '
      'SEATALK:E8 '
      'SEATALK:99 00 00 '
      'SEATALK:84 66 AA AB 00 00 00 00 '
      'SEATALK:00 '
      'IIVHW,,,,,06.3,N,,*1C'
      'IIVLW,02368,N,022.2,N*5E'
      'IIVWR,036,L,16.2,N,,,,*7F'
      'IIDPT,018.3,-1.0,*4A'
      'IIGLL,5046.334,N,00117.972,W,135429,A,A*42'
      'IIMTW,+18.0,C*31'
      'IIMWV,324,R,16.2,N,A*13'
      'SEATALK:10 01 02 88 '
      'SEATALK:26 04 76 02 76 02 D1 '
      'SEATALK:52 01 44 00 '
      'SEATALK:53 20 27 '
      'IIMWV,303,T,12.1,N,A*17'
      'IIRMB,A,0.01,L,,ALPHA   ,,,,,000.10,246,06.5,V,A*1E')
    TabOrder = 14
    Visible = False
  end
  object Panel1: TPanel
    Left = 513
    Top = 2
    Width = 329
    Height = 293
    Align = alRight
    TabOrder = 15
    object Decoded: TListBox
      Left = 1
      Top = 1
      Width = 327
      Height = 291
      Align = alClient
      ExtendedSelect = False
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 184
    Top = 2
    Width = 329
    Height = 293
    Align = alRight
    TabOrder = 16
    object Datagrams: TListBox
      Left = 1
      Top = 1
      Width = 327
      Height = 291
      Align = alClient
      ExtendedSelect = False
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object SeaTalk: TComPort
    BaudRate = br4800
    Port = 'COM1'
    Parity.Bits = prSpace
    Parity.Check = True
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evError]
    Buffer.InputSize = 2048
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    StoredProps = [spBasic, spParity]
    TriggersOnRxChar = True
    SyncMethod = smWindowSync
    OnError = SeaTalkError
    Left = 136
    Top = 32
  end
  object MainMenu1: TMainMenu
    Left = 128
    Top = 240
    object File1: TMenuItem
      Caption = '&File'
      object Openlog1: TMenuItem
        Caption = '&Open log...'
        OnClick = Openlog1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Play1: TMenuItem
        Caption = 'Play'
        ShortCut = 32848
        OnClick = Play1Click
      end
      object Stop1: TMenuItem
        Caption = 'Stop'
        OnClick = Stop1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Jump10001: TMenuItem
        Caption = 'Jump 1000'
        ShortCut = 32842
        OnClick = Jump10001Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        ShortCut = 32883
        OnClick = Exit1Click
      end
    end
    object Windows1: TMenuItem
      Caption = 'Windows'
      object RawSeatalk1: TMenuItem
        AutoCheck = True
        Caption = 'Raw Seatalk'
        Checked = True
        OnClick = RawSeatalk1Click
      end
      object DecodedSeatalk1: TMenuItem
        AutoCheck = True
        Caption = 'Decoded Seatalk'
        Checked = True
        OnClick = RawSeatalk1Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.log|*.log|*.txt|*.txt|*.*|*.*'
    Left = 96
    Top = 248
  end
  object PlayTimer: TTimer
    Enabled = False
    Interval = 300
    OnTimer = PlayTimerTimer
    Left = 96
    Top = 216
  end
end
