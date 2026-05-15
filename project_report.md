# Project Report
# 5-Stage Pipelined RISC-V Processor with Physical Design

Name: Shruthi R
College: RMK Engineering College
Department: Electronics Engineering (VLSI Design and Technology)
Year: 3rd Year
Date: May 2026

---

## 1. Introduction

This project implements a complete 5-stage pipelined RISC-V processor
in Verilog HDL and takes it through the full VLSI design flow from
RTL simulation to physical GDS chip layout. The processor implements
the RV32I base integer instruction set with RV32M multiply extension.

The motivation for this project is to demonstrate practical knowledge
of computer architecture and VLSI design at a level beyond typical
undergraduate coursework.

---

## 2. Objectives

- Design a correct 5-stage pipelined RISC-V processor in Verilog
- Handle all data and control hazards automatically
- Verify correctness through cycle-accurate simulation
- Add advanced features including cache, UART, and branch prediction
- Complete the physical design flow using open-source EDA tools
- Produce a DRC clean, LVS verified GDS chip layout

---

## 3. System Architecture

### 3.1 Pipeline Stages

The processor uses a classic 5-stage pipeline:

Stage 1 IF — Instruction Fetch
  The program counter addresses the instruction memory.
  The fetched instruction and PC+4 are stored in the IF/ID register.

Stage 2 ID — Instruction Decode
  The instruction is decoded. Register file is read.
  Immediate values are sign-extended. Control signals are generated.
  Results stored in ID/EX pipeline register.

Stage 3 EX — Execute
  The ALU performs the required operation.
  Branch target address is computed.
  Forwarding muxes select correct operand values.
  Results stored in EX/MEM pipeline register.

Stage 4 MEM — Memory Access
  Data memory is read for load instructions.
  Data memory is written for store instructions.
  Branch decision is finalized.
  Results stored in MEM/WB pipeline register.

Stage 5 WB — Write Back
  ALU result or memory data is written back to register file.
  Register file write happens in first half of clock cycle.
  Register file read happens in second half to avoid hazard.

### 3.2 Hazard Handling

Data Hazard — When an instruction needs a result that has not yet
been written back, the forwarding unit bypasses the result directly
from the EX/MEM or MEM/WB pipeline register to the ALU input.

Load-Use Hazard — When a load instruction is immediately followed
by an instruction that uses the loaded value, the hazard unit inserts
one stall cycle to allow the load to complete.

Control Hazard — When a branch is taken, the two instructions that
were fetched after the branch are invalid. The pipeline is flushed
by clearing the IF/ID and ID/EX pipeline registers.

---

## 4. Implementation Details

### 4.1 Modules

Total modules implemented: 23
Total lines of Verilog: approximately 1200
Testbenches written: 11

### 4.2 Instruction Set Support

R-type: ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA
I-type: ADDI, ANDI, ORI, SLTI, SLLI, SRLI, SRAI
Load:   LW, LH, LB
Store:  SW, SH, SB
Branch: BEQ, BNE, BLT, BGE, BLTU, BGEU
RV32M:  MUL, MULH, MULHU, MULHSU

### 4.3 Branch Predictor

A 2-bit saturating counter predictor was implemented.
The predictor has four states:
  00 — Strongly not taken
  01 — Weakly not taken
  10 — Weakly taken
  11 — Strongly taken

The prediction is based on the MSB of the state register.
After each branch, the state transitions based on actual outcome.
This allows the predictor to learn repeated branch patterns.

### 4.4 Cache

A direct-mapped L1 cache with 16 cache lines was implemented.
Each line stores a valid bit, a 28-bit tag, and 32-bit data.
On a hit, data is returned in the same cycle.
On a miss, the cache is updated with the new data.
Hit rate statistics are tracked and reported.

---

## 5. Simulation Results

### 5.1 Test Program

A Fibonacci sequence program was used to verify processor correctness.
The program uses ADDI and ADD instructions and exercises the register
file, ALU, pipeline registers, and forwarding unit.

### 5.2 Results

Total Cycles:       30
Total Instructions: 15
Stall Cycles:       0
CPI:                1.93
Branch Count:       0

The forwarding unit successfully eliminated all data hazards.
Zero stall cycles were needed for this program.
All register values matched expected Fibonacci sequence values.

---

## 6. Physical Design

### 6.1 Synthesis

The RTL was synthesized using Yosys, part of the OpenLane flow.
The synthesis mapped Verilog to sky130_fd_sc_hd standard cells.
The synthesized netlist was verified to be functionally equivalent
to the RTL through logical equivalence checking.

### 6.2 Floorplan

Die area was set to 600 x 600 micrometers.
Core utilization was set to 45 percent.
Power rings and stripes were added for power distribution.

### 6.3 Placement

Standard cells were placed within the core area.
Target placement density was 40 percent to allow routing space.
The placement was optimized for timing and wire length.

### 6.4 Clock Tree Synthesis

A balanced clock tree was built to distribute the clock signal
with minimal skew to all sequential elements in the design.

### 6.5 Routing

All signal and power nets were routed using TritonRoute.
The router completed all connections with zero unrouted nets.

### 6.6 Sign-off Checks

DRC Violations: 0
LVS Status: Clean
The design passed all manufacturing design rule checks.
The layout was verified to match the post-synthesis netlist.

---

## 7. Tools Used

Vivado 2023.2    — RTL simulation and FPGA synthesis
OpenLane v1.0.2  — Complete physical design flow
Yosys            — Logic synthesis
OpenROAD         — Placement and routing
Magic VLSI       — DRC verification
Netgen           — LVS verification
KLayout 0.30.8   — GDS layout viewing
SkyWater 130nm   — Target process design kit
Docker + WSL2    — OpenLane container environment

---

## 8. Conclusion

A complete 5-stage pipelined RISC-V processor was successfully
designed, verified, and taken to physical chip layout.

The key achievements are:

1. Functional pipelined processor verified through simulation
2. All hazards handled automatically through hardware
3. Advanced features added including cache, UART, and branch prediction
4. Physical design completed with 0 DRC violations
5. LVS verified layout ready for potential tape-out

This project demonstrates a level of chip design capability typically
expected at Masters level, covering the full VLSI design flow from
RTL to GDS.

---

## 9. References

1. Patterson and Hennessy, Computer Organization and Design RISC-V Edition
2. RISC-V Instruction Set Manual, Volume I, Version 20191213
3. SkyWater SKY130 PDK Documentation
4. OpenLane Documentation, Efabless Corporation
5. Yosys Open Synthesis Suite Manual

