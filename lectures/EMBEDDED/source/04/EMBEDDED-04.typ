#import "_preamble.typ": *
#show: doc.with(title: "Processors and I/O", label: "EMBEDDED-04")
#titleblock("Processors and I/O", "EMBEDDED — Lezione 4")

== Processor and Input and Output Devices
Other than the CPU, sono presenti molti *peripherals* (I/O devices): Timers, UART, Sensors.

#figure(
  block(stroke: 0.6pt + ink, inset: 3.5pt, radius: 2pt, width: 100%, {
    text(size: 5.6pt, weight: "bold")[Chip silicon]
    v(1pt)
    grid(columns: (1fr, 0.7fr, 0.7fr, 0.8fr), column-gutter: 2pt, row-gutter: 2pt,
      gb(fill: rgb("#F6C6A8"))[Cortex-M4], gb[PPB], gb[SCS],
      grid(rows: (auto, auto), row-gutter: 2pt, gb[NVIC], gb[Debug CRTL]))
    v(2pt)
    gb[AHB/ APB]
    v(2pt)
    grid(columns: (1fr, 1fr, 1.15fr), column-gutter: 2.5pt,
      gb(fill: rgb("#E5C6F0"))[On-chip FLASH\ (Code Region)],
      gb(fill: rgb("#F6C6A8"))[On-chip SRAM\ (SRAM Region)],
      grid(columns: (1fr, 1fr, 1fr), column-gutter: 1.5pt, gb[Timer], gb[UART], gb[GPIO]))
    v(2pt)
    grid(columns: (1fr, 1fr), column-gutter: 2.5pt,
      gb[External memory interface\ (External RAM Region)],
      gb(fill: rgb("#F7A8C4"))[External device interface\ (External Device Region)])
  }),
  caption: [On-chip FLASH, on-chip SRAM, peripheral region (Timer, UART, GPIO) e interfacce verso dispositivi esterni (External SRAM/FLASH, External LCD, SD card).]
)
Il processore raggiunge gli *on-chip peripherals* attraverso la *bus matrix*; le *external interfaces* collegano dispositivi *off-chip* (External SRAM/FLASH, External LCD, SD card).

== How Do They Communicate?
#keep[
Ogni *peripheral* (device) espone dei *registers*. La CPU dialoga col dispositivo leggendo e scrivendo i *device registers*. Le interrupt lines (non mostrate nella figura) riportano eventi dai dispositivi I/O che richiedono servizio della CPU.
]

#figure(
  grid(columns: (1fr, 0.55fr, 1.25fr), column-gutter: 2pt, align: center,
    gb[CPU],
    text(size: 6pt)[$arrow.l.r$],
    grid(rows: (auto, auto), row-gutter: 3pt,
      gb(fill: rgb("#DCE7EC"))[Status Register],
      gb(fill: rgb("#F6D9C6"))[Data Register])),
  caption: [CPU collegata ai registri Status e Data; i registri sono collegati al Device Mechanism.]
)

=== Device registers link software e hardware state
I device registers collegano il software allo stato hardware.

#defbox([Data registers],[
  Carry values moving into or out of the device.
  #list([hold data values], [access direction depends on the peripheral], [can be readable or writable])
])

#defbox([Status and control registers],[
  Report events and configure operating modes (e.g., event: the current operation has been completed).
  #list([individual bits often have different meanings])
])

=== Two architectural models for device access
Due modi per accedere ai registri.
- *I/O instructions*: istruzioni speciali per input/output; `in` e `out` nel caso dell'Intel x86; forniscono un *separate address space* per i dispositivi I/O (separate address lines…).
- *Memory-mapped I/O*: fornisce indirizzi per i registri di ciascun dispositivo I/O; i programmi usano le normali istruzioni di memory read/write della CPU per comunicare coi dispositivi.

#cmp((1.1fr, 1.6fr, 1.7fr, 1.2fr),
  [Model], [Addressing], [Instructions], [Typical example],
  [Separate I/O space], [Dedicated device address space], [Special input and output instructions], [Legacy x86 ports],
  [Memory-mapped I/O], [Device registers share the memory address space], [Normal load and store instructions], [Arm microcontrollers])

