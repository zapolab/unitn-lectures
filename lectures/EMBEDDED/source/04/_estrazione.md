# Estrazione — EMBEDDED / 04 (Lecture-4.pdf)

PDF unico: `Lecture-4.pdf`, 42 pagine, 720x405.36 pt (16:9), non cifrato.
Strumenti: `pdftotext -layout` (testo), `pdftoppm` (render per ispezione figure).
`pdfimages -list`: solo p1 (foto JPEG 624x621) e p40 (2 icone 141x74 / 139x71 con smask). Nessuna scansione: testo nativo.

## Mappa pagina -> contenuto

| pag | titolo | contenuto | note |
|-----|--------|-----------|------|
| 1 | Processors and I/O | slide titolo + foto University of Trento | **SCARTATA** (presentazione/docente) |
| 2 | Processor and Input and Output Devices | peripheral (Timers/UART/Sensors) + fig chip silicon | figura ridisegnata |
| 3 | How Do They Communicate? | bus matrix on-chip; external interfaces off-chip + fig chip | stessa fig p2 |
| 4 | How Do They Communicate? | ogni peripheral espone registri; CPU legge/scrive; interrupt lines + fig CPU/reg/device | figura |
| 5 | How Do They Communicate? | data registers / status & control registers + fig CPU/reg/device | stessa fig p4 |
| 6 | Two architectural models for device access | I/O instructions vs memory-mapped + tabella (4 col) | tabella |
| 7 | ARM loads and stores access device registers | codice assembler + note | codice |
| 8 | C requires volatile access to device registers | pointer + `volatile` + nota | codice |
| 9 | C requires volatile access to device registers | funzioni read/write + uso | codice |
| 10 | Register definitions should express width and intent | tabella concern/reason | tabella |
| 11 | Polling (Busy-Wait) I/O | definizione busy-wait/polling | |
| 12 | Polling an output device (Example) | codice + nota CPU bloccata | codice |
| 13 | A polling-based input-to-output loop (Example) | codice + bullet | codice |
| 14 | Interrupt-driven I/O | motivazione + meccanismo handler | |
| 15 | Several signals control the interrupt process | interrupt request/acknowledge/handler + fig CPU/device | figura |
| 16 | Interrupt entry changes control flow | salvataggio PC + tabella phase/action | tabella |
| 17 | Cortex-M interrupt entry | context save, vector table, C handler | |
| 18 | A minimal input interrupt handler in C | handler C + bullet | codice |
| 19 | Interrupts (Example) | input/output handlers C + achar/gotchar | codice |
| 20 | Interrupts (Example) | main C + bullet | codice |
| 21 | A circular buffer separates producer and consumer timing | head/tail + buffer vuoto | figura |
| 22 | ... | buffer [a] | figura |
| 23 | ... | buffer [a..g] head/tail | figura (rappresentativa) |
| 24 | ... | buffer [b..g] head/tail | figura |
| 25 | ... | buffer [b..h] tail/head | figura |
| 26 | Interrupts (Example) - With Circular Buffer | codice buffer_empty/full/nchars | codice |
| 27 | Interrupts (Example) - With Circular Buffer | codice buffer_put/get | codice |
| 28 | Input ISR adds data and starts output | codice input_handler | codice |
| 29 | Input ISR adds data and starts output | codice output_handler | codice |
| 30 | Interrupts (Example) - With Circular Buffer | timeline foreground/ISR | figura |
| 31 | Bugs | save/restore registri | |
| 32 | Bugs | read-modify-write + codice | figura |
| 33 | Bugs | spiegazione RMW + timeline | figura |
| 34 | Interrupt handlers should do bounded work | 5 bullet | |
| 35 | Interrupts - Implementaton | IRQ check + fig CPU/device | figura (stessa p15) |
| 36 | Priorities and Vectors | priorità + vettori + fig sensors/CPU | figura |
| 37 | Programmable interrupt controller (PIC) | PIC/NVIC + fig sensors/PIC/CPU | figura (full) |
| 38 | Priorities and Vectors | priority logic + nested interrupts | |
| 39 | Priorities and Vectors | pending bits, masking, NMI | |
| 40 | Interrupt Vector Table | vector number/vector + fig PIC/CPU/table | figura |
| 41 | Overhead of Interrupts | elenco overhead | |
| 42 | Overhead of Interrupts | Interrupt Response Time + timeline | figura |

## Pagine scartate
- p1: slide di presentazione (titolo corso, docente, università). Fuori scope.

## Figure
- Ridisegno Typst: chip silicon (p2/3); CPU-status/data-device (p4/5/15/35); circular buffer (p21-25); tabella vettori (p40); diagramma priorità/PIC (p36-39, ASCII).
- ASCII (timeline/flussi): foreground vs ISR (p30); read-modify-write (p32/33); Interrupt Response Time (p42).
- Raster: nessuno (la foto p1 e le icone p40 sono amministrative/decorative; escluse).
