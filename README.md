# Seatalker
A Delphi 7 implementation of a seatalk remote control.  I use the Tcomport library 4.11f originallyl by  Dejan Crnila
This uses the circuitry described by Thomas Knauf.
To simulate the 9-bit commands I set the mark and space parity bits.  It is set to mark for transmission of the command byte and then space for the other bytes.
For reception I wait for a parity error - which occurs when there is a byte received with the command bit set and the port is configured to space parity.  However there has to be a little messy coding to make it work reliably
