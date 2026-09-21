// ===== PALETTE (costante, unico punto di modifica) =====
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
        [ROBOTICS-03])
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

#set figure(gap: 4pt, supplement: [Fig.], numbering: "1")
#show figure.caption: set text(size: 6.9pt, fill: muted)

#place(top, scope: "parent", float: true)[
  #text(14.5pt, weight: "bold", fill: primary)[Geometric Background]
  #v(2pt)
  #text(7.3pt, fill: muted)[ROBOTICS — Lecture 03]
  #v(4pt) #line(length: 100%, stroke: 1pt + primary)
]

= Matlab Implementation of Rotations

== Fundamental Rotation Matrices

The rotation matrix about the $z$-axis is:
$ R_z(alpha) = mat(cos alpha, -sin alpha, 0; sin alpha, cos alpha, 0; 0, 0, 1) $

Matlab implementation `zRot`:
```matlab
% Function that returns the Rotation about z axis
function [Rz] = zRot(alpha)
    Rz = [
        cos(alpha), -sin(alpha), 0;
        sin(alpha),  cos(alpha), 0;
        0,           0,          1
    ];
end
```

Rotation about the $y$-axis (`yRot(beta)`):
$ R_y(beta) = mat(cos beta, 0, sin beta; 0, 1, 0; -sin beta, 0, cos beta) $

Rotation about the $x$-axis (`xRot(gamma)`):
$ R_x(gamma) = mat(1, 0, 0; 0, cos gamma, -sin gamma; 0, sin gamma, cos gamma) $

The same can be done for the other fundamental rotation matrices.

== Drawing a Reference Frame

`scriptDraw` builds a 3D plot (`close all`, `view(3)`, `daspect([1 1 1])`,
`hold on`) and draws the three axes with `plot3` in red, green, blue. Then it
rotates the three unit vectors by 45 degrees about $z$:
`v1 = zRot(pi/4)*[1;0;0]`, `v2 = zRot(pi/4)*[0;1;0]`,
`v3 = zRot(pi/4)*[0;0;1]`, and plots the rotated vectors dashed.

= Still on Rotation Matrices

== Composition of Rotation Matrices

Example with three frames sharing the same origin: $O - x_0 y_0 z_0$,
$O - x_1 y_1 z_1$, $O - x_2 y_2 z_2$. A point $P$ has coordinates $p_0$, $p_1$,
$p_2$ in the three frames. Let $R_(i j)$ denote the rotation matrix of Frame $i$
with respect to Frame $j$. Then:
$ p_1 = R_(2 1) p_2 quad p_0 = R_(1 0) p_1 quad p_0 = R_(2 0) p_2 $
By substitution and comparison:
$ R_(2 0) = R_(1 0) R_(2 1) $

The relation can be interpreted in two steps:
+ First, rotate $O - x_0 y_0 z_0$ so as to align it with frame
  $O - x_1 y_1 z_1$ (matrix $R_(1 0)$).
+ Then rotate again so as to align frame $O - x_1 y_1 z_1$ with
  $O - x_2 y_2 z_2$ (matrix $R_(2 1)$).

#defbox("Composition of Rotations", [
  A rotation can be expressed as a sequence of partial rotations, each one
  defined with respect to the previous one. The frame from which the rotation
  occurs is termed the *current frame*. The sequence is obtained by
  post-multiplying the matrices associated with each rotation.
])
In view of the properties of rotation matrices:
$ R_(i j) = (R_(j i))^(-1) = (R_(j i))^T $

=== Example: rotations about current axes

Sequence about axes in the current frame:
+ First rotate by $phi$ about the current $y$-axis.
+ Then rotate by $theta$ about the current $z$-axis.

Result: $ R_(2 0) = R_y(phi) R_z(theta) $.

Another example:
$ R_(4 0) = R_z(alpha) R_y(beta) R_y(gamma) R_z(delta) $
The order is absolutely important:
$ R_z(alpha) R_y(beta) R_y(gamma) R_z(delta) != R_y(gamma) R_z(delta) R_z(alpha) R_y(beta) $

