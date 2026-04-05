# Fault-Tolerant RISC-V RV32I Processor with ML-Enhanced TMR Voter

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![Python](https://img.shields.io/badge/ML-Python%20%7C%20Scikit--learn-green)
![FPGA](https://img.shields.io/badge/FPGA-Artix--7%20XC7A35T-orange)
![Accuracy](https://img.shields.io/badge/ML%20Voter%20Accuracy-99.90%25-brightgreen)
![Status](https://img.shields.io/badge/Status-Complete-success)

---

## Overview

This project implements a fully pipelined **RISC-V RV32I processor** with hardware fault tolerance using **Triple Modular Redundancy (TMR)**. Unlike traditional TMR systems that use a simple majority voter, this design replaces the voter with a **trained neural network** that can detect and handle both single and double fault scenarios.

The system runs three identical RISC-V CPUs in parallel. The ML voter monitors all three outputs and intelligently selects the correct result — even in cases where the traditional majority voter would fail.

---

## Key Features

- Full **RV32I instruction set** (40+ instructions)
- **5-stage pipeline** — IF → ID → EX → MEM → WB
- **Hazard detection** with data forwarding and stall logic
- **Triple Modular Redundancy** — 3 CPU copies running in parallel
- **Fault injection** — inject arbitrary bad values to test the system
- **ML Neural Network Voter** — replaces traditional majority voter
- Handles **double fault cases** where majority voting fails
- Fully **synthesized** on Artix-7 FPGA

---

## ML Voter Results

| Voter Type | Accuracy | Handles Double Faults |
|------------|----------|----------------------|
| Simple Majority Voter | 65.30% | No |
| **ML Neural Network Voter** | **99.90%** | **Yes** |
| **Improvement** | **+34.60%** | — |

The ML voter is trained using **MLPClassifier** (scikit-learn) on 3000 synthetic fault scenarios including no-fault, single-fault, and double-fault cases. It predicts which of the 3 CPUs is producing the correct output.

---

## Simulation Results (Vivado)

| Phase | Description | fault_detected | Result |
|-------|-------------|----------------|--------|
| Phase 1 — Normal | All 3 CPUs running correctly | 0 | PASS |
| Phase 2 — Fault Injected | DEADBEEF injected into CPU2, ML voter corrects output | 1 | PASS |
| Phase 3 — Recovery | Fault removed, system continues normally | 0 | PASS |

---

## FPGA Resource Utilization (Artix-7 XC7A35T)

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| LUT | 49 | 32,600 | 0.15% |
| Flip Flops | 91 | 65,200 | 0.14% |
| IO | 68 | 210 | 32.38% |

The entire TMR + ML voter system uses less than **0.15% of the FPGA** — highly area efficient.

---

## Project Structure

```
├── src/
│   ├── riscv_top.v        ← Top-level RISC-V processor
│   ├── tmr_top.v          ← TMR wrapper (3 CPUs + ML voter)
│   ├── ml_voter.v         ← Neural network voter in Verilog
│   ├── pc.v               ← Program counter
│   ├── imem.v             ← Instruction memory
│   ├── control.v          ← Control unit
│   ├── regfile.v          ← Register file (32 registers)
│   ├── alu.v              ← ALU (10 operations)
│   └── dmem.v             ← Data memory
├── testbench/
│   ├── riscv_tb.v         ← RISC-V testbench
│   └── tmr_tb.v           ← TMR testbench (3 phases)
├── ml_voter/
│   └── train_voter.py     ← ML voter training script
├── constraints/
│   └── boolean_board.xdc  ← FPGA pin constraints
└── image/                 ← Simulation screenshots
```

---

## How It Works

### 1. Triple Modular Redundancy
Three identical RISC-V processors run in parallel. Their outputs are fed into the ML voter which decides which output is correct.

### 2. Fault Injection
The `fault_enable` and `fault_inject` ports allow injecting an arbitrary bad value into CPU2 to simulate radiation-induced bit flips or hardware faults.

### 3. ML Voter
A neural network (3 → 16 → 8 → 3) is trained to classify which CPU is producing the correct output. The trained weights are converted into synthesizable Verilog hardware.

---

## How to Run

### Python ML Voter
```bash
cd ml_voter
pip install scikit-learn numpy
python train_voter.py
```

### Vivado Simulation
1. Open Vivado and load the project
2. Set `tmr_tb.v` as the top testbench
3. Click **Run Simulation → Run Behavioral Simulation**
4. Observe the 3 phases in the waveform viewer

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Verilog / Vivado | Hardware design and simulation |
| Python + Scikit-learn | ML voter training |
| Boolean Board (Artix-7) | FPGA synthesis target |
