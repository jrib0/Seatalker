unit SeatalkerUnit;

//(c) 2023 James Brown

{character frame
232
START 0- lsb ---- MSB - PAR- STOP +

ST
1  Start bit (0V)
8  Data Bits (least significant bit transmitted first)
1  Command bit, set on the first character of each datagram. Reflected in the parity bit of most UARTs. Not compatible with NMEA0183 but well suited for the multiprocessor communications mode of 8051-family microcontrollers (bit SM2 in SCON set).
1  Stop bit (+12V)

SO set parity to MARK for first byte
then SPACE for subsequent bytes}


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,strutils,
  Dialogs, StdCtrls,Buttons,genunit,ExtCtrls,  CPort,CPortCtl,
  Menus,seatalkunit;

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
    LampOnButton: TButton;
    LampOffButton: TButton;
    SeaTalk: TComPort;
    ComComboBox1: TComComboBox;
    STCommands: TListBox;
    ComLed1: TComLed;
    ComLed2: TComLed;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Openlog1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Bevel1: TBevel;
    OpenDialog1: TOpenDialog;
    LogListBox: TListBox;
    Play1: TMenuItem;
    Stop1: TMenuItem;
    PlayTimer: TTimer;
    N2: TMenuItem;
    Jump10001: TMenuItem;
    N3: TMenuItem;
    Panel1: TPanel;
    Decoded: TListBox;
    Panel2: TPanel;
    Datagrams: TListBox;
    Windows1: TMenuItem;
    RawSeatalk1: TMenuItem;
    DecodedSeatalk1: TMenuItem;
    procedure OpenPortButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SendButtonClick(Sender: TObject);
    procedure ClosePortButtonClick(Sender: TObject);
    procedure Minus1Click(Sender: TObject);
    procedure LampOnButtonClick(Sender: TObject);
    procedure LampOffButtonClick(Sender: TObject);
    procedure SeaTalkError(Sender: TObject; Errors: TComErrors);
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Openlog1Click(Sender: TObject);
    procedure Play1Click(Sender: TObject);
    procedure Stop1Click(Sender: TObject);
    procedure PlayTimerTimer(Sender: TObject);
    procedure Jump10001Click(Sender: TObject);
    procedure RawSeatalk1Click(Sender: TObject);
  private
    { Private declarations }
  public
        playcount:integer;
        sendsimulateddata:boolean;
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
     sendsimulateddata:=false;
end;

procedure TSeatalkerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     try
        seatalk.connected:=false;
     except
     end;
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
     senddatagram(seatalk,datagramedit.text);
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
     if seatalk.connected then
        begin
             with sender as tbutton do tg:=tag;
                  case tg of  1: Senddatagram(seatalk,'86 21 05 FA'); //- 1
                              2: Senddatagram(seatalk,'86 21 07 F8'); //+ 1
                             10: Senddatagram(seatalk,'86 21 06 F9'); //-10
                             11: Senddatagram(seatalk,'86 21 08 F7'); //+10
                             30: Senddatagram(seatalk,'86 21 02 FD'); //Standby
                             31: Senddatagram(seatalk,'86 21 01 FE'); //Auto
                  end;
        end;
end;

procedure TSeatalkerForm.LampOnButtonClick(Sender: TObject);
begin
     Senddatagram(seatalk,'30 00 0C');
end;

procedure TSeatalkerForm.LampOffButtonClick(Sender: TObject);
begin
     Senddatagram(seatalk,'30 00 00');
end;

procedure TSeatalkerForm.SeaTalkError(Sender: TObject;  Errors: TComErrors);
var
   i,recd:integer;
   ba:array[1..2049] of byte; //bigger than the input buffer
   s,s1:string;
   len:byte;
   completedcommand:boolean;