=== Rotation about Fixed Axes

To compose rotations about fixed axes, consider two rotated frames
$O - x_0 y_0 z_0$ and $O - x_1 y_1 z_1$. For a generic point $P$:
$p_0 = R_(1 0) p_1$. Consider a generic linear application $A$ defined in the
$O - x_0 y_0 z_0$ frame. For a generic point $P$ and its transformed point:
$ q_0 = A p_0 quad q_1 = R_(0 1) A p_0 = R_(0 1) A R_(1 0) p_1 = (R_(1 0))^(-1) A R_(1 0) p_1 $

Example: the first rotation is $R_(1 0) = R_y(phi)$ about the $y_0$-axis. The
rotation $R^1_2$ happens about the $z_0$-axis (not the $z_1$-axis, as in the
current-frame case):
$ R_(2 0) = R_(1 0) R^1_2 $
Since the latter is known in the current axes:
$ R^1_2 = (R_(1 0))^(-1) R_z(theta) R_(1 0) $
which leads to:
$ R_(2 0) = R_(1 0) (R_(1 0))^(-1) R_z(theta) R_(1 0) = R_z(theta) R_y(phi) $

#keypt("Rule", [
  When the composition of rotations happens with fixed axes, we have to
  *pre-multiply* instead of post-multiplying (as is the case for rotations in
  the current frame). Example:
  $ R_(4 0) = R_z(delta) R_y(gamma) R_y(beta) R_z(alpha) $
])

=== Rotation about Current Axes — Example

Consider the rotation composed as follows:
+ A rotation of $theta$ about the current $x$-axis.
+ A rotation of $phi$ around the current $z$-axis.

Result: $ R_(2 0) = R_x(theta) R_z(phi) $. A point expressed as $p_2$ in
$O - x_2 y_2 z_2$ corresponds to $p_0 = R_(2 0) p_2$ in the initial frame.

==== A more complex example

+ A rotation of $theta$ about the current $x$-axis.
+ A rotation of $phi$ around the current $z$-axis.
+ A rotation of $alpha$ about the fixed $z_0$-axis.

Following the same procedure:
$ R_(3 0) = R_(1 0) R_(2 1) R^2_3 = R_x(theta) R_z(phi) R^2_3 $
where $R^2_3$ denotes the rotation with respect to the initial fixed axes. The
effect of the rotation about the fixed frame in the current frame
$O - x_2 y_2 z_2$ is:
$ R^2_3 = (R_(1 0) R_(2 1))^(-1) R_z(alpha) (R_(1 0) R_(2 1)) = (R_x(theta) R_z(phi))^(-1) R_z(alpha) R_x(theta) R_z(phi) $
which leads to:
$ R_(3 0) = R_z(alpha) R_x(theta) R_z(phi) $

#defbox("The Final Example", [
  Composition: (1) $theta$ about the current $x$-axis; (2) $phi$ around the
  current $z$-axis; (3) $alpha$ about the fixed $z_0$-axis; (4) $beta$ around
  the current $y$-axis; (5) $delta$ about the fixed $x_0$-axis.
  $ R_(r 0) = R_x(delta) R_z(alpha) R_x(theta) R_z(phi) R_y(beta) $
])

== Parametrisation of Rotation Matrices

+ A 3D rotation matrix has 9 elements, but a rotation is completely specified
  by three parameters.
+ A rotation is an element of $"SO"(m)$ completely specified by
  $m(m-1)/2$ parameters: 1 parameter for $"SO"(2)$, 3 parameters for
  $"SO"(3)$.
+ A 3D rotation is completely specified by three rotations about different
  axes, such that no two adjacent rotations are about the same axis.

#cmp((auto, 1fr), [Count], [Choice], [3x], [Any of the three axes is acceptable for the first rotation],
  [2x], [Rule out the axis used for the first rotation],
  [2 =], [Rule out the axis used for the second rotation],
  [12], [Total parametrisations with three rotations])

