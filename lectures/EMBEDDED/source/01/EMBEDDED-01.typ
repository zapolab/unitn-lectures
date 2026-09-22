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
        [Introduction to Embedded Systems],
        [EMBEDDED-01])
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
  let n = cols.len()
  grid(
    columns: cols, inset: (x: 4pt, y: 3pt), align: left,
    column-gutter: 3pt,
    stroke: (x, y) => if y > 0 { (top: 0.35pt + rule) } else { none },
    ..c.enumerate().map(((i, v)) => if calc.rem(i, n) == 0 {
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

#let node(body, col: primary, bg: panel) = box(
  inset: (x: 4pt, y: 3pt), radius: 2pt, fill: bg,
  stroke: 0.6pt + col, text(size: 7.2pt, body))

#set figure(gap: 4pt, supplement: [Fig.], numbering: "1")
#show figure.caption: set text(size: 6.9pt, fill: muted)

#place(top, scope: "parent", float: true)[
  #text(14.5pt, weight: "bold", fill: primary)[Introduction to Embedded Systems]
  #v(2pt)
  #text(7.3pt, fill: muted)[EMBEDDED — Lecture 01]
  #v(4pt) #line(length: 100%, stroke: 1pt + primary)
]

= Embedded Systems: Definition

#defbox("Definition", [
  Computing systems with *tightly coupled hardware and software integration*,
  designed to perform a *dedicated functionality*. The word "embedded" means
  built into (to be an integral part of) a larger system; the larger system is
  called the *embedding system*. An embedded system is an *application-specific
  computer system*.
])

#keep[
- Many embedded systems must also respond within a defined time (*realtime
  constraints*).
]

#figure(placement: top, scope: "parent", caption: [Embedded computer between two environments: input from the environment and output to the environment; hardware and software work together to perform a dedicated function inside a larger system.])[
  #grid(columns: (1fr, auto, 1.3fr, auto, 1fr), align: horizon, column-gutter: 4pt,
    node([*Environment* \ Sensors and user input]),
    $arrow.r$,
    node([*Embedded computer* \ Hardware + software], col: defcol, bg: rgb("#EDF5F4")),
    $arrow.r$,
    node([*Environment* \ Actuators, display, network]),
  )
  #v(3pt)
  #grid(columns: (1fr, 1fr), align: horizon,
    text(size: 6.9pt, fill: muted)[Input from environment \ User interface],
    align(right, text(size: 6.9pt, fill: muted)[Output to environment \ Link to other systems]),
  )
]

= Why Embed Computing?

#keep[
- *Lower cost and more performance*: application-specific and optimized system.
- *Improve dependability*: one device fails but others continue.
- *More functionality*: e.g., intelligence.
- *Scalability*.
]

= Bike Computer Example

#keep[
- Wheel rotation becomes speed and distance on a local display.
- The design is shaped by *size, cost, weight, power, and energy*.
- A small *8-bit microcontroller (MCU)* can be enough.
]

#figure(caption: [Bike computer: wheel rotation becomes speed and distance on a local display.])[
  #grid(columns: (1fr, auto, 1fr, auto, 1fr), align: horizon, column-gutter: 4pt,
    node([*Input* \ Wheel rotation]),
    $arrow.r$,
    node([*8-bit MCU*], col: defcol, bg: rgb("#EDF5F4")),
    $arrow.r$,
    node([*Output* \ Display speed and distance]),
  )
]

= A Vehicle Is a Network of Computers

#keep[
- Today's high-end automobile may have *100 processors*:
  - many specialized controllers: a *4-bit microcontroller* checks the seat
    belt; microcontrollers run dashboard devices; a *16/32-bit microprocessor*
    controls the engine.
  - Low-end cars use *20+ processors*.
- Different *timing and safety needs*.
]

= Microcontroller vs. Microprocessor

#keep[
- *Common to both*: a core to execute instructions; both devices fetch, decode,
  and execute instructions; both contain registers and an arithmetic logic unit
  (ALU).
- The main distinction lies in *what surrounds the processor core*.
]

