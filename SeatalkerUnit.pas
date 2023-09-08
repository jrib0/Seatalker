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
  Dialogs, StdCtrls,Buttons,genunit,odslogger,ExtCtrls,  CPort,CPortCtl,SDL_stringl,
  Menus;

type
    tdatagram=record
        length:byte;
        bytes:array[0..19] of byte;
    end;
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
        remainder:string;
        playcount,remainderlength:integer;
        sendsimulateddata:boolean;
        procedure senddatagram(datagram:string);
        function decodedatagramtext(Datagram:string):string;
    { Public declarations }
  end;

var
  SeatalkerForm: TSeatalkerForm;

implementation

{$R *.dfm}
function STDepth(var dg:tdatagram):string;//00
begin
     result:=floattostr(((dg.bytes[4]*$100+dg.bytes[3])/10)/3.28084);      //converted to metres
end;

function STIDPoweron(var dg:tdatagram):string;//01
var
   id:int64;
begin
     id:=dg.bytes[7]+dg.bytes[6]*$100+dg.bytes[5]*$10000+dg.bytes[4]*$1000000+dg.bytes[3]*$100000000+dg.bytes[2]*$10000000000;
     result:=inttohex(id,10);
     if id=$4e1030280100 then result:='ST60 Multi';
     if id=$000000600100 then result:='Course Computer 400G';
     if id=$04BA20280100 then result:='ST60 Tridata';
     if id=$709910280100 then result:='ST60 Log';
     if id=$F31800260F06 then result:='ST80 Masterview';
     if id=$FA0300300703 then result:='ST80 Maxi Display';
     if id=$FFFFFFD00000 then result:='Smart Controller Remote Control Handset';
end;

function STWindAngleApparent(var dg:tdatagram):string; //10;
var
   waa:integer;
begin
     waa:=trunc((dg.bytes[2]*$100+dg.bytes[3])/2);
     if waa>180 then waa:=360-waa;
     result:=inttostr(waa);
end;

function STWindSpeedApparent(var dg:tdatagram):string; //11;
begin
     result:=floattostr(dg.bytes[2]+(dg.bytes[3] and $7f)/10);
end;

function stlogspeed1(var dg:tdatagram):string; //20
begin
     result:=floattostr((dg.bytes[3]*$100+dg.bytes[2])/10);
end;

function STLogTrip(var dg:tdatagram):string; //21
begin
     result:=floattostr((dg.bytes[4]*$10000+dg.bytes[3]*$100+dg.bytes[2])/100);
end;

function STLogTotal(var dg:tdatagram):string; //22
begin
     result:=floattostr((dg.bytes[4]*$10000+dg.bytes[3]*$100+dg.bytes[2])/10);
end;

function STLogUnits(var dg:tdatagram):string; //24
begin
     //Display units for Mileage & Speed XX: 00=nm/knots, 06=sm/mph, 86=km/kmh"
     result:='Knots';
     if dg.bytes[4]=6 then result:='SM';
     if dg.bytes[4]=86 then result:='KM';
end;

function STLogTripandTotal(var dg:tdatagram):string; //25
var
   total,trip:double;
begin
     total:=(dg.bytes[2]+dg.bytes[3]*256+(dg.bytes[1]shr 4)* 4096)/ 10;
     trip:=(dg.bytes[4]+dg.bytes[5]*256+(dg.bytes[6] and $F)*65536)/100;
     result:=floattostr(total)+','+floattostr(trip);
end;

function stlogspeed2(var dg:tdatagram):string; //26
begin
     result:=floattostr((dg.bytes[3]*$100+dg.bytes[2])/100);
     if dg.bytes[5]and 2<>2 then result:=result+'MPH';
end;

function stlamp(var dg:tdatagram):string; //30 & 80
begin
     case dg.bytes[2] of 0:result:='0';
                         4:result:='1';
                         8:result:='2';
                         $C:result:='3'
                         else result:='error';
     end;
end;

function STSOG(var dg:tdatagram):string; //52
begin
     result:=floattostr((dg.bytes[3]*$100+dg.bytes[2])/10);
end;

