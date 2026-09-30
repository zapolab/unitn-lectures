#import "_preamble.typ": *
#import "@preview/cetz:0.5.2": canvas, draw
#import "_cetz-boxes.typ": cbox

#let C = rgb("#1B4965")
#let A = rgb("#2E7D32")
#let ar(a, b, l: none, col: A, off: 0, fs: 5pt) = {
  draw.line(a, b, stroke: 0.6pt + col, mark: (end: ">", fill: col))
  if l != none {
    draw.content(((a.at(0) + b.at(0)) / 2 + off, (a.at(1) + b.at(1)) / 2), text(size: fs, l))
  }
}
#let layer(x, y, w, name, ex) = cbox(x, y, w, 0.8, [#strong(name) \ #text(size: 4.3pt)[#ex]], fs: 5.2pt)

#show: doc.with(title: "Sensing Devices", label: "ROBOTICS-07")
#titleblock("Sensing Devices", "ROBOTICS — Lezione 7")

== Perception and sensing

=== Sensors for Mobile Robots
- Key components for perceiving the environment.
- Understanding the physical principles enables appropriate use.
- Understanding the physical principle behind sensors enables us:
  - to properly select the sensors for a given application;
  - to properly model the sensor system, e.g., resolution, bandwidth, uncertainties.

=== Perception for Mobile Robots
#figure(caption: [Pipeline di percezione: Raw Data $arrow.r$ Features $arrow.r$ Objects $arrow.r$ Places/Situations; a destra i modelli.], [#raw("")
  #scale(92%, reflow: true)[
    #canvas({
      cbox(0, 4.35, 3.0, 0.7, [Kitchen \ #text(size: 4.3pt)[Cabinet, Table, Oven, Drawers]], fs: 5.2pt)
      layer(0, 0, 3.0, [Raw Data], [Vision, Laser, Sound, Smell, ...])
      layer(0, 1.15, 3.0, [Features], [Corners, Lines, Colors, Phonemes, ...])
      layer(0, 2.3, 3.0, [Objects], [Doors, Humans, Coke bottle, car, ...])
      layer(0, 3.45, 3.0, [Places/Situations], [A specific room, a meeting situation, ...])
      ar((1.5, 0.8), (1.5, 1.12), l: [Navigation], off: 0.95)
      ar((1.5, 1.95), (1.5, 2.27), l: [Interaction], off: 0.95)
      ar((1.5, 3.1), (1.5, 3.42), l: [Servicing/Reasoning], off: 1.25)
      ar((3.35, 0.4), (3.35, 4.0), l: [Compressing Information], col: C, off: 1.35)
      cbox(4.3, 1.15, 2.9, 0.8, [Models \ #text(size: 4.3pt)[imposed; learned]], fs: 5.2pt)
      cbox(4.3, 2.3, 2.9, 0.8, [Models/Semantics \ #text(size: 4.3pt)[imposed; learned]], fs: 5.2pt)
      cbox(4.3, 3.45, 2.9, 0.95, [Functional/Contextual Relationships of Objects \ #text(size: 4.3pt)[imposed; learned; spatial / temporal / semantic]], fs: 5.2pt)
      draw.line((3.0, 1.55), (4.28, 1.55), stroke: 0.5pt + C, mark: (end: ">", fill: C))
      draw.line((3.0, 2.7), (4.28, 2.7), stroke: 0.5pt + C, mark: (end: ">", fill: C))
      draw.line((3.0, 3.85), (4.28, 3.85), stroke: 0.5pt + C, mark: (end: ">", fill: C))
    })
  ]])

=== Dealing with Real World Situations
- Reasoning about a situation.
- Cognitive systems have to interpret situations based on uncertain and only partially available information.
- They need ways to learn functional and contextual information (semantics / understanding).
#keypt("Probabilistic Reasoning", [Interpretazione di situazioni con informazione incerta e parziale.])

=== Classification of Sensors
- *What:*
  - *Proprioceptive sensors*: measure values internally to the system (robot); e.g. motor speed, wheel load, heading of the robot, battery status.
  - *Exteroceptive sensors*: information from the robot's environment; distances to objects, intensity of the ambient light, unique features.
- *How:*
  - *Passive sensors*: measure energy coming from the environment; very much influenced by the environment.
  - *Active sensors*: emit their proper energy and measure the reaction; better performance, but some influence on environment.

=== General Classification
*Tactile sensors* (detection of physical contact or closeness; security switches): Contact switches, bumpers (EC, P); Optical barriers (EC, A); Noncontact proximity sensors (EC, A).

*Wheel/motor sensors* (wheel/motor speed and position): Brush encoders (PC, P); Potentiometers (PC, P); Synchros, resolvers (PC, A); Optical encoders (PC, A); Magnetic encoders (PC, A); Inductive encoders (PC, A); Capacitive encoders (PC, A).

*Heading sensors* (orientation of the robot in relation to a fixed reference frame): Compass (EC, P); Gyroscopes (PC, P); Inclinometers (EC, A/P).

*Ground-based beacons* (localization in a fixed reference frame): GPS (EC, A); Active optical or RF beacons (EC, A); Active ultrasonic beacons (EC, A); Reflective beacons (EC, A).

*Active ranging* (reflectivity, time-of-flight, and geometric triangulation): Reflectivity sensors (EC, A); Ultrasonic sensor (EC, A); Laser rangefinder (EC, A); Optical triangulation (1D) (EC, A); Structured light (2D) (EC, A).

*Motion/speed sensors* (speed relative to fixed or moving objects): Doppler radar (EC, A); Doppler sound (EC, A).

*Vision-based sensors* (visual ranging, whole-image analysis, segmentation, object recognition): CCD/CMOS camera(s) (EC, A); Visual ranging packages; Object tracking packages.

A, active; P, passive; P/A, passive/active; PC, proprioceptive; EC, exteroceptive.

=== Sensors: outline
- Optical encoders; Heading sensors: Compass, Gyroscopes.
- Accelerometer; IMU; GPS.
- Range sensors: Sonar, Laser, Structured light.
- Vision.

== Encoders and odometry

=== Encoders
#defbox("Definition", [Electro-mechanical device that converts linear or angular position of a shaft to an analog or digital signal, making it a linear/angular transducer.])

=== Wheel / Motor Encoders
*Use cases*
- measure position or speed of the wheels or steering;
- integrate wheel movements to get an estimate of the position `->` odometry;
- optical encoders are proprioceptive sensors;
- typical resolutions: 64 - 2048 increments per revolution;
- for high resolution: interpolation.

*Working principle of optical encoders*
- regular: counts the number of transitions but cannot tell the direction of motion;
- quadrature: uses two sensors in quadrature-phase shift. The ordering of which wave produces a rising edge first tells the direction of motion. Additionally, resolution is 4 times bigger;
- a single slot in the outer track generates a reference pulse per revolution.

== Heading sensors

=== Heading Sensors
#defbox("Definition", [Heading sensors are sensors that determine the robot's orientation and inclination with respect to a given reference.])
- Heading sensors can be proprioceptive (gyroscope, accelerometer) or exteroceptive (compass, inclinometer).
- Allows, together with an appropriate velocity information, to integrate the movement to a position estimate.
- This procedure is called deduced reckoning (ship navigation).

=== Compass
- Used since before 2000 B.C.: when Chinese suspended a piece of natural magnetite from a silk thread and used it to guide a chariot over land.
- Magnetic field on earth: absolute measure for orientation (even birds use it for migrations (2001 discovery)).
- Large variety of solutions to measure magnetic or true north:
  - mechanical magnetic compass;
  - direct measure of the magnetic field (Hall-effect, magneto-resistive sensors);
  - Gyrocompass (non-magnetic, finds true north by using fast-spinning wheel and friction forces in order to exploit the rotation of the Earth) `->` used on ships.
- Major drawback of magnetic solutions:
  - weakness of the earth field (30 $mu$Tesla);
  - easily disturbed by magnetic objects or other sources;
  - bandwidth limitations (0.5 Hz) and susceptible to vibrations;
  - not suitable for indoor environments for absolute orientation;
  - useful indoor (only locally).

=== Gyroscope
#defbox("Definition", [Heading sensors that preserve their orientation in relation to a fixed reference frame; they provide an absolute measure for the heading of a mobile system.])
- Two categories, the mechanical and the optical gyroscopes:
  - Mechanical Gyroscopes: Standard gyro (angle); Rate gyro (speed).
  - Optical Gyroscopes: Rate gyro (speed).

=== Mechanical Gyroscopes
#figure(caption: [Gyroscope meccanico: gimbal annidati e rotore.], [#raw("")
  #scale(85%, reflow: true)[
    #canvas({
      draw.circle((2.1, 1.7), radius: 1.35, stroke: 0.6pt + C)
      draw.circle((2.1, 1.7), radius: 0.95, stroke: 0.6pt + C)
      draw.circle((2.1, 1.7), radius: 0.55, stroke: 0.6pt + C)
      draw.line((1.55, 1.7), (2.65, 1.7), stroke: 0.4pt + C)
      draw.line((2.1, 1.15), (2.1, 2.25), stroke: 0.4pt + C)
      draw.line((1.72, 2.08), (2.48, 1.32), stroke: 0.4pt + C)
      draw.line((1.72, 1.32), (2.48, 2.08), stroke: 0.4pt + C)
      draw.circle((2.1, 3.05), radius: 0.06, fill: C)
      draw.circle((2.1, 0.35), radius: 0.06, fill: C)
      draw.circle((1.15, 1.7), radius: 0.06, fill: C)
      draw.circle((3.05, 1.7), radius: 0.06, fill: C)
      draw.line((0.15, 3.25), (2.1, 3.05), stroke: 0.3pt + C)
      draw.content((0.1, 3.35), text(size: 4.6pt, [Outer pivot]))
      draw.line((3.95, 3.25), (2.95, 2.75), stroke: 0.3pt + C)
      draw.content((4.0, 3.35), text(size: 4.6pt, [Outer gimbal]))
      draw.line((3.95, 0.15), (2.95, 0.65), stroke: 0.3pt + C)
      draw.content((4.0, 0.05), text(size: 4.6pt, [Inner gimbal]))
      draw.line((0.15, 0.15), (1.15, 1.7), stroke: 0.3pt + C)
      draw.content((0.1, 0.05), text(size: 4.6pt, [Inner pivot]))
      draw.line((4.35, 1.7), (2.65, 1.7), stroke: 0.3pt + C)
      draw.content((4.4, 1.7), text(size: 4.6pt, [Wheel]))
      draw.line((0.15, 1.0), (1.62, 1.6), stroke: 0.3pt + C)
      draw.content((0.1, 0.9), text(size: 4.6pt, [Wheel bearing]))
    })
  ]])