#cmp((0.6fr, 1.4fr),
  [*CPU (Microprocessor)*], [A single processor core that supports at least instruction fetching, decoding, and executing. Used for general-purpose computing but depends on external memory and peripherals.],
  [*MCU (Microcontroller)*], [Typically has a single processor core; typically used for basic control purposes. Has memory blocks, Digital IOs, Analog IOs, and other basic peripherals. Integrates the processor, memory, and common peripherals on one chip.],
)

= Dedicated Hardware

#keep[
- Custom logic implements a narrow, well-defined function:
  - high performance or energy efficiency;
  - updates are harder.
- *The value of programmability*: the same hardware can perform different
  functions by changing only the software.
]

= Alternatives

#keep[
- Field-programmable gate arrays (FPGAs), custom logic, etc.
  - FPGAs offer *reconfigurable logic between fixed hardware and software*.
]

= Why MCUs Fit Embedded Products

#keep[
- *Low development and manufacturing cost*: integrated peripherals reduce board
  complexity.
- *Enough performance* for sensing and control.
- *Low power consumption* and effective sleep modes.
]

= Options for Building Embedded Systems

#keep[
*Dedicated Hardware*
#cmp((0.8fr, 1.7fr),
  [Discrete Logic], [design cost low; unit cost mid; upgrades \& bug fixes hard; size large; weight high; power ?; system speed very fast],
  [ASIC], [design cost high (\$500K/mask set); unit cost very low; upgrades hard; size tiny -- 1 die; weight very low; power low; system speed extremely fast],
  [Programmable logic -- FPGA, PLD], [design cost low; unit cost mid; upgrades easy; size small; weight low; power medium to high; system speed very fast],
)
]

#keep[
*Software Running on Generic Hardware*
#cmp((0.8fr, 1.7fr),
  [Microprocessor + memory + peripherals], [design cost low to mid; unit cost mid; upgrades easy; size small to med.; weight low to moderate; power medium; system speed moderate],
  [Microcontroller (int. memory \& peripherals)], [design cost low; unit cost mid to low; upgrades easy; size small; weight low; power medium; system speed slow to moderate],
)
]

= Resource Constraints

#keep[
- How much hardware do we need? How fast is the CPU? Memory size?
- How do we meet our deadlines? Faster hardware or cleverer software?
- How do we minimize power? Turn off unnecessary logic? Reduce memory
  accesses?
]

= Correctness, Evolution, and Security

#keep[
- *Does it really work?* Is the specification correct? Does the implementation
  meet the specifications? How do we test for real-time characteristics? How do
  we test on real data?
- *How do we design for upgradeability?* How to add features by changing
  software and hardware?
- *Is it secure?* How are the dangerous acts prevented?
]

= Why Embedded Testing Is Difficult

#keep[
- *Complex testing*: we cannot separate the testing of an embedded computer
  from the machine in which it is embedded (how to test a washing machine
  software?).
- *Limited observability and controllability*: difficult to see what is going
  on; no keyboards and screens, need to watch the values of electrical signals.
- *Restricted development environments*: much more limited than those available
  for PCs.
]

= Core Properties

#keep[
- *Interfacing with the environment*: analog signals from sensors, e.g., a
  voltage value that represents a physical value.
- *Concurrent and reactive behaviours*: respond to events timely (real-time
  constraints on responses); must perform multiple separate activities
  concurrently (e.g., several sensors).
- *Fault handling*: operate independently for long periods and handle likely
  faults without crashing.
- *Diagnostics*: help developers determine problems quickly.
]

= Example: Analog Sensing Path

#keep[
- A sensor detects pressure and generates a *proportional output voltage*
  $V_"sensor"$.
- An *Analog to Digital Converter* (ADC) generates a proportional digital
  integer (code) based on $V_"sensor"$ and $V_"ref"$.
]

#figure(placement: top, scope: "parent", caption: [Analog sensing path: physical quantity, sensor voltage, ADC code, software value.])[
  #grid(columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr), align: horizon, column-gutter: 3pt,
    node([*Physical quantity* \ Pressure]),
    $arrow.r$,
    node([*Sensor voltage* \ Proportional analog signal]),
    $arrow.r$,
    node([*ADC code* \ Integer sample]),
    $arrow.r$,
    node([*Software value* \ Calibrated pressure]),
  )
]

