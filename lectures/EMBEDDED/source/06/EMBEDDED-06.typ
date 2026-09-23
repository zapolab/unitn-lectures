#import "_preamble.typ": *
#import "@preview/fletcher:0.5.8": diagram, node, edge
#import "@preview/cetz:0.5.2": canvas, draw
#show: doc.with(title: "General Purpose Input/Output (GPIO)", label: "EMBEDDED-06")
#titleblock("General Purpose Input/Output (GPIO)", "EMBEDDED — Lezione 6")

== General-purpose and peripheral pin functions

- *Pin multiplexing* selects which internal function reaches the package pin.

#figure(caption: [Function select: GPIO / UART TX / ADC / … / SPI verso Pin.], raw(
  "GPIO ─┐
UART TX ─┤
   ADC ──┼─[ Function Select ]──► Pin
   …  ───┤
   SPI ──┘",
  block: true,
))

#cmp((1fr, 1fr))[
  *GPIO mode*: software reads or drives a digital level. Typical devices: LEDs, switches, keypads, simple control signals.
][
  *Peripheral mode*: the pin connects to on-chip hardware such as a timer, UART, SPI, I²C, or ADC input; the peripheral controls the signals and timing.
]

== GPIO (General Purpose I/O)

- A *GPIO port* connects memory-mapped registers to configurable electrical circuitry at the package pin.

#figure(caption: [GPIO Controller: bus interface, registers, MUX, output/input buffer, pin pad.], [
  #raw("")
  #scale(72%, reflow: true)[
    #diagram(
    spacing: 1.5em,
    node-stroke: 0.6pt + rgb("#1B4965"),
    edge-stroke: 0.7pt + rgb("#2E7D32"),
    node((0, 4))[Bus Interface],
    node((1, 0), fill: rgb("#F2C6C6"))[Data Output Register],
    node((1, 2), fill: rgb("#F2C6C6"))[Direction Register],
    node((1, 3), fill: rgb("#F2C6C6"))[Input Register],
    node((2, 1))[MUX],
    node((3, 1))[Output Buffer],
    node((4, 1))[Pin Pad],
    node((3, 2))[Inv],
    node((3, 3))[Input Buffer],
    edge((0, 4), (1, 0), "<->"),
    edge((0, 4), (1, 2), "<->"),
    edge((0, 4), (1, 3), "<->"),
    edge((1, 0), (2, 1), "->"),
    edge((2, 1), (3, 1), "->"),
    edge((3, 1), (4, 1), "->"),
    edge((1, 2), (3, 2), "->"),
    edge((3, 2), (4, 1), "->"),
    edge((4, 1), (3, 3), "->"),
    edge((3, 3), (1, 3), "->"),
  )
]])

== GPIO Direction and Data Registers

- Minimum of 3 registers associated with each GPIO port: *Data IN, Data Out, and Direction*.
  - The *Direction* (`PxDIR`) register is used to make the pin either input or output.
  - Data registers to actually write to the pin (`PxOUT`) or read data from the pin (`PxIN`).

== MSP GPIO Ports

- The GPIO ports in MSP432 are designated as port *P1* to *P10* and *PJ*.
  - P1 to P10 are also referred as the *Simple I/O* or *Digital I/O* ports.
  - Port J has special function such as external crystal oscillator and JTAG connections.
- Each port contains *eight numbered pins*.

== Commonly Used Registers of Port1

- The *base address* of I/O port is `0x4000 4C00`.

#tbl(5,
  head: ([Address], [Name], [Description], [Type], [Reset Value]),
  [0x4000 4C00], [P1IN], [Port1 Input Register], [R], [0b00000000],
  [0x4000 4C02], [P1OUT], [Port1 Output Register], [R/W], [0b00000000],
  [0x4000 4C04], [P1DIR], [Port1 Direction Register], [R/W], [0b00000000],
  [0x4000 4C06], [P1REN], [Port1 Resistor Enable Register], [R/W], [0b00000000],
  [0x4000 4C08], [P1DS], [Port1 Drive Strength Register], [R/W], [0b00000000],
  [0x4000 4C0A], [P1SEL0], [Port1 Select 0 Register], [R/W], [0b00000000],
  [0x4000 4C0C], [P1SEL1], [Port1 Select 1 Register], [R/W], [0b00000000],
)

=== Register field descriptions

