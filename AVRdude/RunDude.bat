@ECHO OFF
"E:\Lazarus\AVRDude GUI\avrdude\avrdude.exe" -Cavrdude.conf -v -patmega2560 -cwiring -PCOM8 -b115200 -D -Uflash:w:"E:\WizJob\Sindengen Deltamas\ESD Tester\AS7_ESDTester\Debug\AS7_ESDTester.hex":i
PAUSE