begin
     recd:=0;
     if errors=[ceRxParity] then
        begin
             if not playtimer.enabled then
                begin
                     sleep(6); //want to wait a little so that the buffer can fill the full datagram
                     //longest datagram is D ie 13+3 bytes
                     //at 4800 baud that would be 3.3ms but 20 seems to do the trick
                     repeat //wait until we have at least 3 bytes (smallest command)
                            recd:=seatalk.inputcount;
                            if recd<2 then sleep(5);
                     until recd>2;
                     seatalk.Read(ba,recd);
                end; //if playback then we shall find the data in remainder
             s:=remainder; //push remainder into s
             for i:=1 to recd do //turn to string
                 s:=s+inttohex(ba[i],2)+' ';
             recd:=recd+remainderlength; //add reaminder length
             completedcommand:=false; //to indicate when we have done all we can
             repeat
                   len:=hextoint(copy(s,4,2))AND $F+3;//extract length of command from attribute byte
                   if len<recd then
                      begin
                           s1:=leftstr(s,len*3); //pull the first command
                           s:=rightstr(s,length(s)-len*3);
                           decoded.items.add(decodedatagramtext(s1)); //decode
                           if seatalk.connected and sendsimulateddata then senddatagram(seatalk,s1);
                           Datagrams.Items.Add(s1);//display datagram
                           //add line here to send as $STALK
                           recd:=recd-len;
                      end;
                   if len=recd then //we have whole datagram so clear everything and exit this loop
                      begin
                           decoded.items.add(decodedatagramtext(s)); //decode
                           Datagrams.items.add(s);//display datagram
                           if seatalk.connected and sendsimulateddata then senddatagram(seatalk,s);
                           //add line here to send as $STALK
                           completedcommand:=true;
                           remainder:='';
                           remainderlength:=0;
                      end;
                   if len>recd then
                      begin
                           remainder:=s; //we only have a remainder
                           remainderlength:=recd;
                           completedcommand:=true;
                      end;
             until completedcommand;

             //tidy up the listboxes
             while datagrams.Items.Count>100 do datagrams.items.delete(0);
             if datagrams.Items.count>0 then datagrams.selected[Datagrams.items.count-1]:=true;
             while decoded.Items.Count>100 do decoded.items.delete(0);
             if decoded.items.count>0 then decoded.selected[decoded.items.count-1]:=true;
        end;
end;

procedure TSeatalkerForm.Exit1Click(Sender: TObject);
begin
     close;
end;

procedure TSeatalkerForm.Openlog1Click(Sender: TObject);
begin
     playtimer.enabled:=false;
     If opendialog1.execute then
        begin
             remainder:='';
             remainderlength:=0;
             loglistbox.Items.loadfromfile(opendialog1.filename);
        end;
end;

procedure TSeatalkerForm.Play1Click(Sender: TObject);
begin
     Playtimer.enabled:=true;
end;

procedure TSeatalkerForm.Stop1Click(Sender: TObject);
begin
     Playtimer.enabled:=false;
end;

procedure TSeatalkerForm.PlayTimerTimer(Sender: TObject);
var
   s:string;
begin
     if loglistbox.items.count=0 then exit;
     if playcount>=loglistbox.items.count-1 then playcount:=0;
     s:=loglistbox.items[playcount];
     //do something here for $STALK NMEA
     if pos('$STALK,',s)=1 then
        begin
             s:=copyafter(',',s);
             s:=copybefore('*',s);
             s:='SEATALK:'+s;
        end;
     while pos('SEATALK:',s)=0 do
           begin
                inc(playcount);
                if playcount>=loglistbox.items.count-1 then playcount:=0;
                s:=loglistbox.items[playcount];
           end;

     remainder:=remainder+copyafter(':',s);
     remainderlength:=remainderlength+trunc(length(copyafter(':',loglistbox.items[playcount]))/3);
     sendsimulateddata:=true;
     SeaTalkError(Sender,[cerxparity]);
     sendsimulateddata:=false;
     inc(playcount);
end;

procedure TSeatalkerForm.Jump10001Click(Sender: TObject);
begin
     inc(playcount,1000);
     remainder:='';
     remainderlength:=0;
end;

procedure TSeatalkerForm.RawSeatalk1Click(Sender: TObject);
begin
     panel2.visible:=rawseatalk1.Checked;
     panel1.visible:=decodedseatalk1.Checked;
     width:=529;
     if panel1.visible and panel2.visible then width:=858;
     if not panel1.visible and not panel2.visible then width:=188;
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
