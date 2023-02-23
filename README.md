# sava-drina
SAVA project (Drina team)

**Zadatak**

U okviru projektnog zadatka bilo je potrebno implementirati obradu audio odmjeraka u realnom vremenu korištenjem _Cyclone V_ čipa i Audio CODEC-a _Wolfson WM8731_ na DE1-SoC ploči. 

**Korišteni hardverski resursi**

- DE1-SoC ploča (FPGA, audio CODEC WM8731, periferije,..)
- Raspberry Pi 4

**Implementirane funkcionalnosti**

_Implementirano je:_
- I2S RX linija
- I2S TX linija
- parametrizacija audio CODEC-a korištenjem FPGA
- _loop-back_ (slanje audio odmjeraka sa ulaza audio CODEC-a _Line In_ na izlaz _Line Out_ u realnom vremenu)

_Nije završeno:_
- Parametrizacija audio CODEC-a korištenjem RPi
- Modulacija ulaznog signala 
