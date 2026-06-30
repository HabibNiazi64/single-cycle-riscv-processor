\# Single Cycle RISC-V Processor for Tang Nano 9K



A 32-bit Single Cycle RISC-V (RV32I) processor implemented in Verilog and targeted for the Tang Nano 9K FPGA development board.



The project demonstrates the complete design flow of a simple RISC-V processor including instruction fetch, decode, execute, memory access, and write-back stages in a single clock cycle.



\---



\## Features



\- 32-bit RISC-V Single Cycle Processor

\- Verilog HDL implementation

\- RV32I instruction subset

\- Wishbone-based instruction and data memory

\- Register File

\- Arithmetic Logic Unit (ALU)

\- Immediate Generator

\- Branch Unit

\- Program Counter

\- C and Assembly test programs

\- Simulation support

\- FPGA implementation on Tang Nano 9K



\---



\## Repository Structure



```

rtl/            Verilog source files

tb/             Testbench

software/       C and Assembly programs

constraints/    FPGA constraint files

scripts/        Build scripts

docs/           Documentation

images/         Images and screenshots

```



\---



\## Hardware Platform



\- Tang Nano 9K FPGA

\- Gowin FPGA Toolchain



\---



\## Processor Components



\- Program Counter (PC)

\- Instruction Memory

\- Control Unit

\- Register File

\- Immediate Generator

\- ALU Control

\- Arithmetic Logic Unit

\- Branch Unit

\- Data Memory

\- Write Back Logic



\---



\## Supported Instruction Types



\- R-Type

\- I-Type

\- Load Instructions

\- Store Instructions

\- Branch Instructions

\- Jump Instructions



\---



\## Software



Example software includes



\- C programs

\- Assembly programs

\- Linker script

\- Memory initialization files



\---



\## Simulation



The processor can be simulated using the provided testbench.



Simulation produces waveform files for functional verification.



\---



\## FPGA Implementation



Target FPGA:



\- Tang Nano 9K



The generated memory image is loaded into instruction memory before programming the FPGA.



\---



\## Future Improvements



\- Five-stage pipeline implementation

\- Hazard Detection Unit

\- Data Forwarding

\- Branch Prediction

\- CSR Support

\- Interrupt Handling

\- RV32M Extension

\- UART Debug Interface



\---



\## Author



Habibullah

