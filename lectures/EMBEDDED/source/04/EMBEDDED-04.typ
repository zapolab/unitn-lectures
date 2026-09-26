#import "_preamble.typ": *
#show: doc.with(title: "Processors and I/O", label: "EMBEDDED-04")
#titleblock("Processors and I/O", "EMBEDDED — Lecture 4")

#import "@preview/cetz:0.5.2": canvas, draw

#let cbox(x, y, w, h, t, fs: 5.5pt, fill: none) = {
  draw.rect((x, y), (x + w, y + h), fill: fill, stroke: 0.5pt + rgb("#1B4965"))
  draw.content((x + w / 2, y + h / 2), text(size: fs, t))
}

== Processor and Input and Output Devices

=== Peripherals and Chip Architecture

Other than the CPU, a chip integrates many peripherals (e.g., I/O devices): timers, UART, sensors.

#figure(caption: [MCU architecture: Cortex-M4 core, on-chip memories, peripherals and external interfaces.], [
  #raw("")
  #scale(82%, reflow: true)[
    #canvas({
      cbox(0.4, 5.8, 4.0, 1.25, [])
      draw.content((2.4, 6.85), text(size: 6pt, weight: "bold")[Cortex-M4])
      cbox(0.6, 5.95, 2.1, 0.7, [PPB \ SCS, NVIC, Debug CRTL], fs: 4.5pt)
      cbox(2.8, 5.95, 1.4, 0.7, [AHB/APB], fs: 5pt)
      draw.line((0.3, 5.5), (9.7, 5.5), stroke: 1pt + rgb("#2E7D32"))
      draw.content((5.0, 5.67), text(size: 5.5pt)[bus matrix])
      cbox(0.4, 4.2, 2.7, 1.1, [On-chip FLASH \ (Code Region)])
      cbox(3.3, 4.2, 2.7, 1.1, [On-chip SRAM \ (SRAM Region)])
      cbox(6.2, 4.2, 2.8, 1.1, [Timer \ UART \ (Peripheral Region)])
      cbox(0.4, 2.9, 4.5, 1.0, [External memory interface \ (External RAM Region)])
      cbox(5.1, 2.9, 4.5, 1.0, [External device interface \ (External Device Region)])
      draw.rect((0, 2.3), (10, 7.6), stroke: 0.8pt + rgb("#333333"))
      draw.content((5.0, 7.42), text(size: 6.5pt, weight: "bold")[Chip Silicon])
      cbox(0.4, 0.5, 2.6, 0.9, [External SRAM, \ FLASH])
      cbox(3.2, 0.5, 2.2, 0.9, [External LCD])
      cbox(5.6, 0.5, 2.0, 0.9, [SD card])
      cbox(7.8, 0.5, 1.8, 0.9, [GPIO])
      draw.line((1.5, 2.9), (1.7, 1.4), stroke: 0.5pt + rgb("#1B4965"), mark: (end: ">"))
      draw.line((3.0, 2.9), (4.3, 1.4), stroke: 0.5pt + rgb("#1B4965"), mark: (end: ">"))
      draw.line((7.0, 2.9), (6.6, 1.4), stroke: 0.5pt + rgb("#1B4965"), mark: (end: ">"))
      draw.line((8.0, 2.9), (8.7, 1.4), stroke: 0.5pt + rgb("#1B4965"), mark: (end: ">"))
    })
  ]
])

=== How Do They Communicate?

- The processor reaches on-chip peripherals through the *bus matrix*; external interfaces connect off-chip devices.
- Each peripheral (i.e., device) exposes registers; the CPU talks to the device by reading and writing device registers.
- Interrupt lines (not shown in this figure) will report events from I/O devices that need CPU service.

#asciifig("
+------+   Status Register   +--------------+
|      |====================>|              |
| CPU  |   Data Register     |    Device    |
|      |====================>|   Mechanism  |
+------+                     +--------------+
", [Status and data registers between CPU and device.])

Device registers connect software to hardware state:

#cmp(2)[Data registers][#list(
  [carry values moving into or out of the device;],
  [hold data values;],
  [access direction depends on the peripheral;],
  [can be readable or writable.]
)][Status and control registers][#list(
  [report events and configure operating modes;],
  [e.g., event: the current operation has been completed;],
  [individual bits often have different meanings.]
)]

=== Two Architectural Models for Device Access

Two ways to access those registers:

