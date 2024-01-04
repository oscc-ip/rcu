# RCU

## Features
* Multiple clock source support
    * high-speed extern osc clock
    * low-speed extern osc clock
    * audio extern osc clock
* Programmable clock output
* 4 division clock of core generation
* Clock frequency configuration and core selection pin

## Build and Test
```bash
make comp    # compile code with vcs
make run     # compile and run test with vcs
make wave    # open fsdb format waveform with verdi
```