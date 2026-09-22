# Estrazione — EMBEDDED / 02 — Lecture-2.pdf (59 pagine, 720x405pt)

Fonte unica: `Lecture-2.pdf`. Output: `EMBEDDED-02.typ` → `../../EMBEDDED-02.pdf`.
Lingua slide: inglese → riassunto in inglese.

## Mappa pagina → contenuto
- 1: TITOLO — "ARM Cortex M4 Architecture", docente+università. SCARTATA (amministrativa); titolo usato per l'header.
- 2: A Review of CPU Architecture — review hardware architecture = interfaccia per l'embedded software; capire features del processore; basata su ARM University material. Link YouTube (ESCLUSO, link a piattaforma).
- 3: The processor is the software interface — software vede registers, memory regions, exceptions, instructions; architecture = regole che il codice deve seguire.
- 4: A familiar class of IoT platforms — 32-bit ARM Cortex-M4 MCUs (TI MSP432, STM32 Nucleo F4); different vendors, one common Cortex-M programming model. Foto schede (raster, non essenziali).
- 5: Arm architecture and ecosystem — Architecture (instruction set, registers, exception behavior, memory model); Processor core (implementa l'architettura come microarchitettura concreta, es. Cortex-M4); Microcontroller (core + memory, clocks, buses, peripherals da un vendor).
- 6: RISC and CISC — CISC: molte istruzioni complesse (es. string searching), formati di lunghezza variabile. RISC: meno istruzioni più semplici, load/store, operano solo su registri, pipeline efficiente.
- 7: Arm Architectures and Processors — Arm (Advanced RISC Machines), famiglia di architetture RISC, power efficiency, mobile, disegnata e licenziata a partner.
- 8: ARM Company — licenzia design, non produce chip; vendor aggiungono IP, fabbricano e vendono. Pipeline: Arm (architetture+IP) → Chip vendor (integra core+memory+peripherals+vendor IP) → Foundry (fabrica il SoC). An architectural license consente di costruire una microarchitettura compatibile propria.
- 9: Arm-based SoC combines reusable IP — scegli IP blocks (processor, memory, bus, peripheral); integra in un coherent memory/interrupt system; verifica prima della fabbricazione. IP libraries: Cortex-A9/R5/M4, ARM7/9/11; DRAM/FLASH/SRAM ctrl; AXI/AHB/APB bus; GPIO, I/O, Timer. SoC: Arm processor, ROM, RAM, System bus, Peripherals, External Interface. Fasi: Licensable IPs → SoC Design → Chip Manufacture.
- 10: Cortex families target different constraints — Cortex-A application (full OS, smartphones/TV/smart books); Cortex-R real-time (reliability, automotive braking, powertrains); Cortex-M microcontroller (cost sensitive, deterministic, microcontrollers/smart sensors). Corso = Cortex-M per IoT.
- 11: Arm Cortex-M Series (benefits) — energy-efficiency/battery life; smaller code (flash/memory cost); lower silicon cost (physical space); ease of use/development (short cycles, reuse, tools); broad vendor ecosystem.
- 12: Arm Cortex-M Series (families) — M0/M0+ minimal cost/power/area, simple sensing/control; M3/M4/M7 data intensive/higher performance, DSP; M4/M7 integrate DSP + accelerated floating point. "Choosing a processor core is only one decision. Memory, peripherals, package, power modes often dominate final MCU choice."
- 13: Architectures and Microarchitecture — architecture = caratteristiche vere per tutte le implementazioni; processor = implementazione; diversi processor stessa architettura con performance/energia diverse. ISA: instructions, registers, memory model, exceptions. Microarchitecture: pipeline depth, bus widths, caches, clock frequency.
- 14: ARM processors implement ARM architectures — evoluzione. Armv4/v4T, Armv5/v4E, Armv6, Armv7 (A/R/M), Armv8 (A/R/M). Esempi: Cortex-A9 (v7-A), Cortex-R4 (v7-R), Cortex-M4 (v7-M), Cortex-A53/A57 (v8-A); Armv6-M (Cortex-M0, M1); Armv8-M. Processori: Arm7TDMI, Arm9926EJ-S (testo estratto, forse ARM926EJ-S → DA VERIFICARE), Arm1136.
- 15: Arm Cortex-M Series Family TABLE — Processor / Arm Architecture / Core Architecture / Hardware Multiply / Hardware Divide / DSP Extensions / Floating Point. M0: Armv6-M,Von Neumann,1 or 32 cycle,No,No,No. M0+: idem. M3: Armv7-M,Harvard,1 cycle,Yes,No,No. M4: Armv7E-M,Harvard,1 cycle,Yes,Yes,Optional. M7: idem.
- 16: Von Neumann Architecture — memory holds data+instructions; CPU fetch/decode/execute; registers PC, IR, general-purpose.
- 17: Harvard Architecture — separate memories data/program; separate bus; due fetch simultanei; PC punta a program memory; no self-modifying code; DSP usano Harvard (bandwidth).
- 18: Cortex-M4 balances signal processing and control — DSP features (single-cycle MAC, optional FP); low power (battery, low-power states); enhanced determinism (fast exception handling, interrupt in known cycles).
- 19: Cortex-M4 Processor Features — 32-bit RISC core load-store+Harvard; three-stage pipeline fetch/decode/execute con branch speculation; low power WFI/WFE + interrupt wake-up; DSP multiply/MAC/saturation/optional FPU; debug breakpoints/watchpoints/optional execution trace.
- 20: A microcontroller surrounds the core with a system — diagramma Core / Bus matrix / Peripherals.
- 21: Cortex-M4 core subsystems at a glance — Core; optional FPU, WIC, NVIC, ETM, Debug Access Port, MPU, Serial Wire Viewer, Flash patch, Data watchpoints; Bus matrix; Code interface; SRAM and peripheral interface.
- 22: Cortex-M4 Block Diagram (core/pipeline) — core: internal registers, ALU, data path, control logic; three-stage pipeline fetch/decode/execute; alcune istruzioni multi-ciclo; speculative prefetch da branch target. Tabella timing pipeline (Instruction 1-4).
- 23: stesso block diagram di 21, senza testo nuovo → SCARTATA.
- 24: Block Diagram — NVIC nested interrupts (priorità); WIC sleep mode + power up su interrupt; MPU protezione memoria (read-only, no accesso user app).
- 25: block diagram con annotazioni (real-time program tracing, data tracing) — solo etichette.
- 26: Block Diagram — ETM registra instruction execution; DWT osserva data accesses; SWV streamma trace data su low-pin interface; Debug subsystem (debug control, breakpoints, watchpoints); debug event → halted state per analizzare register values e flags.
- 27: stesso block diagram di 21, senza testo nuovo → SCARTATA.
- 28: Block Diagram — bus interconnect: data transfer management; trasferimenti simultanei su bus diversi; AHB-Lite (high bandwidth); APB (low-power: timers, interrupt controllers, UARTs, I/O ports); bus bridges (AHB-to-APB) per single global memory space.
- 29: Programming Model — set di registri usabili dai programmi = programming model/programmer model; CPU ha altri registri interni non disponibili.
- 30: Arm Cortex-M4 Processor Registers — registri per dati temporanei veloci; load-store architecture (load→process→write back); Cortex-M4: register bank 16x32-bit (13 general-purpose); special registers.
- 31: Cortex-M4 Registers — register bank R0-R15; general purpose R0-R12 (low R0-R7, high R8-R12); SP R13 banked (MSP/PSP); LR R14; PC R15; PSR (APSR/EPSR/IPSR); special: PRIMASK, FAULTMASK, BASEPRI, CONTROL.
- 32: Cortex-M4 Registers — R0-R12 general purpose (low/high); R13 SP (stack address, context switching); PC (current instruction, +4 each op tranne branch). Nota: compiler assegna registri secondo calling convention e optimization strategy. Diagramma stack (PUSH/POP, heap, code).
- 33: Cortex-M4 Registers — R14 LR (return address di subroutine/function call; PC carica da LR al ritorno). Diagramma call/return.
- 34: Special Registers — xPSR combined PSR (APSR+IPSR+EPSR); info su program execution e ALU flags. Bit layout.
- 35: Special Registers — APSR flags: N negative, Z zero, C carry, V overflow, Q sticky saturation.
- 36: Special Registers — APSR + esempio saturating arithmetic: 255+1 normale → 0 (overflow); saturating → 255 (clamped). Uso in audio/video per signal levels.
- 37: Arm Cortex-M4 Memory Map — memory map = organizzazione dell'address space; byte-addressable con indirizzi 32-bit; 4 GB; regioni con usi raccomandati; portabilità tra device; definibile dall'utente tranne indirizzi fissi (internal private peripheral bus).
- 38: memory map example (diagramma completo, etichette regioni).
- 39: memory map + annotazione Code region (program code, anche data memory es. on-chip FLASH).
- 40: memory map + annotazione SRAM region (dati: heaps/stacks; anche program code).
- 41: memory map + annotazione Peripheral region (AHB/APB peripherals, on-chip peripherals).
- 42: memory map example, nessuna annotazione nuova → SCARTATA.
- 43: Arm Cortex-M4 Memory Map TABLE — Vendor specific Memory (0xE0100000-0xFFFFFFFF, reserved); PPB (0xE0000000-0xE00FFFFF, 512MB, NVIC/SCS); External device (0xA0000000-0xDFFFFFFF, 1GB, SD card); External RAM (0x60000000-0x9FFFFFFF, 1GB, DDR/FLASH/LCD); Peripherals (0x40000000-0x5FFFFFFF, 512MB, AHB/APB); SRAM (0x20000000-0x3FFFFFFF, 512MB, SRAM/SDRAM); Code (0x00000000-0x1FFFFFFF, 512MB, on-chip FLASH).
- 44: memory map + PPB internals: ROM table; External PPB (ETM, Trace port interface unit); Reserved; System Control Space incl. NVIC (Internal PPB); Reserved; Fetch patch and breakpoint unit; Data watchpoint and trace unit; Instrumentation trace macrocell.
- 45: Memory Map regions descrizioni — External RAM (large data blocks/caches, off-chip, slower than on-chip SRAM); External device (map external devices, e.g. SD card); PPB (access internal+external processor resources).
- 46: Bit-band Operations — singolo load/store accede a un singolo bit; normal read-modify-write vs bit-band direct write single bit.
- 47: Bit-band Alias address — SRAM e Peripheral regions hanno bit band + bit band alias. SRAM: 1MB bit-band @0x20000000, 31MB non-bit-band, 32MB alias @0x22000000. Peripheral: 1MB @0x40000000, 31MB non-bit-band, 32MB alias @0x42000000. Ogni bit mappato one-to-one.
- 48: Bit-band Alias — each bit has address multiple of 4; 1 byte = 8 bits → 32 addresses.
- 49: Bit-band Alias — formula bit_word_addr = bit_band_base + (byte_offset × 32) + (bit_number × 4). Esempi 0x20000000→0x22000000, 0x2200000C, 0x22000018.
- 50: Bit-band Alias — diagramma byte/bit.
- 51: Bit-band Alias — bit[3] di 0x20000000 → alias 0x2200000C; per settare bit[3] scrivere 1 a 0x2200000C; programmer/HAL traduce con formula. Esempi 0x20000004→0x22000080, 0x20000008→0x22000100.
- 52: Bit-band Operation Example — read-modify-write (LDR/ORR.W/STR, race conditions possibili) vs bit-band (LDR/MOV/STR, atomic single-bit guarantee).
- 53: Benefits of bit-band — faster, fewer instructions; atomic, avoid hazards; esempio ISR che modifica stessa word durante RMW → data conflict / overwrite.
- 54: Cortex-M4 Endianness — order of bytes; little endian (lowest byte in bit0-7); big endian (lowest byte in bit24-31); Cortex-M4 supporta entrambi; endianness solo a hardware level. Tabella word/byte.
- 55: Arm and Thumb — early Arm 32-bit instruction set (Arm instructions), powerful, larger program memory vs 8/16-bit, larger power consumption. Esempio ADDS Rd,Rd,#Constant encoding.
- 56: Arm and Thumb — ADD Rd,#Constant Thumb code 16-bit; ADDS ARM 32-bit; stessa operazione con meno bit.
- 57: Arm and Thumb — Thumb-1 16-bit (subset), ha corrispondente 32-bit ARM; better code size; a volte più istruzioni → più lento (fetch slower); code size -30%, performance -20%.
- 58: Arm and Thumb — mix Arm/Thumb-1: 32-bit Arm (performance) + 16-bit Thumb-1 (code density); multiplexer commuta Arm/Thumb state con switching overhead; gestito da processor e compiler. T bit: 0 Arm, 1 Thumb.
- 59: Arm and Thumb — Thumb-2: 32-bit Thumb + 16-bit Thumb-1; code size -26% vs 32-bit Arm con performance simile; copre quasi tutta la funzionalità Arm; Thumb-2 per lo più unconditional, Arm quasi tutti conditional.

## Slide mute / decorative
- 1 (titolo), 23/27/42 (ripetizioni diagramma). Foto schede p4, immagini decorative.

## Figure di contenuto da ridisegnare
- p5 architecture/core/MCU (testo integrale)
- p6 RISC vs CISC (testo)
- p8 Arm→vendor→foundry pipeline
- p9 IP libraries/SoC/manufacture
- p14 evoluzione architetture Arm (testo)
- p16 Von Neumann
- p17 Harvard
- p19 features boxes (testo)
- p20 core + bus matrix + peripherals
- p21 core subsystems block diagram
- p22 pipeline timing (tabella)
- p31 register bank
- p33 subroutine call/return
- p34 xPSR bit layout (tabella)
- p38-43 memory map
- p44 PPB internals
- p47 bit-band regions
- p49/51 formula + translation examples
- p53 race condition
- p54 endianness (tabella)
- p55/56 encoding (testo)
- p58 Arm/Thumb mux