- Concept: inertial properties of a fast-spinning rotor; angular momentum associated with a spinning wheel keeps the axis of the gyroscope inertially stable.
- No torque can be transmitted from the outer pivot to the wheel axis; spinning axis will therefore be space-stable.
- However, friction in the axis bearings will introduce torque and so drift `->` precession.
- Quality: 0.1$degree$ in 6 hours (a high-quality mech. gyro costs up to 100,000 \$).

=== Rate gyros
- Same basic arrangement shown as regular mechanical gyros.
- But: gimbals are restrained by torsional springs.
- Enables to measure angular speeds instead of the orientation.

=== Optical Gyroscopes
#figure(caption: [Gyroscope ottico: due fasci laser in senso orario e antiorario nella fibra.], [#raw("")
  #scale(90%, reflow: true)[
    #canvas({
      cbox(0, 1.35, 1.15, 0.55, [Light Source], fs: 4.8pt)
      draw.line((1.15, 1.63), (1.75, 1.63), stroke: 0.5pt + C)
      draw.line((1.75, 1.48), (1.95, 1.78), stroke: 0.8pt + C)
      draw.content((1.75, 2.05), text(size: 4.6pt, [Half-silvered mirror]))
      draw.circle((3.3, 1.63), radius: 1.05, stroke: 0.6pt + C)
      draw.arc((3.3, 1.63), start: 20deg, stop: 160deg, radius: 1.05, stroke: 0.5pt + A, mark: (end: ">", fill: A))
      draw.arc((3.3, 1.63), start: 200deg, stop: 340deg, radius: 0.85, stroke: 0.5pt + rgb("#B00020"), mark: (end: ">", fill: rgb("#B00020")))
      draw.content((3.3, 1.63), text(size: 4.6pt, [fiber coil]))
      draw.line((1.95, 1.78), (2.55, 2.1), stroke: 0.5pt + C)
      cbox(1.7, 2.75, 1.15, 0.55, [Detector], fs: 4.8pt)
      draw.content((5.15, 2.35), text(size: 4.6pt, [Single axis optical gyro]))
      draw.content((5.15, 1.4), text(size: 4.6pt, [3-axis optical gyro]))
    })
  ]])
