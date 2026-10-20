# 🔧 SoC Design: RISC-V Processor with UART Integration

This project demonstrates the **hardware integration** of a RISC-V processor core with a UART transmitter module to build a custom **System-on-Chip (SoC)** using Verilog. It focuses on communication between a processor and peripheral via **standard RISC-V memory-mapped I/O instructions**, using an existing RISC-V core and UART module.

---

## 📌 Overview

The goal of this project was to create a functioning SoC by integrating:
- A **RISC-V processor core** (pre-existing IP)
- A **UART transmitter module** (pre-existing IP)
- Custom **glue logic** to form a modular SoC, allowing the processor to send data through UART under specific ALU conditions.

Unlike processor verification labs, this work focuses on **modular integration, memory mapping, and real-time data flow**.

---

## 🎯 Objectives

- ✅ Integrate a RISC-V core and UART transmitter into a single SoC design
- ✅ Enable the processor to interact with UART using `sw` (store) and `lw` (load) instructions
- ✅ Trigger UART transmission when the ALU output equals a specific address (e.g., `0x1600`)
- ✅ Monitor UART transmission status and reflect it in a register (`x7`)
- ✅ Simulate the SoC behavior using waveform analysis and register tracking

---

## 🧠 Architecture

### 📦 Modules Involved
- **RISC-V Core**: Executes instructions and generates ALU outputs
- **UART Transmitter**: Sends data over a serial interface
- **SoC Wrapper**: Integrates the processor and UART, and defines control logic

### 🔁 Control Logic
- When `sw x6, 1600(x0)` is executed:
  - The processor sends the value in `x6` to the UART transmitter
- When `lw x7, 1604(x0)` is executed:
  - The UART status (busy or ready) is loaded into `x7`
- Only the **least significant byte (LSB)** of `x6` is transmitted

---

## 🧪 Simulation and Results

### Run the SoC testbench with Verilator

Install Verilator on Ubuntu or Debian:

```bash
sudo apt update
sudo apt install verilator build-essential
```

From the repository root, build and run the simulation with:

```bash
./tools/run_sim.sh
```

The script places generated build files in `tools/obj_dir/` and runs from
`rtl_files/` so the instruction image `data.mem` can be found. It also writes
the waveform to `rtl_files/soc_wave.vcd`; open that file with GTKWave:

```bash
sudo apt install gtkwave
gtkwave rtl_files/soc_wave.vcd
```

### ✔️ UART Data Transmission
- When ALU OUT = `0x1600`, UART transmits the LSB of `x6`
- The load signal to UART is correctly asserted at this condition
- Waveform confirms valid UART behavior and data transmission

### ✔️ Status Monitoring
- UART status is written to `x7`:
  - `1` = UART Ready
  - `0` = UART Busy
- Status updates reflected correctly in simulation

---

## 🧩 Key Files and Structure

```plaintext
src/
├── riscv_core.v         # Existing RISC-V processor IP
├── uart_tx.v            # UART transmitter module
├── soc_top.v            # Top-level SoC module (integration logic)
├── memory.v             # Instruction and data memory (if used)
├── testbench.v          # Testbench to simulate SoC behavior
````

---

## 📈 Challenges

* Handling **synchronization and timing** between processor and UART
* Ensuring ALU correctly triggers UART logic only when `0x1600` is accessed
* Preventing unintended writes by masking control paths

---

## 🔮 Future Enhancements

* Add interrupt-based UART handling
* Extend SoC with more peripherals (SPI, GPIO, Timer)
* Add UART RX path and full-duplex communication
* Run more complex software programs in the processor core

---

## 📚 References

* **Patterson & Hennessy**: *Computer Organization and Design, RISC-V Edition*
* UART module specification (IP datasheet or design doc)
* RISC-V Instruction Set Manual (privileged and unprivileged specs)

---

## 👨‍💻 Author

**Ahmad Mukhtar**