#tbl(5,
  head: ([Field], [Bits], [Type], [Reset], [Description]),
  [PxDIR], [7–0], [RW], [0h], [Port X direction. 0b = Port configured as input; 1b = Port configured as output.],
  [PxOUT], [7–0], [RW], [Undefined], [Port X output. Output mode: 0b = Output is low, 1b = Output is high. Input mode with pullups/pulldowns enabled: 0b = Pulldown selected, 1b = Pullup selected.],
  [PxREN], [7–0], [RW], [0h], [Port X pullup or pulldown resistor enable. When the port is configured as an input, setting this bit enables or disables the pullup or pulldown. 0b = Pullup or pulldown disabled; 1b = Pullup or pulldown enabled.],
  [PxSEL0], [7–0], [RW], [0h], [Port function selection. Each bit corresponds to one channel on Port X. The values of the PxSEL1 and PxSEL0 bit positions are combined to specify the function. See PxSEL1 for the definition of each value.],
  [PxSEL1], [7–0], [RW], [0h], [Port function selection. 00b = General-purpose I/O is selected; 01b = Primary module function is selected; 10b = Secondary module function is selected; 11b = Tertiary module function is selected.],
  [PxIN], [7–0], [R], [Undefined], [Port X input. 0b = Input is low; 1b = Input is high.],
)

== Bit-mask Operations

- Use *read-modify-write* operations when other pins in the same port must retain their configuration.

#tbl(3,
  head: ([Operation], [Expression], [Effect]),
  [Set selected bits], [`REG |= MASK`], [Selected bits become 1],
  [Clear selected bits], [`REG &= ~MASK`], [Selected bits become 0],
  [Toggle selected bits], [`REG ^= MASK`], [Selected bits invert],
  [Read selected bits], [`REG & MASK`], [Nonzero when any selected bit is 1],
  [Replace whole register], [`REG = value`], [Every bit receives a new value],
)

== GPIO as Input

- *MSP432 LAUNCHPAD*
  - Buttons are connected to *P1.1* AND *P1.4*.

#figure(caption: [User Buttons: P1.4_BUTTON2 (S2) e P1.1_BUTTON1 (S1) verso GND.], raw(
  "User Buttons
  P1.4_BUTTON2 ──[ S2 ]── GND
  P1.1_BUTTON1 ──[ S1 ]── GND",
  block: true,
))

== Configure User Button (P1.1)

- Configure P1.1 as input port
  - `BIT1 = 0000 0001`
  - `P1->DIR = ~BIT1;`
- Select Pullup mode.
  - `P1->OUT = BIT1;`
- Enable Pullup Resistor
  - `P1->REN = BIT1;`
- Set GPIO Mode
  - `P1->SEL0 = 0;`
  - `P1->SEL1 = 0;`
- Check Input Register to detect the input

```c
/* Configure P1.1 as input*/
P1->DIR = ~BIT1;
/* Select pullup*/
P1->OUT = BIT1;
/* Enable pullup*/
P1->REN = BIT1;
/* Set as I/O */
P1->SEL0 = 0;
P1->SEL1 = 0;
...
/* Catch Button Press */
while (P1->IN & BIT1);
while (!(P1->IN & BIT1));
...
```

== Pullup and Pulldown Resistors

- If we do not use internal *pullup* (or *pulldown*) *resistors*, we have a problem.
  - We need to ensure a known value on the output if a pin is left *floating*.
- We want the switch SW to pull the pin to ground, so we enable the pull-up.
  - The pin value is:
    - High when SW is not pressed
    - Low when SW is pressed

#figure(caption: [Pullup Mode e Pulldown Mode: pin, resistore [R], switch SW, GND, 3.3V.], raw(
  "Pullup Mode               Pulldown Mode
   3.3V                        3.3V
    │                           │
   [R]                         SW
    │                           │
  [pin]─── SW       [pin]───────┤
    │        │                  │
            GND                [R]
                               │
                              GND",
  block: true,
))

== Alternate functions

- Pins may have *alternate functions*: UART, SPI, and I2C, timers…
- SEL1 and SEL0 choose
  - The function *multiplexer* selects GPIO or alternate function

#tbl(3,
  head: ([SEL1], [SEL0], [Selected function]),
  [0], [0], [Simple digital I/O],
  [0], [1], [Primary module function],
  [1], [0], [Secondary module function],
  [1], [1], [Tertiary module function],
)

#tbl(2,
  head: ([Pin], [Other functionality]),
  [P1.2 / P1.3], [UART receive and transmit, I²C signals],
  [P2 pins], [Timer capture or compare outputs],
  [P4 pins], [Clock, timer, and peripheral bus signals],
  [P5 / P6 pins], [Analog inputs, references, and communication signals],
  [P7 to P10], [Timer, clock, communication, and analog functions],
)