== From ADC Code to Voltage

#keep[
- The ADC converts a *voltage range into integer codes*.
  - Reference voltage and ADC resolution define the *conversion scale*.
  - *Clipping* occurs when the input exceeds the supported range.
- The MCU reads these integer codes; the MCU software should convert the
  measured integer code back into the voltage reading.
]

#defbox("Formula", [$ V_"sensor" = "ADC_code" times V_"ref" slash "ADC_max" $])

```c
// Your Software
ADC_Code = adc_read();
V_sensor = ADC_code * V_ref / ADC_MASK;
```

== From Voltage to Pressure

#keep[
- The *sensor model* converts voltage into pressure.
  - Calibration constants, units, and environmental assumptions must remain
    *explicit*.
]

```c
// Your Software
ADC_Code = adc_read();
V_sensor = ADC_code * V_ref / ADC_MASK;
Pressure_kPa = 250 * (V_sensor / V_supply + 0.04);
```

== From Pressure to Depth

#keep[
- A *second model* converts pressure difference into depth.
  - Calibration constants, units, and environmental assumptions must remain
    explicit.
  - Each conversion adds *uncertainty* that software must manage.
]

#defbox("Formula", [$ "depth" = f("pressure" - "atmospheric pressure") $])

```c
// Your Software
ADC_Code = adc_read();
V_sensor = ADC_code * V_ref / ADC_MASK;
Pressure_kPa = 250 * (V_sensor / V_supply + 0.04);
Depth_ft = 33 * (Pressure_kPa - Atmos_Press_kPa) / 101.3;
```

= Concurrency Through Peripherals

#keep[
- Things are happening *concurrently* while the CPU is executing instructions:
  peripherals continue working while the CPU executes application code.
- Peripherals use *interrupts* to notify the CPU about events:
  - an interrupt transfers control to a short *service routine*;
  - the routine records the event or moves data;
  - the main program resumes after the urgent work is complete.
]

#figure(caption: [Concurrency through peripherals: the Cortex-M core and the interrupt controller are connected to peripherals on the peripheral bus.])[
  #grid(columns: (1fr, 1fr), column-gutter: 6pt, row-gutter: 3pt,
    node([*Cortex-M* \ Core], col: defcol, bg: rgb("#EDF5F4")),
    node([*Interrupt* \ Controller], col: defcol, bg: rgb("#EDF5F4")),
  )
  #v(3pt)
  #align(center, text(size: 7pt, fill: muted)[Peripheral Bus])
  #v(2pt)
  #grid(columns: (1fr, 1fr, 1fr), column-gutter: 3pt, row-gutter: 3pt,
    node([Timers]), node([ADC]), node([GPIO]),
    node([UART]), node([I2C]),
  )
]

= Interrupt-Driven Execution

#figure(placement: top, scope: "parent", caption: [Interrupt-driven execution: the main program runs while a timer peripheral and an A/D converter peripheral drive the Timer ISR and the ADC ISR through interrupts.])[
  #grid(columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr), align: horizon, column-gutter: 3pt,
    node([*Main* \ Start timer]),
    $arrow.r$,
    node([*Timer Peripheral* \ Timer interrupt]),
    $arrow.r$,
    node([*Timer ISR* \ Start ADC]),
    $arrow.r$,
    node([*A/D Converter* \ ADC interrupt (repeated)]),
  )
  #v(3pt)
  #align(center)[#node([*ADC ISR* \ ADC_done = 1], col: accent, bg: rgb("#FDF4E7"))]
]

= Embedded Software

#keep[
- *Programming language*: programmed in *C rather than Java* (smaller and faster
  code, so less expensive MCU); some performance-critical code may be in
  *assembly language*.
- *Operating system*: typically *no OS*, instead a simple scheduler, or even
  just interrupts + main code (foreground/background system); if an OS is used,
  it is likely to be an *embedded RTOS*.
]

= Hardware and Software Co-design Model

#keep[
- Commonly both the hardware and the software for an embedded system are
  developed *in parallel*.
- If performance is needed: take advantage of special hardware features.
- Push things to the *software layer* if functionality can be achieved in
  software: reduces overall hardware complexity and cost.
]

