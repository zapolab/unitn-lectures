// ===== PALETTE =====
#let ink     = rgb("#1F2328")
#let primary = rgb("#1B4965")
#let accent  = rgb("#B45309")
#let defcol  = rgb("#2A6F6A")
#let danger  = rgb("#9B1C1C")
#let panel   = rgb("#F2F5F7")
#let headbg  = rgb("#E9EFF3")
#let rule    = rgb("#C7D3DB")
#let muted   = rgb("#5A6B76")

#set page(
  paper: "a4",
  margin: (x: 13mm, top: 12mm, bottom: 13mm),
  columns: 2,
  numbering: "1",
  header: context {
    set text(size: 6.6pt, fill: muted)
    block(width: 100%)[
      #grid(columns: (1fr, auto),
        [Recap of Computer Architecture],
        [PARCO-02])
      #v(1.5pt)
      #line(length: 100%, stroke: 0.4pt + rule)
    ]
  },
)

#set text(font: "New Computer Modern", size: 8.4pt, lang: "en",
         fill: ink, hyphenate: true)
#set par(justify: true, leading: 0.55em, spacing: 0.5em, first-line-indent: 0em)
#show raw: set text(font: "DejaVu Sans Mono", size: 7pt)
#set list(indent: 0.85em, marker: [•], spacing: 0.6em, tight: true)
#set enum(indent: 0.85em, spacing: 0.6em, tight: true)
#show list.item: set par(leading: 0.42em, spacing: 0.35em)
#show enum.item: set par(leading: 0.42em, spacing: 0.35em)

#let keep(body) = block(breakable: false, width: 100%, body)

#set heading(numbering: none)
#show heading: it => block(
  breakable: false, sticky: true, above: 0.8em, below: 0.35em,
)[
  #text(size: if it.level <= 1 { 11pt } else if it.level == 2 { 9.4pt } else { 8.6pt },
        weight: "bold", fill: primary, it.body)
  #if it.level <= 1 [#v(1.5pt) #line(length: 100%, stroke: 0.7pt + rule)]
]

#let callout(title, body, col: accent, bg: panel) = keep(block(
  width: 100%, inset: (x: 4pt, y: 4pt), radius: 1pt, fill: bg,
  stroke: (top: 0pt + col, right: 0pt + col, bottom: 0pt + col, left: 1.4pt + col),
)[
  #text(size: 7.9pt, weight: "bold", fill: col)[#title]#h(0.35em)#body
])
#let keypt(t, b) = callout(t, b, col: accent,  bg: rgb("#FDF4E7"))
#let defbox(t, b) = callout(t, b, col: defcol,  bg: rgb("#EDF5F4"))
#let warn(t, b)  = callout(t, b, col: danger,   bg: rgb("#FBEDED"))

#let cmp(cols, ..cells) = keep({
  let c = cells.pos()
  grid(
    columns: cols, inset: (x: 4pt, y: 3pt), align: left,
    stroke: (x, y) => if y > 0 { (top: 0.35pt + rule) } else { none },
    ..c.enumerate().map(((i, v)) => if calc.rem(i, cols) == 0 {
      text(weight: "bold", fill: primary, v)
    } else { v }),
  )
})
#let tbl(cols, head: (), ..cells) = keep({
  let c = cells.pos()
  let hs = head
  grid(
    columns: cols, inset: (x: 4pt, y: 3pt), align: left,
    fill: (x, y) => if hs != () and y == 0 { headbg } else { none },
    stroke: (x, y) => if y > 0 { (top: 0.35pt + rule) } else { none },
    ..if hs != () { hs.map(v => text(weight: "bold", fill: primary, v)) } else { () },
    ..c,
  )
})

#set figure(gap: 4pt, supplement: [Fig.], numbering: "1")
#show figure.caption: set text(size: 6.9pt, fill: muted)

// ===== DIAGRAM PRIMITIVES =====
#let node(body, col: primary, bg: panel, sz: 7.4pt) = box(
  inset: (x: 5pt, y: 4pt), radius: 2pt, fill: bg,
  stroke: 0.6pt + col, text(size: sz, body))