#figure(caption: [Function multiplexer: GPIO / Primary / Secondary / Tertiary Module Function, selezionati da PxSel1/PxSel0.], raw(
  "GPIO ──────────┐
Primary Module ──┤
Secondary Module─┼─[ ]─► Pin
Tertiary Module ─┘
                PxSel1  PxSel0",
  block: true,
))

== Lab #1

- Put breakpoints and observe the execution.

```c
int main(void) {
   P1->SEL1 &= ~2;         /* configure P1.1 as simple I/O */
   P1->SEL0 &= ~2;
   P1->DIR &= ~2;          /* P1.1 set as input */
   P1->REN |= 2;           /* P1.1 pull resistor enabled */
   P1->OUT |= 2;           /* Pull up/down is selected by P1->OUT */
   while (1) {
        while(P1->IN & 2);
        while (!(P1->IN & 2));
   }
}
```

== Bouncing GPIO Input

- Mechanical *bounce* creates several digital transitions.

#figure(caption: [Bounce: BUTTON, RAW INPUT, DEBOUNCED EVENT; finestre di bounce a PRESS e RELEASE.], [
  #raw("")
  #scale(72%, reflow: true)[#canvas({
  import draw: *
  let x0 = 4.2
  content((0.1, 1.1), anchor: "west")[BUTTON]
  line((x0, 1.1), (12, 1.1), stroke: 0.6pt + rgb("#1B4965"))
  rect((4.7, 0.95), (5.3, 1.3), fill: rgb("#C0392B"), stroke: none)
  rect((7.6, 0.95), (8.2, 1.3), fill: rgb("#C0392B"), stroke: none)
  content((5.0, 1.5))[PRESS]
  content((7.9, 1.5))[RELEASE]

  content((0.1, 0.1), anchor: "west")[RAW INPUT]
  line(
    (x0, 0.1), (4.7, 0.1), (4.7, -0.12), (4.85, -0.12), (4.85, 0.1), (5.0, 0.1), (5.0, -0.12), (5.15, -0.12),
    (5.15, 0.1), (7.6, 0.1), (7.6, -0.12), (7.75, -0.12), (7.75, 0.1), (7.9, 0.1), (7.9, -0.12), (8.05, -0.12),
    (8.05, 0.1), (12, 0.1),
    stroke: 0.7pt + rgb("#2E7D32"),
  )
  content((4.9, -0.45))[BOUNCE WINDOW]
  content((7.8, -0.45))[BOUNCE WINDOW]

  content((0.1, -1.0), anchor: "west")[DEBOUNCED EVENT]
  line((x0, -1.0), (5.15, -1.0), (5.15, -1.25), (8.05, -1.25), (8.05, -1.0), (12, -1.0), stroke: 0.8pt + rgb("#C0392B"))
})]])

#keypt("How to handle in software?")[
  #tbl(2,
    head: ([Strategy], [How it works]),
    [Delay after edge], [Wait, then sample again],
    [Stable sample count], [Accept change after N identical samples],
  )
]

== Lab #2

- Write the code that toggles Green LED when S1 switch is pushed.

#figure(caption: [Pulsanti S1/S2 e catene LED con resistori.], raw(
  "User Buttons: P1.1_BUTTON1 (S1), P1.4_BUTTON2 (S2) → GND
User LEDs:
 P1.0_LED1 ──[470, R7]──[LED1]── GND
 P2.0_RGBLED_RED   ──[110R, R2]──
 P2.1_RGBLED_GREEN ──[16R,  R3]──[LED2, EVERLIGHT_19-337]
 P2.2_RGBLED_BLUE  ──[24R,  R4]──",
  block: true,
))

== Lab #3

- Write the code that toggles Green LED when S1 switch is pushed and toggles Blue LED when S2 is pushed.

#keypt("Could you detect switch actions simultaneously?")[]

== MSP432 Port Reference

=== Commonly Used Registers of Port2

#tbl(5,
  head: ([Address], [Name], [Description], [Type], [Reset Value]),
  [0x4000 4C01], [P2IN], [Port2 Input Register], [R], [0b00000000],
  [0x4000 4C03], [P2OUT], [Port2 Output Register], [R/W], [0b00000000],
  [0x4000 4C05], [P2DIR], [Port2 Direction Register], [R/W], [0b00000000],
  [0x4000 4C07], [P2REN], [Port2 Resistor Enable Register], [R/W], [0b00000000],
  [0x4000 4C09], [P2DS], [Port2 Drive Strength Register], [R/W], [0b00000000],
  [0x4000 4C0B], [P2SEL0], [Port2 Select 0 Register], [R/W], [0b00000000],
  [0x4000 4C0D], [P2SEL1], [Port2 Select 1 Register], [R/W], [0b00000000],
)

