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
        [Fundamentals of Robotics — Introduction],
        [ROBOTICS-01])
      #v(1.5pt)
      #line(length: 100%, stroke: 0.4pt + rule)
    ]
  },
)

#set text(font: "New Computer Modern", size: 8.4pt, lang: "it",
         fill: ink, hyphenate: true)
#set par(justify: true, leading: 0.55em, spacing: 0.5em, first-line-indent: 0em)
#show raw: set text(font: "DejaVu Sans Mono", size: 7pt)
#set list(indent: 0.85em, marker: [•], spacing: 0.22em, tight: true)
#set enum(indent: 0.85em, spacing: 0.22em, tight: true)

#let keep(body) = block(breakable: false, width: 100%, body)

#set heading(numbering: none)
#show heading: it => block(
  breakable: false, sticky: true, above: 0.7em, below: 0.28em,
)[
  #text(size: if it.level <= 1 { 11pt } else if it.level == 2 { 9.4pt } else { 8.6pt },
        weight: "bold", fill: primary, it.body)
  #if it.level <= 1 [#v(1.5pt) #line(length: 100%, stroke: 0.7pt + rule)]
]

#let callout(title, body, col: accent, bg: panel) = keep(block(
  width: 100%, inset: (x: 4pt, y: 3pt), radius: 1pt, fill: bg,
  stroke: (top: 0pt + col, right: 0pt + col, bottom: 0pt + col, left: 1.4pt + col),
)[
  #text(size: 7.9pt, weight: "bold", fill: col)[#title]#h(0.35em)#body
])
#let keypt(t, b) = callout(t, b, col: accent,  bg: rgb("#FDF4E7"))
#let defbox(t, b) = callout(t, b, col: defcol,  bg: rgb("#EDF5F4"))
#let warn(t, b)  = callout(t, b, col: danger,   bg: rgb("#FBEDED"))

#let cmp(cols, ..cells) = keep({
  let c = cells.pos()
  let n = if type(cols) == array { cols.len() } else { cols }
  grid(
    columns: cols, inset: (x: 4pt, y: 3pt), align: left,
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

#set figure(gap: 2.5pt, supplement: [Fig.], numbering: "1")
#show figure.caption: set text(size: 6.9pt, fill: muted)

// ===== helpers figure =====
#let node(body, col: primary) = box(
  inset: (x: 5pt, y: 4pt), radius: 2pt, fill: rgb("#EDF1F4"),
  stroke: 0.7pt + col, text(size: 7.2pt, weight: "bold", fill: col, body))
#let pnl(title, body) = block(width: 100%, inset: 4pt, radius: 2pt, fill: panel,
  stroke: 0.5pt + rule)[
  #align(center)[#text(size: 6.6pt, weight: "bold", fill: primary)[#title]]
  #v(2pt)
  #body
]

#place(top, scope: "parent", float: true)[
  #text(14.5pt, weight: "bold", fill: primary)[Fundamentals of Robotics]
  #v(2pt)
  #text(7.3pt, fill: muted)[Introduction]
  #v(4pt) #line(length: 100%, stroke: 1pt + primary)
]

= What are robots?

"Robot" is a Czech word, _robota_, meaning "forced labour". The word was introduced by the novelist Karel Čapek in 1920 and became famous for the vast body of Science Fiction that it generated. More recently the word refers to a well defined technological domain which, over the course of the last years, has generated a multi-billion euros worth market.

#defbox("Definition (Longam dictionary)")[
  A machine that can *move* and do some of the work of a person and is usually *controlled by a computer*. The stress is on the ability to move and on the system intelligence.
]

== Examples

- *Robotic Arm* — moves to operate on the manufactured piece; motion controlled at different levels: *Local* = motion controllers on the joints, *Global* = motion plan to execute.
- *Drone* — can fly (autonomously or controlled) for surveillance, delivery or just for fun; control levels: *Motors* (rpm of each motor), *Trajectory following* (on board), *Mission planning* (remote).
- *Food delivery robot* — control levels: *Motors*, *Path*, *Mission*.
- *Assistive technology "made in Trento"* — key: understanding and adapting to human needs.
- *Autonomous racing* — control all levels + try to adapt to the adversary intent in order to win the race; nice combination of game theory, graph theory and optimal control.
- *Human as pathfinder* — the robot follows closely a human elected as «guide»; big issue: identifying and tracking your pathfinder.

== A few observations

The robots shown in the previous examples have the following abilities:
- estimate their position (more generally their state) in the environment;
- sense the environment and create a map;
- take a decision;
- act to implement the decision.

== The system intelligence

The system intelligence is concentrated in two different aspects:
- *Perception* (surrounding environment, and ... itself in the environment);
- *Decision* (what to do and how to do it).

= Architectures

== Deliberative Paradigm <sec-deliberative>

#figure(
  grid(columns: (1fr, auto, 1fr, auto, 1fr), align: center,
    node("Sense"), $arrow.r$, node("Plan", col: accent), $arrow.r$, node("Act", col: defcol)),
  caption: [Deliberative loop: Sense $arrow.r$ Plan $arrow.r$ Act, then back to Sense.],
)

*Top/Down philosophy.* The robot:
+ senses the world and constructs an updated model of the environment;
+ plans a course of action;
+ implements the plan.

#keypt("Assumption")[The environment is closed and its only changes are due to the robot action.]

All decisions are taken after a thorough deliberation procedure. Planning is prominent because we will not make corrections before the next sensing operation; we need a comprehensive model of the environment. The responses of the system are therefore quite slow.

== Reactive Paradigm <sec-reactive>

