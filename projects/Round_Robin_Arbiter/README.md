## Round Robin Arbiter (Variable Time Slice + Pointer-Based Fairness)

Round Robin Arbiter (Variable Time Slice + Pointer-Based Fairness)

This repository contains a synthesizable 4-request Round Robin Arbiter implemented in Verilog.
The arbiter supports:

- **Fair scheduling** (true round-robin rotation)
- **Variable time slice** per requester
- **Glitch-free** registered outputs
- **Pointer-based** rotating priority logic
- **Clean FSM-based design**
- **Simple testbench included**


## What This Arbiter Does

When multiple requesters assert their REQ signals, the arbiter grants access in a rotating round-robin manner, ensuring that no requester starves.

Each requester receives the bus for a programmable number of cycles (TIME_SLICE + 1).
If a requester drops its request early, the arbiter immediately switches to the next active requester.

## Key Features

 
  1. **Priority Order Based on Pointer**
  
  | pointer | Priority Order     |
  |--------|---------------------|
  |   0    | 0 → 1 → 2 → 3       |
  |   1    | 1 → 2 → 3 → 0       |
  |   2    | 2 → 3 → 0 → 1       |
  |   3    | 3 → 0 → 1 → 2       |
  
  The pointer updates **after every completed grant**, ensuring the next arbitration cycle begins with the correct requester.
  


 2. **Simple, Synthesizable Logic**
 
 The rotated request selection is implemented using a straight-forward `case(pointer)` structure:
 
 ```verilog
 case (pointer)
   0: check 0, then 1, then 2, then 3;
   1: check 1, then 2, then 3, then 0;
   2: check 2, then 3, then 0, then 1;
   3: check 3, then 0, then 1, then 2;
 endcase
 ```
 
    This makes the arbiter:
   
   - easy to read,
   - easy to debug,
   - efficient in hardware,
   - and 100% synthesizable on all EDA tools.

3. **One-Hot Encoded FSM**



   S_ideal  – no grant active
   
   S_0      – requester 0 granted
   
   S_1      – requester 1 granted
   
   S_2      – requester 2 granted
   
   S_3      – requester 3 granted

4. **Glitch-Free Grants**

 The GNT output is synchronously registered, guaranteeing no combinational glitches or short pulses.

5. **Fully Synchronous Design**

  All critical states (present_state, count, pointer) are flops.
  
  No latches.
  No combinational feedback.
  Safe for ASIC/FPGA synthesis.