- Optical gyroscopes are based on the Sagnac effect.
- Angular speed (heading) sensors using two monochromic light (or laser) beams from the same source: one is traveling in a fiber clockwise, the other counterclockwise around a cylinder.
- Laser beam traveling in direction opposite to the rotation: slightly shorter path; phase shift of the two beams is proportional to the angular velocity W of the cylinder.
- In order to measure the phase shift, coil consists of as much as 5 km optical fiber.
- New solid-state optical gyroscopes based on the same principle are built using microfabrication technology.

== Accelerometers and IMU

=== Mechanical Accelerometer
#figure(caption: [Accelerometro come sistema massa-molla-smorzatore.], [#raw("")
  #scale(80%, reflow: true)[
    #canvas({
      draw.rect((0, 0.35), (4.6, 2.95), stroke: 0.6pt + C)
      draw.rect((1.7, 1.25), (2.9, 2.05), stroke: 0.6pt + C, fill: rgb("#eef3f7"))
      draw.content((2.3, 1.65), text(size: 5.2pt, [m]))
      draw.line((0.1, 2.75), (0.6, 2.75), (0.85, 2.95), (1.3, 2.55), (1.75, 2.95), (2.2, 2.55), (2.4, 2.75), (2.4, 2.05), stroke: 0.5pt + C)
      draw.content((0.55, 3.15), text(size: 4.8pt, [spring $k$]))
      draw.line((3.3, 2.6), (3.9, 2.6), stroke: 0.5pt + C)
      draw.rect((3.3, 1.5), (3.9, 2.5), stroke: 0.5pt + C)
      draw.content((4.15, 2.05), text(size: 4.8pt, [damper $c$]))
      draw.line((3.9, 2.05), (4.3, 2.05), stroke: 0.5pt + C)
      draw.line((2.3, 0.75), (3.4, 0.75), stroke: 0.6pt + A, mark: (end: ">", fill: A))
      draw.content((3.6, 0.75), text(size: 4.8pt, [$a$]))
      draw.content((0.55, 2.15), text(size: 4.8pt, [mass]))
    })
  ]])
- Accelerometers measure all external forces acting upon them, including gravity.
- The accelerometer acts like a spring-mass-damper system, where m is the proof mass, c the damping coefficient, k the spring constant.
- $F_"applied" = F_"inertial" + F_"damping" + F_"spring" = m accent(x, dot.double) + c dot(x) + k x$
- At steady-state: $a_"applied" = (k x)/m$.
- On the Earth's surface, the accelerometer always indicates 1g along the vertical axis.
- To obtain the inertial acceleration (due to motion alone), the gravity must be subtracted. Conversely, the device's output will be zero during free fall.
- Bandwidth up to 50 KHz.
- An accelerometer measures acceleration only along a single axis. By mounting three accelerometers orthogonally to one another, a three-axis accelerometer can be obtained.

=== Factsheet: MEMS Accelerometer
#figure(caption: [MEMS accelerometer capacitivo: massa sismica, molle e partitore capacitivo.], [#raw("")
  #scale(88%, reflow: true)[
    #canvas({
      draw.line((0.1, 0.4), (0.1, 2.8), stroke: 0.6pt + C)
      draw.line((5.9, 0.4), (5.9, 2.8), stroke: 0.6pt + C)
      draw.rect((2.35, 1.2), (3.65, 2.1), stroke: 0.6pt + C, fill: rgb("#eef3f7"))
      draw.content((3.0, 1.65), text(size: 5.2pt, [$M$]))
      draw.line((0.15, 1.75), (0.7, 1.75), (0.95, 1.95), (1.4, 1.55), (1.85, 1.95), (2.3, 1.55), (2.35, 1.75), stroke: 0.5pt + C)
      draw.line((3.65, 1.75), (3.75, 1.75), (4.0, 1.95), (4.45, 1.55), (4.9, 1.95), (5.35, 1.55), (5.8, 1.75), stroke: 0.5pt + C)
      draw.content((1.25, 2.35), text(size: 4.6pt, [spring]))
      draw.line((2.5, 2.3), (2.5, 0.9), stroke: 0.5pt + C)
      draw.line((3.5, 2.3), (3.5, 0.9), stroke: 0.5pt + C)
      draw.line((2.5, 0.9), (3.5, 0.9), stroke: 0.5pt + C)
      draw.content((3.0, 0.62), text(size: 4.6pt, [capacitive divider]))
      draw.line((3.65, 1.0), (4.7, 1.0), stroke: 0.6pt + A, mark: (end: ">", fill: A))
      draw.content((4.85, 1.0), text(size: 4.8pt, [$a$]))
    })
  ]])
*Operational Principle*: a spring-like structure connects the device to a seismic mass vibrating in a capacity divider which converts the displacement of the seismic mass into an electric signal. Damping is created by the gas sealed in the device.

*Main Characteristics*: can be multi-directional; various sensing ranges up to 50 g.

*Applications*: dynamic acceleration; static acceleration (inclinometer); airbag sensors ($plus.minus$ 35 g); control of video games (Wii).