=== Euler Angles

+ Euler angles are the angles related to three rotations about the current
  axis.
+ A very popular convention is the use of XYZ rotations about fixed axes, known
  in the aeronautics world as *roll-pitch-yaw*, because these rotations denote
  the change in attitude of an aircraft with respect to three fixed axes.
+ #keep[Since the rotation is about fixed axes, we have to pre-multiply:
  $ R = R_z(phi) R_y(theta) R_x(psi) $]
+ $psi$ is the roll angle, $theta$ is the pitch angle, $phi$ is the yaw angle.

==== Euler — Matlab

Any rotation matrix can be created by specifying three angles, e.g. the triple
of Euler angles (three rotations about the current axes: ZYZ):
$ R(phi, theta, psi) = R_z(phi) R_y'(theta) R_z''(psi) $
```matlab
function [R] = eulerRot(phi, theta, psi)
    R = zRot(phi) * yRot(theta) * zRot(psi);
end
```
Tested by `scriptDrawEuler`: `R = eulerRot(pi/6, pi/6, 0)`, then
`v1 = R*[1;0;0]`, `v2 = R*[0;1;0]`, `v3 = R*[0;0;1]`, plotted dashed.

=== RPY Angles

Introduce the notation $c_alpha = cos(alpha)$, $s_alpha = sin(alpha)$. Then:
$ R = mat(c_phi c_theta, c_phi s_theta s_psi - s_phi c_psi, c_phi s_theta c_psi + s_phi s_psi;
         s_phi c_theta, s_phi s_theta s_psi + c_phi c_psi, s_phi s_theta c_psi - c_phi s_psi;
         -s_theta, c_theta s_psi, c_theta c_psi) $

Given a rotation matrix $R = mat(r_11, r_12, r_13; r_21, r_22, r_23; r_31, r_32, r_33)$,
the inverse problem has two solutions:
$ theta in (-pi/2, pi/2) -> cases(
    phi = "atan2"(r_21, r_11),
    theta = "atan2"(-r_31, sqrt(r_32^2 + r_33^2)),
    psi = "atan2"(r_32, r_33)
  ) $
$ theta in (pi/2, 3pi/2) -> cases(
    phi = "atan2"(-r_21, -r_11),
    theta = "atan2"(-r_31, -sqrt(r_32^2 + r_33^2)),
    psi = "atan2"(-r_32, -r_33)
  ) $

=== Gimbal Lock

+ An important feature of RPY, and generally of Euler-based representations, is
  that the three angles act as three independent degrees of freedom.
+ At a pitch angle of $plus.minus pi/2$, the roll and yaw rotation axes become
  aligned. This results in the loss of a degree of freedom.
+ A rotation around one axis can be replicated by a rotation around the other.
  Indeed, when $theta = pi/2$:
$ R = mat(0, s(phi+psi), c(phi+psi); 0, c(phi+psi), -s(phi+psi); -1, 0, 0) $
  Here $phi$ and $psi$ do not act independently: all rotations achieved with a
  combination of $phi$ and $psi$ can be accomplished by a single rotation of
  angle $(phi + psi)$.
+ The inverse mapping from the rotation matrix to the RPY angles is singular at
  this point: infinitely many combinations of $phi$ and $psi$ produce the same
  rotation matrix.
+ This problem has profound reasons: it is like creating a 2D map from a
  sphere. When you flatten it, the poles become lines; a single point on the
  sphere is mapped to an infinite number of points.

#keypt("Consequence", [
  This lack of invertibility can cause a significant problem: in the singular
  configuration, small changes in the physical orientation can produce
  discontinuous jumps in the calculated RPY angles. This is a major issue for
  physical systems like robots, which require smooth and continuous control.
])

=== Axis–Angle Representation

+ Adopt a redundant parametrisation using an axis
  ($k = [k_x, k_y, k_z]$ with $|k| = 1$) and an angle ($theta$), resulting in
  four parameters overall.
