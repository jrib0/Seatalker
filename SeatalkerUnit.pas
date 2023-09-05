unit SeatalkerUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,strutils,
  Dialogs, StdCtrls,Buttons,genunit,odslogger,ExtCtrls,  CPort,CPortCtl;

type
  TSeatalkerForm = class(TForm)
    OpenPortButton: TButton;
    SendButton: TButton;
    Minus1: TButton;
    Plus1: TButton;
    Minues10: TButton;
    plus10: TButton;
    Standby: TBitBtn;
    Auto: TBitBtn;
    ClosePortButton: TButton;
    DatagramEdit: TEdit;
    LightsOnButton: TButton;
    LightsOffButton: TButton;
    SeaTalk: TComPort;
    ComComboBox1: TComComboBox;
    Datagrams: TListBox;
    STCommands: TListBox;
    Decoded: TListBox;
    ComLed1: TComLed;
    ComLed2: TComLed;
    procedure OpenPortButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SendButtonClick(Sender: TObject);
    procedure ClosePortButtonClick(Sender: TObject);
    procedure Minus1Click(Sender: TObject);
    procedure LightsOnButtonClick(Sender: TObject);
    procedure LightsOffButtonClick(Sender: TObject);
    procedure SeaTalkError(Sender: TObject; Errors: TComErrors);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
        remainder:string;
        remainderlength:integer;
        procedure senddatagram(datagram:string);
        procedure decodedatagramtext(Datagram:string);
    { Public declarations }
  end;

var
  SeatalkerForm: TSeatalkerForm;

implementation

{$R *.dfm}

procedure TSeatalkerForm.FormCreate(Sender: TObject);
begin
     remainderlength:=0;
     remainder:='';
end;

procedure TSeatalkerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     try
        seatalk.connected:=false;
     except
     end;
end;

Procedure TSeatalkerForm.Senddatagram(datagram:string);
var
   s,s1:string;
   b:byte;
begin
     //check to see if anything is waiting if it is process it first
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

procedure Tseatalkerform.decodedatagramtext(Datagram:string);
begin
     decoded.items.add(stcommands.items.Values[leftstr(datagram,2)]);
end;

procedure TSeatalkerForm.OpenPortButtonClick(Sender: TObject);
begin
     try
        seatalk.connected:=true;
        seatalk.Parity.bits:=prspace;
     except
     end;
end;

procedure TSeatalkerForm.SendButtonClick(Sender: TObject);
begin
     senddatagram(datagramedit.text);
end;

procedure TSeatalkerForm.ClosePortButtonClick(Sender: TObject);
begin
     try
        seatalk.connected:=false;
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
   i,recd:integer;
   ba:array[1..2049] of byte; //bigger than the input buffer
   s,s1:string;
   command,len:byte;
   completedcommand:boolean;
begin
     if errors=[ceRxParity] then
        begin
             sleep(15); //want to wait a little so that the buffer can fill the full datagram
             //longest datagram is D ie 13+3 bytes
             //at 4800 baud that would be 3.3ms but 20 seems to do the trick
             repeat
                   recd:=seatalk.inputcount;
                   if recd<2 then sleep(5);
             until recd>2;
             seatalk.Read(ba,recd);
             s:=remainder;
             for i:=1 to recd do
                 s:=s+inttohex(ba[i],2)+' ';
             recd:=recd+remainderlength;
             completedcommand:=false;
             repeat
                   command:=hextoint(copy(s,1,2));
                   len:=hextoint(copy(s,4,2))AND $F+3;
                   if len<recd then
                      begin
                           s1:=leftstr(s,len*3);
                           s:=rightstr(s,length(s)-len*3);
                           decodedatagramtext(s1);
                           Datagrams.Items.Add(s1);
                           recd:=recd-len;
                      end;
                   if len=recd then
                      begin
                           decodedatagramtext(s);
                           Datagrams.items.add(s);
                           completedcommand:=true;
                           remainder:='';
                           remainderlength:=0;
                      end;
                   if len>recd then
                      begin
                           remainder:=s;
                           remainderlength:=recd;
                           completedcommand:=true;
                      end;
             until completedcommand;

             while datagrams.Items.Count>100 do datagrams.items.delete(0);
             if datagrams.Items.count>0 then datagrams.selected[Datagrams.items.count-1]:=true;
             while decoded.Items.Count>100 do decoded.items.delete(0);
             if decoded.items.count>0 then decoded.selected[decoded.items.count-1]:=true;
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




sleep(15); //want to wait a little so that the buffer can fill the full datagram
             //longest datagram is D ie 13+3 bytes
             //at 4800 baud that would be 3.3ms but 20 seems to do the trick
             count:=seatalk.inputcount;
             if count>0 then //do we have any bytes waiting for us?
                begin
                     seatalk.Read(ba,count);
                     for i:=1 to count do
                         s:=s+inttohex(ba[i],2)+' ';
                     //we need to check to see if two messages have arrived at once or left overs
                     Datagrams.items.add(s);

                     //look up name of seatalk command
                     //s:=stcommands.items.Values[inttohex(ba[1],2)]+':';


                     while datagrams.Items.Count>100 do datagrams.items.delete(0);
                     Datagrams.selected[Datagrams.items.count-1]:=true;
