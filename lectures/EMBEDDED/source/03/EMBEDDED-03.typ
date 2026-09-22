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
        [Embedded Program Development],
        [EMBEDDED-03])
      #v(0.75pt)
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
  #if it.level <= 1 [#v(-0.7em) #line(length: 100%, stroke: 0.7pt + rule)]
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
  let n = cols.len()
  grid(columns: cols, inset: (x: 4pt, y: 3pt), align: left,
    stroke: (x, y) => if y > 0 { (top: 0.35pt + rule) } else { none },
    ..c.enumerate().map(((i, v)) => if calc.rem(i, n) == 0 { text(weight: "bold", fill: primary, v) } else { v }))
})
#let tbl(cols, head: (), ..cells) = keep({
  let c = cells.pos(); let hs = head
  grid(columns: cols, inset: (x: 4pt, y: 3pt), align: left,
    fill: (x, y) => if hs != () and y == 0 { headbg } else { none },
    stroke: (x, y) => if y > 0 { (top: 0.35pt + rule) } else { none },
    ..if hs != () { hs.map(v => text(weight: "bold", fill: primary, v)) } else { () },
    ..c)
})

// ===== FIGURE HELPERS =====
#let fb(body, fill: panel, stroke: rule) = box(
  width: 100%, inset: (x: 3.5pt, y: 2.3pt), radius: 1pt, fill: fill,
  stroke: 0.6pt + stroke, align(center)[#text(size: 6.5pt, body)])
#let fbi(body, fill: panel, stroke: rule) = box(
  inset: (x: 3.5pt, y: 2.3pt), radius: 1pt, fill: fill,
  stroke: 0.6pt + stroke)[#text(size: 6.5pt, body)]
#let core(body) = box(
  inset: (x: 2.5pt, y: 2.3pt), radius: 1pt, stroke: 0.6pt + primary,
  fill: rgb("#E7EEF2"))[#text(size: 6.5pt, body)]
#let dn(l) = block(width: 100%, align(center)[
  #text(size: 7.5pt, fill: muted)[#sym.arrow.b]
  #if l != [] [#h(2.5pt) #text(size: 5.9pt, fill: muted)[#l]]
])

#set figure(gap: 4pt, supplement: [Fig.], numbering: "1")
#show figure.caption: set text(size: 6.9pt, fill: muted)

#place(top, scope: "parent", float: true)[
  #text(14.5pt, weight: "bold", fill: primary)[Embedded Program Development]
  #v(2pt) #text(7.3pt, fill: muted)[EMBEDDED — Lecture 3]
  #v(4pt) #line(length: 100%, stroke: 1pt + primary)
]

= Typical Program-generation Flow

- `Compile -> Assemble -> Link -> Download`.
- Generated `executable file` (or `program image`) stored in program memory
  (normally on-chip flash memory), to be fetched by the processor.

#figure(
  block(width: 72%, inset: 0pt)[
    #align(center)[
      #fb[C Code]
      #dn[Compile]
      #fb[Assembly Code]
      #dn[Assemble]
      #fb[Object Code]
      #dn[Link (with Libraries)]
      #fb[Program Image]
      #dn[Download]
      #fb[Program Memory]
    ]
  ],
  caption: [Typical program-generation flow],
)

#figure(
  block(width: 100%)[
    #align(center)[#fb[Processor]]
    #v(1.5pt)
    #align(center)[
      #core[Fetch]
      #h(2pt) #text(size: 7.5pt, fill: muted)[#sym.arrow.r] #h(2pt)
      #core[Decode]
      #h(2pt) #text(size: 7.5pt, fill: muted)[#sym.arrow.r] #h(2pt)
      #core[Execute]
    ]
    #v(2pt)
    #align(center)[
      #fbi[Data Input] #h(2pt) #text(size: 7.5pt, fill: muted)[#sym.arrow.r] #h(2pt)
      #fbi[Processing] #h(2pt) #text(size: 7.5pt, fill: muted)[#sym.arrow.r] #h(2pt)
      #fbi[Data Output]
    ]
  ],
  caption: [Processor: Instruction Fetch, Decode, Execute; data processing],
)

== Program Image and Memory Sections