function STHeadingCOG(var dg:tdatagram):string; //53
var
   cog:double;
begin
     //cog:=((dg.bytes[1] and $30) shr 4)*90;
     //result:=floattostr(cog+(dg.bytes[2] and $3f)*2+(dg.bytes[1] and $3F) shr 6);
     cog:=((dg.bytes[1] and $30)shr 4)*90;
     cog:=cog+(dg.bytes[2] AND $3F)*2;
     cog:=cog+(dg.bytes[1] shr 6)/2;
     result:=floattostr(cog)
end;

function STID1(var dg:tdatagram):string; //6d
var
   id:int64;
begin
     id:=dg.bytes[7]+dg.bytes[6]*$100+dg.bytes[5]*$10000+dg.bytes[4]*$1000000+dg.bytes[3]*$100000000+dg.bytes[2]*$10000000000;
     result:=inttohex(id,10);
     if id=$4e1030284131 then result:='ST60 Multi';
     if id=$04BA20282d2d then result:='ST60 Tridata';
     if id=$05709910282D then result:='ST60 Log';
     if id=$F31800262d2d then result:='ST80 Masterview';
end;

function STwaypointname(var dg:tdatagram):string; //82
var
   ch:char;
begin
     result:='';
     ch:=chr((dg.bytes[2] and $3f)+$30);
     if ch<='Z' then result:=ch;
     ch:=chr((((dg.bytes[4] and $F)*4)+(dg.bytes[2] and $C0) shr 6)+$30);
     if ch<='Z' then result:=result+ch;
     ch:=chr((((dg.bytes[6] and $3)*16)+(dg.bytes[4] and $f0) shr 4)+$30);
     if ch<='Z' then result:=result+ch;
     ch:=chr(((dg.bytes[6] and $FC) shr 2)+$30);
     if ch<='Z' then result:=result+ch;
end;

function STHeadingCompassAP1(var dg:tdatagram):string; //84
var
   hdg:integer;
begin
     hdg:=((dg.bytes[1] and $30)shr 4)*90;
     hdg:=hdg+(dg.bytes[2] AND $3F)*2;
     if (dg.bytes[1] and $40)=1 then inc(hdg);
     result:=inttostr(hdg)
end;

function STNavigation(var dg:tdatagram):string; //85
var
   temp:double;
begin
     temp:=(dg.bytes[3] and 3)*90;
     temp:=temp+(((dg.bytes[4] and $f)shl 4)+((dg.bytes[3] and $C0)shr 4) )shr 1;
     result:=floattostr(temp);
     if dg.bytes[3] and 8<>0 then result:=result+'M'
        else result:=result+'T';
     //Distance to destination: Distance 0-9.99nm: ZZZ/100nm, Y & 1 = 1
     //                         Distance >=10.0nm: ZZZ/10 nm, Y & 1 = 0
     temp:=((dg.bytes[4] and $F0) shr 4) + (dg.bytes[5] shl 4);
     if dg.bytes[6] and 1=1 then temp:=temp/100 else temp:=temp/10;
     result:=result+','+floattostr(temp);
     //xte
     result:=result+','+floattostr((dg.bytes[1] shr 4+dg.bytes[2] shl 4)/100);
end;

function stkey(var dg:tdatagram):string; //86
var
   button:integer;
