@ECHO OFF
"E:\zTooPayZ GitHub\AVRDude GUI\avrdude\avrdude.exe" -Cavrdude.conf -v -pm328p -carduino -PCOM4 -b57600 -D -Uflash:w:"E:\#_2020 Project\PAYZ - Spider LowCost v1.0\AS-SpideyBot_4Leg\Debug\AS-SpideyBot_4Leg.hex":i
PAUSE
