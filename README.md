# Asynchronous FIFO 

## Overview

This project implements a parameterized **Asynchronous FIFO (First-In-First-Out)** buffer in Verilog. It is designed to safely transfer data between two independent clock domains using Gray code pointers and two flip-flop synchronizers.

The FIFO supports independent write and read clocks, making it suitable for Clock Domain Crossing (CDC) applications in digital systems.

---

## Features

- Dual-clock FIFO with independent `wclk` and `rclk`
- Parameterized data width and address width
- Gray code based read and write pointers
- Two flip-flop synchronizers for CDC safety
- Full and empty flag generation
- Dual-port memory structure
- Verified using Vivado XSim simulation

---

## Architecture

The design consists of the following blocks:

### 1. FIFO Top Module

The top module connects the memory, write pointer logic, read pointer logic, and synchronizers.

### 2. FIFO Memory

The memory block stores incoming data and supports independent write and read operations.

- Write operation occurs in the `wclk` domain  
- Read operation occurs in the `rclk` domain  

### 3. Write Pointer and Full Logic

The write pointer block maintains the write address and generates the `full` flag.

- Binary pointer is used for address generation  
- Gray pointer is used for clock domain crossing  
- Full condition is detected using the synchronized read pointer  

### 4. Read Pointer and Empty Logic

The read pointer block maintains the read address and generates the `empty` flag.

- Binary pointer is used for address generation  
- Gray pointer is used for clock domain crossing  
- Empty condition is detected using the synchronized write pointer  

### 5. Two Flip-Flop Synchronizer

The synchronizer safely transfers pointers between clock domains.

- `wptr` is synchronized into the read clock domain  
- `rptr` is synchronized into the write clock domain  

---

## Clock Domain Crossing

Since `wclk` and `rclk` are independent, direct transfer of multi-bit signals can lead to metastability and incorrect sampling.

To ensure safe CDC:

1. Binary pointers are converted to **Gray code**
2. Gray code ensures **only one bit changes at a time**
3. Pointers are passed through **two flip-flop synchronizers**
4. Full and empty flags are generated only after synchronized pointer comparison

---

## Metastability Handling

Metastability occurs when a flip-flop samples a signal that is changing near the clock edge, resulting in an undefined intermediate state.

This design mitigates metastability using:

- **Two Flip-Flop Synchronizers (2FF):**  
  The first flip-flop may enter a metastable state, but the second flip-flop samples a stabilized value in the next clock cycle.

- **Gray Code Encoding:**  
  Since only one bit changes at a time, the probability of multiple bits being sampled incorrectly is minimized.

- **Conservative Flag Logic:**  
  Full and empty conditions are derived from synchronized pointers, ensuring safe operation even with slight delays.

This combination ensures that metastability does not propagate into functional logic, maintaining reliable FIFO behavior.

---

## Latency

Due to synchronization and registered memory read:

- Pointer synchronization delay: approximately **2 clock cycles**
- Registered memory read delay: approximately **1 read clock cycle**

Total observable latency:
- **~3 cycles from write to read visibility**

---

## Testbench

The FIFO is verified using three major test cases:

### Test Case 1: Normal Write and Read

Data is written into the FIFO and read back using different write and read clocks.

### Test Case 2: Full Condition

The FIFO is filled beyond its capacity to verify that additional writes are blocked when `full` is asserted.

### Test Case 3: Empty Condition

The FIFO is completely read out to verify that additional reads are blocked when `empty` is asserted.

---

## Simulation Observation

The simulation confirms:

- Correct FIFO ordering of data  
- Proper full flag assertion  
- Proper empty flag assertion  
- Expected latency due to CDC synchronizers  
- No overwrite during full condition  
- No invalid read during empty condition  

---

## Project Structure

```text
.
├── src/
│   └── fifo.v
│   └── fifo_memory.v
|   └── rptr_empty.v
|   └── wptr_full.v
|   └── two_ff_sync.v
├── Output Waveform/
│   └── waveform images
│
└── README.md