+ The rotation $R_k(theta)$ can be found by transforming the coordinates. Find a
  new frame $O - x_1 y_1 z_1$, with $z_1$ coincident with $k$. Rotate
  $O - x_0 y_0 z_0$ by $alpha$ about the $z$-axis and by $beta$ around the
  $y$-axis.
+ Clearly $R_(1 0) = R_z(alpha) R_y(beta)$. If a transformation $A$ (e.g. a
  rotation) is expressed in $O - x_1 y_1 z_1$, as in $q_1 = A p_1$, then:
$ q_0 = (R_(0 1))^(-1) A R_(0 1) p_0 = R_z(alpha) R_y(beta) A (R_z(alpha) R_y(beta))^(-1) $
  which leads to:
$ R_k(theta) = R_z(alpha) R_y(beta) R_z(theta) R_y(-beta) R_z(-alpha) $

Using trigonometry:
$ sin(alpha) = k_y / sqrt(k_x^2 + k_y^2) quad cos(alpha) = k_x / sqrt(k_x^2 + k_y^2) $
$ sin(beta) = sqrt(k_x^2 + k_y^2) quad cos(beta) = k_z $

==== Rodrigues' formula

$ R_k(theta) = mat(
    k_x^2 (1 - c_theta) + c_theta, k_x k_y (1 - c_theta) - k_z s_theta, k_x k_z (1 - c_theta) + k_y s_theta;
    k_x k_y (1 - c_theta) + k_z s_theta, k_y^2 (1 - c_theta) + c_theta, k_y k_z (1 - c_theta) - k_x s_theta;
    k_x k_z (1 - c_theta) - k_y s_theta, k_y k_z (1 - c_theta) + k_x s_theta, k_z^2 (1 - c_theta) + c_theta) $

+ Four parameters $(k, theta)$ plus the constraint
  $k_x^2 + k_y^2 + k_z^2 = 1$: the system has three degrees of freedom.
+ From the matrix: $R_(-k)(-theta) = R_k(theta)$; inverting both the axis and
  the angle gives the same rotation.
+ The axis–angle parametrisation is not globally invertible, but it is locally
  invertible (to be precise, a local homeomorphism). Unlike RPY angles, there
  are no singularities such as Gimbal Lock.
+ The problem, compared to RPY angles, is that this parametrisation is not very
  intuitive.
+ Unlike using rotation matrices directly, it is not straightforward to
  analytically compose or invert subsequent rotations.

#figure(
  align(center, block(
    inset: 6pt, stroke: 0.5pt + rule, radius: 2pt,
    stack(dir: ltr, spacing: 6pt,
      box(stroke: 0.6pt + primary, inset: 4pt, radius: 2pt)[Frame $O - x_0 y_0 z_0$],
      text(fill: primary)[$arrow.r$],
      box(stroke: 0.6pt + primary, inset: 4pt, radius: 2pt)[$R_z(alpha) R_y(beta)$: $z_1 arrow.r.double k$],
      text(fill: primary)[$arrow.r$],
      box(stroke: 0.6pt + defcol, inset: 4pt, radius: 2pt)[rotate $theta$ about $z_1 = k$],
    ),
  )),
  caption: [Axis–angle construction: frame rotated so that $z_1$ coincides with $k$, then rotated by $theta$ about $k$.],
)

#place.flush()

== Quaternions

=== Fundamentals

+ For a real number $x in RR$ the inverse is $x^(-1) = 1/x$.
+ For an element of $RR^2$, $x = vec(a, b)$, an inverse exists using complex
  numbers: $z = a + i b$, with $i$ the imaginary unit. Introducing the complex
  conjugate $z^* = a - i b$ and $z_1 = z^* / |z|^2$:
  $ z · z_1 = (z z^*) / (a^2 + b^2) = (a^2 + b^2) / (a^2 + b^2) = 1$,
  hence $z^(-1) = z^* / |z|^2$.