=== Factsheet: Piezoelectric Accelerometer
#figure(caption: [Accelerometro piezoelettrico: massa sismica e dischi piezoelettrici.], [#raw("")
  #scale(80%, reflow: true)[
    #canvas({
      draw.rect((0.1, 0.4), (3.9, 3.0), stroke: 0.6pt + C)
      draw.content((0.75, 3.15), text(size: 4.8pt, [box]))
      draw.line((2.0, 2.9), (2.0, 2.55), (2.3, 2.4), (1.7, 2.1), (2.3, 1.8), (1.7, 1.5), (2.0, 1.35), stroke: 0.5pt + C)
      draw.content((1.35, 2.55), text(size: 4.6pt, [spring]))
      draw.rect((1.55, 0.85), (2.45, 1.35), stroke: 0.6pt + C, fill: rgb("#eef3f7"))
      draw.content((2.0, 1.1), text(size: 4.4pt, [mass]))
      draw.rect((1.55, 0.5), (2.45, 0.62), stroke: 0.5pt + C)
      draw.rect((1.55, 0.63), (2.45, 0.75), stroke: 0.5pt + C)
      draw.content((3.35, 0.62), text(size: 4.4pt, [piezoelectric discs]))
      draw.line((2.0, 0.35), (2.0, 0.05), stroke: 0.6pt + A, mark: (end: ">", fill: A))
      draw.content((2.2, 0.1), text(size: 4.8pt, [$u$]))
    })
  ]])
*1. Operational Principle*: primary transducer is typically a single-degree-of-freedom spring-mass system that relates acceleration to displacement. Secondary transducer (piezoelectric discs) converts displacement of the seismic mass into an electrical signal (voltage).

*2. Main Characteristics*: piezoelectric elements cannot produce a signal under constant acceleration (i.e., static) conditions; 2-D and 3-D accelerometers can be created by combining 2 or 3 1-D modules.

*3. Applications*: vibration analysis; machine diagnostics; active vehicle suspension; autonomously guided vehicles; earthquake sensors; modal analysis.

=== Inertial Measurement Unit (IMU)
#defbox("Definition", [A device that uses measurement systems such as gyroscopes and accelerometers to estimate the relative position (x, y, z), orientation (roll, pitch, yaw), velocity, and acceleration of a moving vehicle with respect to an inertial frame.])
#figure(caption: [Catena di stima dell'IMU: giroscopio e accelerometro integrati.], [#raw("")
  #scale(82%, reflow: true)[
    #canvas({
      cbox(0, 2.4, 1.7, 0.6, [Rate gyroscope], fs: 4.8pt)
      cbox(2.4, 2.4, 2.1, 0.6, [Integrate to get \ orientation], fs: 4.8pt)
      ar((1.7, 2.7), (2.38, 2.7))
      cbox(0, 1.2, 1.7, 0.6, [Accelerometer], fs: 4.8pt)
      cbox(2.0, 1.2, 2.1, 0.6, [Subtract gravity \ from vertical], fs: 4.8pt)
      ar((1.7, 1.5), (1.98, 1.5))
      cbox(2.0, 0.2, 2.1, 0.6, [Transform to local \ navigation frame], fs: 4.8pt)
      ar((3.05, 1.2), (3.05, 0.82))
      cbox(2.0, -0.8, 2.1, 0.6, [Integrate to get velocity], fs: 4.8pt)
      ar((3.05, 0.2), (3.05, -0.18))
      cbox(2.0, -1.8, 2.1, 0.6, [Integrate to get position], fs: 4.8pt)
      ar((3.05, -0.8), (3.05, -1.18))
      draw.content((0.85, 0.85), text(size: 4.4pt, [Initial velocity]))
      ar((0.85, 0.85), (3.05, -0.5), col: C)
      draw.content((4.9, -1.5), text(size: 4.4pt, [Initial position]))
      ar((4.9, -1.5), (4.15, -1.5), col: C)
      draw.content((0.85, 0.2), text(size: 4.4pt, [Acceleration]))
      draw.content((4.6, -0.5), text(size: 4.4pt, [Velocity]))
      draw.content((4.6, -1.5), text(size: 4.4pt, [Position]))
    })
  ]])
- In order to estimate motion, the gravity vector must be subtracted. Furthermore, initial velocity has to be known.
- IMUs are extremely sensitive to measurement errors in gyroscopes and accelerometers: drift in the gyroscope unavoidably undermines the estimation of the vehicle orientation relative to gravity, which results in incorrect cancellation of the gravity vector. Because the accelerometer data is integrated twice to obtain the position, any residual gravity vector results in a quadratic error in position.
- After a long period of operation, all IMUs drift. To cancel it, some external reference like GPS or cameras has to be used.

== Localization and beacons

=== Ground-Based Active and Passive Beacons
- "Elegant" way to solve the localization problem in mobile robotics.
- Beacons are signaling guiding devices with a precisely known position.
- Beacon base navigation is used since the humans started to travel:
  - Natural beacons (landmarks) like stars, mountains or the sun;
  - Artificial beacons like lighthouses.
- The recently introduced Global Positioning System (GPS) revolutionized modern navigation technology:
  - already one of the key sensors for outdoor mobile robotics;
  - for indoor robots GPS is not applicable.
- Major drawback with the use of beacons in indoor:
  - beacons require changes in the environment `->` costly;
  - limit flexibility and adaptability to changing environments.

=== Motion-Capture Systems
- Vicon and Optitrack.
- System of several cameras that track the position of reflective markers.
- >300 fps; \<1 mm precision.
- Suitable for ground-truth comparison, control strategies (e.g., quadrotors).
- Indoor or outdoor application.
- Require preinstallation and precalibration of the cameras (done with a special calibration rig moved by the user).

=== Augmented Reality Tags
- Each tag carries a unique identifies.
- Work only in combination with a camera.
- Returns relative pose of the camera (x, y, z, roll, pitch, yaw) wrt tag reference frame.
- Accuracy depends on size and angle of sight of the tag (e.g., with a 10 cm tag and 2 meters distance `->` 2 cm accuracy, 5 deg precision).
- Good for rough localization.

=== Global Positioning System (GPS)
*Facts*
- Became accessible for commercial applications in 1995.
- Initially there were 24 satellites orbiting the earth every 12 hours at a height of 20.190 km.
- 4 satellites were located in each of 6 orbits with 60 degrees orientation between each other.

*Working Principle*
- Location of any GPS receiver is determined through a time of flight measurement (satellites send orbital location (ephemeris) plus time; the receiver computes its location through trilateration and time correction).

*Technical challenges*: time synchronization between the individual satellites and the GPS receiver; real time update of the exact location of the satellites; precise measurement of the time of flight; interferences with other signals.

