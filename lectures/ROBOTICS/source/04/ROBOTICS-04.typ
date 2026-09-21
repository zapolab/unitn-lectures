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
        [Geometric Background],
        [ROBOTICS-04])
      #v(1.5pt)
      #line(length: 100%, stroke: 0.4pt + rule)
    ]
  },
)

#set text(font: "New Computer Modern", size: 8.4pt, lang: "it",
         fill: ink, hyphenate: true)
#set par(justify: true, leading: 0.55em, spacing: 0.5em, first-line-indent: 0em)
#show raw: set text(font: "DejaVu Sans Mono", size: 7pt)
#set list(indent: 0.85em, marker: [•], spacing: 0.6em, tight: true)
#set enum(indent: 0.85em, spacing: 0.6em, tight: true)

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

// ===== PRIMITIVE PER DIAGRAMMI =====
#let diag(h, body) = block(width: 100%, height: h, body)
#let seg(a, b, col: ink, w: 0.6pt, mk: none) = {
  place(dx: 0pt, dy: 0pt, line(start: a, end: b, stroke: w + col))
  if mk != none {
    let ax = a.at(0) / 1pt
    let ay = a.at(1) / 1pt
    let bx = b.at(0) / 1pt
    let by = b.at(1) / 1pt
    let dx = bx - ax
    let dy = by - ay
    let L = calc.sqrt(dx * dx + dy * dy)
    let ux = dx / L
    let uy = dy / L
    let hl = 3.4
    let hw = 1.7
    let px = bx - ux * hl
    let py = by - uy * hl
    let lx = (px - uy * hw) * 1pt
    let ly = (py + ux * hw) * 1pt
    let rx = (px + uy * hw) * 1pt
    let ry = (py - ux * hw) * 1pt
    place(dx: 0pt, dy: 0pt, polygon(
      (bx * 1pt, by * 1pt), (lx, ly), (rx, ry),
      fill: col, stroke: none))
  }
}
#let dotp(x, y, col: primary, r: 1.5pt) = place(dx: x, dy: y, circle(radius: r, fill: col))
#let lab(x, y, t, size: 6.6pt, col: ink) = place(dx: x, dy: y, text(size: size, fill: col, t))
#let arrowmk = (end: "stealth")

#place(top, scope: "parent", float: true)[
  #text(14.5pt, weight: "bold", fill: primary)[Geometric Background]
  #v(2pt)
  #text(7.3pt, fill: muted)[ROBOTICS — Lesson 04]
  #v(4pt) #line(length: 100%, stroke: 1pt + primary)
]

= Pose of a Rigid Body in 3D Euclidean Space
<sec-pose>

== Flashback: 2D recap
<sec-flashback>

- Recall the 2D case. Two frames with the same origin: frame $O' - x' y'$ is rotated by $alpha$. Point $P$ has polar coordinates $(rho, theta)$ with respect to the $O - x y$ frame.
- Applying simple rules on the trigonometric functions:
  $ p_(x') = p_x cos (alpha) + p_y sin (alpha) \
    p_(y') = -p_x sin (alpha) + p_y cos (alpha) $
  which means $p' = R(alpha) p$, with
  $ R(alpha) = mat(cos (alpha), sin (alpha); -sin (alpha), cos (alpha)) $
- $R(alpha)$ is called a rotation matrix.