- The linker turns many object-file sections into one image whose bytes have
  defined storage and runtime addresses.

= Cortex-M4 Memory Map

#figure(
  block(width: 100%)[
    #align(center)[#text(size: 7pt, weight: "bold", fill: primary)[Global memory space]]
    #v(2pt)
    #fb[Vendor-specific Memory]
    #fb[Private Peripheral Bus (PPB)]
    #fb[External Device]
    #fb[External RAM]
    #fb[Peripherals]
    #fb[SRAM Region]
    #fb[Code Region]
  ],
  caption: [Cortex-M4 memory map example: regions and their address ranges],
)

#tbl(
  (auto, 1fr),
  head: ([Region], [Address range]),
  [Code], [0x00000000 – 0x1FFFFFFF],
  [SRAM], [0x20000000 – 0x3FFFFFFF],
  [Peripherals], [0x40000000 – 0x5FFFFFFF],
  [External RAM], [0x60000000 – 0x9FFFFFFF],
  [External device], [0xA0000000 – 0xDFFFFFFF],
  [Private Peripheral Bus (PPB)], [0xE0000000 – 0xE00FFFFF],
  [Vendor-specific memory], [0xE0100000 – 0xFFFFFFFF],
)

On-chip blocks: Cortex-M4 core with PPB (SCS: NVIC, Debug CRTL), connected via
AHB/APB to on-chip FLASH (code region), on-chip SRAM (SRAM region), Peripheral
Region (Timer, UART, GPIO), External memory interface (external RAM region) and
External device interface (external device region); external SRAM/FLASH,
external LCD, SD card attached below.

= Cortex-M4 Program Image

#defbox([Program image], [(also called `executable file`) piece of fully
integrated code that is ready to execute; contains machine instructions and
constant data; addresses in the image match the target memory layout.])

== Program Image Contents

In the Cortex-M4, the program image includes:

#list([Vector table], [C start-up routine], [Program code], [C library code])

#figure(
  block(width: 100%)[
    #fb[Vendor-specific memory]
    #fb[Private peripheral bus]
    #fb[External Device]
    #fb[External RAM]
    #fb[Peripherals]
    #fb[SRAM Region]
    #grid(columns: (auto, 1fr), align: horizon,
      [#text(size: 6.5pt, fill: muted)[Code region:]], [])
    #fb[Start-up routine & Program code & C library code]
    #fb[Vector table]
  ],
  caption: [Program image occupies the code region of the global memory space],
)

== Vector Table

- Contains the starting addresses of interrupt vectors:
  - Entry 0 stores the value of the main stack point (MSP)
  - Entry 1 stores the Reset Handler address
  - Later entries store exception and interrupt handler addresses

#tbl(
  (auto, 1fr),
  head: ([Address], [Content]),
  [0x00000000], [Initial MSP value],
  [0x00000004], [Reset vector],
  [0x00000008], [NMI vector],
  [0x0000000C], [Hard fault vector],
  [0x00000010], [Reserved],
  [0x0000002C], [SVCall],
  [0x00000030], [Reserved],
  [0x00000038], [PendSV],
  [0x0000003C], [SysTick],
  [0x00000040], [External Interrupts],
)

== C Start-up Code

- Used to set up data memory and the initialization of values for global data
  variables.
- Inserted by the compiler/linker automatically, e.g., labeled as `__start` by
  the GNU C compiler.

== Program and Library Code

- Program code: instructions and data generated from the application program.
- C library code: object codes inserted into the program image by linkers.

= Systems Initialization

#defbox([After reset, the processor], [
  First reads the initial MSP value,
  then reads the reset vector,
  then branches to the start of the program execution address (reset handler),
  subsequently executes program instructions.
])

#figure(
  block(width: 78%, inset: 0pt)[
    #align(center)[
      #fb[Reset]
      #dn[]
      #fb[Fetch initial value for MSP (Read address 0x00000000)]
      #dn[]
      #fb[Fetch reset vector (Read address 0x00000004)]
      #dn[]
      #fb[Fetch 1st instruction (Read address of reset vector)]
      #dn[]
      #fb[Fetch 2nd instruction (Read subsequent instructions)]
    ]
  ],
  caption: [Reset sequence in ARM Cortex processors],
)