- *I/O instructions*: special instructions for input and output (`in` and `out` in the case of the Intel x86); provide a separate address space for I/O devices (separate address lines…).
- *Memory-mapped I/O*: provides addresses for the registers in each I/O device; programs use the CPU's normal memory read and write instructions to communicate with the devices.

#tbl(4, head: ([Model], [Addressing], [Instructions], [Typical example]),
  [Separate I/O space], [Dedicated device address space], [Special input and output instructions], [Legacy x86 ports],
  [Memory-mapped I/O], [Device registers share the memory address space], [Normal load and store instructions], [Arm microcontrollers])

=== ARM Loads and Stores Access Device Registers

#raw(block: true, lang: "asm", "DEV1_BASE   EQU 0x40001000\nLDR r1, = DEV1_BASE\nLDR r0, [r1]        // read register\nMOVS r0, #8\nSTR r0, [r1]        // write register")

#keypt("What matters", [
  A wrong address can control a different peripheral or trigger a bus fault. The address must identify the correct register. The access width and alignment must match the peripheral specification.
])

=== C Requires Volatile Access to Device Registers

We can use pointers to manipulate the addresses of I/O devices.

#raw(block: true, lang: "c", "#include <stdint.h>\n#define DEV1_STATUS_ADDR 0x40001000u\n#define DEV1_STATUS (*(volatile uint32_t *)DEV1_STATUS_ADDR)\nuint32_t status = DEV1_STATUS;\nDEV1_STATUS = 8u;")

#defbox("volatile", [
  Tells the compiler that every read and write matters because hardware may change the value outside normal program flow.
])

Introduce functions that read and write memory locations:

#raw(block: true, lang: "c", "#define DEV1_STATUS_ADDR 0x40001000u\nint read(uint8_t *location) {\n  return *location;\n}\nvoid write(uint8_t *location, char newval) {\n  (*location) = newval;\n}\nuint32_t status = read(DEV1_STATUS_ADDR); /* read device register */\nwrite(DEV1_STATUS_ADDR, 8); /* write 8 to device register */")

=== Register Definitions Should Express Width and Intent

The device reference manual defines the legal access pattern for each device register.

#tbl(2, head: ([Concern], [Reason]),
  [Access width], [A byte, halfword, or word transfer may have different hardware meaning],
  [Read-only and write-only behavior], [Some registers reject unsupported access directions],
  [Reserved bits], [Software should preserve or write required values],
  [Side effects], [A read may clear status and a write may acknowledge an event])

== Polling (Busy-Wait) I/O

- I/O devices are typically slower than the CPU and may require many cycles to complete an operation.
- *Busy-wait* (often called polling): asking an I/O device whether it is finished by reading its status register; software reads a status register until the ready or complete condition appears.
- The loop provides low control-flow complexity; CPU cycles are consumed while no useful application work progresses.

=== Polling an Output Device (Example)

One character starts each transaction; the inner loop waits for completion.

#raw(block: true, lang: "c", "#define OUT_CHAR 0x1000 /* output device character register */\n#define OUT_STATUS 0x1001 /* output device status register */\nwhile (*current != '\\0') {\n  OUT_DATA = *current;\n  OUT_STATUS = START;\n  while (OUT_STATUS != DONE) {\n    // CPU waits here\n  }\n  current++;\n}")

The CPU cannot perform independent application work during the wait.

=== A Polling-Based Input-to-Output Loop (Example)

Repeat forever:

- wait until the input status reports available data;
- read one value from the input data register;
- write that value into the output data register;
- wait until the output device completes the transaction.

#raw(block: true, lang: "c", "for (;;) {\n  while (IN_STATUS == EMPTY) { }\n  uint8_t c = IN_DATA;\n  while (OUT_STATUS == BUSY) { }\n  OUT_DATA = c;\n  OUT_STATUS = START;\n}")

The loop does not allow the foreground work to continue.

== Interrupt-driven I/O

- Busy-wait I/O is inefficient; the CPU could do useful work in parallel with the I/O.
- The interrupt mechanism allows a device to request service only when an event occurs.
- The processor saves context, runs a handler, then resumes the interrupted program.

=== Several Signals Control the Interrupt Process

- The device asserts an *interrupt request*; the I/O device's logic decides when to interrupt (e.g., when data is ready, the user pressed a button).
- The CPU accepts the request: it asserts the *interrupt acknowledge* signal and changes the program counter to point to the device's interrupt handler.
- The interrupt handler identifies the event source (e.g., which device) and takes the necessary processing actions.