=== Commonly Used Registers of Port3

#tbl(5,
  head: ([Address], [Name], [Description], [Type], [Reset Value]),
  [0x4000 4C20], [P3IN], [Port3 Input Register], [R], [0b00000000],
  [0x4000 4C22], [P3OUT], [Port3 Output Register], [R/W], [0b00000000],
  [0x4000 4C24], [P3DIR], [Port3 Direction Register], [R/W], [0b00000000],
  [0x4000 4C26], [P3REN], [Port3 Resistor Enable Register], [R/W], [0b00000000],
  [0x4000 4C28], [P3DS], [Port3 Drive Strength Register], [R/W], [0b00000000],
  [0x4000 4C2A], [P3SEL0], [Port3 Select 0 Register], [R/W], [0b00000000],
  [0x4000 4C2C], [P3SEL1], [Port3 Select 1 Register], [R/W], [0b00000000],
)

=== Commonly Used Registers of Port4

#tbl(5,
  head: ([Address], [Name], [Description], [Type], [Reset Value]),
  [0x4000 4C21], [P4IN], [Port4 Input Register], [R], [0b00000000],
  [0x4000 4C23], [P4OUT], [Port4 Output Register], [R/W], [0b00000000],
  [0x4000 4C25], [P4DIR], [Port4 Direction Register], [R/W], [0b00000000],
  [0x4000 4C27], [P4REN], [Port4 Resistor Enable Register], [R/W], [0b00000000],
  [0x4000 4C29], [P4DS], [Port4 Drive Strength Register], [R/W], [0b00000000],
  [0x4000 4C2B], [P4SEL0], [Port4 Select 0 Register], [R/W], [0b00000000],
  [0x4000 4C2D], [P4SEL1], [Port4 Select 1 Register], [R/W], [0b00000000],
)

=== Alternate Pin Functions

#tbl(3,
  head: ([PxSEL1.y], [PxSEL0.y], [Meaning]),
  [0], [0], [Alternative 0 (Default) Simple I/O],
  [0], [1], [Alternative 1 (UART, SPI, I²C, …)],
  [1], [0], [Alternative 2 (Timers, …)],
  [1], [1], [Alternative 3 (ADC, Comparator, …)],
)

=== Port 1 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P1.0], [Simple I/O], [UCA0STE], [–], [–],
  [P1.1], [Simple I/O], [UCA0CLK], [–], [–],
  [P1.2], [Simple I/O], [UCA0RXD/UCA0SOMI], [–], [–],
  [P1.3], [Simple I/O], [UCA0TXD/UCA0SIMO], [–], [–],
  [P1.4], [Simple I/O], [UCB0STE], [–], [–],
  [P1.5], [Simple I/O], [UCB0CLK], [–], [–],
  [P1.6], [Simple I/O], [UCB0SIMO/UCB0SDA], [–], [–],
  [P1.7], [Simple I/O], [UCB0SOMI/UCB0SCL], [–], [–],
)

=== Port 2 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P2.0], [Simple I/O], [PM_UCA1STE], [–], [–],
  [P2.1], [Simple I/O], [PM_UCA1CLK], [–], [–],
  [P2.2], [Simple I/O], [PM_UCA1RXD/PM_UCA1SOMI], [–], [–],
  [P2.3], [Simple I/O], [PM_UCA1TXD/PM_UCA1SIMO], [–], [–],
  [P2.4], [Simple I/O], [PM_TA0.1], [–], [–],
  [P2.5], [Simple I/O], [PM_TA0.2], [–], [–],
  [P2.6], [Simple I/O], [PM_TA0.3], [–], [–],
  [P2.7], [Simple I/O], [PM_TA0.4], [–], [–],
)

=== Port 3 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P3.0], [Simple I/O], [PM_UCA2STE], [–], [–],
  [P3.1], [Simple I/O], [PM_UCA2CLK], [–], [–],
  [P3.2], [Simple I/O], [PM_UCA2RXD/PM_UCA2SOMI], [–], [–],
  [P3.3], [Simple I/O], [PM_UCA2TXD/PM_UCA2SIMO], [–], [–],
  [P3.4], [Simple I/O], [PM_UCB2STE], [–], [–],
  [P3.5], [Simple I/O], [PM_UCB2CLK], [–], [–],
  [P3.6], [Simple I/O], [PM_UCB2SIMO/PM_UCB2SDA], [–], [–],
  [P3.7], [Simple I/O], [PM_UCB2SOMI/PM_UCB2SCL], [–], [–],
)