== Device register access in ARM and C
=== ARM loads and stores access device registers
Definire la location del device e fornire il codice Read/Write:

```c
DEV1_BASE EQU 0x40001000
LDR r1, = DEV1_BASE
LDR r0, [r1]        // read register
MOVS r0, #8
STR r0, [r1]        // write register
```

#keypt([What matters],[
  L'address deve identificare il registro corretto; access width e alignment devono corrispondere alla specifica del peripheral.
  Un address errato può controllare un altro peripheral o causare un *bus fault*.
])

=== C requires volatile access to device registers
Si possono usare i pointer per manipolare gli indirizzi dei dispositivi I/O.

```c
#include <stdint.h>
#define DEV1_STATUS_ADDR 0x40001000u
#define DEV1_STATUS(*(volatile uint32_t *)DEV1_STATUS_ADDR)

uint32_t status = DEV1_STATUS;
DEV1_STATUS = 8u;
```
`volatile` indica al compiler che ogni read e write conta, perché l'hardware può cambiare il valore fuori dal normale flusso del programma.

Introducendo funzioni che leggono e scrivono memory locations:

```c
#define DEV1_STATUS_ADDR 0x40001000u

int read(uint8_t *location) {
  return *location;
}

void write(uint8_t *location, char newval) {
  (*location) = newval;
}

uint32_t status = read(DEV1_STATUS_ADDR); /* read device register */
write(DEV1_STATUS_ADDR,8); /* write 8 to device register */
```

=== Register definitions should express width and intent
Il device reference manual definisce il legal access pattern per ogni device register.

#tbl((1fr, 2.1fr), head: ([Concern], [Reason]),
  [Access width], [A byte, halfword, or word transfer may have different hardware meaning],
  [Read-only and write-only behavior], [Some registers reject unsupported access directions],
  [Reserved bits], [Software should preserve or write required values],
  [Side effects], [A read may clear status and a write may acknowledge an event])

== Polling (Busy-Wait) I/O
- I dispositivi I/O sono tipicamente più lenti della CPU: possono richiedere molti cicli per completare un'operazione.
- *Busy-wait* (spesso chiamato *polling*): chiedere a un dispositivo I/O se ha finito leggendo il suo *status register*; il software legge lo status register finché non appare la condizione *ready* o *complete*.
- Il loop fornisce bassa complessità di control-flow, ma i cicli CPU vengono consumati mentre non progredisce lavoro utile.

=== Polling an output device (Example)
- Un carattere avvia ogni transazione.
- Il loop interno attende il completamento.

```c
#define OUT_CHAR 0x1000 /* output device character register */
#define OUT_STATUS 0x1001 /* output device status register */

while (*current != '\0') {
  OUT_DATA = *current;
  OUT_STATUS = START;

  while (OUT_STATUS != DONE) {
    // CPU waits here
  }

  current++;
}
```
La CPU non può svolgere lavoro applicativo indipendente durante l'attesa.

=== A polling-based input-to-output loop (Example)
Ripetere per sempre:
- attendere che l'input status riporti dati disponibili;
- leggere un valore dal input data register;
- scrivere quel valore nel output data register;
- attendere che il output device completi la transazione.

```c
for (;;) {
  while (IN_STATUS == EMPTY) { }
  uint8_t c = IN_DATA;

  while (OUT_STATUS == BUSY) { }
  OUT_DATA = c;
  OUT_STATUS = START;
}
```
Il loop non permette al foreground work di continuare.

== Interrupt-driven I/O
- Il busy-wait I/O è inefficiente: la CPU potrebbe fare lavoro utile in parallelo all'I/O.
- Il meccanismo degli interrupt permette a un dispositivo di richiedere servizio solo quando si verifica un evento.
- Il processore salva il context, esegue un handler, poi riprende il programma interrotto.

=== Several signals control the interrupt process
- Il dispositivo asserisce un *interrupt request*: la logica del dispositivo I/O decide quando interrompere (e.g., quando i dati sono pronti).
- La CPU accetta la richiesta: asserisce il segnale *interrupt acknowledge* e cambia il program counter in modo che punti all'*interrupt handler* del dispositivo.
- L'*interrupt handler* identifica la sorgente dell'evento (e.g., quale dispositivo) e compie le azioni di processing necessarie.

