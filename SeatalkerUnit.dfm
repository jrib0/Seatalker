object SeatalkerForm: TSeatalkerForm
  Left = 192
  Top = 152
  BorderStyle = bsDialog
  Caption = 'Seatalk Remote Control'
  ClientHeight = 287
  ClientWidth = 843
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
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
  object OpenPortButton: TButton
    Left = 8
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Open Port'
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
    Caption = 'Close Port'
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
  object LightsOnButton: TButton
    Left = 8
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Lights On'
    TabOrder = 8
    OnClick = LightsOnButtonClick
  end
  object LightsOffButton: TButton
    Left = 88
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Lights Off'
    TabOrder = 9
    OnClick = LightsOffButtonClick
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
  object Datagrams: TListBox
    Left = 168
    Top = 8
    Width = 329
    Height = 273
    ExtendedSelect = False
    ItemHeight = 13
    TabOrder = 13
  end
  object STCommands: TListBox
    Left = 416
    Top = 80
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
      '81=Config Course Computer #1'
      '82=Waypoint Name'
      '83=Course computer failure'
      '84=Heading Compass AP #1'
      '85=Navigation'
      '86=Key'
      '87=Config Set response level'
      '88=Config autopilot #1'
      '89=Heading Compass'
      '90=ID #2'
      '91=Rudder gain'
      '92=Config autopilot #2'
      '93=Config autopilot enter'
      '95=Heading Compass AP #2'
      '99=Heading var'
      '9A=Version'
      '9C=Heading Compass and Rudder'
      '9E=Waypoint Definition'
      'A1=Waypoint name'
      'A2=Waypoint Arrival'
      'A3=Rudder'
      'A4=ID discover devices'
      'A5=GPS info #1'
      'A7=GPS unk'
      'A8=Alarm'
      'AC=Waypoint XTE')
    Sorted = True
    TabOrder = 14
    Visible = False
  end
  object Decoded: TListBox
    Left = 504
    Top = 8
    Width = 329
    Height = 273
    ExtendedSelect = False
    ItemHeight = 13
    TabOrder = 15
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
end