#figure(caption: [Architettura GPS: satelliti, stazioni di monitoraggio e controllo, master station e utenti.], [#raw("")
  #scale(88%, reflow: true)[
    #canvas({
      cbox(2.1, 3.3, 1.9, 0.55, [GPS satellites], fs: 5pt)
      cbox(0.1, 2.0, 1.7, 0.55, [monitor stations], fs: 5pt)
      cbox(2.3, 2.0, 1.5, 0.55, [master station], fs: 5pt)
      cbox(4.4, 2.0, 1.7, 0.55, [uploading stations], fs: 5pt)
      cbox(4.4, 0.4, 1.7, 0.55, [users], fs: 5pt)
      ar((2.35, 3.3), (1.2, 2.58))
      ar((1.8, 2.27), (2.28, 2.27))
      ar((3.8, 2.27), (4.38, 2.27))
      ar((5.25, 2.55), (4.0, 3.28), col: C)
      ar((3.9, 3.3), (5.1, 0.97))
    })
  ]])
*Time synchronization*: atomic clocks on each satellite; monitoring them from different ground stations.
- Ultra-precision time synchronization is extremely important: electromagnetic radiation propagates at light speed; light travels roughly 0.3 m per nanosecond; position accuracy proportional to precision of time measurement.
- Real time update of the exact location of the satellites: monitoring the satellites from a number of widely distributed ground stations; master station analyses all the measurements and transmits the actual position to each of the satellites.
- Exact measurement of the time of flight: quartz clock on the GPS receivers are not very precise; the range measurement with four satellite allows to identify the three values (x, y, z) for the position and the clock correction $Delta T$.
- Recent commercial GPS receiver devices allows position accuracies down to a couple meters.

=== GPS Error Sources
- *Ephemeris data errors*: 1 meter.
- *Tropospheric delays*: 1 meter. The troposphere is the lower part (ground level to from 8 to 13 km) of the atmosphere that experiences the changes in temperature, pressure, and humidity associated with weather changes. Complex models of tropospheric delay require estimates or measurements of these parameters.
- *Unmodeled ionosphere delays*: 10 meters. The ionosphere is the layer of the atmosphere from 50 to 500 km that consists of ionized air. The transmitted model can only remove about half of the possible 70 ns of delay leaving a ten-meter un-modeled residual.
- *Multipath*: 0.5 - 100 meters. Multipath is caused by reflected signals from surfaces near the receiver that can either interfere with or be mistaken for the signal that follows the straight-line path from the satellite. Multipath is difficult to detect and sometime hard to avoid.
- Number of satellites under line of sight.

=== Differential Global Positioning System (dGPS)
- DGPS requires that a GPS receiver, known as the base station, be set up on a precisely known location. The base station receiver calculates its position based on satellite signals and compares this location to the known location. The difference is applied to the GPS data recorded by the roving GPS receiver.
- Position accuracies in sub-meter to cm range.
#figure(caption: [dGPS: la base station calcola l'errore e lo applica al ricevitore rover.], [#raw("")
  #scale(85%, reflow: true)[
    #canvas({
      cbox(2.4, 3.2, 1.9, 0.55, [GPS satellites], fs: 5pt)
      cbox(0.1, 1.7, 1.9, 0.6, [base station \ #text(size: 4.2pt)[precisely known location]], fs: 4.8pt)
      cbox(4.3, 1.7, 1.9, 0.6, [roving GPS receiver], fs: 4.8pt)
      ar((2.4, 3.2), (1.4, 2.32))
      ar((3.9, 3.2), (5.2, 2.32))
      draw.content((0.95, 1.25), text(size: 4.4pt, [Measured: x y z]))
      draw.content((0.95, 1.05), text(size: 4.4pt, [True: x y z]))
      draw.content((0.95, 0.85), text(size: 4.4pt, [Delta: x y z]))
      draw.content((5.15, 1.25), text(size: 4.4pt, [Measured: x y z]))
      draw.content((5.15, 1.05), text(size: 4.4pt, [Delta: x y z]))
      draw.content((5.15, 0.85), text(size: 4.4pt, [True: x y z after survey]))
      ar((2.05, 0.55), (4.25, 0.55), col: C)
      draw.content((3.15, 0.38), text(size: 4.4pt, [Corrections applied]))
    })
  ]])

== Range sensors

=== Range Sensors (time of flight)
- Large range distance measurement `->` thus called range sensors.
- Range information: key element for localization and environment modeling.
- Ultrasonic sensors as well as laser range sensors make use of propagation speed of sound or electromagnetic waves respectively.
- The traveled distance of a sound or electromagnetic wave is given by $d = c t$: d = distance traveled (usually round-trip); c = speed of wave propagation; t = time of flight.
- It is important to point out:
  - propagation speed v of sound: 0.3 m/ms;
  - propagation speed v of electromagnetic signals: 0.3 m/ns;
  - electromagnetic signals travel one million times faster;
  - 3 meters: equivalent to 10 ms for an ultrasonic system, equivalent to only 10 ns for a laser range sensor.
- Measuring time of flight with electromagnetic signals is not an easy task; laser range sensors expensive and delicate.
- The quality of time of flight range sensors mainly depends on:
  - inaccuracies in the time of fight measurement (laser range sensors);
  - opening angle of transmitted beam (especially ultrasonic range sensors);
  - interaction with the target (surface, specular reflections);
  - variation of propagation speed (sound);
  - speed of mobile robot and target (if not at stand still).

=== Ultrasonic Sensor
#figure(caption: [Sensore ultrasonico: impulso emesso, riflesso dall'oggetto e ricevuto; $d = (v space Delta t)/2$.], [#raw("")
  #scale(80%, reflow: true)[
    #canvas({
      cbox(0.1, 2.05, 1.15, 0.5, [emitter], fs: 4.8pt)
      cbox(0.1, 1.35, 1.15, 0.5, [receiver], fs: 4.8pt)
      draw.rect((4.9, 1.1), (5.2, 2.8), stroke: 0.6pt + C, fill: rgb("#eef3f7"))
      draw.line((1.25, 2.3), (4.9, 2.3), stroke: 0.4pt + A, mark: (end: ">", fill: A))
      draw.line((4.9, 1.85), (1.25, 1.85), stroke: 0.4pt + rgb("#B00020"), mark: (end: ">", fill: rgb("#B00020")))
      draw.line((1.25, 0.5), (4.9, 0.5), stroke: 0.4pt + C, mark: (start: ">", end: ">", fill: C))
      draw.content((3.05, 0.25), text(size: 4.6pt, [$d = (v space Delta t)/2$]))
    })
  ]])