#let dn(col: primary) = text(fill: col)[$arrow.b$]
#let vstack(..items) = align(center, stack(dir: ttb, spacing: 3pt, ..items))
#let arrr(col: primary) = text(fill: col)[$arrow.r$]

// ===== TITOLO =====
#place(top, scope: "parent", float: true)[
  #text(14.5pt, weight: "bold", fill: primary)[Recap of Computer Architecture]
  #v(2pt)
  #text(7.3pt, fill: muted)[PARCO — Lecture 02]
  #v(4pt) #line(length: 100%, stroke: 1pt + primary)
]

#block(breakable: false, width: 100%)[
  #text(size: 8.2pt, fill: muted)[*Sections:* Von Neumann Architecture; Modern and
  Accelerated Processors; Flynn's Taxonomy; Latency and Throughput; Limits of Von Neumann
  Architectures; Fetch-Decode-Execute Design; Implicit Parallelism and ILP; Pipeline.]
  #v(4pt)
]

= Von Neumann Architecture <vn>

== Architecture model

Most modern computers are based on the Von Neumann architecture (or Princeton
architecture). Also known as "stored-program computer": both program instructions and
data are kept in the same memory.

In the classical Von Neumann model, instructions and data share the same memory and
address space, and are processed by a CPU according to a sequential instruction stream.
The CPU is characterized by the FDE cycle and data path.

== Four main components

Four main components:
1. Memory
2. Control Unit
3. Arithmetic Logic Unit
4. Input/Output

Random access memory (RAM) stores both program instructions and data:
1. Program instructions are encoded operations interpreted by the processor according to
   the instruction set architecture (ISA).
2. Data: information to be used by the program.
3. From the memory perspective they look the same — not from the CPU side.

#cmp(2,
  [Control unit], [coordinates instruction fetch, decode, and execution; controls the movement of operands between registers, memory, and execution units],
  [ALU], [performs basic arithmetic operations],
  [Input/Output], [interface to the human and external environment],
)

== Fetch-Decode-Execute cycle <fde>

1. PC identifies the next instruction.
2. Instruction is fetched into the IR.
3. Instruction is decoded.
4. Required operands are obtained.
5. Operation is executed.
6. Architectural state is updated.

#figure(
  align(center)[
    #vstack(
      node[IR gets instruction from memory],
      dn(),
      node[PC points to the next instruction],
      dn(),
      node[Load data into register],
      dn(),
      node[Execute instruction],
      text(size: 6.6pt, fill: muted)[$arrow.t$ loop back to IR],
    )
  ],
  caption: [Fetch-Decode-Execute cycle],
)

== Data Path <datapath>

The *ALU* performs arithmetic and bitwise operations on integer binary numbers.
The *FPU* performs floating-point arithmetic.

Data movement: register-memory instruction; register-register instruction.

#defbox("Definition", [
  The datapath is the collection of hardware components that store, move, and operate on
  data, including registers, ALUs, FPUs, load/store units, and interconnections.
])

#figure(
  align(center)[
    #vstack(
      node[Registers: $A + B$ / $A$ / $B$],
      text(size: 6.6pt, fill: primary)[$arrow.b$ #h(0.2em) ALU input bus],
      node[ALU],
      dn(),
      node[ALU output register: $A + B$],
    )
  ],
  caption: [Data path: registers feed the ALU through the input bus; the result is written to the output register],
)

== Different organization

#cmp(2,
  [AMD Barcelona], [4 cores],
  [Intel Core i7], [8 cores],
  [IBM Cell BE], [8+1 cores],
  [IBM POWER9], [24 cores],
  [Sun Niagara II], [8 cores],
  [Nvidia Volta], [5120 "cores"],
  [Intel SCC], [48 cores, networked],
  [Tilera TILE Gx], [100 cores, networked],
)

= Modern and Accelerated Processors <modern-proc>

== FUJITSU Processor A64FX <a64fx>

- Superscalar processor of the out-of-order execution type.
- Based on Armv8-A architecture and the Scalable Vector Extension for Armv8-A ISA.
- Integrates 52 processor cores, including 4 assistant cores.
- Cores organized into 4 Core Memory Group (CMG).