+ The same trick cannot be repeated with $RR^3$, but it can with $RR^4$, by
  using *quaternions*.

#defbox("Definition of a Complex Number", [
  + Let $1$ and $i$ be the basis elements.
  + The following axiom holds: $i^2 = -1$.
  + A complex number is an element of a vector space over the reals, with the
    form $z = x + i y$, where $x, y in RR$.
])

#defbox("Definition of a Quaternion", [
  + Let $1$ and $i, j, k$ be the basis elements.
  + The following axioms hold: $i^2 = j^2 = k^2 = i j k = -1$.
  + A quaternion is an element of a vector space over the reals, with the form
    $q = q_0 + q_1 i + q_2 j + q_3 k$.
  + Shorthand distinguishes the *scalar part* $q_0$ and the *vector part*
    $q.bar = q_1 i + q_2 j + q_3 k$: $q = q_0 + q.bar$. An equivalent notation
    is $[q_0, q.bar]$.
])

==== Background on vector products

*Scalar (dot) product.* Given $u = u_1 i + u_2 j + u_3 k$ and
$v = v_1 i + v_2 j + v_3 k$, the scalar product is the real number
$u · v = u_1 v_1 + u_2 v_2 + u_3 v_3$. If $theta$ is the angle between the
vectors, $u · v = |u| |v| cos theta$. It represents the projection of one vector
onto the other and is commutative.

*Vector (cross) product.* The vector product $s = u times v$ is a vector
orthogonal to both $u$ and $v$, whose magnitude is $|s| = |u| |v| sin theta$.
$ s = u times v = s_1 i + s_2 j + s_3 k$ with
$cases(s_1 = u_2 v_3 - u_3 v_2, s_2 = u_3 v_1 - u_1 v_3, s_3 = u_1 v_2 - u_2 v_1)$.
The vector product is anti-commutative: $u times v = -v times u$.

=== Quaternion Product, Conjugate and Inverse

From the axiom $i^2 = j^2 = k^2 = i j k = -1$, the multiplication rules of the
basis elements are:
$ i j = k, j i = -k; quad j k = i, k j = -i; quad k i = j, i k = -j $
These rules are the same as those for the vector cross product.

With the shorthand $p = p_0 + p.bar$ and $q = q_0 + q.bar$:
$ p q = (p_0 + p.bar)(q_0 + q.bar) = p_0 q_0 + p_0 q.bar + q_0 p.bar + p.bar q.bar $
The product of the two vector parts simplifies as
$p.bar q.bar = -p.bar · q.bar + p.bar times q.bar$. Thus the full product is:
$ p q = (p_0 q_0 - p.bar · q.bar) + (p_0 q.bar + q_0 p.bar + p.bar times q.bar) $
Scalar part: $p_0 q_0 - p.bar · q.bar$; vector part:
$p_0 q.bar + q_0 p.bar + p.bar times q.bar$. The quaternion product is
*associative* but *not commutative* ($p q != q p$).

#defbox("Quaternion Conjugate", [
  $ q = q_0 + q_1 i + q_2 j + q_3 k ==> q^* = q_0 - q_1 i - q_2 j - q_3 k $
  $ q q^* = (q_0 + q.bar)(q_0 - q.bar) = q_0^2 - q.bar^2 = q_0^2 + |q.bar|^2 = q_0^2 + q_1^2 + q_2^2 + q_3^2 $
])

#defbox("Quaternion Length", [
  $ |q| = sqrt(q q^*) = sqrt(q_0^2 + q_1^2 + q_2^2 + q_3^2) $ is the quaternion
  length, or norm.
])

A quaternion (except $0$) has a unique inverse:
$ q^(-1) = q^* / |q|^2 quad "with" quad (q q^*) / |q|^2 = 1 $
The relation simplifies further when the quaternion has unit length.

==== To complex numbers and back

