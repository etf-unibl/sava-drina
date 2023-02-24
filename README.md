# sava-drina
SAVA project (Drina team)

**Zadatak**

U okviru projektnog zadatka bilo je potrebno implementirati obradu audio odmjeraka u realnom vremenu korištenjem _Cyclone V_ čipa i Audio CODEC-a _Wolfson WM8731_ na DE1-SoC ploči. 

**Korišteni hardverski resursi**

- DE1-SoC ploča (FPGA, audio CODEC WM8731, periferije,..)
- Raspberry Pi 4

**Korišteni softverski resursi**

- _Quartus Prime_ alat i VHDL programski jezik
- _Python_ i _C_ programski jezici (za parametrizaciju CODEC-a preko RPi)

**Implementirane funkcionalnosti**

_Implementirano je:_
- I2S RX linija
- I2S TX linija
- parametrizacija audio CODEC-a korištenjem FPGA
- _loop-back_ (slanje audio odmjeraka sa ulaza audio CODEC-a _Line In_ na izlaz _Line Out_ u realnom vremenu)

_Nije završeno:_
- Parametrizacija audio CODEC-a korištenjem RPi
- Modulacija ulaznog signala 

_VUnit testovi:_

_VUnit_ testovima pokrivena je većina implementiranih funkcionalnosti. Pojedine funkcionalnosti su testirane standardnim _testbench_-evima.