= Program Image in Global Memory

- Program image stored in the code region in global memory:
  - up to 512 MB memory space range from 0x00000000 to 0x1FFFFFFF;
  - usually implemented on non-volatile memory, such as on-chip FLASH memory.
- Normally separated from program data, which is allocated in the SRAM region.
- Code region mainly used for program image (e.g., on-chip FLASH); SRAM region
  mainly used for data memory (e.g., on-chip SRAM, SDRAM).

#figure(
  block(width: 92%)[
    #fb[External RAM]
    #fb[Peripherals]
    #fb[SRAM Region — 512 MB]
    #fb[Code Region — 512 MB]
  ],
  caption: [Global memory space: code region and SRAM region],
)

= How Data Is Stored in SRAM

Typically the data can be divided into three sections: static data, stack and
heap.

- Static data: global variables and static variables.
- Stack: local variables, parameter passing in function calls, registers saving
  during exceptions, etc.
- Heap: dynamically reserved by function calls, such as `alloc()` and `malloc()`.
  - Generally not preferred in embedded systems.

#figure(
  block(width: 100%)[
    #grid(columns: (1.1fr, 1.4fr, 1fr), row-gutter: 2.5pt, align: center + horizon,
      [], [], [#text(size: 6.2pt, fill: muted)[High]],
      [], [#fb[Stack]], [#text(size: 6.2pt, fill: muted)[Grow downwards]],
      [], [#text(size: 6.2pt, fill: muted)[Memory Address]], [],
      [], [#fb[Heap]], [#text(size: 6.2pt, fill: muted)[Grow upwards]],
      [], [#fb[Static Data]], [],
      [], [], [#text(size: 6.2pt, fill: muted)[Low]],
    )
  ],
  caption: [SRAM layout: stack grows downwards, heap grows upwards, static data at low addresses],
)

= Memory Placement Begins with Mutability

Can the information change?

#cmp(
  (auto, 1fr),
  [No], [Put it in read-only nonvolatile memory: instructions, constant strings,
    constant operands, initialization values],
  [Yes], [Put it in volatile (read/write) memory: variables, intermediate
    computations, return address],
)

#figure(
  block(width: 92%, inset: 3pt, fill: rgb("#FAFCFD"), stroke: 0.5pt + rule)[
    #raw(
      "int a, b;
const char c=123;
int d=31;
void main(void) {
  int e;
  char f[32];
  e = d + 7;
  a = e + 29999;
  strcpy(f,\"Hello!\");
}",
      block: true, lang: "c",
    )
  ],
  caption: [Example C program used throughout the placement examples],
)

== Data Lifetime

How long does the data need to exist? Reuse memory if possible.

- Statically allocated:
  - exists from program start to end;
  - each variable has its own fixed location;
  - space is not reused.
- Automatically allocated:
  - exists from function start to end;
  - space can be reused.
- Dynamically allocated:
  - explicit allocation to explicit de-allocation;
  - space can be reused.

= Executable Image Sections

Executable image contains initialized data and uninitialized data sections:

- `.data` and `.sdata`: contain the initial values for the global and static
  variables.
- `.bss` and `.sbss`: uninitialized (or zero initialized) data sections (their
  content is empty).
- `.const`: constant data is part of this section, which is read-only.

#tbl(
  (auto, 1.25fr, 1fr),
  head: ([Section], [Contents], [Storage / runtime]),
  [`.text`], [Machine instructions], [Flash #sym.arrow.r Flash],
  [`.rodata` / `.const`], [Read-only constants], [Flash #sym.arrow.r Flash],
  [`.data`], [Initialized writable objects], [Initial bytes in flash #sym.arrow.r SRAM],
  [`.bss`], [Zero-initialized writable objects], [Size only #sym.arrow.r SRAM],
  [Stack], [Call frames and saved context], [Not stored in image #sym.arrow.r SRAM],
  [Heap], [Dynamic allocations], [Not stored in image #sym.arrow.r SRAM],
)

= Program Memory Use

#figure(
  block(width: 100%)[
    #grid(columns: (1fr, 1fr), column-gutter: 9pt, align: top,
      block(width: 100%)[
        #align(center)[#text(size: 7pt, weight: "bold", fill: primary)[RAM]]
        #v(2pt)
        #fb[Zero-Initialized Data `.bss` and `.sbss`]
        #fb[Initialized Data]
        #fb[Stack]
        #fb[Heap Data]
      ],
      block(width: 100%)[
        #align(center)[#text(size: 7pt, weight: "bold", fill: primary)[Flash ROM]]
        #v(2pt)
        #fb[Constant Data `.const`]
        #fb[Initialization Data `.data` and `.sdata`]
        #fb[Startup and Runtime Library Code `.text`]
        #fb[Program `.text`]
      ],
    )
  ],
  caption: [Program memory use: RAM sections and Flash ROM sections],
)

Variables of the example map to sections as follows:

- `int a, b;` #sym.arrow.r Zero-initialized data (`.bss`/`.sbss`)
- `const char c=123;` #sym.arrow.r Constant data (`.const`)
- `int d=31;` #sym.arrow.r Initialization data (`.data`/`.sdata`)
- `int e;`, `char f[32];` #sym.arrow.r Stack
- `e = d + 7;`, `a = e + 29999;`, `strcpy(f,"Hello!");` #sym.arrow.r Program `.text`
- `"Hello!"` #sym.arrow.r Constant data (`.const`)

#keypt([WHY?], [Zero-initialized data are filled with zeros and initialized data
are copied from Flash ROM to RAM at start-up.])

= C Run-Time Start-Up Module

After reset, MCU must:

- Initialize hardware, ...
- Initialize C or C++ runtime environment:
  - set up heap memory, initialize variables.

#figure(
  block(width: 100%)[
    #grid(columns: (1fr, 1fr), column-gutter: 9pt, align: top,
      block(width: 100%)[
        #align(center)[#text(size: 7pt, weight: "bold", fill: primary)[RAM]]
        #v(2pt)
        #fb[Zero-Initialized Data\ a, b]
        #fb[Initialized Data\ d]
        #fb[Stack\ e, f]
        #fb[Heap Data]
      ],
      block(width: 100%)[
        #align(center)[#text(size: 7pt, weight: "bold", fill: primary)[Flash ROM]]
        #v(2pt)
        #fb[Initialization Data\ 31]
        #fb[Constant Data\ c: 123\\ Hello!]
        #fb[Startup and Runtime Library Code]
        #fb[Code]
      ],
    )
  ],
  caption: [Start-up: zero-initialized data filled with zeros, initialized data copied from Flash ROM],
)

= Loading Program Image

- Transferring an executable image built for a target embedded system from the
  host onto the target:
  - the entire executable image is burned into the ROM or flash memory using
    special equipment.
- Each time the code changes due to bugs or code addition:
  - reprogram the ROM or the flash memory using special equipment.
    - e.g., JTAG interface (JTAG — Joint Test Action Group).

= An Example Booting Procedure

- After powered on:
  - fetch and execute code from a predefined and hard-wired address offset;
  - the code contained at this memory location is called the reset vector.
- The reset vector is usually a jump instruction into the real initialization
  code, called the bootstrap code.
  - The reason for jumping to another part of memory is to keep the reset vector
    small.

== Booting Steps

Two CPU registers are of concern:

- Instruction Pointer (IP) register: points to the next instruction (code in the
  `.text` section).
- Stack Pointer (SP) register: points to the next free address in the stack.

The SP must be set appropriately at start-up; the stack is created from a space
in RAM.

#enum(
  [IP is hardwired to execute the first instruction in memory (the reset vector).],
  [The reset vector jumps to the first instruction of the `.text` section in ROM.],
  [The `.data` section of the boot image is copied into RAM (it is both readable and writable).],
  [Space is reserved in RAM for the `.bss` section: nothing to transfer because the content for the `.bss` section is empty.],
  [Stack space is reserved in RAM; the SP register is set to point to the beginning of the newly created stack.],
)