#asciifig("
+------+   Interrupt Request  +--------------+
|      |<---------------------|              |
| CPU  |   Interrupt Ack      |    Device    |
|      |--------------------->|   Mechanism  |
|      |   Data/Address       |              |
|      |<====================>|              |
+------+                      +--------------+
", [Signals between CPU and device: request, acknowledge, data/address.])

=== Interrupt Entry Changes Control Flow

When an interrupt occurs:

- first, the value of the PC at the interruption is saved: the CPU can return to the foreground program later;
- then, the PC starts pointing to an interrupt handler routine: this routine takes care of the device by reading data that have just become ready, writing the next data…

#tbl(2, head: ([Phase], [Processor action]),
  [Recognition], [Detect interrupt],
  [Context save], [Preserve the return state and selected registers],
  [Vector fetch], [Load the handler address from the vector table],
  [Service], [Execute the interrupt handler],
  [Return], [Restore state and resume the interrupted code])

=== Cortex-M Interrupt Entry

- Save the necessary context: pushes important registers R0 to R3, R12, LR, PC, and xPSR into stack.
- Finds the handler address from the interrupt vector table.
- The handler may save additional registers that it uses.
- Interrupt return restores the hardware-saved state and context.
- Interrupt code in C is processed in a specific way by the compiler: compiler-generated handlers follow the architecture calling convention when declared correctly.

=== A Minimal Input Interrupt Handler in C

- Read the data that caused the interrupt.
- Record minimal state for later processing.
- Acknowledge or clear the device event.
- Return quickly.

#raw(block: true, lang: "c", "volatile uint8_t latest_char;\nvolatile bool char_ready;\nvoid input_handler(void) {\n  latest_char = IN_DATA; // read device register\n  char_ready = true;\n  IN_STATUS = ACK; // acknowledge the device\n}")

=== Interrupts (Example)

`achar` passes the character to the foreground program; `gotchar` signals when a new character has been received.

#raw(block: true, lang: "c", "/* get a character and put in global (called when IN_STATUS is 1) */\nvoid input_handler() {\n  achar = read(IN_DATA); /* get character */\n  gotchar = TRUE; /* signal to main program */\n  write(IN_STATUS, 0); /* reset status to initiate next transfer */\n}\n/* react to character being sent (called when OUT_STATUS is 0) */\nvoid output_handler() {\n  /* don't have to do anything */\n}")

The main program is somewhat simpler compared to Busy Wait I/O, but still does not let the foreground program do useful work: it polls input and writes data.

#raw(block: true, lang: "c", "main() {\n  while (TRUE) { /* read then write forever */\n    if (gotchar) { /* write a character */\n      write(OUT_DATA, achar); /* put character in device */\n      write(OUT_STATUS, 1); /* set status to initiate write */\n      gotchar = FALSE; /* reset flag */\n    }\n  }\n}")

== Circular Buffer

=== A Circular Buffer Separates Producer and Consumer Timing

- One index identifies the next read position.
- The other identifies the next write position.

#asciifig("
+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |
+--+--+--+--+--+--+--+--+
  ^  ^
 head tail
", [Empty circular buffer: head and tail coincide.])

#asciifig("
+--+--+--+--+--+--+--+--+
|  | b| c| d| e| f| g| h|
+--+--+--+--+--+--+--+--+
  ^  ^
 tail head
", [Circular buffer holding data b–h.])

=== Circular Buffer Implementation

#raw(block: true, lang: "c", "#define BUF_SIZE 8\nchar io_buf[BUF_SIZE]; /* character buffer */\nint buf_head = 0, buf_tail = 0; /* current position in buffer */\nint error = 0; /* set to 1 if buffer ever overflows */\n\nint buffer_empty() { /* returns TRUE if buffer is empty */\n  return buf_head == buf_tail;\n}\nint buffer_full() { /* returns TRUE if buffer is full */\n  return (buf_tail+1) % BUF_SIZE == buf_head ;\n}\nint nchars() { /* returns the number of characters in the buffer */\n  if (buf_head >= buf_tail)\n    return buf_head - buf_tail;\n  else\n    return BUF_SIZE - buf_tail - buf_head;\n}")

