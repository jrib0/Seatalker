unit SeatalkUnit;

//(c) 2023 James Brown
//unit to decode and send Seatalk 1 sentences

interface

uses
  SysUtils,
  strutils,
  genunit,
  CPort,
  SDL_stringl;

  const
       STCommands:array[0..60] of string =(
          '00=Depth,5',
          '01=ID Power on,8',
          '05=Engine,6',
          '10=Wind Angle Apparent,10',
          '11=Wind Speed Apparent,10',
          '20=Log Speed #1,4',
          '21=Log Trip,5',
          '22=Log Total,5',
          '23=Water Temp #1,4',
          '24=Log Units,5',
          '25=Log Trip and Total,7',
          '26=Log Speed #2,7',
          '27=Water Temp #2,4',
          '30=Lamp #1,3',
          '36=MOB Cancel,3',
          '38=Codelock,4',
          '50=Position Lat,5',
          '51=Position Long,5',
          '52=SOG,4',
          '53=Heading COG,3',
          '54=Time,4',
          '55=Key GPS,4',
          '56=Date,4',
          '57=GPS sat info,3',
          '58=Position,8',
          '59=Timer set,5',
          '61=Initialisation E80,6',
          '65=Depth units Fathom,3',
          '66=Alarm Wind,3',
          '68=Alarm Ack,4',
          '6C=ID #1,8',
          '6E=MOB,10',
          '70=KEY ST60 Maxiview Remote,3',
          '80=Lamp #2,3',
          '81=Config Course Computer #1-3-4',
          '82=Waypoint Name,8',
          '83=Course computer failure,10',
          '84=Heading Compass AP #1-9',
          '85=Navigation,9',
          '86=Key,4',
          '87=Config Set response level,3',
          '88=Config Autopilot #1-6',
          '89=Heading Compass,5',
          '90=ID #2,5',
          '91=Rudder gain,3',
          '92=Config Autopilot #2-5',
          '93=Config Autopilot enter,3',
          '95=Heading Compass AP #2-9',
          '99=Heading Var,,3',
          '9A=Version,12',
          '9C=Heading Compass and Rudder,4',
          '9E=Waypoint Definition,15',
          'A1=Waypoint name,16',
          'A2=Waypoint Arrival,7',
          'A3=Rudder,5',
          'A4=ID discover devices,5-9',
          'A5=GPS Info,4-7-10-16',
          'A7=GPS unk,12',
          'A8=Alarm #1,6',
          'AB=Alarm #1,6',
          'AC=Waypoint XTE,5');

type
    tdatagram=record
        length,
        expectedlength:byte;
        bytes:array[0..19] of byte;
    end;

var
   remainder:string;
   remainderlength:integer;

function STDepth(var dg:tdatagram):string;//00
function STIDPoweron(var dg:tdatagram):string;//01
function STWindAngleApparent(var dg:tdatagram):string; //10;
function STWindSpeedApparent(var dg:tdatagram):string; //11;
function stlogspeed1(var dg:tdatagram):string; //20
function STLogTrip(var dg:tdatagram):string; //21
function STLogTotal(var dg:tdatagram):string; //22
function STLogUnits(var dg:tdatagram):string; //24
function STLogTripandTotal(var dg:tdatagram):string; //25
function stlogspeed2(var dg:tdatagram):string; //26
function stlamp(var dg:tdatagram):string; //30 & 80
function STSOG(var dg:tdatagram):string; //52
function STHeadingCOG(var dg:tdatagram):string; //53
function STID1(var dg:tdatagram):string; //6d
function STwaypointname(var dg:tdatagram):string; //82
function STHeadingCompassAP1(var dg:tdatagram):string; //84
function STNavigation(var dg:tdatagram):string; //85
function stkey(var dg:tdatagram):string; //86
function STHeadingVar(var dg:tdatagram):string;     //99
function STHeadingCompassandRudder(var dg:tdatagram):string;     //9C

function decodedatagramtext(Datagram:string):string;
Procedure Senddatagram(var seatalk:tcomport;datagram:string);
procedure STlookupcommand(datagram:string;var command:string;var expectedlength:byte);

implementation

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
   hdg:integer;
   turn:string;
begin
     hdg:=((dg.bytes[1] and $30)shr 4)*90;
     hdg:=hdg+(dg.bytes[2] AND $3F)*2;
     if (dg.bytes[1] and $40)=1 then inc(hdg);
     if dg.bytes[1]>127 then turn:='Right' else turn:='Left';
     result:=inttostr(hdg)+','+turn+','+inttostr(shortint(dg.bytes[3]));
end;

function decodedatagramtext(Datagram:string):string;
var
   dg:tdatagram;
   expectedlength:byte;
   count:integer;
   s:string;
begin
     //s:=stcommands.items.Values[leftstr(datagram,2)]+' :';
     STlookupcommand(leftstr(datagram,2),s,expectedlength);
     s:=s+' :';
     dg.length:=countwords(datagram);
     if dg.length>20 then dg.length:=20;
     for count:=0 to dg.length-1 do
         dg.bytes[count]:=hextoint(ExtractSubString(datagram,count,' '));
     //check we have the correct number of bytes
     if (dg.length<>(dg.bytes[1] and $F+3)) or //this checks what we have actually received and sees if it matches
     // this checks if it matches what the datagram should look like (because sometimes the above check can be wrong)
        (expectedlength>0) and (dg.length<>expectedlength) then s:=s+'Error incorrect number of bytes received'
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

Procedure Senddatagram(var seatalk:tcomport;datagram:string);
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

procedure STlookupcommand(datagram:string;var command:string;var expectedlength:byte);
var
   dg:string;
   count:integer;
begin
     dg:=datagram;
     expectedlength:=0;
     if length(dg)=1 then dg:='0'+dg;
     Command:='Unknown';
     for count:=0 to 59 do
         if copybefore('=',stcommands[count])=dg then Command:=copyafter('=',stcommands[count]);
     expectedlength:=strtointdef(copyafter(',',Command),0);
end;
end.