begin
     result:='error';
     if dg.bytes[1] and 15<>1 then exit;
     button:=(dg.bytes[2] shl 8) + dg.bytes[3];
     result:='unrecognised '+inttohex(button,4);
     case button of $01fe :result:='Auto';
                    $02FD :result:='Standby';
                    $03FC :result:='Track';
                    $04FB :result:='Disp';  //disp (in display mode or page in auto chapter = advance)
                    $05FA :result:='-1';//-1 (in auto mode)
                    $06F9 :result:='-10';//-10 (in auto mode)
                    $07F8 :result:='+1';//+1 (in auto mode)
                    $08F7 :result:='+10' ;//+10 (in auto mode)
                    $09F6 :result:='-1 resp mode';//-1 (in resp or rudder gain mode)
                    $0AF5 :result:='+1 resp mode' ;//+1 (in resp or rudder gain mode)
                    $21DE :result:='-1 & -10';//-1 & -10 (port tack, doesn´t work on ST600R?)
                    $22DD :result:='+1 & +10';//+1 & +10 (stb tack)
                    $23DC :result:='Standby & Auto';
                    $28D7 :result:='+10 & -10';
                    $2ED1 :result:='+1 & -1 Response display';
                    $41BE :result:='Auto long';
                    $42BD :result:='Standby long';
                    $43BC :result:='Track long';
                    $44BB :result:='Displ long';
                    $45BA :result:='-1 long';
                    $46B9 :result:='-10 long';
                    $47b8 :result:='+1 long';
                    $48b7 :result:='-10 long';
                    $639c :result:='Standby & Auto Long';
                    $6897 :result:='+10 & -10 long';
                    $6e91 :result:='+1 & -1 long';
                    $807F :result:='-1 long repeat';//-1 pressed (repeated 1x per second)
                    $817E :result:='-1 long repeat';//+1 pressed (repeated 1x per second)
                    $827D :result:='-10 long repeat';  //-10 pressed (repeated 1x per second)
                    $837C :result:='+10 long repeat';  //+10 pressed (repeated 1x per second)
                    $847b :result:='Numeric released';
     end;
end;

function STHeadingVar(var dg:tdatagram):string;     //99
var
   variation:integer;
begin
     variation:=dg.bytes[2];
     //need to do correction for east west +ve for west -ve for east
     if variation>128 then variation:=-($FF-variation);
     result:=inttostr(variation);
end;

function STHeadingCompassandRudder(var dg:tdatagram):string;     //9C
var
   b:byte;
   hdg:integer;
   turn:string;
