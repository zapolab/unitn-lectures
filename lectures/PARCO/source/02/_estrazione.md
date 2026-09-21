# _estrazione.md — mappa interna slide↔contenuto (NON deliverable)

PDF: IntroPARCO-L2.pdf — 43 pagine, 959.76x540pt, testo nativo (pdftotext ok), non cifrato.
Lingua slide: inglese → riassunto in inglese, termini tecnici invariati.

| pag | titolo | contenuto utile | figure | stato |
|-----|--------|-----------------|--------|-------|
| 1 | Introduction to Parallel Computing / Lecture 2 Recap of Computer Architecture | titolo lezione | logo | titolo |
| 2 | Outline | elenco argomenti corso | - | corso/organizzativo: escluso |
| 3 | Today's computers look different | immagine | foto | muta/decorativa |
| 4 | But if you look inside | immagine | foto | muta/decorativa |
| 5 | Architecture model | Von Neumann / Princeton; stored-program; istruzioni+dati stessa memoria/address space; CPU FDE cycle e data path | foto John von Neumann | contenuto |
| 6 | Von Neumann Architecture | 4 componenti; RAM per istruzioni+dati; control unit; ALU; I/O | - | contenuto |
| 7 | Fetch-Decode-Execute cycle | 6 passi FDE | blocco CPU (control/ALU/registers/memory/IO) + flow IR→PC→Load→Execute loop | contenuto |
| 8 | Data Path | ALU arith/bitwise int; FPU float; data movement reg-mem, reg-reg | datapath (registers A+B/A/B, ALU input bus, ALU, output reg) + blocco CPU | contenuto |
| 9 | Data Path (dup) | come p8 + Definizione datapath | idem p8 | contenuto (definizione nuova) |
| 10 | Different organization | 8 processori e n. core | 8 die shot | contenuto → reso come tabella |
| 11 | FUJITSU Processor A64FX | superscalar OoO; Armv8-A + SVE; 52 core (4 assistant); 4 CMG; CMG spec 13 core, L2 8MiB, Mem 8GiB 256GB/s; Tofu; PCIe Gen3; HBM2; NoC | blocco A64FX | contenuto |
| 12 | FUJITSU Processor A64FX | solo immagine | die | muta |
| 13 | GPU and accelerators | NVIDIA AMPERE GA102 arch | die GPU | contenuto (figura) |
| 14 | GPU and accelerators | dettaglio SM: warp scheduler, reg file, FP32/INT32, tensor core 3rd gen, LD/ST, SFU, L1/shared 128KB, Tex, RT core 2nd gen | schema SM | contenuto |
| 15 | Many other systems | immagine | foto | muta/decorativa |
| 16 | Emerging Systems | PUM (bulk bitwise, [Seshadri17]); PNM (CU nello stack layer); 3D stacked DRAM, TSV, logic layer | schema PIM | contenuto |
| 17 | Flynn's Taxonomy of Computers | griglia 2x2 SI/SD; "Other Classifications" | griglia SISD/SIMD/MISD/MIMD | contenuto |
| 18 | Flynn's Taxonomy (dup) | SISD/SIMD/MISD/MIMD definizioni | - | contenuto (definizioni) |
| 19 | Flynn's Taxonomy (dup identico p18) | idem | - | duplicato: escluso |
| 20 | Single Instruction on a single Data | SISD seriale, in-order, esempi | - | contenuto |
| 21 | Latency and Throughput | definizioni latency/throughput; tradeoff | - | contenuto |
| 22 | Understanding the limits of VN | 4 fattori performance | - | contenuto |
| 23 | Understanding the limits of VN (dup p22) | idem | - | duplicato: escluso |
| 24 | Understanding the limits of VN | FDE bottleneck | flow FDE | contenuto |
| 25 | Fetch Decode Execution Design | clock, MIPS, CPI, FLOP/s; CPU time formula | - | contenuto |
| 26 | Implicit Parallelism: Trends in Microprocessor Architectures | implicit vs explicit; clock scaling limitata da power/thermal; transistors; HW-level parallelism: ILP+superscalar, OoO+pipelining, vectorization | - | contenuto |
| 27 | Instruction Level Parallelism (ILP) | definizione ILP; execution/functional unit; componenti ALU AGU FPU LSU BEU; superscalar many EUs | - | contenuto |
| 28 | Example of Superscalar execution | def superscalar; dependency; a=x*x+y*y+z*z; ILP=3/1/1; assembly; dep/indep instr | grafo dataflow + assembly | contenuto |
| 29 | Modern architectures | single-core superscalar=SISD; speculative, OoO, pipeline, vectorization SIMD | - | contenuto |
| 30 | Pipeline | obiettivo ridurre latency e massimizzare risorsa; washing clothes example | foto elettrodomestici | contenuto |
| 31 | Pipeline | space-time: T0-T3, I0/I1; inputs=instruction streams | diagramma pipeline | contenuto |
| 32 | Pipeline | balanced pipeline; throughput bound=1/max(t); latency bound=#stages*max(t) | - | contenuto |
| 33 | Pipeline | unbalanced: w=5s, d=10s, f=5s, c=10s | foto | contenuto |
| 34 | Pipeline | 5 loads, totale 70s; latency issue; soluzione: ogni stage = longest | - | contenuto |
| 35 | Pipeline | tutti gli stage 10s | foto | contenuto |
| 36 | Pipeline | balancing | foto | contenuto |
| 37 | Pipeline | totale 80s; latency 40s/load; throughput 1 load/10s ~6/min; migliorare latency+throughput insieme? | - | contenuto |
| 38 | Pipeline | increase FU: washer 10s; dryers d1=4s+d2=6s; folding 5s; closets c1=4s+c2=6s | foto | contenuto |
| 39 | Pipeline | bounding latency: d1,d2 6s; c1,c2 6s | foto | contenuto |
| 40 | Pipeline | totale 60s; latency 36 (6*6)s/load; throughput 1 load/6s ~10/min | - | contenuto |
| 41 | Pipeline | fetch da memoria bottleneck; prefetch buffer; fetch+execution; molte parti in parallelo | - | contenuto |
| 42 | Pipeline | simple 5 stage pipeline: IF/ID/OF/EX/WB + space-time | 2 diagrammi | contenuto |
| 43 | References | bibliografia (Pacheco cap.2) | - | escluso (bibliografia) |

## Pagine scartate / non riassunte
- 1: frontespizio (titolo usato solo per header/titolo).
- 2: outline del corso (organizzazione) → escluso.
- 3, 4, 15: solo immagini decorative.
- 12: slide muta (solo immagine).
- 19, 23: duplicati esatti di 18, 22.
- 43: bibliografia.