#figure(
  grid(columns: (1fr, 1.15fr, 1.25fr), column-gutter: 3pt, align: center,
    gb[CPU],
    block(text(size: 5.5pt)[
      #text(fill: accent)[Interrupt Request] $arrow.r$ \
      #v(1pt) $arrow.l$ Interrupt Acknowledge \
      #v(1pt) Data/Address $arrow.r$
    ]),
    block(width: 100%, stroke: 0.5pt + ink, inset: 3pt, radius: 1.5pt,
      grid(columns: (1fr, 1.1fr), column-gutter: 2pt, align: center,
        grid(rows: (auto, auto), row-gutter: 3pt, gb(fill: rgb("#DCE7EC"))[Status Register], gb(fill: rgb("#F6D9C6"))[Data Register]),
        gb(fill: rgb("#E2E6E8"))[Device Mechanism]))),
  caption: [Interrupt request, interrupt acknowledge e data/address tra CPU e dispositivo.]
)

=== Interrupt entry changes control flow
Quando avviene un interrupt:
- per prima cosa viene salvato il valore del PC al momento dell'interruzione, così la CPU può tornare al foreground program;
- poi il PC punta a una interrupt handler routine, che serve il dispositivo leggendo i dati appena pronti, scrivendo i successivi dati…

#tbl((1fr, 2.1fr), head: ([Phase], [Processor action]),
  [Recognition], [Detect interrupt],
  [Context save], [Preserve the return state and selected registers],
  [Vector fetch], [Load the handler address from the vector table],
  [Service], [Execute the interrupt handler],
  [Return], [Restore state and resume the interrupted code])

=== Cortex-M interrupt entry
- Salva il context necessario: pushes dei registri importanti R0–R3, R12, LR, PC e xPSR nello stack.
- Trova l'handler address dall'interrupt vector table; l'handler può salvare registri aggiuntivi che usa.
- L'interrupt return ripristina lo stato e il context salvati dall'hardware.
- Il codice interrupt in C è processato dal compiler in modo specifico: gli handler generati dal compiler seguono l'architecture calling convention quando dichiarati correttamente.

=== A minimal input interrupt handler in C
- Legge il dato che ha causato l'interrupt.
- Registra lo stato minimo per il processing successivo.
- Acknowledge o clear dell'evento del dispositivo.
- Ritorna rapidamente.

```c
volatile uint8_t latest_char;
volatile bool char_ready;

void input_handler(void) {
  latest_char = IN_DATA; // read device register
  char_ready = true;
  IN_STATUS = ACK; // acknowledge the device
}
```

=== Interrupts example
Copiare caratteri da input a output con interrupt di base:
- `achar`: passa il carattere al foreground program;
- `gotchar`: segnala quando è stato ricevuto un nuovo carattere.

```c
/* INTERRUPT HANDLERS */
/* get a character and put in global (called when IN_STATUS is 1) */
void input_handler() {
  achar = read(IN_DATA); /* get character */
  gotchar = TRUE;        /* signal to main program */
  write(IN_STATUS,0);    /* reset status to initiate next transfer */
}

/* react to character being sent (called when OUT_STATUS is 0) */
void output_handler() {
  /* don't have to do anything */
}
```

Il main program è un po' più semplice rispetto al Busy Wait I/O, ma ancora non permette al foreground program di fare lavoro utile: esegue polling di input e scrive dati.

```c
main() {
  while (TRUE) { /* read then write forever */
    if (gotchar){ /* write a character */
      write(OUT_DATA,achar); /* put character in device */
      write(OUT_STATUS,1);   /* set status to initiate write */
      gotchar = FALSE;       /* reset flag */
    }
  }
}
```

== A circular buffer separates producer and consumer timing
- Un indice identifica la next read position.
- L'altro identifica la next write position.

