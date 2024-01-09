# RCU

<p>
    <a href=".">
      <img src="https://img.shields.io/badge/RTL%20dev-done-green?style=flat-square">
    </a>
    <a href=".">
      <img src="https://img.shields.io/badge/VCS%20sim-done-green?style=flat-square">
    </a>
    <a href=".">
      <img src="https://img.shields.io/badge/FPGA%20verif-no%20start-wheat?style=flat-square">
    </a>
    <a href=".">
      <img src="https://img.shields.io/badge/Tapeout%20test-no%20start-wheat?style=flat-square">
    </a>
</p>

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