= Functional vs. Non-functional Requirements

#cmp((0.9fr, 1.3fr),
  [*Functional*], [Output as a function of input.],
  [*Non-functional*], [Time required to compute output; size, weight (mobile and portable); power consumption (battery capacity); reliability.],
)

#keep[
- Functionality is a must but embedded applications should meet non-functional
  requirements as well.
- *Performance goal*: the program must meet its *deadline*.
  - *Deadline*: the time at which a computation must be finished.
- Example: *TV broadcast* involves digital signal processing and cannot
  tolerate delays.
  - If the program does not produce the required output by the deadline, the
    system does not work properly even if the output it eventually produces is
    functionally correct.
- A *digital signal processor* (DSP) has specialized arithmetic units to
  perform complex calculations extremely fast in real time.
]

= The Internet of Things (IoT)

#keep[
- Embedded devices *exchange data* and *coordinate with software services*
  across the physical world.
]

= IoT Device Examples

#keep[
- Different products share one pattern: *sensing, local computation,
  communication, and action*.
]

#figure(caption: [IoT device examples sharing one pattern: sensing, local computation, communication, action.])[
  #grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 3pt,
    node([THERMOSTAT]), node([WEARABLE]), node([VOICE]), node([SENSOR NODE]),
  )
  #v(3pt)
  #grid(columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr), align: horizon, column-gutter: 3pt,
    node([Sensing], col: defcol, bg: rgb("#EDF5F4")), $arrow.r$,
    node([Local computation], col: defcol, bg: rgb("#EDF5F4")), $arrow.r$,
    node([Communication], col: defcol, bg: rgb("#EDF5F4")), $arrow.r$,
    node([Action], col: defcol, bg: rgb("#EDF5F4")),
  )
]

= Why Connect Embedded Devices?

#keep[
- Collect measurements beyond the reach of wired infrastructure.
- Manage devices and update behavior remotely.
- Coordinate devices that share a physical process.
- Combine local sensing with remote storage and analysis.
- Expose new *security, privacy, and reliability risks*.
]

= Wireless Networking

#keep[
- Networking is a *critical component* of an IoT system: allows a much wider
  range of sensor applications.
- Why IoT? Items can have more functionality and become more intelligent;
  items can be managed more easily; more information becomes available.
]

= Trillion Embedded Devices Will Be Deployed Soon

#keep[
- Graph of $log("people per computer")$ over time (1950--2020), with computer
  classes: Mainframe (1 per enterprise), Workstation (1 per engineer), Laptop
  (1 per professional), Personal Computer (1 per family), Smartphone (1 per
  person), IoT/Wearable (10's per person), Smart Dust (100--1000's per person).
]

#figure(placement: top, scope: "parent", caption: [Growth of computing classes, from mainframe to smart dust.])[
  #grid(columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr), column-gutter: 3pt, row-gutter: 3pt,
    node([*Mainframe* \ 1 per enterprise]), node([*Workstation* \ 1 per engineer]),
    node([*Laptop* \ 1 per professional]), node([*Personal Computer* \ 1 per family]),
    node([*Smartphone* \ 1 per person]), node([*IoT/Wearable* \ 10's per person]),
    node([*Smart Dust* \ 100--1000's per person]),
  )
  #v(3pt)
  #align(center, text(size: 6.7pt, fill: muted, style: "italic")[
    "Roughly every decade a new, lower priced computer class forms based on a
    new programming platform, network, and interface resulting in new usage and
    the establishment of a new industry." --- Bell et al., Computer, 1972, ACM, 2008])
]

= Cyber-physical Systems

#keep[
- Combines *physical devices* with *computers that control the device*.
- The embedded computer is the *cyber part*:
  - replaces mechanical controllers: more accurate and more sophisticated
    control;
  - monitors and controls the physical processes with *feedback loops*.
]

= Summary

#keep[
- An embedded system is built for a *specific application*: hardware and
  software components.
- Embedded systems pose many *design challenges*: functional and non-functional
  requirements (design time, deadlines, power, cost, etc.).
- In *real-time systems*, timing correctness is just as important as functional
  or logical correctness.
]