#figure(
  block(width: 100%)[
    #grid(columns: (1fr, 1fr), column-gutter: 14pt, align: top,
      block(width: 100%)[
        #align(center)[#text(size: 7pt, weight: "bold", fill: primary)[ROM]]
        #v(2pt)
        #fb([Reset Vector], fill: rgb("#F3EAD3"))
        #fb([`.text`], fill: rgb("#E4EFE1"))
        #fb([`.data`], fill: rgb("#F7E1E1"))
        #fb([`.bss`])
      ],
      block(width: 100%)[
        #align(center)[#text(size: 7pt, weight: "bold", fill: primary)[RAM]]
        #v(2pt)
        #fb([`.data`], fill: rgb("#F7E1E1"))
        #fb([`.bss`])
        #fb([stack])
      ],
    )
  ],
  caption: [Boot procedure: `.text` executes from ROM; `.data` copied to RAM; `.bss` and stack reserved in RAM],
)

At this point, the boot completes: the CPU continues to execute the code in the
`.text` section.

= Linker Map File

- The linker creates a single executable image for the target embedded system.
  - Merge sections from the different object files into program segments.
- Linker commands (called linker directives) control how the linker combines the
  sections and allocates the segments into the target system.

#figure(
  block(width: 62%, inset: 0pt)[
    #align(center)[
      #fb[C/C++ and Assembly]
      #dn[compiler / assembler]
      #fb[Object and Libraries]
      #dn[linker]
      #fb[Image]
      #dn[]
      #fb[Binary]
    ]
  ],
  caption: [Linker map file: from C/C++ and assembly sources to binary],
)