#figure(
  grid(columns: (1fr, auto, 1fr, auto, 1fr), align: center + horizon,
    node("Sense"), $arrow.r$,
    stack(dir: ttb, spacing: 3pt, node("Wander", col: accent), node("Avoid Obstacles", col: accent)), $arrow.r$,
    node("Act", col: defcol)),
  caption: [Reactive loop: Sense feeds the concurrent behaviours (Wander, Avoid Obstacles) driving Act; Act $arrow.r$ Environment $arrow.r$ Sense.],
)

*Sens-Act organisation*: a reaction in response to a sensed data. Several Sensing/Reaction pairs are stored (system behaviours), which operate concurrently; the robot will actually execute a combination of behaviours.

#keep[
- *Situated* agent: the robot is an integral part of the world.
- *No memory*: controlled by what is happening in the world.
- *Tight coupling* between perception and action via behaviours.
- Only *local, behaviour-specific* sensing is permitted (*ego-centric* representation).
- The overall behaviour of the robot *emerges* from the combination of the different behaviours.
]

== Example: Potential Fields <sec-potential>

- Treat the robot as a *particle* acting under the influence of potential fields.
- The robot travels along the *derivative* of the potential.
- The field depends on obstacles, desired travel directions and targets.
- The resulting field (vector) is given by the *summation of primitive fields*.
- The strength of the field may change with distance to obstacle/target.

#figure(
  stack(dir: ttb, spacing: 4pt,
    pnl([Uniform Potential Field])[
      #align(center)[#text(size: 9pt)[$+$]]
      #align(center)[#text(size: 8pt)[$arrow.b$ #h(2pt) $arrow.b$ #h(2pt) $arrow.b$ #h(2pt) $arrow.b$ #h(2pt) $arrow.b$]]
      #align(center)[#text(size: 9pt)[$-$]]
    ],
    pnl([Attractive / Repulsive Fields])[
      #grid(columns: (auto, 1fr), align: center + horizon, column-gutter: 6pt,
        circle(radius: 8pt, fill: rgb("#D6E6F2"), stroke: 0.5pt + primary)[#text(5.4pt, fill: primary)[Goal]],
        [#text(6.4pt)[attractive field: vectors converge on the *Goal*]],
        circle(radius: 8pt, fill: rgb("#F6E1CF"), stroke: 0.5pt + accent)[#text(5.4pt, fill: accent)[Obs]],
        [#text(6.4pt)[repulsive field: vectors diverge from the obstacle]],
      )
    ],
    pnl([Combination])[
      #align(center)[#text(size: 8pt)[$arrow.tr$ $arrow.r$ $arrow.br$ #h(4pt) $arrow.tl$ $arrow.l$ $arrow.bl$]]
      #align(center)[#text(6.4pt)[Goal $plus$ Obs $arrow.r$ resultant vector field (sum of primitive fields)]]
    ],
  ),
  caption: [Potential fields: uniform field, attractive/repulsive primitive fields, and their combination.],
)

== Example: Corridor Following <sec-corridor>

#cmp((auto, 1fr),
  [Level 0], [collision avoidance: done by the repulsive fields of detected obstacles.],
  [Level 1], [wander: adds a uniform field.],
  [Level 2], [corridor following: replaces the wander field by three fields (two perpendicular, one uniform).],
)

== Hybrid Paradigm <sec-hybrid>

#figure(
  align(center, stack(dir: ttb, spacing: 2pt,
    node("Plan", col: accent),
    $arrow.t.b$,
    grid(columns: (1fr, auto, 1fr), align: center,
      node("Sense"), $arrow.l.r$, node("Act", col: defcol)),
  )),
  caption: [Hybrid paradigm: Plan interacts with Sense and Act; Sense and Act are coupled.],
)

The robot first plans (deliberates) how to best decompose a task into subtasks (also called "mission planning") and then what are the suitable behaviours to accomplish each subtask. Then the behaviours start executing as per the Reactive Paradigm. Sensing organisation is also a mixture of Hierarchical and Reactive styles: sensor data gets routed to each behaviour that needs that sensor, but is also available to the planner for construction of a task-oriented global world model.

#keep[
- Hybrid Paradigms combine a good attention for *planning* with the ability for the system to *react to unexpected changes* in the environment.
- The idea is to have a combination of *strategy* (for planning) and *tactics* (for the execution of subtasks).
- The system maximises performance paying the price of a high level of complexity.
]

= Perception <sec-perception>

In the context described above perception is key.

#defbox("Perception")[A cognitive activity that makes the system aware of itself and of its environment.]

It helps the robot respond such queries as:
- How can I detect and classify the different entities of my surrounding environment?
- How can I construct a map that contains both *metric and semantic* information?
- Where am I in the map right now?
- Where are the objects I need to interact with or avoid?

This information is key to take the right decisions both in terms of which action I should do and of which path I should follow.

== Perception examples

- Example from the scrabble game: detection of the tiles with their position and angle.
- Gesture recognition for HRI (provided by one of your former colleagues).

== Perceiving humans <sec-humans>

#keep[
- Humans are increasingly part of the robot's horizon.
- Sometimes the robot is required to operate in an environment populated by humans and has to preserve their safety.
- Sometimes the robot is supposed to collaborate with the human (e.g., cobots).
- Sometimes the robot is supposed to assist the human.
- Once again a reliable perception is key.
]

#tbl((1fr, 1fr, 1fr),
  head: ([SAFETY], [ASSISTANCE], [COLLABORATION]),
  [Where are the humans in the scene and where are they going?],
  [What is the human's affective state right now?],
  [What action is a human doing right now, and what will she/he do in the near future?],
)