#cmp(2,
  [CMG specification], [13 cores; L2\$ 8MiB; Mem 8GiB, 256GB/s],
  [Tofu], [28Gbps, 2 lanes, 10 ports],
  [I/O], [PCIe Gen3, 16 lanes],
  [Memory], [HBM2],
  [Interconnect], [Network on Chip],
)

== GPU and accelerators <gpu>

NVIDIA Ampere GA102 GPU architecture — detail of a Stream Multiprocessor (SM):

#cmp(2,
  [Scheduler], [L0 I-Cache + Warp Scheduler + Dispatch (32 thread/clk)],
  [Register File], [16,384 x 32-bit],
  [Compute], [FP32/INT32, FP32, TENSOR CORE 3rd Gen],
  [Units], [LD/ST, SFU],
  [Cache / shared], [128KB L1 Data Cache / Shared Memory],
  [Texture], [Tex],
  [Ray tracing], [RT CORE 2nd Generation],
)

== Emerging Systems <emerging>

*Processing Using Memory (PUM)*: minimal chip modification to support Bulk Bitwise
Operations [Seshadri17].

*Processing near memory (PNM)*: example adding a CU in the stack layer.

#figure(
  align(center)[
    #grid(columns: (1fr, 1fr), column-gutter: 6pt, align: horizon,
      vstack(
        text(size: 6.6pt, fill: primary)[3D stacked DRAM],
        node[Memory stack],
        node[Logic layer],
        text(size: 6.4pt, fill: muted)[Through-Silicon Via (TSV)],
        dn(),
        node[CPU],
      ),
      vstack(
        text(size: 6.6pt, fill: primary)[PNM],
        node[CPU],
        node[MC + PIM],
        text(size: 6.6pt)[$arrow.b$ $arrow.t$],
        node[Memory module (DIMM)],
      ),
    )
  ],
  caption: [Emerging systems: 3D stacked DRAM (logic layer + memory stack, TSV) and processing near memory],
)

= Flynn's Taxonomy <flynn>

Mike Flynn, "Very High-Speed Computing Systems," Proc. of IEEE, 1966.

- *SISD*: single instruction operates on single data element.
- *SIMD*: single instruction operates on multiple data elements.
  - Array processor
  - Vector processor
- *MISD*: multiple instructions operate on single data element.
  - "MISD is rare in general-purpose computing; practical examples are uncommon and
    classification is sometimes application-dependent."
- *MIMD*: multiple instructions operate on multiple data elements (multiple instruction
  streams).
  - Multiprocessor
  - Multithreaded processor

#figure(
  align(center)[
    #grid(columns: (auto, 1fr, 1fr), column-gutter: 4pt, row-gutter: 4pt, align: center,
      [],
      text(size: 7pt, weight: "bold", fill: primary)[Single Data],
      text(size: 7pt, weight: "bold", fill: primary)[Multiple Data],
      text(size: 7pt, weight: "bold", fill: primary)[Single Instruction],
      node(bg: rgb("#FDF4E7"))[SISD],
      node(bg: rgb("#EDF5F4"))[SIMD],
      text(size: 7pt, weight: "bold", fill: primary)[Multiple Instruction],
      node(bg: rgb("#EDF5F4"))[MISD],
      node(bg: rgb("#FDF4E7"))[MIMD],
    )
  ],
  caption: [Flynn's taxonomy of computers],
)

== Single Instruction on a single Data (SISD) <sisd>

- Simple serial architecture.
- *Single Instruction*: a single logical instruction stream controls execution.
- *Single Data*: only one data stream is being used as input during any one clock cycle.
- In-order execution (modern architectures support out-of-order).
- Examples: older generation mainframes, minicomputers, workstations and single
  processor/core PCs.

= Latency and Throughput <latency>

- *Latency* is the number of clock cycles an instruction takes to have its data available
  for use by another instruction (lower is better).
- Latency also represents the cost to get the next instruction.
- *Throughput* is the number of instructions, operations, or tasks completed per unit
  time (higher is better).

A design may aim to minimise latency, maximise throughput, or balance both. The concepts of
latency and throughput are also applied to CPU and memory.

= Limits of Von Neumann Architectures <limits>

