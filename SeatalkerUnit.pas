unit SeatalkerUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Buttons,genunit,odslogger, ExtCtrls,  CPort,CPortCtl;

type
  TSeatalkerForm = class(TForm)
    PortsLabel: TLabel;
    OpenPortButton: TButton;
    SendButton: TButton;
    Minus1: TButton;
    Plus1: TButton;
    Minues10: TButton;
    plus10: TButton;
    Standby: TBitBtn;
    Auto: TBitBtn;
    CloseButton: TButton;
    DatagramEdit: TEdit;
    LightsOnButton: TButton;
    LightsOffButton: TButton;
    SeaTalk: TComPort;
    ComComboBox1: TComComboBox;
    Datagrams: TListBox;
    procedure OpenPortButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SendButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure Minus1Click(Sender: TObject);
    procedure LightsOnButtonClick(Sender: TObject);
    procedure LightsOffButtonClick(Sender: TObject);
    procedure SeaTalkError(Sender: TObject; Errors: TComErrors);
    procedure SeaTalkRxChar(Sender: TObject; Count: Integer);
  private
    { Private declarations }
  public
        procedure senddatagram(datagram:string);
    { Public declarations }
  end;

var
  SeatalkerForm: TSeatalkerForm;

implementation

{$R *.dfm}

Procedure TSeatalkerForm.Senddatagram(datagram:string);
var
   s,s1:string;
   b:byte;
begin
     s:=stringreplace(datagram,',',' ',[rfReplaceAll]);
     splitstring(' ',s+' ',s,s1);
     //send with command bit set
     seatalk.Parity.bits:=prmark;
     b:=hextoint(s);
     seatalk.write(b,1);
     sleep(20);
     //send anything else without command bit set
     seatalk.Parity.bits:=prspace;
     repeat
           splitstring(' ',s1,s,s1);
           b:=hextoint(s);
           seatalk.write(b,1);
           sleep(10);
     until pos(' ',s1)=0;
     sleep(50);
     //clearing the input buffer means we dont get our own command back
     seatalk.clearbuffer(true,false);
end;

procedure TSeatalkerForm.OpenPortButtonClick(Sender: TObject);
begin
     seatalk.connected:=true;
     seatalk.Parity.bits:=prspace;
end;

procedure TSeatalkerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     try
        seatalk.connected:=false;
     except
     end;
end;

procedure TSeatalkerForm.SendButtonClick(Sender: TObject);
begin
     senddatagram(datagramedit.text);
end;

procedure TSeatalkerForm.CloseButtonClick(Sender: TObject);
begin
     try
        seatalk.connected:=false;
        portslabel.Caption:='Port Closed';
     except

     end;
end;

procedure TSeatalkerForm.Minus1Click(Sender: TObject);
var
   tg:integer;
begin
       with sender as tbutton do tg:=tag;
       case tg of  1: Senddatagram('86 21 05 FA'); //- 1
                   2: Senddatagram('86 21 07 F8'); //+ 1
                  10: Senddatagram('86 21 06 F9'); //-10
                  11: Senddatagram('86 21 08 F7'); //+10
                  30: Senddatagram('86 21 02 FD'); //Standby
                  31: Senddatagram('86 21 01 FE'); //Auto
       end;
end;

procedure TSeatalkerForm.LightsOnButtonClick(Sender: TObject);
begin
     Senddatagram('30 00 0C');
end;

procedure TSeatalkerForm.LightsOffButtonClick(Sender: TObject);
begin
     Senddatagram('30 00 00');
end;

procedure TSeatalkerForm.SeaTalkError(Sender: TObject;  Errors: TComErrors);
var
   i,count:integer;
   b:byte;
   ba:array[1..100] of byte;
   s:string;
begin
     if errors=[ceRxParity] then
        begin
             odslogmessage('Command bit recd');
             sleep(20); //want to wait a little so that the buffer can fill the full datagram
             //longest datagram is D ie 13+3 bytes
             //at 4800 baud that would be 3.3ms but 20 seems to do the trick

             count:=seatalk.inputcount;
             if count>0 then
                begin
                     seatalk.Read(ba,count);
                     odslogmessage('input count',count);
                     s:='';
                     for i:=1 to count do
                         begin
                              //seatalk.Read(b,1);
                              odslogmessage('byte '+inttohex(ba[i],2));
                              s:=s+inttohex(ba[i],2)+' ';
                         end;
                     //need to check to see if two messages have arrived at once
                     Datagrams.items.add(s);
                end;
        end;
end;

procedure TSeatalkerForm.SeaTalkRxChar(Sender: TObject; Count: Integer);
var
   i:integer;
   b:byte;
begin
     odslogmessage('Waiting',count);
     for i:=1 to count do
         begin
              seatalk.Read(b,1);
              odslogmessage('byte '+inttohex(b,2));
         end;
end;

end.

//character frame
232
START 0- lsb ---- MSB - PAR- STOP +

ST
1  Start bit (0V)
8  Data Bits (least significant bit transmitted first)
1  Command bit, set on the first character of each datagram. Reflected in the parity bit of most UARTs. Not compatible with NMEA0183 but well suited for the multiprocessor communications mode of 8051-family microcontrollers (bit SM2 in SCON set).
1  Stop bit (+12V)

SO set parity to MARK for first byte
then SPACE for subsequent bytes


Date
56 81 04 05

Lights
30 00 0C
30 00 00


comport1.parity.Bits:=prmark;
     b:=$30;
     comport1.write(b,1);
     sleep(100);
     comport1.parity.Bits:=prspace;
     b:=$00;
     comport1.write(b,1);
     b:=$00;   //$C = full on