*Operational Principle*: an ultrasonic pulse is generated by a piezoelectric emitter, reflected by an object in its path, and sensed by a piezo-electric receiver. Based on the speed of sound in air and the elapsed time from emission to reception, the distance between the sensor and the object is easily calculated.

*Main Characteristics*: precision influenced by angle to object; useful in ranges from several cm to several meters; typically relatively inexpensive.

*Applications*: distance measurement (also for transparent surfaces); collision detection.
- Typical frequency: 40 kHz - 180 kHz; lower frequencies correspond to longer maximal sensor range.
- Generation of sound wave via piezo transducer; transmitter and receiver can be separate or integrated in the same unit.
- Range between 12 cm up to 5 m; resolution of ~ 2 cm; relative error 2%.
- Sound beam propagates in a cone (approx.); opening angles around 20 to 40 degrees; regions of constant depth; segments of an arc (sphere for 3D).
#figure(caption: [Distribuzione tipica di intensità di un sensore ultrasonico: cono di misura.], [#raw("")
  #scale(78%, reflow: true)[
    #canvas({
      let center = (2.4, 0.45)
      draw.line((2.4, 0.0), center, (2.4, 3.1), stroke: 0.4pt + C)
      draw.line((0.6, 1.5), center, (4.2, 1.5), stroke: 0.4pt + C)
      draw.line((1.0, 2.7), center, (3.8, 2.7), stroke: 0.4pt + C)
      draw.line((1.0, 2.7), center, (0.6, 1.5), stroke: 0.4pt + C)
      draw.line((3.8, 2.7), center, (4.2, 1.5), stroke: 0.4pt + C)
      draw.line((0.6, 1.5), (1.75, 2.85), (2.4, 3.1), (3.05, 2.85), (4.2, 1.5), center, close: true, fill: rgb("#cfe3f0"), stroke: 0.3pt + C)
      draw.content((0.45, 1.5), text(size: 4.6pt, [-60$degree$]))
      draw.content((1.4, 2.85), text(size: 4.6pt, [-30$degree$]))
      draw.content((2.4, 3.25), text(size: 4.6pt, [0$degree$]))
      draw.content((3.45, 2.85), text(size: 4.6pt, [30$degree$]))
      draw.content((4.4, 1.5), text(size: 4.6pt, [60$degree$]))
      draw.content((2.4, 1.9), text(size: 4.4pt, [measurement cone]))
      draw.content((4.6, 0.25), text(size: 4.6pt, [Amplitude [dB]]))
    })
  ]])
- Other problems for ultrasonic sensors: soft surfaces that absorb most of the sound energy; surfaces that are far from being perpendicular to the direction of the sound `->` specular reflections.
#figure(caption: [a) scansione a 360$degree$; b) risultati da diverse primitive geometriche (piano, angolo, cilindro).], [#raw("")
  #scale(80%, reflow: true)[
    #canvas({
      draw.circle((1.2, 1.2), radius: 0.12, fill: C)
      for a in range(0, 12) {
        let t = a * 30deg
        draw.line((1.2, 1.2), (1.2 + 1.0 * calc.sin(t), 1.2 + 1.0 * calc.cos(t)), stroke: 0.35pt + A, mark: (end: ">", fill: A))
      }
      draw.content((1.2, -0.35), text(size: 4.6pt, [a) 360$degree$ scan]))
      draw.line((3.1, 1.9), (4.7, 1.9), stroke: 0.6pt + C)
      draw.content((3.9, 2.15), text(size: 4.4pt, [PLANE]))
      draw.line((3.1, 0.9), (3.1, 1.5), (3.9, 1.5), stroke: 0.6pt + C)
      draw.content((3.0, 0.65), text(size: 4.4pt, [CORNER]))
      draw.arc((5.5, 0.9), start: 0deg, stop: 180deg, radius: 0.45, stroke: 0.6pt + C)
      draw.content((5.5, 0.4), text(size: 4.4pt, [CYLINDER]))
      draw.line((3.7, 0.1), (4.0, 0.55), stroke: 0.35pt + A, mark: (end: ">", fill: A))
      draw.line((3.7, 0.1), (3.35, 1.15), stroke: 0.35pt + A, mark: (end: ">", fill: A))
      draw.line((3.7, 0.1), (4.9, 0.55), stroke: 0.35pt + A, mark: (end: ">", fill: A))
      draw.content((3.7, -0.35), text(size: 4.6pt, [b) results from different geometric primitives]))
      draw.content((5.5, -0.05), text(size: 4.2pt, [0.5 meters]))
    })
  ]])
- *Bandwidth*: measuring the distance to an object that is 3 m away will take such a sensor 20 ms, limiting its operating speed to 50 Hz. But if the robot has a ring of 20 ultrasonic sensors, each firing sequentially and measuring to minimize interference between the sensors, then the ring's cycle time becomes 0.4 seconds `=>` frequency of each one sensor = 2.5 Hz.
- This update rate can have a measurable impact on the maximum speed possible while still sensing and avoiding obstacles safely.

#let tofgeom() = {
  draw.rect((0.1, 1.85), (1.25, 2.45), stroke: 0.5pt + C)
  draw.content((0.68, 2.15), text(size: 4.4pt, [Transmitter]))
  draw.rect((4.95, 0.55), (5.3, 2.7), stroke: 0.6pt + C, fill: rgb("#eef3f7"))
  draw.content((5.5, 1.6), text(size: 4.4pt, [Target]))
  draw.content((5.1, 2.85), text(size: 4.4pt, [P]))
  draw.line((1.25, 2.3), (4.95, 1.55), stroke: 0.5pt + A, mark: (end: ">", fill: A))
  draw.content((2.9, 2.1), text(size: 4.2pt, [Transmitted Beam]))
  draw.line((4.95, 1.35), (1.25, 1.95), stroke: 0.5pt + rgb("#B00020"), mark: (end: ">", fill: rgb("#B00020")))
  draw.content((2.9, 1.4), text(size: 4.2pt, [Reflected Beam]))
  draw.line((1.25, 0.15), (4.95, 0.15), stroke: 0.4pt + C, mark: (start: ">", end: ">", fill: C))
  draw.content((3.1, -0.1), text(size: 4.4pt, [$D$]))
  draw.content((1.75, 2.85), text(size: 4.4pt, [Phase Measurement]))
}

