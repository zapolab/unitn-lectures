# Mappa concetti — EMBEDDED / 06

`concetto | dove (pag) | sezione | stato`

| concetto | dove | sezione | stato |
|----------|------|---------|-------|
| Pin multiplexing | 2 | == General-purpose and peripheral pin functions | nuovo |
| GPIO mode vs Peripheral mode | 2 | == General-purpose and peripheral pin functions | nuovo |
| GPIO port (memory-mapped) | 3 | == GPIO (General Purpose I/O) | nuovo |
| GPIO Controller block | 3–4 | == GPIO (General Purpose I/O) | nuovo |
| 3 registri: Data IN/Out, Direction | 4 | == GPIO Direction and Data Registers | nuovo |
| MSP GPIO Ports (P1–P10, PJ, 8 pin) | 5 | == MSP GPIO Ports | nuovo |
| Registri Port1 + base address | 6 | == Commonly Used Registers of Port1 | nuovo |
| Dettagli campi registro (PxDIR/OUT/REN/SEL0/SEL1/IN) | 10,13,14,15,17 | == Commonly Used Registers of Port1 (sotto: Register field descriptions) | approfondimento |
| Bit-mask operations | 7 | == Bit-mask Operations | nuovo |
| GPIO as Input (buttons P1.1/P1.4) | 8 | == GPIO as Input | nuovo |
| Configure User Button (P1.1) | 9–17 | == Configure User Button (P1.1) | nuovo (reveal incrementale) |
| Pullup/Pulldown resistors | 11–12 | == Pullup and Pulldown Resistors | nuovo (p12 aggiunge info → stesso blocco) |
| Lab #1 | 18 | == Lab #1 | nuovo |
| Bouncing GPIO Input + strategie | 19–20 | == Bouncing GPIO Input | nuovo (p20 aggiunge tabella) |
| Lab #2 | 21 | == Lab #2 | nuovo |
| Lab #3 + domanda simultaneità | 22–23 | == Lab #3 | nuovo (p23 aggiunge domanda) |
| MSP432 Port Reference (divider) | 24 | == MSP432 Port Reference | nuovo |
| Registri Port2/3/4 | 25–27 | == MSP432 Port Reference (=== Port2/Port3/Port4) | riferimento (stesso concetto, dati diversi) |
| Alternate Pin Functions meaning | 28 | == MSP432 Port Reference (=== Alternate Pin Functions) | nuovo |
| Tabelle pin Port1–Port10 | 29–38 | == MSP432 Port Reference | riferimento |

## Note antidup
- "Configure User Button (P1.1)" ripetuto su 8 slide: reveal incrementale dello stesso codice → unica sezione con sequenza di step e codice finale.
- "Pullup and Pulldown Resistors" (11,12): p12 aggiunge info → unico blocco.
- "Bouncing GPIO Input" (19,20): p20 aggiunge tabella strategie → unico blocco.
- "Lab #3" (22,23): p23 aggiunge domanda → unico blocco.
- "Commonly Used Registers of Port2/3/4" (25–27): riferimenti con dati distinti; mantenuti come sezioni separate nella sezione "MSP432 Port Reference" per non spostare il capitolo.