Performance in VN architectures depends on many factors (all together):
- FDE design and ISA (latency)
- ALU technology and PEs organization (math bandwidth)
- Memory sub-system (latency and memory bandwidth)
- Applications (ratio between math operations and read/write operations)

Analyze where the potential bottleneck may come from: the FDE design and ISA affect
latency, since the IR gets the instruction from memory, the PC points to the next
instruction, data is loaded into a register, and the instruction is executed.

= Fetch-Decode-Execute Design <fde-design>

- Processors run at a constant rate (clock frequency).
- Performance also depends on the ability to execute instructions per second (MIPS) via
  the FDE cycle.
- Different instructions may require different numbers of cycles, and the average cost is
  reflected in CPI.
- For numerical workloads, FLOP/s is often used because it measures application-relevant
  floating-point work rather than instruction count.

#keypt("Performance", [
  depends on the task and is influenced by several factors:
  - Clock cycle time: HW technology and system organisation
  - Clock cycle per instruction (CPI): system organisation and ISA
  - Instruction count (IC): ISA, compiler technology (program used for the benchmark)
])

$ "CPU time" = "IC" times "Cycles per instruction" times "Clock cycle time" $

= Implicit Parallelism and ILP <implicit-ilp>

== Implicit Parallelism: Trends in Microprocessor Architectures <implicit>

#defbox("Implicit parallelism", [
  Parallel execution extracted automatically by the compiler and/or hardware without the
  programmer explicitly creating parallel tasks or threads. It contrasts with explicit
  parallelism, where the programmer specifically indicates parallel sections in the code.
])

- Historically, increasing clock frequency was a major source of performance improvement,
  but power and thermal constraints limited continued frequency scaling.
- Higher levels of device integration have made many transistors available; the question
  of how best to utilise these resources is an important one.

Parallelism on the hardware level:
- Current processors use these resources in multiple functional units and execute multiple
  operations in the same cycle (Instruction Level Parallelism and Superscalar
  Architectures).
- The way in which these instructions are selected and executed provides different
  architectures (out-of-order execution and pipelining).
- Vectorization.

== Instruction Level Parallelism (ILP) <ilp>

#defbox("Definition", [
  Instruction-level parallelism (ILP) is the ability to execute multiple independent
  instructions from a single instruction stream concurrently.
])

Introduction of an execution unit (also called a functional unit):
- responsible for performing the operations (load and store and arithmetic operations) as
  instructed by the computer program;
- may have its own internal control sequence unit, which is not to be confused with the
  CPU's main control unit, and some registers;
- components are arithmetic logic unit (ALU), address generation unit (AGU), floating-point
  unit (FPU), load-store unit (LSU), branch execution unit (BEU);
- superscalar architectures have many EUs.

== Example of Superscalar execution <superscalar>

A superscalar processor is a CPU that implements a form of parallelism called
instruction-level parallelism within a single processor. It can find instruction
dependencies.

#figure(
  align(center)[
    #grid(columns: (auto, 1fr), column-gutter: 5pt, row-gutter: 3pt,
      [], grid(columns: (1fr,)*3, align: center, [x x], [y y], [z z]),
      [], align(center, text(fill: accent)[$arrow.b$]),
      text(size: 6.6pt, fill: accent)[ILP = 3], grid(columns: (1fr,)*3, align: center, node[$times$], node[$times$], node[$times$]),
      [], align(center, text(fill: accent)[$arrow.b$]),
      text(size: 6.6pt, fill: accent)[ILP = 1], align(center, node[$+$]),
      [], align(center, text(fill: accent)[$arrow.b$]),
      text(size: 6.6pt, fill: accent)[ILP = 1], align(center, node[$+$]),
      [], align(center, text(fill: primary)[$arrow.b$]),
      [], align(center, [a]),
    )
  ],
  caption: [Dependency graph of $a = x*x + y*y + z*z$],
)

#raw("mul  r1, r0, r0     ; dependent instructions
mul  r1, r1, r1
st   r1, mem[r2]
...
add  r0, r0, r3     ; independent instructions
add  r1, r4, r5", block: true)

== Modern architectures <modern>

