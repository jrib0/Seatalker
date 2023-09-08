# Seatalker
A Delphi 7 implementation of a seatalk remote control.  I use the Tcomport library 4.11f originallyl by  Dejan Crnila

This uses the circuitry and datagrams described by Thomas Knauf, thank you!

To simulate the 9-bit commands I set the mark and space parity bits.  It is set to mark for transmission of the command byte and then space for the other bytes.

For reception I wait for a parity error - which occurs when there is a byte received with the command bit set and the port is configured to space parity.  Some of the code is a little messy to make it work reliably.

Any of the following values are valid for the log file, including the NMEA command STALK which is used by some SEATALK to NMEA converters

SEATALK:01 02 0A

SEATALK:01,02,0A

$STALK,01,02,0A*FF

STALK,01,02,0A*FF (the checksum is not required)