= Linker Command File

- The linker directives are kept in the linker command file.
  - Two of the more common directives supported by most linkers are `MEMORY` and
    `SECTION`.
- The `MEMORY` directive can be used to describe the target system's memory map.
  - An embedded developer needs to be familiar with the addressable physical
    memory on a target system.

== MEMORY Directive

- The `MEMORY` directive defines:
  - the types of physical memory present in the target system;
  - the address range occupied by each physical memory block.
- Format:

```text
MEMORY {
    area-name : org = start-address, len = number-of-bytes
    ...
}
```

Example:

```text
MEMORY {
    ROM: origin = 0x0000h, length = 0x0020h
    FLASH: origin = 0x0040h, length = 0x1000h
    RAM: origin = 0x1000h, length = 0x10000h
}
```

#tbl(
  (1fr, auto, auto),
  head: ([Block], [Start], [End]),
  [ROM], [0x00000], [0x0001f],
  [FLASH], [0x00040], [0x0103f],
  [RAM], [0x10000], [0x1ffff],
)

#warn([DA VERIFICARE], [In the `MEMORY` example the RAM block has
`origin = 0x1000h, length = 0x10000h`, while the memory map on the slide shows
RAM from `0x10000` to `0x1ffff`. The mismatch between code and map is in the
slide.])

== SECTION Directive

- The `SECTION` directive tells the linker:
  - which input sections are to be combined into which output section;
  - which output sections are to be grouped together and allocated in contiguous
    memory;
  - where to place each section.

```text
SECTION {
    output-section-name : { contents } > area-name
    ...
    GROUP {
        [ALIGN(expression)]
        section-definition
        ...
    } > area-name
}
```

Example: two object files generated by a compiler or assembler (`file1.o` and
`file2.o`); three default sections (`.text`, `.data`, `.bss`); two
developer-specified sections (`loader` and `my_section`).

```text
SECTION {
    .text :
    {
        my_section
        *(.text)
    }
    loader : > FLASH
    GROUP ALIGN (4) :
    {
        .data : {}
        .bss : {}
    } >RAM
}
```

#figure(
  tbl(
    (1.1fr, 1fr, 1.3fr),
    head: ([Input section], [Source], [Output section]),
    [`loader`], [`file1.o`], [loader section #sym.arrow.r FLASH],
    [`.text`], [`file1.o`, `file2.o`], [`.text` section],
    [`my_section`], [`file2.o`], [`.text` section],
    [`.data`], [`file1.o`, `file2.o`], [`.data` section],
    [`.bss`], [`file1.o`, `file2.o`], [`.bss` section],
  ),
  caption: [Sections from `file1.o` and `file2.o` merged into the executable image],
)

#list(
  [Combine `my_section` and the `.text` sections from all object files into the
    final output `.text` section.],
  [The `loader` section is placed into flash memory.],
  [`.data` and `.bss` are grouped and allocated in contiguous physical RAM,
    aligned on the 4-byte boundary.],
)