A complex number can be expressed in Euler form:
$ z = rho (cos(theta) + j sin(theta)) $
Multiplying two complex numbers in Euler notation:
$ z_1 z_2 = rho_1 rho_2 (cos(theta_1 + theta_2) + j sin(theta_1 + theta_2)) $
Multiplying a complex number by a unit-norm (unit-modulus) complex number has
the effect of a rotation. Multiplying by its complex conjugate "undoes" the
rotation, aligning the result with the real axis.

=== Quaternions and Rotations

Consider a unit-length quaternion $q = [eta, epsilon]$, where $eta$ is the
scalar part and $epsilon = vec(epsilon_x, epsilon_y, epsilon_z)$ the vector
part. It can be expressed as:
$ q = (cos(theta/2), sin(theta/2) k) quad "where" quad k = epsilon / |epsilon| quad theta = 2 "atan2"(|epsilon|, eta) $

#keypt("Key Fact", [
  The unit-length quaternion
  $q = (cos(theta/2), sin(theta/2) k)$ represents a rotation of angle $theta$
  about the axis defined by the unit vector $k$.
])

Let $q = [eta, epsilon]$ be a unit quaternion and $p = [0, p.bar]$ a pure
quaternion representing a vector $p$. The rotated vector $p'$ is computed by
the conjugation formula $ p' = q p q^* $, yielding a pure quaternion
$[0, p'.bar]$. After computation, the vector part $p'.bar$ is:
$ p'.bar = (eta^2 - |epsilon|^2) p.bar + 2 eta (epsilon times p.bar) + 2 (epsilon · p.bar) epsilon $

By substituting $eta = cos(theta/2)$, $epsilon = sin(theta/2) k$ and
$|epsilon|^2 = sin^2(theta/2)$:
$ p'.bar = cos(theta) p.bar + sin(theta) (k times p.bar) + (1 - cos(theta))(k · p.bar) k $

#defbox("Rodrigues' rotation formula", [
  $ p' = cos(theta) p + sin(theta) (k times p) + (1 - cos(theta))(k · p) k $
  It describes the rotation of a vector $p$ by an angle $theta$ about the axis
  $k$.
])

==== Equivalent rotation matrix

Rodrigues' formula is equivalent to applying a rotation matrix $R_k(theta)$:
$ p' = R_k(theta) p $, where:
$ R_k(theta) = mat(
    k_x^2 (1 - c_theta) + c_theta, k_x k_y (1 - c_theta) - k_z s_theta, k_x k_z (1 - c_theta) + k_y s_theta;
    k_x k_y (1 - c_theta) + k_z s_theta, k_y^2 (1 - c_theta) + c_theta, k_y k_z (1 - c_theta) - k_x s_theta;
    k_x k_z (1 - c_theta) - k_y s_theta, k_y k_z (1 - c_theta) + k_x s_theta, k_z^2 (1 - c_theta) + c_theta) $
with $c_theta = cos(theta)$ and $s_theta = sin(theta)$.

#defbox("Summary", [
  Given a unit-length quaternion
  $q = [eta, epsilon] = (cos(theta/2), sin(theta/2) k)$, associate it with a
  rotation of angle $theta$ about the unit vector $k$, with
  $k = epsilon / |epsilon|$ and $theta = 2 "atan2"(|epsilon|, eta)$. The
  parameters correspond to three degrees of freedom:
  + four numbers $eta, epsilon_x, epsilon_y, epsilon_z$ with constraint
    $eta^2 + epsilon_x^2 + epsilon_y^2 + epsilon_z^2 = 1$;
  + four numbers $theta, k_x, k_y, k_z$ with constraint
    $k_x^2 + k_y^2 + k_z^2 = 1$.
])

=== From Rotation Matrix to Quaternions

Given a rotation matrix
$R = mat(r_11, r_12, r_13; r_21, r_22, r_23; r_31, r_32, r_33)$, the inverse
problem is solved by:
$ eta = 1/2 sqrt(r_11 + r_22 + r_33 + 1) $
$ epsilon = 1/2 vec(
    "sgn"(r_32 - r_23) sqrt(r_11 - r_22 - r_33 + 1),
    "sgn"(r_13 - r_31) sqrt(r_22 - r_33 - r_11 + 1),
    "sgn"(r_21 - r_12) sqrt(r_33 - r_11 - r_22 + 1)) $