=== Port 4 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P4.0], [Simple I/O], [–], [–], [A13],
  [P4.1], [Simple I/O], [–], [–], [A12],
  [P4.2], [Simple I/O], [ACLK], [TA2CLK], [A11],
  [P4.3], [Simple I/O], [MCLK], [RTCCLK], [A10],
  [P4.4], [Simple I/O], [HSMCLK], [SVMHOUT], [A9],
  [P4.5], [Simple I/O], [–], [–], [A8],
  [P4.6], [Simple I/O], [–], [–], [A7],
  [P4.7], [Simple I/O], [–], [–], [A6],
)

=== Port 5 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P5.0], [Simple I/O], [–], [–], [A5],
  [P5.1], [Simple I/O], [–], [–], [A4],
  [P5.2], [Simple I/O], [–], [–], [A3],
  [P5.3], [Simple I/O], [–], [–], [A2],
  [P5.4], [Simple I/O], [–], [–], [A1],
  [P5.5], [Simple I/O], [–], [–], [A0],
  [P5.6], [Simple I/O], [TA2.1], [–], [VREF+/VeREF+/C1.7],
  [P5.7], [Simple I/O], [TA2.2], [–], [VREF-/VeREF-/C1.6],
)

=== Port 6 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P6.0], [Simple I/O], [–], [–], [A15],
  [P6.1], [Simple I/O], [–], [–], [A14],
  [P6.2], [Simple I/O], [UCB1STE], [–], [C1.5],
  [P6.3], [Simple I/O], [UCB1CLK], [–], [C1.4],
  [P6.4], [Simple I/O], [UCB1SIMO/UCB1SDA], [–], [C1.3],
  [P6.5], [Simple I/O], [UCB1SOMI/UCB1SCL], [–], [C1.2],
  [P6.6], [Simple I/O], [TA2.3], [UCB3SIMO/UCB3SDA], [C1.1],
  [P6.7], [Simple I/O], [TA2.4], [UCB3SOMI/UCB3SCL], [C1.0],
)

=== Port 7 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P7.0], [Simple I/O], [PM_SMCLK/PM_DMAE0], [–], [–],
  [P7.1], [Simple I/O], [PM_C0OUT/PM_TA0CLK], [–], [–],
  [P7.2], [Simple I/O], [PM_C1OUT/PM_TA1CLK], [–], [–],
  [P7.3], [Simple I/O], [PM_TA0.0], [–], [–],
  [P7.4], [Simple I/O], [PM_TA1.4], [–], [C0.5],
  [P7.5], [Simple I/O], [PM_TA1.3], [–], [C0.4],
  [P7.6], [Simple I/O], [PM_TA1.2], [–], [C0.3],
  [P7.7], [Simple I/O], [PM_TA1.1], [–], [C0.2],
)

=== Port 8 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P8.0], [–], [UCB3STE], [TA1.0], [C0.1],
  [P8.1], [–], [UCB3CLK], [TA2.0], [C0.0],
  [P8.2], [–], [–], [TA3.2], [C0.0],
  [P8.3], [–], [–], [TA3CLK], [A22],
  [P8.4], [–], [–], [–], [A21],
  [P8.5], [–], [–], [–], [A20],
  [P8.6], [–], [–], [–], [A19],
  [P8.7], [–], [–], [–], [A18],
)

=== Port 9 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P9.0], [–], [–], [–], [A17],
  [P9.1], [–], [–], [–], [A16],
  [P9.2], [–], [TA3.3], [–], [–],
  [P9.3], [–], [TA3.4], [–], [–],
  [P9.4], [–], [UCA3STE], [–], [–],
  [P9.5], [–], [UCA3CLK], [–], [–],
  [P9.6], [–], [UCA3RXD/UCA3SOMI], [–], [–],
  [P9.7], [–], [UCA3TXD/UCA3SIMO], [–], [–],
)

=== Port 10 Alternative Pin Functions

#tbl(5,
  head: ([Pin Name], [SEL = 00], [SEL = 01], [SEL = 10], [SEL = 11]),
  [P10.0], [–], [UCB3STE], [–], [–],
  [P10.1], [–], [UCB3CLK], [–], [–],
  [P10.2], [–], [UCB3SIMO/UCB3SDA], [–], [–],
  [P10.3], [–], [UCB3SOMI/UCB3SCL], [–], [–],
  [P10.4], [–], [TA3.0], [–], [C0.7],
  [P10.5], [–], [TA3.1], [–], [C0.6],
)