#figure(
  block(stroke: 0.5pt + rule, inset: 5pt, width: 100%, {
    grid(columns: range(8).map(_ => 1fr), column-gutter: 0pt, row-gutter: 0pt,
      ..([], [a], [b], [c], [d], [e], [f], [g]).map(v => cellbox(v)))
    v(2pt)
    grid(columns: range(8).map(_ => 1fr),
      align(center, text(size: 5.5pt, fill: accent)[head]),
      align(center, text(size: 5.5pt, fill: accent)[tail]),
      ..range(6).map(_ => []))
  }),
  caption: [Buffer circolare a 8 celle; un indice per la next read position, l'altro per la next write position.]
)

=== Buffer implementation
```c
#define BUF_SIZE 8
char io_buf[BUF_SIZE];          /* character buffer */
int buf_head = 0, buf_tail = 0; /* current position in buffer */
int error = 0;                  /* set to 1 if buffer ever overflows */

int buffer_empty() { /* returns TRUE if buffer is empty */
  return buf_head == buf_tail;
}

int buffer_full() { /* returns TRUE if buffer is full */
  return (buf_tail+1) % BUF_SIZE == buf_head ;
}

int nchars() { /* returns the number of characters in the buffer */
  if (buf_head >= buf_tail)
    return buf_head - buf_tail;
  else
    return BUF_SIZE - buf_tail - buf_head;
}
```

```c
void buffer_put(char achar) { /* add a character to the buffer head */
  io_buf[buf_tail++] = achar;
  /* check pointer */
  if (buf_tail == BUF_SIZE)
    buf_tail = 0;
}

char buffer_get() { /* take a character from the buffer head */
  char achar;
  achar = io_buf[buf_head++];
  /* check pointer */
  if (buf_head == BUF_SIZE)
    buf_head = 0;

  return achar;
}
```

== Interrupts example with circular buffer
=== Input ISR adds data and starts output
- Cattura l'elemento in arrivo.
- Registra l'overflow senza bloccarsi.
- Avvia l'output solo quando la coda era idle.
- Acknowledge dell'evento di input.

```c
void input_handler(void) {
  uint8_t c = IN_DATA;

  if (buffer_full()) {
    overflow = true;
  } else {
    bool was_empty = buffer_empty();
    buffer_put(c);
    if (was_empty) start_output();
  }

  IN_STATUS = ACK;
}
```

=== Output ISR launches the next queued item
- Ogni completion interrupt lancia il prossimo elemento in coda.
- L'handler disabilita gli interrupt non necessari quando non restano dati.

```c
void output_handler(void) {
  OUT_STATUS = ACK;
  if (!buffer_empty()) {
    OUT_DATA = buffer_get();
    OUT_CONTROL = START;
  } else {
    stop_output();
  }
}
```

=== Foreground vs interrupt
Il foreground program viene occasionalmente interrotto da operazioni di input e output, gestite dagli interrupt handler in background; il foreground program riprende dopo gli handler.

```text
main() --Input ISR--> main() --Output ISR--> main() --Input ISR--> main()
        (background)          (background)           (background)   --> Time
```

== Bugs
- Gli errori possono essere molto difficili da trovare quando gli interrupt handler hanno bug, a causa della concurrency.
- L'interrupt handler deve salvare ogni registro CPU che modificherà e ripristinarli prima di uscire.
- Dimenticare di salvare/ripristinare un registro nell'handler può far cambiare misteriosamente una variabile del foreground program.

=== Read-modify-write race
Esempio: impostare bit[3] nel word data all'address `0x20000000`.

```text
;Read-Modify-Write Operation
LDR R1, =0x20000000 ;Setup address     LDR R1, =0x20000000 ;Setup address
LDR R0, [R1]        ;Read 0x21         LDR R0, [R1]        ;Read 0x21
...                    Interrupt!      ORR.W R0, #0x8      ;Set bit[3]
LDR R1, =0x20000000 ;Setup address     STR R0, [R1]        ;Write back 0x29
STR R2,[R1]         ;Write back 0x79   ...
...                    Return!
```

#defbox([Read-modify-write operation],[
  #list(
    [Legge il dato (`0x21`) dall'address `0x20000000`.],
    [L'interrupt cambia il dato dell'address `0x20000000` e riscrive il vecchio dato modificato.],
    [`0x79` è andato perso!]
  )
])