$ "where" quad "sgn"(x) = cases(1 &x >= 0, -1 &x < 0) $

=== Composition and Advantages

Consider two rotations associated with unit-length quaternions $q_0$ and $q_1$.
The first transforms $p$ into $p'$, the second $p'$ into $p''$. Using pure
quaternions $p = [0, p.bar]$, $p' = [0, p'.bar]$, $p'' = [0, p''.bar]$:
$ p'' = q_1 p' q_1^* = q_1 (q_0 p q_0^*) q_1^* = (q_1 q_0) p (q_0^* q_1^*) = (q_1 q_0) p (q_1 q_0)^* $
The last step holds because the conjugate of a product is the product of the
conjugates in reverse order, $(q_1 q_0)^* = q_0^* q_1^*$. The composition of
two rotations is therefore equivalent to the product of their quaternions.

#tbl((auto, 1fr, 1fr), head: ([Operation], [Rotation Matrices], [Unit-Quaternions]),
  [Inversion], [$R^(-1) = R^T$], [$q^(-1) = (eta, -epsilon)$],
  [Composition], [$R = R_1 R_2$], [$q = q_1 q_2$])

Composition formula:
$ q_1 q_2 = (eta_1 eta_2 - epsilon_1 · epsilon_2, eta_1 epsilon_2 + eta_2 epsilon_1 + epsilon_1 times epsilon_2) $

+ *Inversion*: the inverse of a unit-length quaternion is its conjugate, found
  by negating the vector part. This is computationally much faster than
  transposing and inverting a matrix.
+ *Composition*: the composition of two rotations is a simple quaternion
  product; the result represents the combined rotation. More efficient and
  numerically stable than composing rotation matrices.

==== In summary

+ *Compact representation*: four numbers instead of the nine of a rotation
  matrix.
+ *Absence of Gimbal Lock*: unlike Euler angles, quaternions provide a
  continuous and non-singular representation of rotations, completely avoiding
  the Gimbal Lock problem. Significant advantage in computer graphics and
  robotics.
+ *Efficient composition*: achieved by a simple quaternion multiplication,
  computationally more efficient than matrix multiplication.
+ *Direct interpolation*: quaternions allow smooth, constant-velocity
  interpolation between two rotations (spherical linear interpolation, slerp),
  crucial for animations.
+ *Non-uniqueness*: a single rotation can be represented by two quaternions,
  $q$ and $-q$; a minor redundancy that does not demean the practical benefits.

#place.flush()

= Homogeneous Transformations

== Position of a Frame in 3D

A rigid body's pose is defined by the position and orientation of a frame
attached to it. So far only rotation was considered, ignoring translation (with
coincident frame origins). In the general case, both rotation and translation
are present. A point $p^1$ in frame $\{1\}$ can be expressed in frame $\{0\}$
as:
$ p^0 = o_1^0 + R_1^0 p^1 $

== Direct and Inverted Coordinate Transformation

The inverse relation is found by isolating $p^1$:
$ p^1 = (R_1^0)^(-1) (p^0 - o_1^0) = R_1^(0 T) (p^0 - o_1^0) = R_0^1 p^0 - R_0^1 o_1^0 $
This representation is rather cumbersome, as the inverse involves both a matrix
transpose and a matrix-vector product.

== Homogeneous Coordinates

A compact way to represent both rotation and translation: create the
homogeneous representation $tilde(p)$ of $p$ by appending a coordinate of
value 1:
$ tilde(p) = vec(p, 1) $
Construct a $4 times 4$ matrix, the homogeneous transformation matrix:
$ A_1^0 = mat(R_1^0, o_1^0; 0^T, 1) $
The transformation of a point from frame $\{1\}$ to frame $\{0\}$ becomes a
single matrix-vector multiplication:
$ tilde(p)^0 = A_1^0 tilde(p)^1 $

