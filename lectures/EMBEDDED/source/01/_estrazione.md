# Estrazione — EMBEDDED / 01 — Lecture-1.pdf (52 pagine, 720x405pt)

Fonte unica: `Lecture-1.pdf`. Output: `EMBEDDED-01.typ` → `../../EMBEDDED-01.pdf`.

## Mappa pagina → contenuto
- 1-14: PRESENTAZIONE/CORSO — SCARTATE (titolo, course at a glance, bio docente, research context, learning outcomes, recommended background, course roadmap, course materials/books, teaching assistants, lecture format, assessment, selected projects).
- 15: divider "Introduction" — solo titolo.
- 16: Embedded Systems: Definition (tightly coupled hw/sw, dedicated functionality, embedded = built into larger system, embedding system).
- 17: Embedded Systems: Definition (application-specific, realtime); diagramma Embedded computer: Environment(sensors/user input) ↔ Embedded computer(Hardware+software) ↔ Environment(actuators/display/network); Input from environment / Output to environment; User interface; Link to other systems.
- 18: Why embed computing? (lower cost/more performance; improve dependability; more functionality; scalability).
- 19: Bike computer example (wheel rotation→speed/distance display; design shaped by size/cost/weight/power/energy; 8-bit MCU enough; "What is a microcontroller?").
- 20: A vehicle is a network of computers (100 processors high-end; specialized controllers: 4-bit seat belt, dashboard; 16/32-bit engine; low-end 20+; different timing/safety needs).
- 21: MCU vs Microprocessor (both have core, fetch/decode/execute, registers + ALU).
- 22: come 21 + "main distinction = what surrounds the processor core".
- 23: CPU (microprocessor): single core supporting fetch/decode/execute; general-purpose but depends on external memory/peripherals.
- 24: MCU: single core; basic control; has memory blocks, Digital IOs, Analog IOs, basic peripherals; integrates processor+memory+peripherals on one chip.
- 25: Dedicated hardware (custom logic narrow function; high perf/energy eff; updates harder; value of programmability).
- 26: Alternatives (FPGAs, custom logic; FPGA reconfigurable logic between fixed hw and sw).
- 27: Why MCUs fit embedded products (low dev/manuf cost, integrated peripherals; enough perf for sensing/control; low power + sleep modes).
- 28: TABELLA "Options for Building Embedded Systems" (Implementation / Design Cost / Unit Cost / Upgrades & Bug Fixes / Size / Weight / Power / System Speed; 5 righe + 2 gruppi).
- 29: Resource constraints (hardware amount? CPU speed? memory? deadlines? power? turn off logic, reduce memory accesses).
- 30: Correctness, evolution, security (does it work? spec correct? meets spec? test realtime? test real data? upgradeability? secure? dangerous acts prevented?).
- 31: Why embedded testing is difficult (complex testing, cannot separate; limited observability/controllability; restricted dev environments).
- 32: Core properties (interfacing with environment: analog signals; concurrent & reactive behaviors: timely response realtime, multiple concurrent activities; fault handling; diagnostics).
- 33: Analog sensing path (sensor detects pressure → proportional V_sensor; ADC generates integer code based on V_sensor & V_ref).
- 34: come 33 + diagramma Pressure Sensor → ADC (V_ref, V_sensor) → MCU, ADC_Code scale 111..111..100.
- 35: From ADC code to voltage — V_sensor = ADC_code × V_ref / ADC_max; ADC converts voltage range into integer codes; reference voltage + resolution define conversion scale; clipping; MCU reads codes; code `ADC_Code = adc_read();`.
- 36: come 35 + software `V_sensor = ADC_code * V_ref / ADC_MASK;`.
- 37: From voltage to pressure — sensor model; calibration constants/units/environmental assumptions explicit; `Pressure_kPa = 250 * (V_sensor / V_supply + 0.04);`.
- 38: From pressure to depth — second model; each conversion adds uncertainty; `Depth_ft =33*(Pressure_kPa–Atmos_Press_kPa)/101.3;`; depth = f(pressure − atmospheric pressure); actual relationship.
- 39: Concurrency through peripherals — diagramma Peripheral Bus (Timers, ADC, GPIO, UART, I2C) + Cortex-M Core + Interrupt Controller; peripherals run while CPU executes; interrupts notify; ISR transfers control, records event/moves data; main resumes.
- 40: Interrupt-driven execution — timing diagram Main/Timer Peripheral/Timer ISR/A-D Converter/ADC ISR: Start timer → Timer interrupt → Start ADC → ADC interrupt x4 → ADC_done = 1 (ripetuto).
- 41: Embedded Software (C rather than Java: smaller/faster/cheaper MCU; assembly for perf-critical; typically no OS: simple scheduler or interrupts+main foreground/background; if OS → embedded RTOS).
- 42: Hardware and Software Co-design Model (developed in parallel; special hw features for perf; push to software if possible → reduces hw complexity/cost).
- 43: Functional vs Non-functional Requirements (functional = output as function of input; non-functional = time, size/weight, power, reliability).
- 44: Functional vs Non-functional (functionality must; performance goal meet deadline; Deadline = time computation must finish; TV broadcast DSP cannot tolerate delays; late → system improper even if eventually correct).
- 45: come 44 + DSP specialized arithmetic units fast in real time.
- 46: The Internet of Things (IoT) (embedded devices exchange data and coordinate with software services across physical world).
- 47: IoT device examples (THERMOSTAT, WEARABLE, VOICE, SENSOR NODE; pattern: sensing, local computation, communication, action).
- 48: Why connect embedded devices? (collect beyond wired infrastructure; manage/update remotely; coordinate shared physical process; combine local sensing with remote storage/analysis; expose security/privacy/reliability risks).
- 49: Wireless Networking (critical component; wider range of sensor apps; why IoT: more functionality/intelligence, easier management, more info available).
- 50: Trillion embedded devices (grafico log people per computer 1950-2020: Mainframe, Workstation, Laptop, Smartphone, IoT/Wearable, Smart Dust; cit. Bell et al. Computer 1972, ACM 2008).
- 51: Cyber-physical Systems (physical devices + computers controlling; embedded computer = cyber part; replaces mechanical controllers more accurate/sophisticated; monitors/controls physical processes with feedback loops).
- 52: Summary (specific application, hw+sw; design challenges functional/non-functional; realtime timing correctness as important as functional/logical).

## Slide mute / decorative
- 15 solo divider. Immagini decorative presenti nelle slide scartate.

## Figure di contenuto da ridisegnare
- p17 schema embedded computer (Input/Output, environment, user interface, link)
- p19 bike computer (Input wheel rotation → Output display speed/distance)
- p28 tabella opzioni (testo disponibile integralmente)
- p33-38 pipeline sensing analogico + formule
- p39 concurrency/peripherals block diagram
- p40 interrupt-driven timeline
- p47 IoT device pattern (4 categorie)
- p50 classi di computer nel tempo (timeline)