#raw(block: true, lang: "c", "void buffer_put(char achar) { /* add a character to the buffer head */\n  io_buf[buf_tail++] = achar;\n  /* check pointer */\n  if (buf_tail == BUF_SIZE)\n    buf_tail = 0;\n}\nchar buffer_get() { /* take a character from the buffer head */\n  char achar;\n  achar = io_buf[buf_head++];\n  /* check pointer */\n  if (buf_head == BUF_SIZE)\n    buf_head = 0;\n  return achar;\n}")

=== Input ISR Adds Data and Starts Output

The input ISR adds data and starts output:

- capture the arriving item;
- record overflow without blocking;
- kick the output only when the queue was idle;
- acknowledge the input event.

#raw(block: true, lang: "c", "void input_handler(void) {\n  uint8_t c = IN_DATA;\n  if (buffer_full()) {\n    overflow = true;\n  } else {\n    bool was_empty = buffer_empty();\n    buffer_put(c);\n    if (was_empty) start_output();\n  }\n  IN_STATUS = ACK;\n}")

Each completion interrupt launches the next queued item; the handler disables unnecessary interrupts when no data remains.

#raw(block: true, lang: "c", "void output_handler(void) {\n  OUT_STATUS = ACK;\n  if (!buffer_empty()) {\n    OUT_DATA = buffer_get();\n    OUT_CONTROL = START;\n  } else {\n    stop_output();\n  }\n}")

=== Foreground/ISR Timing

The foreground program is occasionally interrupted by input and output operations, handled by the interrupt handlers in the background; the foreground program resumes after interrupt handlers.

#asciifig("
Foreground Program
+------+     +------+     +------+
| main |.....| main |.....| main |
+------+     +------+     +------+
   Input ISR    Output ISR   Input ISR   Time ->
", [Periodic interruptions of the foreground by the ISRs.])

#raw(block: true, lang: "c", "void main(){\n  ...\n  for (i = 0; i < M; i++) {\n    y[i] = b[i];\n    for (j = 0; j < N; j++)\n      y[i] = y[i] + A[i,j]*x[ j];\n  }\n  ...\n}")

== Bugs

The errors can be very hard to find when the interrupt handlers are buggy due to the concurrency.

=== Saving Registers

An interrupt handler:

- must save any CPU register that it will modify;
- must restore them before it exits.

Forgetting to save/restore a register in the handler might cause that register to mysteriously change a variable in the foreground program.

=== Read-Modify-Write

For example, in order to set bit[3] in word data in address `0x20000000`:

#raw(block: true, lang: "asm", "...\nLDR R1, =0x20000000   ;Setup address\nSTR R2,[R1]           ;Write back 0x79\n...\n\n;Read-Modify-Write Operation\nLDR R1, =0x20000000   ;Setup address\nLDR R0, [R1]          ;Read 0x21\nORR.W R0, #0x8        ;Set bit[3]\nSTR R0, [R1]          ;Write back 0x29")

#asciifig("
Main: Read 0x21 -> Modify bit[3] ------------> Write 0x29
                        |
                  Interrupt occurs
                        v
ISR:  Read 0x21 -> Modify bit[3] -> Write 0x29
                        |
                  Interrupt returns
Bit[3] modified by ISR is overwritten by main
", [Interrupted read-modify-write: the main program's write overwrites the ISR's.])

Read-modify-write operation:

- reads the data (0x21) from the address `0x20000000`;
- the interrupt changes the data of `0x20000000` address;
- writes back the modified old data back;
- `0x79` has been lost!

Bit[3] modified by ISR is overwritten by the main program.

== Interrupt Handlers Should Do Bounded Work

- Capture or deliver the minimum data required by the device.
- Clear the interrupt source before it can retrigger unexpectedly.
- Avoid blocking calls and unbounded loops.
- Move expensive processing into foreground or deferred work.
- Measure worst-case execution time.

== Interrupts — Implementation

- The CPU checks the interrupt request (IRQ) line at every instruction.
- If an interrupt request has been asserted, the CPU:
  - puts the return address on a stack (as CPU does for subroutines);
  - does not fetch the instruction pointed to by the PC;
  - sets the PC to the beginning of the interrupt handler.
- The address of the interrupt handlers are stored in a table.

== Priorities and Vectors

- Most systems have more than one I/O device: multiple devices can interrupt, several interrupt handlers and device addresses.
- *Interrupt priorities*: recognize some interrupts as more important than others.
- *Interrupt vectors*: allow the interrupting device to specify its interrupt handler.