begin
     {9c Heading Compass and Rudder	"Compass heading and Rudder position (see also command 84)
     Compass heading in degrees:
     (U & 0x3)* 90 + (VW & 0x3F)* 2 + (U & 0x4 ? 1 : 0) (VW & 0x3F) gives 2 deg resolution
     (U & 0x4) gives 1 deg. Total resolution: 1deg
     (U & 0x8): turn bit
     Turning direction:
     Most significant bit of U = 1: Increasing heading, Ship turns right
     Most significant bit of U = 0: Decreasing heading, Ship turns left
     Rudder position: RR degrees (positive values steer right, negative values steer left. Example: 0xFE = 2° left)
     The rudder angle bar on the ST600R uses this record"}


     hdg:=((dg.bytes[1] and $30)shr 4)*90;
     hdg:=hdg+(dg.bytes[2] AND $3F)*2;
     if (dg.bytes[1] and $40)=1 then inc(hdg);

     {b:=dg.bytes[1] shr 4;
     HDG:=90*(b AND 3);
     b:=b shr 2;
     if b=1 then inc(HDG);
     if b=3 then inc(HDG,2);
     b:=dg.bytes[2] AND $3F;
     HDG:=HDG+b*2;}
     if dg.bytes[1]>127 then turn:='Right' else turn:='Left';
     result:=inttostr(hdg)+','+turn+','+inttostr(shortint(dg.bytes[3]));
end;

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

Procedure TSeatalkerForm.Senddatagram(datagram:string);
var
   s,s1:string;
   b:byte;
begin
     seatalk.Events:=[]; //turn off the event for command bit received
     remainderlength:=0; //clear internal buffer of left over bytes not yet processed
     remainder:='';
     //check to see if anything is waiting if it is process it first
     while seatalk.inputcount<>0 do
        begin
             seatalk.clearbuffer(true,false);
             sleep(11);  //wait a little time to allow bus to settle
        end;
     s:=stringreplace(datagram,',',' ',[rfReplaceAll]); //incase we have commas rather than spaces between bytes
     split_string(' ',s+' ',s,s1);
     //send with command bit set
     seatalk.Parity.bits:=prmark;
     b:=hextoint(s);
     seatalk.write(b,1);
     sleep(20);//need a little pause
     //send anything else without command bit set
     seatalk.Parity.bits:=prspace;
     repeat
           split_string(' ',s1,s,s1);
           b:=hextoint(s);
           seatalk.write(b,1);
           sleep(10); //another little pause
     until pos(' ',s1)=0;
     sleep(50);
     //clearing the input buffer means we dont get our own command back
     seatalk.clearbuffer(true,false);
     //turn event back on
     seatalk.Events:=[everror];
end;

function Tseatalkerform.decodedatagramtext(Datagram:string):string;
var
   dg:tdatagram;
   count:integer;
   s:string;
begin
     s:=stcommands.items.Values[leftstr(datagram,2)]+' :';
     dg.length:=countwords(datagram);
     if dg.length>20 then dg.length:=20;
     for count:=0 to dg.length-1 do
         dg.bytes[count]:=hextoint(ExtractSubString(datagram,count,' '));
     //check we have the correct number of bytes
     if dg.length<>dg.bytes[1] and $F+3 then s:=s+'Error incorrect number of bytes received'
     else
     case dg.bytes[0] of
          $00:s:=s+STDepth(dg);
          $01:s:=s+STIDPoweron(dg);
          $10:s:=s+STWindAngleApparent(dg);
          $11:s:=s+STWindSpeedApparent(dg);
          $20:s:=s+STLogSpeed1(dg);
          $21:s:=s+STLogTrip(dg);
          $22:s:=s+STLogTotal(dg);
          //$23:Water Temp #1
          $24:s:=s+STLogUnits(dg);
          $25:s:=s+STLogTripandTotal(dg);
          $26:s:=s+STLogSpeed2(dg);
          //$27:Water Temp #2
          $30:s:=s+STlamp(dg);//Lamp #1
          //$36:MOB Cancel
          //$38:Codelock
          //$5:Engine
          //$50:Position Lat
          //$51:Position Long
          $52:s:=s+STSOG(dg);
          $53:s:=s+STHeadingCOG(dg);
          //$54:Time
          //$55:Key GPS
          //$56:Date
          //$57:GPS sat info
          //$58:Position
          //$59:Timer set
          //$61:Initialisation E80
          //$65:Depth units Fathom
          //$66:Alarm Wind
          //$68:Alarm Ack
          $6C:s:=s+STID1(dg);
          //$6E:MOB
          //$70:KEY ST60 Maxiview Remote
          $80:s:=s+STlamp(dg);//Lamp #2
          //$81:Config Course Computer #1
          $82:s:=s+STWaypointName(dg);
          //$83:Course computer failure
          $84:s:=s+STHeadingCompassAP1(dg);//Heading Compass AP #1
          $85:s:=s+STNavigation(dg);
          $86:s:=s+STKey(dg);
          //$87:Config Set response level
          //$88:Config autopilot #1
          //$89:Heading Compass
          //$90:ID #2
          //$91:Rudder gain
          //$92:Config autopilot #2
          //$93:Config autopilot enter
          //$95:Heading Compass AP #2
          $99:s:=s+STHeadingvar(dg);
          //$9A:Version
          $9C:s:=s+STHeadingCompassandRudder(dg);//Heading Compass and Rudder
          //$9E:Waypoint Definition
          //$A1:Waypoint name
          //$A2:Waypoint Arrival
          //$A3:Rudder
          //$A4:ID discover devices
          //$A5:GPS info #1
          //$A7:GPS unk
          //$A8:Alarm
          //$AC:Waypoint XTE
     end;
     result:=s;
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
     if seatalk.connected then
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
end;

procedure TSeatalkerForm.LampOnButtonClick(Sender: TObject);
begin
     Senddatagram('30 00 0C');
end;

procedure TSeatalkerForm.LampOffButtonClick(Sender: TObject);
begin
     Senddatagram('30 00 00');
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
                           if seatalk.connected and sendsimulateddata then senddatagram(s1);
                           Datagrams.Items.Add(s1);//display datagram
                           //add line here to send as $STALK
                           recd:=recd-len;
                      end;
                   if len=recd then //we have whole datagram so clear everything and exit this loop
                      begin
                           decoded.items.add(decodedatagramtext(s)); //decode
                           Datagrams.items.add(s);//display datagram
                           if seatalk.connected and sendsimulateddata then senddatagram(s);
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
