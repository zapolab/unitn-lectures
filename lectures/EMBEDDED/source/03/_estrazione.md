# Estrazione interne — EMBEDDED / 03

File unico: `Lecture-3.pdf` (45 pagine, 720x405.36 pt, non cifrato, testo estraibile).
Strumenti: `pdftotext -layout`, `pdftoppm -r 120` per ispezione visiva figure.

Mappa pagina ↔ contenuto:

| pg | titolo | contenuto | tipo |
|----|--------|-----------|------|
| 1 | Embedded Program Development (title) | slide titolo | scartata (amministrativa) |
| 2 | Typical Program-generation Flow | Compile→Assemble→Link→Download; executable/program image in program memory; figura toolchain+processor | testo+figura |
| 3 | Program image and memory sections | linker fonde sezioni object-file in un'unica image, bytes con indirizzi definiti; stessa figura pg2 | testo+figura |
| 4 | Cortex-M4 memory map example | chip silicon, AHB/APB, regioni; pannello indirizzi | figura |
| 5 | Cortex-M4 Program Image | definizione program image; layout global memory + vector table addr | testo+figura |
| 6 | Cortex-M4 Program Image | cosa include il program image (4 voci) | testo+figura |
| 7 | Cortex-M4 Program Image | Vector table (entry 0/1/later) | testo+figura |
| 8 | Cortex-M4 Program Image | C Start-up code | testo+figura |
| 9 | Cortex-M4 Program Image | Program code / C library code | testo+figura |
| 10 | Systems Initialization (in ARM Cortex Processors) | sequenza post-reset; figura flusso reset | testo+figura |
| 11 | Program Image in Global Memory | code region 0x0–0x1FFFFFFF; SRAM region; figura global memory | testo+figura |
| 12 | Cortex-M4 memory map example | identica a pg4 | duplicato |
| 13 | How is Data Stored in SRAM? | static data / stack / heap; figura layout SRAM | testo+figura |
| 14 | Memory placement begins with mutability | mutabilità: RO nonvolatile vs volatile; code snippet | testo+figura |
| 15 | Memory placement begins with mutability | lifetime: statico / automatico / dinamico; stesso snippet | testo+figura |
| 16 | Executable Image Sections | .data/.sdata, .bss/.sbss, .const | testo |
| 17 | Executable Image Sections | tabella section/content/storage at reset/runtime | tabella |
| 18 | Program Memory Use | RAM vs Flash ROM + snippet; animazione | testo+figura |
| 19 | Program Memory Use | identica a pg18 | duplicato (animazione) |
| 20 | Program Memory Use | identica a pg18 | duplicato (animazione) |
| 21 | Program Memory Use | identica a pg18 | duplicato (animazione) |
| 22 | Program Memory Use | identica a pg18 | duplicato (animazione) |
| 23 | Program Memory Use | identica a pg18 | duplicato (animazione) |
| 24 | Program Memory Use | mapping variabili→sezioni, evidenzia `WHY?` | testo+figura |
| 25 | C Run-Time Start-Up Module | post-reset MCU init; fill-with-zeros / copy | testo+figura |
| 26 | Loading Program Image | trasferimento host→target; burn ROM/flash; JTAG | testo |
| 27 | An Example Booting Procedure | reset vector → bootstrap code; motivo jump | testo |
| 28 | An Example Booting Procedure | registri IP/SP; ROM/RAM layout | testo+figura |
| 29 | An Example Booting Procedure | step (1) | testo+figura |
| 30 | An Example Booting Procedure | step (2) | testo+figura |
| 31 | An Example Booting Procedure | step (3) .data copiata in RAM | testo+figura |
| 32 | An Example Booting Procedure | step (4) .bss riservata | testo+figura |
| 33 | An Example Booting Procedure | step (5) stack riservato, SP settato | testo+figura |
| 34 | An Example Booting Procedure | boot completo | testo+figura |
| 35 | Linker Map File | linker crea single executable image; linker directives; figura catena | testo+figura |
| 36 | Linker Command File | MEMORY e SECTION; memory map figura | testo+figura |
| 37 | Linker Command File | MEMORY directive definisce/format | testo+figura |
| 38 | Linker Command File | esempio MEMORY {} | codice+figura |
| 39 | Linker Command File | SECTION directive: cosa dice | codice |
| 40 | Linker Command File | esempio file1.o/file2.o → executable image | testo+figura |
| 41 | Linker Command File | SECTION{} completo | codice+figura |
| 42 | Linker Command File | annotazione combine .text | codice+figura |
| 43 | Linker Command File | annotazione loader > FLASH | codice+figura |
| 44 | Linker Command File | annotazione GROUP ALIGN(4) >RAM | codice+figura |
| 45 | Linker Command File | MEMORY{} + immagine finale | codice+figura |

Pagine scartate: 1 (titolo), 12 (duplicato di 4), 19–23 (duplicati animazione di 18).
Slide mute: nessuna (tutte con testo). Figure raster intrinseche: nessuna (diagrammi vettoriali ridisegnabili).