- In Flynn's taxonomy, a single-core superscalar processor is classified as an SISD.
- Superscalar design can be combined with other performance enhancement techniques:
  - Speculative execution: predict results to continue execution
  - Out-of-Order (OoO) execution: potentially change execution order of instructions
  - Pipeline
  - Vectorization (SIMD approach)

= Pipeline <pipeline>

The goal is to reduce the latency and maximize the use of the resource (washing clothes
example, credits ETH Introduction to Parallel Programming). Inputs are instruction streams.

#figure(
  align(center)[
    #tbl((auto, 1fr, 1fr, 1fr, 1fr, 1fr),
      head: ([Stage], [T0], [T1], [T2], [T3], [T4]),
      [Washer],  [I0], [I1], [],   [],   [],
      [Dryer],   [],   [I0], [I1], [],   [],
      [Folding], [],   [],   [I0], [I1], [],
      [Closet],  [],   [],   [],   [I0], [I1],
    )
  ],
  caption: [Space-time diagram: two instruction streams I0, I1 across four pipeline stages],
)

== Bounds of a pipeline <pipe-bounds>

*Balanced pipeline*: all the steps require the same time (practically never happens).

- Throughput bound $= 1\/max("computation time" ("stages"))$
- Latency bound $= #"stages" times max("computation time" ("stages"))$

== Washing clothes example <washing>

Pipelines are usually unbalanced. Stages:
#cmp(2,
  ["w" Washer], [5 seconds],
  ["d" Dryer], [10 seconds],
  ["f" Folding], [5 seconds],
  ["c" Closet], [10 seconds],
)

Assuming 5 washing loads, the total time for all is 70 secs. This is a latency issue.
Solution: one approach is to make each stage take as much time as the longest one
(all stages 10 secs). The total time for all is then 80 secs; latency is bound at
40 seconds for each load; throughput is 1 load / 10 seconds, so about 6 loads / minute.
Can we improve latency and throughput at the same time?

Increase the FU:
- Adding 2 dryers working in a row: the first dryer is referred to as d1 and takes
  4 seconds, the second as d2 and takes 6 sec.
- Adding 2 closets working in a row: the first closet is referred to as c1 and takes
  4 seconds, the second as c2 and takes 6 sec.

Bounding of the latency: each of d1 and d2 dryers take 6 seconds; each of c1 and c2
closets now take 6 seconds.

#cmp(4,
  [Configuration], [Total], [Latency / load], [Throughput],
  [Unbalanced (w5, d10, f5, c10), 5 loads], [70 s], [—], [—],
  [Balanced (all stages 10 s)], [80 s], [40 s], [1 load / 10 s ≈ 6 / min],
  [+FU, bounded (d1,d2,c1,c2 at 6 s)], [60 s], [36 s (6×6)], [1 load / 6 s ≈ 10 / min],
)

== Instruction pipeline <instr-pipe>

- Fetching of instructions from memory is a major bottleneck in instruction execution
  speed.
- Instructions can be stored in a set of registers called the prefetch buffer.
- Execution is divided into two parts: fetching and actual execution.
- Instead of dividing instruction execution into only two parts, it is often divided into
  many parts, each one handled by a dedicated piece of hardware, all of which can run in
  parallel.

#figure(
  align(center)[
    #vstack(
      node[S1 — Instruction fetch unit],
      dn(),
      node[S2 — Instruction decode unit],
      dn(),
      node[S3 — Operand fetch unit],
      dn(),
      node[S4 — Instruction execution unit],
      dn(),
      node[S5 — Write back unit],
    )
  ],
  caption: [A simple 5 stage pipeline],
)

#figure(
  align(center)[
    #tbl((auto, ..(1fr,)*9),
      head: ([], [1], [2], [3], [4], [5], [6], [7], [8], [9]),
      [S1], [1], [2], [3], [4], [5], [6], [7], [8], [9],
      [S2], [],  [1], [2], [3], [4], [5], [6], [7], [8],
      [S3], [],  [],  [1], [2], [3], [4], [5], [6], [7],
      [S4], [],  [],  [],  [1], [2], [3], [4], [5], [6],
      [S5], [],  [],  [],  [],  [1], [2], [3], [4], [5],
    )
  ],
  caption: [Pipeline space-time diagram: instructions 1–9 in stages S1–S5 over time],
)
