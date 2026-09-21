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
        [Fundamentals of Robotics — Modeling robots],
        [ROBOTICS-02])
      #v(1.5pt)
      #line(length: 100%, stroke: 0.4pt + rule)
    ]
  },
)

#set text(font: "New Computer Modern", size: 8.4pt, lang: "en",
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

#let node(body, col: primary) = box(
  inset: (x: 4pt, y: 3pt), radius: 2pt, fill: rgb("#EDF1F4"),
  stroke: 0.6pt + col, text(size: 6.4pt, weight: "bold", fill: col, body))
#let pnl(title, body) = block(width: 100%, inset: 4pt, radius: 2pt, fill: panel,
  stroke: 0.5pt + rule)[
  #align(center)[#text(size: 6.6pt, weight: "bold", fill: primary)[#title]]
  #v(2pt)
  #body
]

#place(top, scope: "parent", float: true)[
  #text(14.5pt, weight: "bold", fill: primary)[MODELING ROBOTS]
  #v(2pt)
  #text(7.3pt, fill: muted)[Fundamentals of Robotics — Lecture 02]
  #v(4pt) #line(length: 100%, stroke: 1pt + primary)
]

= Why modelling <sec-why>

- Purpose of robotics: endow a mechanical machine with some degree of intelligence.
- A robot's intelligence is expressed through the physical interaction with the surrounding world; thus it is crucial to understand what a robot can do with its own body.
- As humans, we have the same problem: we learn our body and how to use it via our experiences since the first days of our lives.

== Learning vs mathematical model

- In some cases, using experiences and learning to figure out how to transfer intent into action is possible and useful.
- However, most of the times we know quite a bit of the physical structure of a robot; this knowledge comes from physics and is expressed by a *mathematical model*.
- Mathematical models can be manipulated by mathematical means, with guaranteed results for *control* and *motion planning*.

== What to model

- The math of robotic modelling: capture *geometry*, *kinematics* and *dynamics* using a quite general mathematical formalism.
- What we need to understand: how to create and use a model in *simulation* and *design*.

= Taxonomy and terminology <sec-taxonomy>

#cmp((auto, 1fr),
  [Manipulators], [robots with a fixed base.],
  [Mobile robots], [robots with a mobile base.],
)

= Robotic manipulators <sec-manipulator>

A robotic manipulator consists of:
- *Arm* — ensuring mobility.
- *Wrist* — located at the end of the arm, enabling dextrous operation.
- *End-effector* — executing the robot's tasks.

From the geometric point of view, the manipulator is a sequence of rigid bodies (*links*), connected by mechanical articulations (*joints*).

#figure(
  grid(columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
    column-gutter: 2pt, align: center + horizon,
    node("Base"), $arrow.r$, node("Link"), $arrow.r$, node("Link"),
    $arrow.r$, node("Wrist"), $arrow.r$, node("End-effector")),
  caption: [Manipulator structure: base, rigid links connected by joints, wrist and end-effector.],
)

== Joints <sec-joints>

- Joints provide the structure with its necessary mobility.
- Two types:
  - *Prismatic joints*: enable a relative translational motion between the links.
  - *Revolute joints*: enable a relative rotational motion between the links.

#figure(
  grid(columns: (1fr, 1fr), column-gutter: 6pt,
    pnl([Prismatic])[
      #align(center, stack(dir: ttb, spacing: 2pt,
        rect(width: 44pt, height: 8pt, radius: 1pt, fill: rgb("#D6E6F2"), stroke: 0.5pt + primary),
        rect(width: 24pt, height: 8pt, radius: 1pt, fill: rgb("#F6E1CF"), stroke: 0.5pt + accent),
        $arrow.double.l.r$,
        text(size: 5.8pt, fill: muted)[translational]))
    ],
    pnl([Revolute])[
      #align(center, stack(dir: ttb, spacing: 2pt,
        rect(width: 44pt, height: 8pt, radius: 1pt, fill: rgb("#D6E6F2"), stroke: 0.5pt + primary),
        rect(width: 44pt, height: 8pt, radius: 1pt, fill: rgb("#F6E1CF"), stroke: 0.5pt + accent),
        [$arrow.curve$ #h(3pt) $theta$],
        text(size: 5.8pt, fill: muted)[rotational]))
    ]),
  caption: [Joint types: prismatic (relative translational motion) and revolute (relative rotational motion).],
)

== Definitions <sec-definitions>

#defbox("Dexterity")[A robot's ability to cope with a variety of objects and actions: how robots can interact and handle objects and take the necessary actions on the objects.]

#defbox("Stiffness")[Ability of a body to resist deformation. In formal terms, the amount of force required to induce a motion along a DoF.]

== Degrees of freedom and workspace <sec-dof>