#figure(
  diag(37mm, {
    seg((26mm, 30mm), (77mm, 30mm), mk: arrowmk)
    seg((26mm, 30mm), (26mm, 3mm), mk: arrowmk)
    seg((26mm, 30mm), (55mm, 12.5mm), col: primary, w: 0.7pt, mk: arrowmk)
    seg((26mm, 30mm), (12mm, 6mm), col: primary, w: 0.7pt, mk: arrowmk)
    seg((26mm, 30mm), (61mm, 16mm), col: accent, w: 0.9pt, mk: arrowmk)
    dotp(61mm, 16mm, col: accent, r: 1.7pt)
    lab(77mm, 29mm, [x])
    lab(22mm, 2mm, [y])
    lab(55.5mm, 9mm, [x'], col: primary)
    lab(6mm, 3mm, [y'], col: primary)
    lab(26mm, 31.5mm, [O])
    lab(62.5mm, 15mm, [P], col: accent)
    lab(31mm, 26mm, [theta], size: 6pt, col: muted)
  }),
  caption: [Frame $O'-x'y'$ rotated by $alpha$; point $P$ with polar coordinates $(rho, theta)$ in $O - x y$.],
)

== Pose of a Rigid Body
<sec-rigid>

- Robots are modelled as a collection of rigid bodies.
- Preliminary point: define what we mean by *pose*.
- Generic rigid body: assume a frame attached to the body. By the definition of a rigid body, the coordinates of its points are invariant in the frame attached to the robot.

=== Frame identification

The frame is uniquely identified by:
- the position of its origin $O'$ (which is a bound vector) $arrow(o)' = vec(o_(x'), o_(y'), o_(z'))$;
- the coordinates of the three unit vectors $x', y', z'$ of the frame attached to the robot, expressed in the world frame:
  $ x' = x'_(x) x + x'_(y) y + x'_(z) z \
    y' = y'_(x) x + y'_(y) y + y'_(z) z \
    z' = z'_(x) x + z'_(y) y + z'_(z) z $

#figure(
  diag(34mm, {
    seg((10mm, 26mm), (26mm, 26mm), mk: arrowmk)
    seg((10mm, 26mm), (10mm, 15mm), mk: arrowmk)
    seg((58mm, 20mm), (72mm, 17mm), col: primary, w: 0.7pt, mk: arrowmk)
    seg((58mm, 20mm), (56mm, 9mm), col: primary, w: 0.7pt, mk: arrowmk)
    place(dx: 50mm, dy: 9mm, circle(radius: 8mm, stroke: 0.6pt + ink))
    seg((10mm, 26mm), (58mm, 20mm), col: accent, w: 0.9pt, mk: arrowmk)
    dotp(10mm, 26mm)
    dotp(58mm, 20mm, col: primary)
    lab(27mm, 25mm, [x])
    lab(5mm, 14mm, [y])
    lab(35mm, 21mm, [OO'], col: accent)
    lab(73mm, 15mm, [x'], size: 6pt, col: primary)
    lab(53mm, 6mm, [y'], size: 6pt, col: primary)
    lab(6mm, 27mm, [O])
    lab(59mm, 21.5mm, [O'])
  }),
  caption: [Two frames and the vector joining the origins $OO'$.],
)

=== Coordinates through the scalar product

Let $P$ be the vector joining $O$ with a generic point of the body, $P'$ the vector joining $O'$ with the same point, and $OO'$ the vector joining the two origins. Then:
$ P = P' + OO' $
Given $P$ and the unit vectors $x, y, z$, the coordinates of $P$ are:
$ p_x = P dot x, quad p_y = P dot y, quad p_z = P dot z $
where $dot$ stands for the scalar product.

Since $P = P' + OO'$ and $P' = p_(x') x' + p_(y') y' + p_(z') z'$:
$ p_x = P dot x = P' dot x + OO'_x = p_(x') (x' dot x) + p_(y') (y' dot x) + p_(z') (z' dot x) + OO'_x \
  p_y = P dot y = P' dot y + OO'_y = p_(x') (x' dot y) + p_(y') (y' dot y) + p_(z') (z' dot y) + OO'_y \
  p_z = P dot z = P' dot z + OO'_z = p_(x') (x' dot z) + p_(y') (y' dot z) + p_(z') (z' dot z) + OO'_z $

In simple terms:
$ vec(p_x, p_y, p_z) = R vec(p_(x'), p_(y'), p_(z')) + vec(OO'_x, OO'_y, OO'_z) $
with
$ R = mat(x'_x, y'_x, z'_x; x'_y, y'_y, z'_y; x'_z, y'_z, z'_z) $
or equivalently
$ R = mat(x'^T x, y'^T x, z'^T x; x'^T y, y'^T y, z'^T y; x'^T z, y'^T z, z'^T z) $

#place.flush()

= Rotation Matrices
<sec-rotations>

== Rotation Matrix
<sec-rotmat>

- A matrix defined using the coordinates of the three unit vectors is called a *rotation matrix*.

#defbox("Rotation Matrix", [
  $ R = mat(x'_x, y'_x, z'_x; x'_y, y'_y, z'_y; x'_z, y'_z, z'_z) $
  The different elements of $R$ can be found by using the scalar product:
  $ R = mat(x' dot x, y' dot x, z' dot x; x' dot y, y' dot y, z' dot y; x' dot z, y' dot z, z' dot z) $
])

=== Orthogonality
Let us compute $R R^T$:
$ R R^T = mat(x' dot x', y' dot x', z' dot x'; x' dot y', y' dot y', z' dot y'; x' dot z', y' dot z', z' dot z') $
Since the frame $O' - x' y' z'$ is made of orthonormal vectors, $x' dot x' = y' dot y' = z' dot z' = 1$, while $x' dot y' = x' dot z' = y' dot z' = 0$, which leads to:
$ R^T R = I_3 arrow.r R^T = R^(-1) $

#defbox("Key Property of the Rotation Matrix", [
  The Rotation matrix is an orthogonal matrix with $det(R) = 1$ for right-handed frames and $det(R) = -1$ for left-handed frames.
])

== SO(3)
<sec-so3>

Rotation matrices have the following properties:
+ Composing (i.e., multiplying) two rotation matrices produces another rotation matrix.
+ Rotations respect the associative property: $R_1 (R_2 R_3) = (R_1 R_2) R_3$.
+ Every rotation has a unique inverse.
+ The degenerate rotation $I_3$ is a rotation.

- Rotations do not commute.
- These properties qualify rotations as an algebraic non-abelian (i.e., non-commutative) group under composition, named $S O (3)$.

== Elementary Rotations
<sec-elementary>

Rotation by an angle $alpha$ about the $z$-axis:
$ x' = vec(cos (alpha), sin (alpha), 0), quad y' = vec(-sin (alpha), cos (alpha), 0), quad z' = vec(0, 0, 1) $
with resulting matrix
$ R_z (alpha) = mat(cos (alpha), -sin (alpha), 0; sin (alpha), cos (alpha), 0; 0, 0, 1) $

Likewise, for an angle $beta$ about the $y$-axis and an angle $gamma$ about the $x$-axis:
$ R_y (beta) = mat(cos (beta), 0, sin (beta); 0, 1, 0; -sin (beta), 0, cos (beta)) quad
  R_x (gamma) = mat(1, 0, 0; 0, cos (gamma), -sin (gamma); 0, sin (gamma), cos (gamma)) $
We can easily verify that:
$ R_k (-theta) = R_k^T (theta), quad k = x, y, z $

== Geometric Interpretation
<sec-geom>

#defbox("Geometric Interpretation of a Rotation Matrix", [
  A rotation matrix $R$ represents a rotation about an axis in space required to align the axes of the reference frame with the corresponding axes of the body frame.
])

== Representation of a Vector
<sec-vec-repr>

- Recap of the representation of a vector in the case where the two origins $O$ and $O'$ coincide.
- A generic point is represented by $p = vec(p_x, p_y, p_z)$ in the $O - x y z$ frame and by $p' = vec(p_(x'), p_(y'), p_(z'))$ in the $O - x' y' z'$ frame.
- Since both $p$ and $p'$ refer to the same point:
  $ p = p_(x') x' + p_(y') y' + p_(z') z' = mat(x' & y' & z') p' = R p' $
  and exploiting the properties of $R$:
  $ p' = R^T p $

#figure(
  diag(33mm, {
    seg((20mm, 28mm), (70mm, 28mm), mk: arrowmk)
    seg((20mm, 28mm), (58mm, 12mm), mk: arrowmk)
    seg((20mm, 28mm), (20mm, 4mm), mk: arrowmk)
    seg((20mm, 28mm), (62mm, 18mm), col: primary, w: 0.7pt, mk: arrowmk)
    seg((20mm, 28mm), (58mm, 4mm), col: primary, w: 0.7pt, mk: arrowmk)
    seg((20mm, 28mm), (56mm, 15mm), col: accent, w: 0.9pt, mk: arrowmk)
    dotp(56mm, 15mm, col: accent, r: 1.7pt)
    lab(70mm, 27mm, [x])
    lab(15mm, 3mm, [z])
    lab(58mm, 9mm, [y], size: 6pt)
    lab(62.5mm, 17mm, [x'], size: 6pt, col: primary)
    lab(58mm, 1.5mm, [y'], size: 6pt, col: primary)
    lab(20mm, 29.5mm, [O])
    lab(57.5mm, 14mm, [P], col: accent)
  }),
  caption: [Coincident origins: same point expressed in the two frames.],
)

== Rotation of a Vector
<sec-vec-rot>

- Another way of seeing a rotation matrix: a matrix operator that enables the rotation of a vector about an arbitrary axis in space.
- Consider a rotation matrix $R$, a vector $p'$ expressed in the $O - x y z$ frame and the vector $p = R p'$. Then:
  $ norm(p)^2 = p^T p = (p')^T R^T R p' = (p')^T p' $
- The rotation operator preserves the norm.

== Worked Examples

=== Coordinate transformation ($p' = R_z(alpha)^T p$)
<sec-ex-transform>

Generalisation to 3D of the 2D example. The frame $O' - x' y' z'$ is rotated by $alpha$ about the $z$-axis; point $P$ has polar coordinates $(rho, theta)$ with respect to $O - x y z$. It is easy to see that:
$ p_x = rho cos (theta), quad p_y = rho sin (theta) \
  p_(x') = rho cos (theta - alpha), quad p_(y') = rho sin (theta - alpha) $
Applying simple trigonometric functions:
$ p_(x') = p_x cos (alpha) + p_y sin (alpha) \
  p_(y') = -p_x sin (alpha) + p_y cos (alpha) \
  p_(z') = p_z $
which means $p' = R_z (alpha)^T p$.

#figure(
  diag(34mm, {
    seg((14mm, 30mm), (74mm, 30mm), mk: arrowmk)
    seg((14mm, 30mm), (14mm, 2mm), mk: arrowmk)
    seg((14mm, 30mm), (66mm, 10mm), col: primary, w: 0.7pt, mk: arrowmk)
    seg((14mm, 30mm), (4mm, 6mm), col: primary, w: 0.7pt, mk: arrowmk)
    seg((14mm, 30mm), (60mm, 20mm), col: accent, w: 0.9pt, mk: arrowmk)
    dotp(60mm, 20mm, col: accent, r: 1.7pt)
    lab(74mm, 29mm, [x])
    lab(9mm, 1mm, [y])
    lab(66.5mm, 8mm, [x'], size: 6pt, col: primary)
    lab(0mm, 3mm, [y'], size: 6pt, col: primary)
    lab(14mm, 31.5mm, [O])
    lab(61.5mm, 19mm, [P], col: accent)
    lab(22mm, 26mm, [theta], size: 6pt, col: muted)
    lab(18mm, 21mm, [alpha], size: 6pt, col: muted)
  }),
  caption: [Point $P$ with polar coordinates $(rho, theta)$ in a frame rotated by $alpha$ about $z$.],
)

=== Rotation of a vector ($p = R_z(alpha) p'$)
<sec-ex-rotate>

Consider the vector obtained by rotating a vector $p'$ by an angle $alpha$ about the $z$-axis; $p'$ has polar coordinates $(rho, theta)$. Vector $p$ will have polar coordinates $(rho, alpha + theta)$. We have:
$ p_(x') = rho cos (theta), quad p_(y') = rho sin (theta) \
  p_x = rho cos (theta + alpha), quad p_y = rho sin (theta + alpha) \
  p_z = p_(z') $
#keep[
  With a little effort, we find:
  $ p_x = p_(x') cos (alpha) - p_(y') sin (alpha) \
    p_y = p_(x') sin (alpha) + p_(y') cos (alpha) \
    p_z = p_(z') $
  which means $p = R_z (alpha) p'$.
]

#figure(
  diag(34mm, {
    seg((12mm, 30mm), (74mm, 30mm), mk: arrowmk)
    seg((12mm, 30mm), (12mm, 2mm), mk: arrowmk)
    seg((12mm, 30mm), (46mm, 22mm), col: primary, w: 0.7pt, mk: arrowmk)
    dotp(46mm, 22mm, col: primary, r: 1.7pt)
    seg((12mm, 30mm), (62mm, 12mm), col: accent, w: 0.9pt, mk: arrowmk)
    dotp(62mm, 12mm, col: accent, r: 1.7pt)
    lab(74mm, 29mm, [x])
    lab(7mm, 1mm, [y])
    lab(12mm, 31.5mm, [O])
    lab(47mm, 21mm, [p'], col: primary)
    lab(63mm, 11mm, [p], col: accent)
    lab(24mm, 25mm, [alpha], size: 6pt, col: muted)
  }),
  caption: [Vector $p'$ rotated by $alpha$ about $z$ gives $p$.],
)

== Summary
<sec-summary>

#defbox("Geometric Meanings of a Rotation Matrix", [
  + It describes the *mutual orientation* between two coordinate frames. Its column vectors are the direction cosines of the axes of the rotated frame with respect to the original one.
  + It represents the *coordinate transformation* between two rotated frames.
  + It is the *operator* that enables rotations within the same coordinate frame.
])
