object SeatalkerForm: TSeatalkerForm
  Left = 192
  Top = 152
  BorderStyle = bsDialog
  Caption = 'Seatalk Remote Control'
  ClientHeight = 266
  ClientWidth = 652
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object PortsLabel: TLabel
    Left = 8
    Top = 237
    Width = 20
    Height = 13
    Caption = 'N/A'
    Transparent = False
  end
  object OpenPortButton: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Open Port'
    TabOrder = 0
    OnClick = OpenPortButtonClick
  end
  object SendButton: TButton
    Left = 8
    Top = 168
    Width = 75
    Height = 25
    Caption = 'Send'
    TabOrder = 10
    OnClick = SendButtonClick
  end
  object Minus1: TButton
    Tag = 1
    Left = 8
    Top = 40
    Width = 75
    Height = 25
    Caption = '-1'
    TabOrder = 2
    OnClick = Minus1Click
  end
  object Plus1: TButton
    Tag = 2
    Left = 88
    Top = 40
    Width = 75
    Height = 25
    Caption = '+1'
    TabOrder = 3
    OnClick = Minus1Click
  end
  object Minues10: TButton
    Tag = 10
    Left = 8
    Top = 72
    Width = 75
    Height = 25
    Caption = '-10'
    TabOrder = 4
    OnClick = Minus1Click
  end
  object plus10: TButton
    Tag = 11
    Left = 88
    Top = 72
    Width = 75
    Height = 25
    Caption = '+10'
    TabOrder = 5
    OnClick = Minus1Click
  end
  object Standby: TBitBtn
    Tag = 30
    Left = 8
    Top = 104
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
    Top = 104
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
  object CloseButton: TButton
    Left = 8
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Close Port'
    TabOrder = 12
    OnClick = CloseButtonClick
  end
  object DatagramEdit: TEdit
    Left = 88
    Top = 168
    Width = 201
    Height = 21
    TabOrder = 11
    Text = '30 00 0C'
  end
  object LightsOnButton: TButton
    Left = 8
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Lights On'
    TabOrder = 8
    OnClick = LightsOnButtonClick
  end
  object LightsOffButton: TButton
    Left = 88
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Lights Off'
    TabOrder = 9
    OnClick = LightsOffButtonClick
  end
  object ComComboBox1: TComComboBox
    Left = 88
    Top = 8
    Width = 201
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
    Left = 296
    Top = 8
    Width = 329
    Height = 249
    ItemHeight = 13
    TabOrder = 13
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
    OnRxChar = SeaTalkRxChar
    OnError = SeaTalkError
    Left = 200
    Top = 88
  end
end