- In a mechanical structure a *degree of freedom* (DoF) defines a specific mode in which the robot can move.
- Typically each joint is endowed with an actuator (e.g., a brushless, or a linear motor) and provides the structure with one degree of freedom.
- The more the degrees of freedom, the more flexible the machine.
- *Workspace*: the area that the end effector can reach; its structure very much depends on the number and on the type of the joints.
- Typical rotation axes: 1) waist rotation, 2) shoulder rotation, 3) elbow rotation, 4) wrist rotation, 5) gripper rotation.

= Types of manipulators <sec-manip-types>

According to the structure of the different DoF: *Cartesian*, *Cylindrical*, *Spherical*, *SCARA*, *Anthropomorphic*.

#cmp((auto, 1fr),
  [Cartesian], [three prismatic joints with three mutually orthogonal axes; workspace is a parallelepiped; good mechanical stiffness and accuracy everywhere in its workspace; the exclusive presence of prismatic joints reduces the structure's dexterity.],
  [Cylindrical], [one of the joints is replaced by a revolute joint; wrist accuracy decreases with horizontal stroke; good stiffness; workspace is a portion of cylinder; primarily used to move heavy loads within cylindric cavities.],
  [Spherical], [two prismatic joints are replaced with revolute joints; workspace is a portion of a hollow sphere; reduced accuracy when the radial stroke increases; primarily used for machining.],
  [SCARA], [Selective Compliance Assembly Robot Arm: two revolute joints and one prismatic joint; axes of motion are parallel; high stiffness to vertical loads, compliance to horizontal loads; well suited to vertical assembly tasks and manipulation of small objects; positioning accuracy decreases with the distance from the first axis.],
  [Anthropomorphic], [three revolute joints; the axis of the second and third joint are orthogonal to the axis of the first; evident similarity with the human arm (second joint = shoulder, third = elbow); the three revolute joints maximise dexterity; wrist position accuracy is different in the workspace; by far the most widespread in industry (59% of the installation).],
)

== Wrist <sec-wrist>

- All different manipulators have an end-effector attached to a wrist.
- The end-effector is usually a gripper, but can be a different thing according to the task (e.g., a welding gun, a spray gun, a screwdriver).
- The configuration of the wrist that maximises dexterity is spherical (three revolute joints).
- Each joint of a wrist provides an additional DoF.

= Mobile robots <sec-mobile>

A mobile robot is characterised by a mobile base. Two types:
- *Wheeled robots*: a rigid body (chassis) and a system of wheels that provide motion with respect to the ground; can be connected to a system of trailers connected by revolute joints.
- *Legged robots*: multiple rigid bodies connected through revolute (and sometimes) prismatic joints; some of the links form lower limbs and feet that stay in contact with the ground and provide locomotion. Not considered in this course.

== Wheel types <sec-wheels>

Wheeled robots use three types of wheels:
- *Fixed*: can only rotate about an axis passing through the centre and orthogonal to the wheel plane.
- *Steerable*: has two axes of rotation: the standard axis typical of all wheels, and a vertical axis passing through the centre.
- *Caster wheel*: similar to a steerable wheel, but its vertical axis has an offset from the centre of the wheel; the wheel swivels around when bending and automatically aligns itself with the direction of motion of the chassis.

#keypt("Note")[By combining different types of wheels we can obtain different types of kinematic structures.]

== Drive configurations <sec-drive-configs>

=== Differential drive
- Two actuated fixed wheels with the same axis; a caster wheel to keep the robot statically balanced.
- The robot can rotate by applying a different velocity to the wheels, or move straight applying the same angular velocity.
- It can rotate on the spot by setting the two speeds to opposite values.

#figure(
  block(width: 100%, height: 56pt)[
    #place(dx: 66pt, dy: 30pt, line(angle: 0deg, length: 44pt, stroke: 1pt + primary))
    #place(dx: 64pt, dy: 15pt, rect(width: 7pt, height: 30pt, radius: 1pt, fill: primary))
    #place(dx: 105pt, dy: 15pt, rect(width: 7pt, height: 30pt, radius: 1pt, fill: primary))
    #place(dx: 86pt, dy: 6pt, circle(radius: 3.5pt, stroke: 0.8pt + accent))
    #place(dx: 46pt, dy: 50pt, text(size: 5.8pt, fill: muted)[fixed wheels (same axis)])
    #place(dx: 92pt, dy: 12pt, text(size: 5.8pt, fill: muted)[caster])
  ],
  caption: [Differential drive: two actuated fixed wheels on a common axis plus a caster wheel.],
)

=== Synchro drive
- Three steerable wheels connected by a chain.
- Two motors: one rotates the three wheels "synchronously", the other transmits the motion (synchronously) to all of them.
- It can do the same kinematics of the differential drive, but it needs only one motor to move straight.

=== Tricycle
- Two wheels that are fixed and actuated by a motor.
- The third wheel is steerable and its rotation around the vertical axis is governed by another motor.
- It is also possible that the two motors operate both on the steering wheel to turn it and to secure locomotion.