#figure(caption: [Source priorities: the PIC selects the highest-priority request and presents the vector to the CPU.], [
  #raw("")
  #scale(78%, reflow: true)[
    #canvas({
      cbox(0, 4.4, 1.7, 0.9, [Airbag \ Sensor])
      cbox(0, 3.2, 1.7, 0.9, [Break \ Sensor])
      cbox(0, 2.0, 1.7, 0.9, [Real \ Time \ Clock])
      cbox(0, 0.8, 1.7, 0.9, [Fuel \ Level \ Sensor])
      draw.content((2.6, 4.85), text(size: 5.5pt)[HIGHEST])
      draw.content((2.2, 3.65), text(size: 5.5pt)[HIGH])
      draw.content((1.9, 2.45), text(size: 5.5pt)[MED])
      draw.content((1.9, 1.25), text(size: 5.5pt)[LOW])
      cbox(4.2, 1.4, 1.8, 3.6, [PIC])
      draw.line((1.7, 4.85), (4.2, 4.5), stroke: 0.7pt + rgb("#E07A00"), mark: (end: ">"))
      draw.line((1.7, 3.65), (4.2, 3.5), stroke: 0.7pt + rgb("#E07A00"), mark: (end: ">"))
      draw.line((1.7, 2.45), (4.2, 2.5), stroke: 0.7pt + rgb("#E07A00"), mark: (end: ">"))
      draw.line((1.7, 1.25), (4.2, 1.7), stroke: 0.7pt + rgb("#E07A00"), mark: (end: ">"))
      cbox(7.2, 2.6, 1.6, 1.2, [CPU])
      draw.line((6.0, 3.2), (7.2, 3.2), stroke: 0.7pt + rgb("#E07A00"), mark: (end: ">"))
      draw.content((6.6, 3.55), text(size: 5pt)[Interrupt])
      draw.content((6.6, 2.95), text(size: 5pt)[Vector])
      cbox(9.3, 2.8, 1.3, 0.8, [Interrupt \ Vector], fs: 5pt)
      draw.line((8.8, 3.2), (9.3, 3.2), stroke: 0.7pt + rgb("#E07A00"), mark: (end: ">"))
    })
  ]
])

=== Programmable Interrupt Controller (PIC)

The PIC prioritizes multiple interrupt sources so that at any time the highest priority interrupt is presented to the core CPU for processing. Cortex-M integrates this function in the NVIC.

=== Nested Interrupts

- Priority logic selects the highest eligible request.
- The PIC stores the priority level of that interrupt in an internal register.
- When a subsequent interrupt occurs, the priority is checked against current priority.
- *Nested interrupts*: a higher priority interrupt source can preempt the processing of a lower priority interrupt.

=== Pending Bits and Masking

- *Pending bits* record interrupts awaiting service.
- *Masking*: enable bits determine which sources may interrupt.
- The highest-priority interrupt is called the *nonmaskable interrupt* (NMI); the NMI cannot be turned off.
- E.g., usually reserved for interrupts caused by power failures to save critical state in nonvolatile memory, turn off I/O devices…

=== Interrupt Vector Table

- Each interrupt has a *vector number*.
- The vector number indexes the vector table.
- The selected entry holds the *interrupt vector*: i.e., the memory address of the interrupt handler.

#raw(block: true, lang: "c", "void handler1() {\n  ...\n}")

#tbl(2, head: ([Vector], [Handler]),
  [Vector 0], [Handler 1],
  [Vector 1], [Handler 3],
  [Vector 2], [Handler 4],
  [Vector 3], [Handler 2])

== Overhead of Interrupts

- An interrupt causes a change in the program counter: incurs a branch penalty.
- Interrupt might automatically store some CPU registers: requires extra cycles.
- Acknowledge the interrupt and obtain the interrupt vector: requires extra cycles.
- The interrupt handler overhead: saves and restores CPU registers that were not automatically saved; the interrupt return instruction restores the automatically saved state, incurs a branch penalty.

=== Interrupt Response Time

The time required for the hardware to respond to the interrupt, obtain the vector, save state and so on cannot be changed by the programmer.

#asciifig("
Interrupt        Interrupt
  |                |
  v                v
--+----------------+------------------> Time
  |<-Response Time->|
  |<-Latency->|<Processing Time>|
", [Interrupt latency, response time and processing time.])

#keypt("Time between interrupts", [
  Interval between successive interrupts, relative to latency, response time and processing time.
])