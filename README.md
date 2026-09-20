# Fault-Tolerant RISC-V (RV32I subset) TMR System in Verilog

A Triple Modular Redundancy (TMR) system built from three copies of a small single-cycle RISC-V core, with fault injection, fault detection and recovery, simulated and synthesized in Vivado. A neural-network voter is explored separately in Python.

**Status:** hardware simulation working; the neural-network voter is a Python experiment and is **not yet implemented in RTL** (see [Limitations and future work](#limitations-and-future-work)).

## What is in this project

| Part | Description |
|---|---|
| Processor core | Single-cycle RV32I **subset**: ADD, AND, OR, ADDI, LW, SW, BEQ (`rtl/riscv_top.v` and submodules) |
| TMR system | Three core copies, a fault-injection input, and a comparator-based voter (`rtl/tmr_top.v`, `rtl/ml_voter.v`) |
| ML experiment | Neural-network voter trained in Python and compared with a majority voter (`ml_experiment/`) |
| FPGA target | Digilent Basys3 (Artix-7 XC7A35T), constraints in `constraints/basys3.xdc` |

## How the TMR system works

1. Three identical cores run the same program; each exposes its program counter (PC).
2. `fault_enable` / `fault_inject` replace CPU2's PC at the voter input with an arbitrary value (for example `DEADBEEF`) to emulate a fault.
3. The voter (`ml_voter.v`, a plain comparator despite its name) compares the three PCs, raises `fault_detected` when they differ, and selects a value that two cores agree on.
4. While a fault is flagged, `tmr_top` holds the **last known good PC** on its output. When the fault is removed, normal output resumes.

## Simulation results (Vivado / Icarus Verilog)

| Phase | Stimulus | `fault_detected` | Result |
|---|---|---|---|
| 1. Normal | All cores healthy | 0 | PASS |
| 2. Fault injected | `DEADBEEF` forced into CPU2 | 1 | PASS (output does not show `DEADBEEF`) |
| 3. Recovery | Fault removed | 0 | PASS |

![TMR waveform](docs/images/tmr_ml_voter_waveform.jpeg)

Single-core simulation (PC, instruction, ALU result). The instruction memory holds only a 6-instruction test program, so `instr` becomes `X` after it ends:

![Single core waveform](docs/images/riscv-top-complete-cpu.jpeg)

## FPGA utilization (Artix-7 XC7A35T, synthesis)

| Resource | Used | Available |
|---|---|---|
| Slice LUTs | 49 | 32,600 |
| Slice registers | 91 | 65,200 |
| Bonded IOB | 68 | 210 |

Only the PC is brought out of each core, so synthesis removes most of the unobserved logic. These numbers do **not** represent three complete cores.

![Utilization](docs/images/utilization-report.jpeg)

More reports: [`docs/images/`](docs/images) and [`docs/elaborated-design.pdf`](docs/elaborated-design.pdf).

## ML voter experiment (Python)

`ml_experiment/train_voter.py` trains a scikit-learn `MLPClassifier` (hidden layers 32 and 16) to pick which of the three CPU outputs is correct.

- **Data:** 10,000 synthetic scenarios (no fault, single fault, double fault); 80/20 train/test split.
- **Baseline:** a majority voter that returns the value two CPUs agree on.
- **Result (3 runs, unseeded):** majority voter about 65 to 67%, neural network about 99.9% on the held-out test set.
- **Caveats:** the data is synthetic, and in double-fault cases the faulty values are always larger than the correct one, so the network can learn that pattern. In those cases the two faulty values also differ, which a majority voter cannot resolve. Treat this as a proof of concept, not a hardware result.

```
cd ml_experiment
pip install scikit-learn numpy joblib
python train_voter.py
```

## Repository structure

```
rtl/            Verilog design files (core, TMR top, voter)
tb/             Testbenches (tmr_tb.v is the main one)
constraints/    basys3.xdc
ml_experiment/  train_voter.py, extract_weights.py
docs/           elaborated-design.pdf, images/
release/        riscv_top.bit (bitstream)
```

## How to run

**Icarus Verilog (no Vivado needed):**

```
iverilog -g2012 -o tmr_sim rtl/*.v tb/tmr_tb.v
vvp tmr_sim
```

**Vivado:** create a project, add `rtl/*.v` as design sources and `tb/*.v` as simulation sources, set `tmr_tb` as the top simulation module, then run behavioral simulation.

## Limitations and future work

- The core is single-cycle and supports only a subset of RV32I. Planned: a 5-stage pipeline with hazard detection and forwarding, and the full RV32I base set.
- Known issues: SUB is currently decoded as ADD (funct7 is not checked), and SW/BEQ use the I-type immediate instead of the S/B-type formats.
- Faults are injected at the PC signal at the voter input, not inside the cores. Planned: injection into registers or pipeline state.
- The neural network is not yet in RTL. Planned: export fixed-point weights and implement the network in Verilog.
- Test coverage: `tb/tmr_tb.v` checks detection and recovery; the other testbenches are unit-level.
