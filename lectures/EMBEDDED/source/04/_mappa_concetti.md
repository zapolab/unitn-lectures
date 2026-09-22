# Mappa concetti — EMBEDDED / 04

| concetto | dove | sezione | stato |
|----------|------|---------|-------|
| Peripherals e chip silicon | p2 | Processor and Input and Output Devices | origine |
| Bus matrix / external interfaces | p3 | Processor and Input and Output Devices | accodato (stessa sezione, fig condivisa) |
| Device registers (data / status & control) | p4-5 | How Do They Communicate? > Device registers | origine |
| Two architectural models (I/O vs MMIO) | p6 | How Do They Communicate? > Modelli architetturali | origine |
| ARM load/store su registri | p7 | Device register access in ARM and C > ARM loads/stores | origine |
| volatile in C | p8 | Device register access in ARM and C > C volatile access | origine |
| read/write helper functions | p9 | Device register access in ARM and C > C volatile access | accodato |
| Width/intent dei registri | p10 | Device register access in ARM and C > Register width and intent | origine |
| Polling / busy-wait | p11 | Polling (Busy-Wait) I/O | origine |
| Polling output example | p12 | Polling (Busy-Wait) I/O > Polling an output device | origine |
| Polling input->output loop | p13 | Polling (Busy-Wait) I/O > Polling-based input-to-output loop | origine |
| Interrupt-driven I/O | p14 | Interrupt-driven I/O | origine |
| Segnali interrupt (req/ack) | p15 | Interrupt-driven I/O > Signals controlling the interrupt process | origine |
| Interrupt entry / fasi | p16 | Interrupt-driven I/O > Interrupt entry changes control flow | origine |
| Cortex-M entry (context save) | p17 | Interrupt-driven I/O > Cortex-M interrupt entry | origine |
| Handler minimale C | p18 | Interrupt-driven I/O > Minimal input interrupt handler in C | origine |
| Esempio base interrupt | p19-20 | Interrupt-driven I/O > Interrupts example | origine |
| Circular buffer head/tail | p21-25 | A circular buffer separates producer and consumer timing | origine |
| Implementazione buffer | p26-27 | A circular buffer... > Buffer implementation | accodato |
| Input ISR | p28 | Interrupts example with circular buffer | origine |
| Output ISR | p29 | Interrupts example with circular buffer | accodato |
| Timeline foreground/ISR | p30 | Interrupts example with circular buffer > Foreground vs interrupt | accodato (figura) |
| Bugs save/restore | p31 | Bugs > Save and restore registers | origine |
| Read-modify-write race | p32-33 | Bugs > Read-modify-write race | origine |
| Bounded work | p34 | Interrupt handlers should do bounded work | origine |
| Interrupt implementation (IRQ) | p35 | Interrupts - Implementaton | origine |
| Priorities & vectors | p36 | Priorities and Vectors | origine |
| PIC / NVIC | p37 | Priorities and Vectors > Programmable interrupt controller (PIC) | origine |
| Priority logic / nested | p38 | Priorities and Vectors > Priority logic and nested interrupts | accodato |
| Pending/masking/NMI | p39 | Priorities and Vectors > Pending bits, masking, NMI | accodato |
| Interrupt vector table | p40 | Interrupt Vector Table | origine |
| Overhead interrupts | p41-42 | Overhead of Interrupts | origine |
