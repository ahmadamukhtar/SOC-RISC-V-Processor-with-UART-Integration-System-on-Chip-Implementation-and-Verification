#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$SCRIPT_DIR/obj_dir"

if ! command -v verilator >/dev/null 2>&1; then
    printf 'Error: Verilator is required. Install it with: sudo apt install verilator build-essential\n' >&2
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    printf 'Error: make is required to build the Verilator simulation. Install it with: sudo apt install build-essential\n' >&2
    exit 1
fi

verilator \
    --binary \
    --timing \
    --trace \
    --Wno-fatal \
    --top-module SOC_riscv_uart_tb \
    --Mdir "$BUILD_DIR" \
    "$ROOT_DIR/rtl_files/A_mux.sv" \
    "$ROOT_DIR/rtl_files/B_mux.sv" \
    "$ROOT_DIR/rtl_files/Branch_comp.sv" \
    "$ROOT_DIR/rtl_files/Control_unit.sv" \
    "$ROOT_DIR/rtl_files/PC.sv" \
    "$ROOT_DIR/rtl_files/SOC_riscv_uart.sv" \
    "$ROOT_DIR/rtl_files/alu.sv" \
    "$ROOT_DIR/rtl_files/baud_rate_selector.sv" \
    "$ROOT_DIR/rtl_files/clock_divider.sv" \
    "$ROOT_DIR/rtl_files/data_mem.sv" \
    "$ROOT_DIR/rtl_files/imm_gen.sv" \
    "$ROOT_DIR/rtl_files/inst_mem.sv" \
    "$ROOT_DIR/rtl_files/mem_mux.sv" \
    "$ROOT_DIR/rtl_files/reg_file.sv" \
    "$ROOT_DIR/rtl_files/riscv_data_path.sv" \
    "$ROOT_DIR/rtl_files/transmitter_controller.sv" \
    "$ROOT_DIR/tb/tb_SOC.sv"

# The instruction memory loads data.mem relative to the simulator's working directory.
cd "$ROOT_DIR/rtl_files"
"$BUILD_DIR/VSOC_riscv_uart_tb"