```text
Main program:  Read data --> Modify bit[3] ----------------> Write data back
                                      Interrupt occurs
ISR:                          Read data -> Modify bit[3] -> Write data back
                              (Interrupt Service Routine)
Bit[3] modificato dall'ISR viene sovrascritto dal main program.
```

== Interrupt handlers should do bounded work
- Catturare o consegnare il minimo dato richiesto dal dispositivo.
- Clear della sorgente di interrupt prima che possa riattivarsi inaspettatamente.
- Evitare blocking calls e loop non limitati.
- Spostare il processing costoso nel foreground o in deferred work.
- Misurare il worst-case execution time.

== Interrupts - Implementaton
- La CPU controlla la *interrupt request (IRQ)* line a ogni istruzione.
- Se una interrupt request è stata asserita, la CPU:
  - mette il return address su uno stack (come fa per le subroutine);
  - non fetcha l'istruzione puntata dal PC, ma setta il PC all'inizio dell'*interrupt handler*.
- Gli address degli interrupt handler sono memorizzati in una tabella.

== Priorities and Vectors
- La maggior parte dei sistemi ha più di un dispositivo I/O: più dispositivi possono interrompere; più interrupt handler, device address.
- *Interrupt priorities*: riconoscere alcuni interrupt come più importanti di altri.
- *Interrupt vectors*: permettere al dispositivo che interrompe di specificare il proprio interrupt handler.

=== Programmable interrupt controller (PIC)
- Il *Programmable interrupt controller* (PIC) prioritizza più sorgenti di interrupt in modo che, in ogni momento, l'interrupt a priorità più alta sia presentato alla core CPU per il processing.
- Cortex-M integra questa funzione nell'*NVIC*.

#asciifig("Airbag Sensor HIGHEST \\\nBreak Sensor  HIGH     \\\nReal Time Clk MED       > PIC --> CPU\nFuel Level    LOW      /        (Interrupt Vector)",
  [Sorgenti di interrupt con priorità HIGHEST/HIGH/MED/LOW verso il PIC, poi verso la CPU; il PIC fornisce l'Interrupt Vector.])

=== Priority logic and nested interrupts
- La *priority logic* seleziona la highest eligible request; il PIC memorizza il priority level di quell'interrupt in un registro interno.
- Quando sopraggiunge un interrupt successivo, la priorità è confrontata con la priorità corrente.
- *Nested interrupts*: una sorgente a priorità più alta può preemptare il processing di un interrupt a priorità più bassa.

=== Pending bits, masking, NMI
- I *pending bits* registrano gli interrupt in attesa di servizio.
- *Masking interrupts*: gli enable bits determinano quali sorgenti possono interrompere.
- L'interrupt a priorità più alta è chiamato *nonmaskable interrupt (NMI)*.
- L'NMI non può essere disattivato: e.g., di solito riservato a interrupt causati da power failures, per salvare critical state in memoria non volatile, spegnere dispositivi I/O…

== Interrupt Vector Table
- Ogni interrupt ha un *vector number*, che indicizza la vector table.
- La entry selezionata contiene l'*interrupt vector*, cioè il memory address dell'interrupt handler.

#tbl((1.4fr, 1fr), head: ([Interrupt Vector Table], []),
  [Handler 1], [Vector 0],
  [Handler 3], [Vector 1],
  [Handler 4], [Vector 2],
  [Handler 2], [Vector 3])

== Overhead of Interrupts
Un interrupt causa un cambiamento del program counter (incorre in un branch penalty):
- l'interrupt può salvare automaticamente alcuni registri CPU, richiedendo cicli extra;
- acknowledge dell'interrupt e ottenimento dell'interrupt vector richiedono cicli extra;
- l'overhead dell'interrupt handler: salva e ripristina i registri CPU non salvati automaticamente; la interrupt return instruction ripristina lo stato salvato automaticamente e incorre in un branch penalty.

#defbox([Interrupt Response Time],[
  Il tempo richiesto dall'hardware per rispondere all'interrupt, ottenere il vector, salvare lo stato e così via, *non può essere cambiato dal programmatore*.
])

```text
        Interrupt Latency   Processing Time
        |<-------------->|<--------------->|
... ____|                 |                |____ ...
               Interrupt Response Time
|<---------- Time Between Interrupts ---------->|
```