#let trigeom() = {
  draw.content((0.05, 2.75), text(size: 4.4pt, [Laser / Collimated beam]))
  draw.line((0.2, 2.55), (3.35, 1.0), stroke: 0.5pt + A, mark: (end: ">", fill: A))
  draw.circle((3.55, 0.9), radius: 0.05, fill: C)
  draw.content((3.7, 1.0), text(size: 4.4pt, [P]))
  draw.rect((3.45, 0.35), (3.75, 1.45), stroke: 0.5pt + C, fill: rgb("#eef3f7"))
  draw.content((4.45, 0.9), text(size: 4.4pt, [Target]))
  draw.line((3.7, 0.9), (1.75, 0.3), stroke: 0.5pt + rgb("#B00020"), mark: (end: ">", fill: rgb("#B00020")))
  draw.content((2.75, 0.35), text(size: 4.2pt, [Reflected Beam]))
  draw.line((1.45, 0.55), (2.05, 0.55), stroke: 0.6pt + C)
  draw.content((1.75, 0.75), text(size: 4.4pt, [Lens]))
  draw.line((1.75, 0.55), (1.75, 0.12), stroke: 0.4pt + C)
  draw.rect((0.2, -0.15), (1.4, 0.1), stroke: 0.5pt + C)
  draw.content((0.8, -0.45), text(size: 4.2pt, [Position-Sensitive Device (PSD) or Linear Camera]))
  draw.content((2.75, -0.05), text(size: 4.6pt, [$D = f L/x$]))
}

=== Laser Range Sensor
#figure(caption: [Sensore laser a tempo di volo: fascio trasmesso e riflesso, misura di fase.], [#raw("")
  #scale(85%, reflow: true)[#canvas({ tofgeom() })]])
*Operating Principles*
- Pulsed laser (today the standard): measurement of elapsed time directly, resolving picoseconds.
- Phase shift measurement to produce range estimation: technically easier than the above method.
- Transmitted and received beams coaxial; transmitter illuminates a target with a collimated laser beam; receiver detects the time needed for round-trip; a mechanical mechanism with a mirror sweeps; 2D or 3D measurement.
#figure(caption: [Principi operativi: a) laser pulsato; b) misura di sfasamento.], [#raw("")
  #scale(80%, reflow: true)[
    #canvas({
      draw.content((0.0, 2.55), text(size: 4.4pt, [a)]))
      draw.line((0.4, 2.2), (5.2, 2.2), stroke: 0.4pt + C)
      for i in range(0, 5) {
        let x = 0.6 + i * 0.9
        draw.line((x, 2.2), (x, 2.7), stroke: 0.6pt + A)
        draw.line((x + 0.3, 2.2), (x + 0.3, 2.7), stroke: 0.6pt + rgb("#B00020"))
      }
      draw.content((0.0, 1.45), text(size: 4.4pt, [b)]))
      draw.line((0.4, 1.1), (5.2, 1.1), stroke: 0.5pt + A)
      draw.line((0.4, 0.45), (5.2, 0.45), stroke: 0.5pt + rgb("#B00020"))
      draw.content((5.3, 2.35), text(size: 4.2pt, [LED/Laser]))
      draw.content((5.3, 1.0), text(size: 4.2pt, [Reflected light]))
      draw.content((5.3, 0.35), text(size: 4.2pt, [Detector]))
    })
  ]])

*Phase-Shift Measurement*
#figure(caption: [Misura di sfasamento tra fascio trasmesso e riflesso; lunghezza d'onda $lambda$ e sfasamento $phi$.], [#raw("")
  #scale(80%, reflow: true)[
    #canvas({
      draw.line((0.2, 1.6), (5.4, 1.6), stroke: 0.5pt + A)
      draw.line((0.2, 0.6), (5.4, 0.6), stroke: 0.5pt + rgb("#B00020"))
      draw.line((0.6, 1.6), (0.6, 0.6), stroke: 0.35pt + C)
      draw.line((3.0, 1.6), (3.0, 0.6), stroke: 0.35pt + C)
      draw.line((0.6, 2.05), (3.0, 2.05), stroke: 0.35pt + C, mark: (start: ">", end: ">", fill: C))
      draw.content((1.8, 2.2), text(size: 4.4pt, [lambda]))
      draw.line((3.0, 0.15), (4.4, 0.15), stroke: 0.35pt + C, mark: (start: ">", end: ">", fill: C))
      draw.content((3.7, -0.05), text(size: 4.4pt, [Phase $phi$]))
      draw.content((0.05, 1.7), text(size: 4.2pt, [Transmitted Beam]))
      draw.content((0.1, 0.35), text(size: 4.2pt, [Reflected Beam]))
      draw.content((5.5, 1.4), text(size: 4.4pt, [Amplitude [V]]))
    })
  ]])
- $D' = 2D = (lambda phi)/(2 pi)$.
- $lambda = c/f$: c is the speed of light; f the modulating frequency; D' the distance covered by the emitted light.
- For f = 5 MHz (as in the AT&T sensor), $lambda$ = 60 meters.
- Distance D, between the beam splitter and the target: $D = (lambda phi)/(4 pi)$, where $phi$ is the phase difference between transmitted and reflected beam.
- Max measurable distance = $lambda/2$ $=>$ ambiguous range estimates. E.g., if f = 5 MHz (i.e., $lambda$ = 60 meters) $=>$ max distance = 30 m $=>$ a target at a range of 35 meters = target at 5 meters.
- Uncertainty of the range (phase/time estimate) is inversely proportional to the square of the received signal amplitude: dark, distant objects will not produce such good range estimation as closer brighter objects.
#figure(caption: [Range image di un sensore laser 2D a specchio rotante: la lunghezza delle linee indica l'incertezza.], [#raw("")
  #scale(78%, reflow: true)[
    #canvas({
      for i in range(0, 25) {
        let t = -60deg + i * 5deg
        let p = (2.7 + 1.5 * calc.sin(t), 0.5 + 1.5 * calc.cos(t))
        draw.line((2.7, 0.5), p, stroke: 0.2pt + A)
        draw.circle(p, radius: 0.04, fill: rgb("#B00020"))
      }
      draw.circle((2.7, 0.5), radius: 0.07, fill: C)
    })
  ]])