=== Carlike
- Very similar to a tricycle except that it has two turning wheels.
- Traction can be on the fixed wheels (rear-wheel traction) or on the front wheel (front-wheel traction).
- Contrary to a differential drive robot, a car-like (and a tricycle) cannot turn on the spot and has a limited curvature radius.

== Ackerman steering <sec-ackerman>

- Back in 1758 Erasmus Darwin was driving his horse-drawn carriage; the two front wheels turned of the same angle and one of the wheels (the external one) slipped sideways, causing the carriage to tip over its driver.
- The solution was devised by Lankensperger in Munich and patented by his English agent (Ackerman) in London: the two wheels have to follow the same circular trajectory.
- In order to follow the same circle the internal wheel has to turn more than the external one; this is solved, in modern cars, by the geometry of the axle.
- The Ackerman steering can be generalised to the case of trailers.

#figure(
  block(width: 100%, height: 76pt)[
    // centre of turning circle (on the rear-axle line, toward the turn)
    #place(dx: 13pt, dy: 49pt, circle(radius: 3pt, fill: defcol))
    // radii (perpendicular to the wheels) converge on the centre
    #place(dx: 16pt, dy: 52pt, line(angle: -31.3deg, length: 65.5pt,
      stroke: (paint: accent, thickness: 0.5pt, dash: "dashed")))
    #place(dx: 16pt, dy: 52pt, line(angle: -13.3deg, length: 148pt,
      stroke: (paint: accent, thickness: 0.5pt, dash: "dashed")))
    // chassis side rails
    #place(dx: 72pt, dy: 18pt, line(angle: 90deg, length: 34pt, stroke: 0.5pt + rule))
    #place(dx: 160pt, dy: 18pt, line(angle: 90deg, length: 34pt, stroke: 0.5pt + rule))
    // rear axle and fixed rear wheels (rolling direction = forward/up)
    #place(dx: 72pt, dy: 52pt, line(angle: 0deg, length: 88pt, stroke: 1pt + primary))
    #place(dx: 69pt, dy: 41pt, rect(width: 6pt, height: 22pt, radius: 1pt, fill: primary))
    #place(dx: 157pt, dy: 41pt, rect(width: 6pt, height: 22pt, radius: 1pt, fill: primary))
    // front wheels: perpendicular to their radius; internal turns more than external
    #place(dx: 69pt, dy: 7pt, rotate(-30deg, origin: center,
      rect(width: 6pt, height: 22pt, radius: 1pt, fill: accent)))
    #place(dx: 157pt, dy: 7pt, rotate(-13deg, origin: center,
      rect(width: 6pt, height: 22pt, radius: 1pt, fill: accent)))
    #place(dx: 0pt, dy: 58pt, text(size: 5.6pt, fill: muted)[centre of turning circle])
    #place(dx: 104pt, dy: 0pt, text(size: 5.6pt, fill: muted)[front wheels (steered)])
    #place(dx: 118pt, dy: 58pt, text(size: 5.6pt, fill: muted)[rear wheels (fixed)])
  ],
  caption: [Ackerman steering: the two front wheels follow the same circular trajectory (the internal wheel turns more than the external one).],
)

== Motion constraints <sec-constraints>

- Contrary to manipulators, mobile robots do not usually have a limited workspace: they can reach any location in the Euclidean space.
- However, they do have motion constraints:
  - a differential drive robot is quite flexible, but it cannot move sideways along the axis connecting the actuated wheels: *nonholonomic constraint*;
  - a carlike has a limited curvature radius.

== Exception: omnibot <sec-omnibot>

- An exception is an omnibot.
- It is characterised by three autonomously actuated caster-wheels (usually in symmetric positions).
- It can move in any direction.

== Additional types of robots <sec-additional>

- Mounting an anthropomorphic manipulator and a differential drive mobile base improves the robot's working abilities.
- Dexterity can be improved by additional degrees of freedom (7 for the Kuka LWR).

== More sophisticated end-effectors <sec-end-effectors>

- A very active research area has been on the development of sophisticated anthropomorphic hands, usable for:
  - rehabilitation and assistive purposes (e.g., as a replacement for severed human hands);
  - creation of sophisticated anthropomorphic robots.

== Humanoid robots <sec-humanoid>

- Putting together several types of robots we can create humanoid robots, but this is out of the scope of this course.

= Modelling: kinematics <sec-kinematics>

== Kinematics of manipulators
- *Kinematics*: the motion of a robotic structure with respect to a generic frame; for a manipulator, given the joint position, find the position and orientation of the end effector.
- *Differential kinematics*: given the joint positions and motion (and their velocity), find the velocity of the end effector.
- *Forward kinematics*: find the end effector motion as a function of the joint motion.
- *Inverse kinematics*: find the joint motion as a function of the "desired" end-effector motion and configuration.

== Kinematics of mobile robots
- The robot's kinematics requires a correct understanding of the motion constraints.
- The kinematic model translates the instantaneous motion of the motors into an instantaneous motion of the robot as a whole, which accounts for the robot's current configuration and for its motion constraints.
