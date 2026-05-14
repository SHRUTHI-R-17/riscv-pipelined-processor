# 5-Stage Pipelined RISC-V Processor (RV32I+M)

A complete 32-bit RISC-V pipelined processor implemented in Verilog,
simulated in Vivado 2023.2 and taken to physical GDS layout using
OpenLane on the SkyWater 130nm PDK.

## Pipeline Architecture
IF → ID → EX → MEM → WB

## Features
- Full RV32I base instruction set
- 5-stage pipeline with pipeline registers
- Data hazard detection and stall generation
- Full data forwarding (MEM to EX, WB to EX)
- 2-bit saturating branch predictor
- Performance counter (CPI, stall cycles, branch count)
- UART transmitter (115200 baud)
- Direct-mapped L1 cache
- RV32M multiply extension
- Exception handler
- OpenLane GDS layout on SkyWater 130nm (0 DRC violations, LVS clean)

## Simulation Results (Fibonacci Program)
| Metric | Value |
|---|---|
| Total Cycles | 30 |
| Total Instructions | 15 |
| Stall Cycles | 0 |
| CPI | 1.93 |

## OpenLane Physical Design Results
| Check | Result |
|---|---|
| Magic DRC Violations | 0 |
| LVS | Clean |
| Flow Steps Completed | 42/42 |
| Die Area | 600 x 600 um |
| PDK | SkyWater 130nm |

## Tools Used
- Vivado 2023.2
- OpenLane v1.0.2
- KLayout 0.30.8
- SkyWater 130nm PDK
- Docker on WSL2 Ubuntu

## File Structure
- sources/ - All Verilog RTL source files
- testbench/ - Simulation testbenches
- gds/ - Final GDS chip layout file
- reports/ - Synthesis, timing and power reports

## About
Built independently as a 3rd year Electronics (VLSI) undergraduate
at RMK Engineering College. This project is typically undertaken
at Masters level in computer architecture programs.
