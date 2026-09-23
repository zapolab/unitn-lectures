# Estrazione — EMBEDDED / 06

Fonte: `Lecture-6.pdf` (38 pagine, 720x405.36 pt, non cifrato).
Strumenti: `estrai.sh` (pdftotext -layout + contact sheet), `pdftoppm` render mirati 130–220 dpi.
Nessun OCR necessario (layer testuale presente e leggibile).

## Mappa pagina ↔ contenuto

| pag | titolo | contenuto | stato |
|-----|--------|-----------|-------|
| 1 | General Purpose Input/Output (GPIO) | titolo, nome corso, autore | AMMINISTRATIVO (omessa) |
| 2 | General-purpose and peripheral pin functions | pin multiplexing, GP≠ mode vs peripheral mode, fig. pin mux | in-scope |
| 3 | GPIO (General Purpose I/O) | GPIO port = memory-mapped registers + circuitry, fig. controller | in-scope |
| 4 | GPIO Direction and Data Registers | 3 registers: Data IN/Out, Direction; PxDIR, PxOUT, PxIN | in-scope |
| 5 | MSP GPIO Ports | P1–P10, PJ, Simple/Digital I/O, Port J special, 8 pins | in-scope |
| 6 | Commonly Used Registers of Port1 | base address 0x4000 4C00, tabella 7 registri | in-scope |
| 7 | Bit-mask Operations | read-modify-write, tabella operazioni | in-scope |
| 8 | GPIO as Input | MSP432 Launchpad, P1.1 e P1.4, fig. user buttons + foto board | in-scope (foto board: figura non ridisegnabile) |
| 9 | Configure User Button (P1.1) | titolo | MUTA |
| 10 | Configure User Button (P1.1) | P1.1 input, BIT1, codice DIR, fig/table PxDIR | in-scope |
| 11 | Pullup and Pulldown Resistors | problema pin floating | in-scope |
| 12 | Pullup and Pulldown Resistors | pull-up per portare a ground, valori pin, fig pullup/pulldown | in-scope |
| 13 | Configure User Button (P1.1) | select pullup, codice OUT, fig/table PxOUT | in-scope |
| 14 | Configure User Button (P1.1) | enable pullup resistor, codice REN, fig/table PxREN | in-scope |
| 15 | Configure User Button (P1.1) | set GPIO mode, codice SEL0/SEL1, fig/table PxSEL0/PxSEL1 | in-scope |
| 16 | Alternate functions | alternate functions UART/SPI/I2C/timer, SEL1/SEL0 tab, fig mux | in-scope |
| 17 | Configure User Button (P1.1) | check input register, codice IN, while, fig/table PxIN | in-scope |
| 18 | Lab #1 | codice completo main, breakpoint | in-scope |
| 19 | Bouncing GPIO Input | mechanical bounce, fig timing | in-scope |
| 20 | Bouncing GPIO Input | how to handle in software, tab strategy | in-scope |
| 21 | Lab #2 | toggles Green LED when S1 pushed, fig buttons+LEDs | in-scope |
| 22 | Lab #3 | Green LED S1, Blue LED S2, fig buttons+LEDs | in-scope |
| 23 | Lab #3 | domanda switch simultanei, fig buttons+LEDs | in-scope |
| 24 | MSP432 Port Reference | divider | in-scope (sezione) |
| 25 | Commonly Used Registers of Port2 | tabella registri | in-scope |
| 26 | Commonly Used Registers of Port3 | tabella registri | in-scope |
| 27 | Commonly Used Registers of Port4 | tabella registri | in-scope |
| 28 | Alternate Pin Functions | PxSEL1.y/PxSEL0.y meaning | in-scope |
| 29 | Port 1 Alternative Pin Functions | tabella P1.0–P1.7 | in-scope |
| 30 | Port 2 Alternative Pin Functions | tabella P2.0–P2.7 | in-scope |
| 31 | Port 3 Alternative Pin Functions | tabella P3.0–P3.7 | in-scope |
| 32 | Port 4 Alternative Pin Functions | tabella P4.0–P4.7 | in-scope |
| 33 | Port 5 Alternative Pin Functions | tabella P5.0–P5.7 | in-scope |
| 34 | Port 6 Alternative Pin Functions | tabella P6.0–P6.7 | in-scope |
| 35 | Port 7 Alternative Pin Functions | tabella P7.0–P7.7 | in-scope |
| 36 | Port 8 Alternative Pin Functions | tabella P8.0–P8.7 | in-scope |
| 37 | Port 9 Alternative Pin Functions | tabella P9.0–P9.7 | in-scope |
| 38 | Port 10 Alternative Pin Functions | tabella P10.0–P10.5 | in-scope |

## Pagine mute / scartate
- p1: amministrativa (presentazione corso + autore).
- p9: slide di transizione, nessun contenuto in-scope.

## Figure
- p2: selettore funzione (multiplexer) → ridisegnata (fletcher).
- p3/p4: GPIO Controller block diagram → ridisegnata (fletcher).
- p5: pinout chip MSP432 → non ridisegnabile fedelmente (≈100 etichette pin); info testuali riportate.
- p8/p21/p22/p23: foto board LAUNCHPAD (p8) e schematici User Buttons / Buttons and LEDs → schematici ridisegnati (fletcher/asciifig).
- p12: Pullup/Pulldown Mode → ridisegnata (fletcher).
- p19/p20: timing diagram del bounce → ridisegnata (cetz).

## Divergenze estratto↔render (corrette dal render)
- p14: etichetta tabella PxREN = **Table 10-8** (pdftotext dava "Table 10-4").
- p13: PxOUT, per input mode con pullup/pulldown abilitati: **0b = Pulldown selected, 1b = Pullup selected** (pdftotext invertiva i due valori).