A key advantage is that the coordinate transformation is a simple matrix
multiplication. The inverse transformation is found by simply inverting the
matrix:
$ tilde(p)^1 = A_0^1 tilde(p)^0 = (A_1^0)^(-1) tilde(p)^0 $
#keep[The inverse homogeneous transformation matrix is:
$ A_0^1 = (A_1^0)^(-1) = mat(R_1^(0 T), -R_1^(0 T) o_1^0; 0^T, 1) $]

+ Unlike rotation matrices, homogeneous transformations are not orthogonal:
  for a general homogeneous matrix $A$, $A^(-1) != A^T$.
+ The formalism generalizes the properties of the rotation group to include
  translations. A sequence of transformations in the current axes is a simple
  matrix product:
  $ tilde(p)^0 = A_1^0 A_2^1 dots A_n^(n-1) tilde(p)^n $
+ The set of all homogeneous transformations forms a group, the *special
  Euclidean group* $"SE"(3) = RR^3 ⋊ "SO"(3)$ (semi-direct product).

== Matlab Examples for Homogeneous Transformations

`homogeneousTrans` builds a homogeneous transformation:
```matlab
% homogeneous transformation
function [T] = homogeneousTrans(phi, theta, psi, Ov)
    R = eulerRot(phi, theta, psi);
    T = [R, Ov;
        zeros(1,3), 1]
end
```
$ A_1^0 = mat(R(phi, theta, psi), O_1^0; O, 1) $

+ `scriptDrawHom`: `T = homogeneousTrans(0, 0, pi/4, [1;1;1])`;
  `O1 = T*[0;0;0;1]`; `v1 = T*[1;0;0;1]`, `v2 = T*[0;1;0;1]`,
  `v3 = T*[0;0;1;1]`; the transformed frame is plotted dashed.
+ `scriptDrawHom1`: equivalent using built-in Matlab functions:
  `T = makehgtform('translate', [1,1,1], 'zrotate', pi/4)`.
+ `scriptTestTriad`: uses a downloaded community file to draw axis frames:
  `h = triad('Parent', axs)`; then
  `h1 = triad('Parent', h, 'Matrix', makehgtform('translate', [1,1,1], 'xrotate', pi/4), 'linewidth', 3, 'linestyle', '--')`.
+ `scriptTransformTest`: Matlab provides an object to create a transformation,
  link it to the current axis, and define child objects transformed
  accordingly: `t = hgtransform('Parent', axs)`; a cylinder is created with
  `cylinder([1,1],100)` and `surface`; `set(h, 'Parent', t)` associates it;
  then `Rz = makehgtform('xrotate', 2*pi/3)`, `set(t, 'Matrix', Rz)`, and
  `drawnow` updates the children.
+ `scriptTransformTriads`: combines triads and `hgtransform`; a second frame is
  obtained with `makehgtform('translate', [1,1,1], 'xrotate', pi/4)`, then a
  loop `for angle = 0:0.5:360` applies
  `Rz = makehgtform('zrotate', deg2rad(angle))` and `drawnow` animates it.

#figure(
  align(center, block(
    inset: 6pt, stroke: 0.5pt + rule, radius: 2pt,
    stack(dir: ltr, spacing: 6pt,
      box(stroke: 0.6pt + primary, inset: 4pt, radius: 2pt)[Frame $\{0\}$],
      text(fill: primary)[$arrow.r.long$],
      box(stroke: 0.6pt + primary, inset: 4pt, radius: 2pt)[$p^0 = o_1^0 + R_1^0 p^1$],
      text(fill: primary)[$arrow.r.long$],
      box(stroke: 0.6pt + defcol, inset: 4pt, radius: 2pt)[$tilde(p)^0 = A_1^0 tilde(p)^1$],
    ),
  )),
  caption: [Rigid transformation: translation plus rotation, compactly written with homogeneous coordinates.],
)