=== 3D Laser Range Finder
- A 3D laser range finder is a laser scanner that acquires scan data in more than a single plane.
- Custom-made 3D scanners are typically built by nodding or rotating a 2D scanner in a stepwise or continuous manner around an axis parallel to the scanning plane.
- By lowering the rotational speed of the turn-table, the angular resolution in the horizontal direction can be made as small as desired.
- A full spherical field of view can be covered (360$degree$ in azimuth and $plus.minus$90$degree$ in elevation).
- The Alasca XT laser scanner splits the laser beam into four vertical layers with an aperture angle of 3.2$degree$; typically used for obstacle and pedestrian detection on cars; because of its multi-layer scanning principle, it allows any pitching of the vehicle.
- The Velodyne HDL-64E uses 64 laser emitters; turn-rate up to 15 Hz; field of view 360$degree$ in azimuth and 26.8$degree$ in elevation; angular resolution 0.09$degree$ and 0.4$degree$ respectively; delivers over 1.3 million data points per second; distance accuracy better than 2 cm and can measure depth up to 50 m; primary means of terrain map construction and obstacle detection for all the top DARPA 2007 Urban Challenge teams; currently still much more expensive than Sick laser range finders.
#figure(caption: [Velodyne HDL-64E: gruppi di emettitori e ricevitori, unità rotante.], [#raw("")
  #scale(80%, reflow: true)[
    #canvas({
      draw.rect((1.4, 0.5), (3.6, 2.3), stroke: 0.6pt + C, fill: rgb("#eef3f7"))
      draw.circle((2.5, 2.3), radius: 1.1, stroke: 0.6pt + C)
      draw.line((1.4, 1.2), (3.6, 1.2), stroke: 0.4pt + C)
      draw.line((1.4, 1.7), (3.6, 1.7), stroke: 0.4pt + C)
      draw.rect((2.1, 0.1), (2.9, 0.5), stroke: 0.6pt + C, fill: rgb("#dfe9f0"))
      draw.content((2.5, 0.3), text(size: 4.2pt, [Mounting]))
      draw.content((2.5, 1.45), text(size: 4.2pt, [Housing]))
      ar((0.15, 2.9), (1.75, 2.6), l: [Emitters (4 Groups of 16)], col: A)
      ar((0.15, 1.9), (1.35, 1.45), l: [Receivers (2 Groups of 32)], col: A)
      ar((0.15, 1.05), (1.35, 1.0), l: [Laser], col: A)
      draw.content((3.9, 2.75), text(size: 4.2pt, [unit spins at 5-15 Hz]))
    })
  ]])

=== 3D Range Sensor: Time Of Flight (TOF) camera
- Works similarly to a lidar with the advantage that the whole 3D scene is captured at the same time and that there are no moving parts. This device uses an infrared lighting source to determine the distance for each pixel of a Photonic Mixer Device (PMD) sensor.
- Swiss Ranger 3000 (produced by MESA).

=== Triangulation Sensor
- Use of geometrical properties of the image to establish a distance measurement.
- If a well-defined light pattern (e.g., point, line) is projected onto the environment: reflected light is then captured by a photo-sensitive line or matrix (camera) sensor device; simple triangulation allows to establish a distance.
- If size of a captured object is precisely known: triangulation without light projecting.

=== Laser Triangulation (1D)
#figure(caption: [Triangolazione laser 1D; $D = f L/x$.], [#raw("")
  #scale(85%, reflow: true)[#canvas({ trigeom() })]])
- Principle of 1D laser triangulation: $D = f L/x$.

=== Structured Light (vision, 2D or 3D)
#figure(caption: [Pattern di luce strutturata per eliminare il correspondence problem.], [#raw("")
  #scale(88%, reflow: true)[
    #canvas({
      draw.rect((0.0, 1.7), (1.1, 2.8), stroke: 0.6pt + C)
      draw.line((0.0, 2.6), (1.1, 2.6), stroke: 0.5pt + A)
      draw.content((0.55, 1.45), text(size: 4.4pt, [(a) single light stripe]))
      draw.rect((1.6, 1.7), (2.7, 2.8), stroke: 0.6pt + C)
      for i in range(0, 4) { for j in range(0, 4) {
        draw.circle((1.75 + i * 0.27, 1.85 + j * 0.27), radius: 0.04, fill: A)
      } }
      draw.content((2.15, 1.45), text(size: 4.4pt, [(b) multiple light points]))
      draw.rect((3.2, 1.7), (4.3, 2.8), stroke: 0.6pt + C)
      for i in range(0, 5) {
        draw.line((3.2, 1.8 + i * 0.22), (4.3, 1.8 + i * 0.22), stroke: 0.5pt + A)
      }
      draw.content((3.75, 1.45), text(size: 4.4pt, [(c) multiple parallel light stripes]))
      draw.rect((4.8, 1.7), (5.9, 2.8), stroke: 0.6pt + C)
      for i in range(0, 5) {
        draw.line((4.8 + i * 0.22, 1.7), (4.8 + i * 0.22, 2.8), stroke: 0.4pt + A)
        draw.line((4.8, 1.7 + i * 0.22), (5.9, 1.7 + i * 0.22), stroke: 0.4pt + A)
      }
      draw.content((5.35, 1.45), text(size: 4.4pt, [(d) geometrically arranged light grid]))
    })
  ]])
- Eliminate the correspondence problem by projecting structured light on the scene.
- Slits of light or emit collimated light (possibly laser) by means of a rotating mirror; light perceived by camera; range to an illuminated point can then be determined from simple geometry.
- *Baseline length L*: the smaller L, the more compact the sensor; the larger L, the better the range resolution. Note: for large L, the chance that an illuminated point is not visible to the receiver increases.
- *Focal length f*: larger focal length f can provide either a larger field of view or an improved range resolution; however, large focal length means a larger sensor head.
- Range: $D = f L/x$.
