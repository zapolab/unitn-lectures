#import "_preamble.typ": *
#import "_geom3d.typ": *
#show: doc.with(title: "Geometric Background", label: "ROBOTICS-03")
#titleblock("Geometric Background", "ROBOTICS — Lezione 3")

#let mm(A, B) = {
  let col(j) = mv(A, (B.at(0).at(j), B.at(1).at(j), B.at(2).at(j)))
  ((col(0).at(0), col(1).at(0), col(2).at(0)),
   (col(0).at(1), col(1).at(1), col(2).at(1)),
   (col(0).at(2), col(1).at(2), col(2).at(2)))
}

== Fundamental Rotation Matrices

=== Rotation about the $z$-axis
$ R_z(alpha) = mat(cos alpha, -sin alpha, 0; sin alpha, cos alpha, 0; 0, 0, 1) $

Matlab translation `zRot`:
```matlab
% Returns the rotation about the z axis
function [Rz] = zRot(alpha)
  Rz = [cos(alpha), -sin(alpha), 0;
        sin(alpha),  cos(alpha), 0;
        0, 0, 1];
end
```

=== Rotation about the $y$-axis
$ R_y(beta) = mat(cos beta, 0, sin beta; 0, 1, 0; -sin beta, 0, cos beta) $

```matlab
function [Ry] = yRot(beta)
  Ry = [cos(beta), 0, sin(beta);
        0, 1, 0;
        -sin(beta), 0, cos(beta)];
end
```

=== Rotation about the $x$-axis
$ R_x(gamma) = mat(1, 0, 0; 0, cos gamma, -sin gamma; 0, sin gamma, cos gamma) $

```matlab
function [Rx] = xRot(gamma)
  Rx = [1, 0, 0;
        0, cos(gamma), -sin(gamma);
        0, sin(gamma), cos(gamma)];
end
```

=== Drawing a reference frame
Script `scriptDraw` draws a frame and a second frame rotated by $45°$ about $z$:
```matlab
close all; view(3);          % 2D or 3D plots
daspect([1 1 1]);
plot3([0,1],[0,0],[0,0], 'Color',[1,0,0]); hold on   % x axis
plot3([0,0],[0,1],[0,0], 'Color',[0,1,0]);           % y axis
plot3([0,0],[0,0],[0,1], 'Color',[0,0,1]);           % z axis
v1 = zRot(pi/4) * [1;0;0]    % x axis rotated 45 deg around z
v2 = zRot(pi/4) * [0;1;0]    % y axis rotated 45 deg around z
v3 = zRot(pi/4) * [0;0;1]    % z axis rotated 45 deg around z
plot3([0,v1(1)],[0,v1(2)],[0,v1(3)], 'Color',[1,0,0], 'LineStyle','--');
plot3([0,v2(1)],[0,v2(2)],[0,v2(3)], 'Color',[0,1,0], 'LineStyle','--');
plot3([0,v3(1)],[0,v3(2)],[0,v3(3)], 'Color',[0,0,1], 'LineStyle','--');
```

== Composition of Rotations

=== Composing two rotations
Three frames share the same origin: $O - x_0 y_0 z_0$, $O - x_1 y_1 z_1$, $O - x_2 y_2 z_2$; a point $P$ has coordinates $p_0$, $p_1$, $p_2$ in the three frames. Let $R_i^j$ denote the rotation matrix of Frame $i$ with respect to Frame $j$:
$ p_1 = R_2^1 p_2 quad p_0 = R_1^0 p_1 quad p_0 = R_2^0 p_2 $
By substitution and comparison:
$ p_0 = R_1^0 R_2^1 p_2 arrow.r.double R_2^0 = R_1^0 R_2^1 $
The relation is obtained in two steps: first rotate $O - x_0 y_0 z_0$ to align it with frame 1 ($R_1^0$); then rotate again to align frame 1 with frame 2 ($R_2^1$).

#defbox("Composition of Rotations", [A rotation can be expressed as a sequence of partial rotations, each one defined with respect to the previous one. The frame from which the rotation occurs is termed the *current frame*. The sequence is obtained by *post-multiplying* the matrices associated with each rotation.])
$ R_i^j = (R_j^i)^(-1) = (R_j^i)^top $

=== Example in the current frame
We first rotate by $phi$ about the current $y$-axis, then by $theta$ about the current $z$-axis:
$ R_2^0 = R_y(phi) R_z(theta) $

#figure(caption: [Rotations about axes in the current frame: $phi$ about the current $y$-axis, then $theta$ about the current $z$-axis.], [
  #raw("")
  #scale(78%, reflow: true)[
    #canvas({
      import "_geom3d.typ": proj, axis, frameR, rotarc, Rx, Ry, Rz, I3, mv, vadd, smul
      let R1 = Ry(55deg)
      let R2 = mm(R1, Rz(45deg))
      frameR((0,0,0), I3, $x_0$, $y_0$, $z_0$, len: 1.3)
      frameR((0,0,0), R1, $x_1$, $y_1$, $z_1$, dash: "dashed", len: 1.3)
      frameR((0,0,0), R2, $x_2$, $y_2$, $z_2$, c: rgb("#B3261E"), len: 1.3)
      rotarc((0,0,0), (1,0,0), mv(R1, (1,0,0)), $phi$, r: 0.55)
      rotarc((0,0,0), mv(R1, (1,0,0)), mv(R2, (1,0,0)), $theta$, r: 1.05)
    })
  ]
])

=== Another example
$ R_4^0 = R_z(alpha) R_y(beta) R_y(gamma) R_z(delta) $
The order is absolutely important:
$ R_z(alpha) R_y(beta) R_y(gamma) R_z(delta) != R_y(gamma) R_z(delta) R_z(alpha) R_y(beta) $

=== Rotations about fixed axes
For a generic point $P$, $p_0 = R_1^0 p_1$. For a generic linear application $A$ defined in frame $O - x_0 y_0 z_0$:
$ q_0 = A p_0 quad q_1 = R_0^1 A p_0 = R_0^1 A R_1^0 p_1 = (R_1^0)^(-1) A R_1^0 p_1 $

Example: $R_1^0 = R_y(phi)$ around the $y_0$-axis, and a rotation $A = R_2$ around the $z_0$-axis (not $z_1$ as in the current frame):
$ R_2^0 = R_1^0 R_2 quad R_2 = (R_1^0)^(-1) R_z(theta) R_1^0 $
$ R_2^0 = R_1^0 (R_1^0)^(-1) R_z(theta) R_1^0 = R_z(theta) R_y(phi) $
#keypt("Fixed axes", [When the composition happens with *fixed* axes we have to *pre-multiply*, instead of post-multiplying as in the current frame.])
$ R_4^0 = R_z(delta) R_y(gamma) R_y(beta) R_z(alpha) $

=== Rotation about current axes — example
1. A rotation of $theta$ about the current $x$-axis. 2. A rotation of $phi$ about the current $z$-axis.
$ R_2^0 = R_x(theta) R_z(phi) $
A point $p_2$ in frame $O - x_2 y_2 z_2$ corresponds to $p_0 = R_2^0 p_2$ in the initial frame.

=== More complex examples
Three rotations: $theta$ about current $x$, $phi$ about current $z$, $alpha$ about fixed $z_0$:
$ R_3^0 = R_1^0 R_2^1 R_3 = R_x(theta) R_z(phi) R_3 $
where $R_3$ denotes the notation with respect to the initial fixed axes, in the current frame $O - x_2 y_2 z_2$:
$ R_3 = (R_1^0 R_2^1)^(-1) R_z(alpha) R_1^0 R_2^1 = (R_x(theta) R_z(phi))^(-1) R_z(alpha) R_x(theta) R_z(phi) $
$ arrow.r.double R_3^0 = R_z(alpha) R_x(theta) R_z(phi) $

Five rotations: $theta$ about current $x$, $phi$ about current $z$, $alpha$ about fixed $z_0$, $beta$ about current $y$, $delta$ about fixed $x_0$:
$ R_r^0 = R_x(delta) R_z(alpha) R_x(theta) R_z(phi) R_y(beta) $
#keypt("Check", [Verify this result yourself with paper and a pencil.])

== Parametrisation of Rotations

=== Degrees of freedom
A 3D rotation matrix has 9 elements, but a rotation is completely specified by *three* parameters. In general a rotation is an element of $S O(m)$ completely specified by $m(m-1)/2$ parameters:
- 1 parameter for $S O(2)$; 3 parameters for $S O(3)$.
- A 3D rotation is specified by three rotations about different axes, such that no two adjacent rotations are about the same axis.
- There are $3 times 2 times 2 = 12$ parametrisations: 3 choices for the first axis, 2 for the second (rule out the first), 2 for the third (rule out the second).

=== Euler angles
Euler angles are the angles of three rotations about the current axes. A popular convention is *XYZ rotations about fixed axes*, known in aeronautics as *roll-pitch-yaw*, denoting the change in attitude of an aircraft with respect to three fixed axes. Since the rotation is about fixed axes we have to pre-multiply:
$ R = R_z(phi) R_y(theta) R_x(psi) $
$psi$ = roll angle, $theta$ = pitch angle, $phi$ = yaw angle.

=== Euler — Matlab
A rotation matrix can be created by specifying three angles; one way is the triple of Euler angles (three rotations about the current axes, ZYZ):
$ R(phi, theta, psi) = R_z(phi) R_y'(theta) R_z''(psi) $
```matlab
function [R] = eulerRot(phi, theta, psi)
  R = zRot(phi) * yRot(theta) * zRot(psi);
end
```
Script `scriptDrawEuler` tests it with `R = eulerRot(pi/6, pi/6, 0)` and plots the three rotated vectors `R*[1;0;0]`, `R*[0;1;0]`, `R*[0;0;1]` (same drawing structure as `scriptDraw`).

=== RPY angles
With the notation $c_alpha = cos(alpha)$, $s_alpha = sin(alpha)$:
$ R = mat(c_phi c_theta, c_phi s_theta s_psi - s_phi c_psi, c_phi s_theta c_psi + s_phi s_psi; s_phi c_theta, s_phi s_theta s_psi + c_phi c_psi, s_phi s_theta c_psi - c_phi s_psi; -s_theta, c_theta s_psi, c_theta c_psi) $
Given $R = mat(r_11, r_12, r_13; r_21, r_22, r_23; r_31, r_32, r_33)$, the inverse problem has two solutions. For $theta in (-pi/2, pi/2)$:
$ &phi = op("atan2")(r_21, r_11), quad psi = op("atan2")(r_32, r_33), \
  &theta = op("atan2")(-r_31, sqrt(r_32^2 + r_33^2)) $
For $theta in (pi/2, 3pi/2)$:
$ &phi = op("atan2")(-r_21, -r_11), quad psi = op("atan2")(-r_32, -r_33), \
  &theta = op("atan2")(-r_31, -sqrt(r_32^2 + r_33^2)) $
#keypt("Exercise", [Solve the inverse problem and find the two solutions.])

=== RPY — Gimbal lock
An important feature of RPY (and generally of Euler-based representations) is that the three angles act as three independent degrees of freedom. At a pitch angle of $plus.minus pi/2$ the roll and yaw rotation axes become aligned, resulting in the loss of a degree of freedom: a rotation around one axis can be replicated by a rotation around the other. Indeed, when $theta = pi/2$:
$ R = mat(c_phi c_theta, c_phi s_theta s_psi - s_phi c_psi, c_phi s_theta c_psi + s_phi s_psi; s_phi c_theta, s_phi s_theta s_psi + c_phi c_psi, s_phi s_theta c_psi - c_phi s_psi; -s_theta, c_theta s_psi, c_theta c_psi) \
  = mat(0, s(phi+psi), c(phi+psi); 0, c(phi+psi), -s(phi+psi); -1, 0, 0) $
From this, $phi$ and $psi$ do not act independently: all rotations achieved by a combination of $phi$ and $psi$ can be accomplished by a single rotation of angle $(phi + psi)$. The inverse mapping from the rotation matrix to RPY angles is singular at this point: infinitely many combinations of $phi$ and $psi$ produce the same matrix.
- Profound reason: it is like creating a 2D map from a sphere; when flattening it, the poles become lines, so a single point on the sphere maps to an infinite number of points.
- In the singular configuration small changes in physical orientation produce discontinuous jumps in the calculated RPY angles.
#keypt("Robotics issue", [This lack of invertibility is a major problem for physical systems like robots, which require smooth and continuous control.])

=== Axis–angle representation
A redundant parametrisation uses an axis $k = [k_x, k_y, k_z]$ with $|k| = 1$ and an angle $theta$, four parameters overall. The rotation $R_k(theta)$ is found by transforming coordinates: find a new frame $O - x_1 y_1 z_1$ with $z_1$ coincident with $k$, rotating $O - x_0 y_0 z_0$ by $alpha$ about the $z$-axis and by $beta$ around the $y$-axis, so $R_1^0 = R_z(alpha) R_y(beta)$. For $q_1 = A p_1$:
$ q_0 = (R_0^1)^(-1) A R_0^1 p_0 = R_z(alpha) R_y(beta) A (R_z(alpha) R_y(beta))^(-1) $
$ arrow.r.double R_k(theta) = R_z(alpha) R_y(beta) R_z(theta) R_y(-beta) R_z(-alpha) $

#figure(caption: [Axis–angle construction: $z_1$ coincident with the unit axis $k$; $alpha$ about $z_0$ and $beta$ about $y$.], [
  #raw("")
  #scale(78%, reflow: true)[
    #canvas({
      import "_geom3d.typ": proj, axis, frameR, rotarc, Rx, Ry, Rz, I3, mv, vadd, smul
      let k = (0.5, 0.32, 0.80)
      frameR((0,0,0), I3, $x_0$, $y_0$, $z_0$, len: 1.25)
      axis((0,0,0), k, $k$, c: rgb("#B3261E"), len: 1.5)
      rotarc((0,0,0), (1,0,0), (k.at(0), k.at(1), 0), $alpha$, r: 0.55)
    })
  ]
])

Using trigonometry:
$ &sin alpha = k_y/sqrt(k_x^2 + k_y^2), quad cos alpha = k_x/sqrt(k_x^2 + k_y^2), \
  &sin beta = sqrt(k_x^2 + k_y^2), quad cos beta = k_z $
From Rodrigues' formula:
$ R_k(theta) = mat(k_x^2(1-c_theta)+c_theta, k_x k_y(1-c_theta)-k_z s_theta, k_x k_z(1-c_theta)+k_y s_theta; k_x k_y(1-c_theta)+k_z s_theta, k_y^2(1-c_theta)+c_theta, k_y k_z(1-c_theta)-k_x s_theta; k_x k_z(1-c_theta)-k_y s_theta, k_y k_z(1-c_theta)+k_x s_theta, k_z^2(1-c_theta)+c_theta) $
Four parameters plus the constraint $k_x^2 + k_y^2 + k_z^2 = 1$ give three degrees of freedom. Also $R_(-k)(-theta) = R_k(theta)$: inverting both axis and angle yields the same rotation.

Unlike RPY, there are no singularities such as Gimbal Lock (it is locally invertible, a local homeomorphism), but the parametrisation is not intuitive, and it is not straightforward to analytically compose or invert subsequent rotations as with matrices.

== Quaternions

=== From $RR$ to $RR^4$
Consider a real number $x in RR$: $1/x dot x = 1 arrow.r.double x^(-1) = 1/x$.
Consider an element of $RR^2$, $x = mat(a; b)$: its inverse exists using complex numbers. Define $z = a + i b$ ($i$ imaginary unit) and the *complex conjugate* $z^* = a - i b$; consider $z_1 = z^* / (|z|^2)$. Then:
$ z dot z_1 = z z^* / (|z|^2) = 1, quad |z|^2 = a^2 + b^2, quad "hence" z^(-1) = z_1 $
The same trick cannot be repeated with $RR^3$, but it can with $RR^4$ by using quaternions.

=== Definitions
#defbox("Complex number", [Let $1$ and $i$ be the basis elements, with the axiom $i^2 = -1$. A complex number is an element of a vector space over the reals with the form $z = x + i y$, where $x, y in RR$.])
#defbox("Quaternion", [Let $1$ and $i, j, k$ be the basis elements, with the axioms $i^2 = j^2 = k^2 = i j k = -1$. A quaternion is an element of a vector space over the reals with the form $q = q_0 + q_1 i + q_2 j + q_3 k$. Shorthand distinguishes the *scalar part* $q_0$ and the *vector part* $bold(q) = q_1 i + q_2 j + q_3 k$: $q = q_0 + bold(q)$, equivalently $[q_0, bold(q)]$.])

=== Background on vector products
#defbox("Scalar (dot) product", [Given $u = u_1 i + u_2 j + u_3 k$ and $v = v_1 i + v_2 j + v_3 k$, $u dot v = u_1 v_1 + u_2 v_2 + u_3 v_3$. If $theta$ is the angle between the vectors, $u dot v = |u| |v| cos theta$. It represents the projection of one vector onto the other and is commutative.])
#defbox("Vector (cross) product", [Given $u$ and $v$, $s = u times v$ is a vector orthogonal to both, with $|s| = |u| |v| sin theta$. With $s = s_1 i + s_2 j + s_3 k$:
$ s_1 = u_2 v_3 - u_3 v_2, quad s_2 = u_3 v_1 - u_1 v_3, quad s_3 = u_1 v_2 - u_2 v_1 $
The vector product is anti-commutative: $u times v = -v times u$.])

=== Multiplication of basis elements
Applying $i^2 = j^2 = k^2 = i j k = -1$:
$ i j = k, quad j i = -k, quad j k = i, quad k j = -i, quad k i = j, quad i k = -j $
These rules are the same as those of the vector cross product.

=== Quaternion product
With $p = p_0 + bold(p)$ and $q = q_0 + bold(q)$:
$ p q = (p_0 + bold(p))(q_0 + bold(q)) = p_0 q_0 + p_0 bold(q) + q_0 bold(p) + bold(p)bold(q) $
Using the multiplication rules, $bold(p)bold(q) = -bold(p) dot bold(q) + bold(p) times bold(q)$, so the full product is:
$ p q = (p_0 q_0 - bold(p) dot bold(q)) + (p_0 bold(q) + q_0 bold(p) + bold(p) times bold(q)) $
The scalar part is $p_0 q_0 - bold(p) dot bold(q)$ and the vector part is $p_0 bold(q) + q_0 bold(p) + bold(p) times bold(q)$. The product is *associative* but *not commutative*: $p q != q p$.

=== Conjugate, length and inverse
$ q = q_0 + q_1 i + q_2 j + q_3 k arrow.r.double q^* = q_0 - q_1 i - q_2 j - q_3 k $
$ q q^* = (q_0 + bold(q))(q_0 - bold(q)) = q_0^2 - q_0 bold(q) + q_0 bold(q) - bold(q)^2 \
  = q_0^2 - (-bold(q) dot bold(q) + bold(q) times bold(q)) = q_0^2 + |bold(q)|^2 = q_0^2 + q_1^2 + q_2^2 + q_3^2 $
#defbox("Quaternion length", [The quantity $|q| = sqrt(q q^*) = sqrt(q_0^2 + q_1^2 + q_2^2 + q_3^2)$ is the quaternion length or norm.])
#defbox("Quaternion inverse", [Every non-zero quaternion has a unique inverse $q^(-1) = q^* / (|q|^2)$:
$ q q^* / (|q|^2) = 1 $
For a unit-length quaternion this simplifies to $q^(-1) = q^*$.])

=== Complex numbers and rotations
A complex number in Euler form is $z = rho (cos(theta) + j sin(theta))$. Multiplying two:
$ z_1 z_2 = rho_1 (cos theta_1 + j sin theta_1) rho_2 (cos theta_2 + j sin theta_2) \
  = rho_1 rho_2 (cos(theta_1 + theta_2) + j sin(theta_1 + theta_2)) $
#keypt("Rotation", [Multiplying a complex number by a unit-norm (unit-modulus) complex number has the effect of a rotation. Multiplying by its complex conjugate "undoes" the rotation, aligning the result with the real axis.])

=== Unit-length quaternions
Consider a unit-length quaternion $q = [eta, epsilon]$, with scalar part $eta$ and vector part $epsilon = mat(epsilon_x; epsilon_y; epsilon_z)$. It can be expressed as:
$ q = (cos(theta/2), sin(theta/2) bold(k)) $
where $bold(k)$ is a unit vector:
$ bold(k) = epsilon / (|epsilon|), quad theta = 2 op("atan2")(|epsilon|, eta) $
#keypt("Key fact", [The unit-length quaternion $q = (cos(theta/2), sin(theta/2) bold(k))$ represents a rotation of angle $theta$ about the axis defined by the unit vector $bold(k)$.])

=== Quaternions and rotations
Let $q = [eta, epsilon]$ be a unit quaternion and $p = [0, bold(p)]$ a pure quaternion representing a vector $bold(p)$. The rotated vector $bold(p)'$ is computed by conjugation $bold(p)' = q bold(p) q^*$, yielding a pure quaternion $[0, bold(p)']$. After computation:
$ bold(p)' = (eta^2 - |epsilon|^2) bold(p) + 2 eta (epsilon times bold(p)) + 2 (epsilon dot bold(p)) epsilon $
Substituting $eta = cos(theta/2)$, $epsilon = sin(theta/2) bold(k)$ and $|epsilon|^2 = sin^2(theta/2)$:
$ bold(p)' = (cos^2(theta/2) - sin^2(theta/2)) bold(p) \
  + 2 cos(theta/2) sin(theta/2) (bold(k) times bold(p)) + 2 sin^2(theta/2) (bold(k) dot bold(p)) bold(k) \
  = cos(theta) bold(p) + sin(theta) (bold(k) times bold(p)) + (1 - cos theta)(bold(k) dot bold(p)) bold(k) $
#defbox("Rodrigues' rotation formula", [The formula
$ bold(p)' = cos(theta) bold(p) + sin(theta)(bold(k) times bold(p)) \
  + (1 - cos(theta))(bold(k) dot bold(p)) bold(k) $
describes the rotation of a vector $bold(p)$ by an angle $theta$ about the axis $bold(k)$.])

=== Equivalent rotation matrix
The Rodrigues formula is equivalent to applying a rotation matrix $R_k(theta)$:
$ bold(p)' = R_k(theta) bold(p) $
$ R_k(theta) = mat(k_x^2(1-c_theta)+c_theta, k_x k_y(1-c_theta)-k_z s_theta, k_x k_z(1-c_theta)+k_y s_theta; k_x k_y(1-c_theta)+k_z s_theta, k_y^2(1-c_theta)+c_theta, k_y k_z(1-c_theta)-k_x s_theta; k_x k_z(1-c_theta)-k_y s_theta, k_y k_z(1-c_theta)+k_x s_theta, k_z^2(1-c_theta)+c_theta) $
with $c_theta = cos(theta)$, $s_theta = sin(theta)$.

=== Summary
Given $q = [eta, epsilon] = (cos(theta/2), sin(theta/2) bold(k))$ associated with a rotation of angle $theta$ about unit vector $bold(k)$:
$ bold(k) = epsilon / (|epsilon|), quad theta = 2 op("atan2")(|epsilon|, eta) $
The parameters of a unit-length quaternion correspond to three degrees of freedom, expressed as:
- four numbers $eta, epsilon_x, epsilon_y, epsilon_z$ with the constraint $eta^2 + epsilon_x^2 + epsilon_y^2 + epsilon_z^2 = 1$;
- four numbers $theta, k_x, k_y, k_z$ with the constraint $k_x^2 + k_y^2 + k_z^2 = 1$.

=== From rotation matrix to quaternion
Given $R = mat(r_11, r_12, r_13; r_21, r_22, r_23; r_31, r_32, r_33)$:
$ eta = 1/2 sqrt(r_11 + r_22 + r_33 + 1) $
$ epsilon = 1/2 mat(op("sgn")(r_32 - r_23) sqrt(r_11 - r_22 - r_33 + 1); op("sgn")(r_13 - r_31) sqrt(r_22 - r_33 - r_11 + 1); op("sgn")(r_21 - r_12) sqrt(r_33 - r_11 - r_22 + 1)) $
$ op("sgn")(x) = 1 "if" x >= 0, quad -1 "if" x < 0 $

=== Composition via quaternions
Consider two rotations with unit-length quaternions $q_0$ and $q_1$; the first maps $bold(p)$ to $bold(p)'$, the second maps $bold(p)'$ to $bold(p)''$. With pure quaternions $p = [0, bold(p)]$, $p' = [0, bold(p)']$, $p'' = [0, bold(p)'']$:
$ p' &= q_0 p q_0^* \
  p'' &= q_1 p' q_1^* = q_1 (q_0 p q_0^*) q_1^* \
  &= (q_1 q_0) p (q_0^* q_1^*) = (q_1 q_0) p (q_1 q_0)^* $
The last step uses $(q_1 q_0)^* = q_0^* q_1^*$ (conjugate of a product = product of conjugates in reverse order). The composition of two rotations is thus the product of their quaternions.

=== Operations and advantages
#tbl(3, head: ([Operation], [Rotation matrices], [Unit-quaternions]),
  [Inversion], [$R^(-1) = R^top$], [$q^(-1) = (eta, -epsilon)$],
  [Composition], [$R = R_1 R_2$], [$q = q_1 q_2$],
  [Composition formula], [—], [$q_1 q_2 = (eta_1 eta_2 - epsilon_1 dot epsilon_2, eta_1 epsilon_2 + eta_2 epsilon_1 + epsilon_1 times epsilon_2)$])
- *Inversion*: the inverse of a unit-length quaternion is its conjugate (negate the vector part), much faster than transposing and inverting a matrix.
- *Composition*: two rotations combine by a simple quaternion product, more efficient and numerically stable than matrix multiplication.

=== In summary
- *Compact representation*: four numbers instead of the nine of a rotation matrix.
- *Absence of Gimbal Lock*: continuous, non-singular representation, unlike Euler angles; significant in computer graphics and robotics.
- *Efficient composition*: simple quaternion multiplication, more efficient than matrix multiplication.
- *Direct interpolation*: smooth constant-velocity interpolation between rotations (spherical linear interpolation, slerp), crucial for animations.
- *Non-uniqueness*: a single rotation can be represented by two quaternions, $q$ and $-q$; a minor redundancy that does not demean the practical benefits.

== Homogeneous Transformations

=== Position of a frame in 3D
A rigid body's pose is defined by the position and orientation of a frame attached to it. So far only rotation was considered, ignoring translation (frames with coincident origins); we now return to the general case with both rotation and translation. A point $p_1$ in frame ${1}$ is expressed in frame ${0}$ as:
$ p_0 = o_0^1 + R_1^0 p_1 $

=== Direct and inverted transformation
The inverse is found by isolating $p_1$:
$ R_1^0 p_1 = p_0 - o_0^1 arrow.r.double p_1 = (R_1^0)^(-1)(p_0 - o_0^1) = R_1^(0 top)(p_0 - o_0^1) \
  = R_0^1(p_0 - o_0^1) = R_0^1 p_0 - R_0^1 o_0^1 $
This representation is cumbersome: the inverse involves both a matrix transpose and a matrix-vector product.

=== Homogeneous coordinates (1)
A compact way to represent rotation and translation: create the homogeneous representation $tilde(p)$ of $p$ by appending a coordinate of value 1, $tilde(p) = mat(p; 1)$, and construct a $4 times 4$ homogeneous transformation matrix:
$ A_0^1 = mat(R_1^0, o_0^1; 0^top, 1) $
The transformation of a point from frame ${1}$ to frame ${0}$ is then a single matrix-vector multiplication: $tilde(p)_0 = A_0^1 tilde(p)_1$.

=== Homogeneous coordinates (2)
The coordinate transformation is a simple matrix multiplication $tilde(p)_0 = A_0^1 tilde(p)_1$; the inverse is found by inverting the matrix:
$ tilde(p)_1 = A_1^0 tilde(p)_0 = (A_0^1)^(-1) tilde(p)_0 $
$ A_1^0 = (A_0^1)^(-1) = mat(R_1^(0 top), -R_1^(0 top) o_0^1; 0^top, 1) $

=== Homogeneous coordinates (3)
- Unlike rotation matrices, homogeneous transformations are not orthogonal: for a general homogeneous matrix $A$, $A^(-1) != A^top$.
- The formalism generalizes the properties of the rotation group to include translations.
- A sequence of transformations in the current axes is a simple matrix product: $tilde(p)_0 = A_0^1 A_1^2 dots A_(n-1)^n tilde(p)_n$.
- The set of all homogeneous transformations forms a group called the *special Euclidean group* $S E(3)$, the semi-direct product $S E(3) = RR^3 times.r S O(3)$.

#figure(caption: [Position of a frame in 3D: $p_0 = o_0^1 + R_1^0 p_1$.], [
  #raw("")
  #scale(78%, reflow: true)[
    #canvas({
      import "_geom3d.typ": proj, axis, frameR, rotarc, Rx, Ry, Rz, I3, mv, vadd, smul
      let o = (1.4, 0.8, 0.5)
      frameR((0,0,0), I3, $x_0$, $y_0$, $z_0$, len: 1.2)
      frameR(o, I3, $x_1$, $y_1$, $z_1$, c: rgb("#1B4965"), len: 1.0)
      axis((0,0,0), o, $o_0^1$, c: rgb("#B3261E"), dash: "dashed", len: 1.0)
      axis(o, (0.7, -0.3, 0.2), $p_1$, c: rgb("#3A7D44"), len: 1.0)
    })
  ]
])

== Matlab Examples for Homogeneous Transformations

=== homogeneousTrans
An homogeneous transformation matrix $A = mat(R(phi, theta, psi), O_1^0; O, 1)$:
```matlab
% homogeneous transformation
function [T] = homogeneousTrans(phi, theta, psi, Ov)
  R = eulerRot(phi, theta, psi);
  T = [R, Ov;
       zeros(1,3), 1];
end
```

=== Test scripts
`scriptDrawHom` uses the function and plots the translated/rotated frame:
```matlab
T = homogeneousTrans(0, 0, pi/4, [1;1;1]);
O1 = T * [0;0;0;1];
v1 = T * [1;0;0;1];  v2 = T * [0;1;0;1];  v3 = T * [0;0;1;1];
```
`scriptDrawHom1` uses built-in Matlab functions instead:
```matlab
T = makehgtform('translate',[1,1,1],'zrotate',pi/4);
```

=== Drawing reference frames
`scriptTestTriad` uses a community file `triad` to draw axis frames:
```matlab
axs = axes; view(3); daspect([1 1 1]);
h = triad('Parent', axs);   % frame coincident with the current axes
h1 = triad('Parent', h, 'Matrix', ...
     makehgtform('translate',[1,1,1],'xrotate',pi/4), ...
     'linewidth',3,'linestyle','--');
```

=== Matlab transformation objects
Matlab provides an object to create a transformation, link it to the current axis, and define child objects transformed accordingly. `scriptTransformTest`:
```matlab
axs = axes('XLim',[-1.5 1.5],'YLim',[-1.5 1.5],'ZLim',[-1.5 1.5]);
view(3); grid on;
t = hgtransform('Parent', axs);          % empty transformation
[x,y,z] = cylinder([1,1],100);
h = surface(x,y,z,'FaceColor','red');
set(h,'Parent',t);                       % link cylinder to t
pause
Rz = makehgtform('xrotate',2*pi/3);   % rotation matrix
set(t,'Matrix',Rz);   % apply to t and children
drawnow;              % update children objects
```
`scriptTransformTriads` draws two frames and animates the second by rotating about $z$:
```matlab
t = hgtransform('Parent', axs); h = triad('Parent', t);
h1 = triad('Parent', h, 'Matrix', ...
     makehgtform('translate',[1,1,1],'xrotate',pi/4));
for angle = 0:0.5:360
  Rz = makehgtform('zrotate', deg2rad(angle));
  set(t,'Matrix',Rz); drawnow;
end
```

== Some questions for you

#list(
  [Rotation matrix about the $x$-axis by $gamma$: $R_x(gamma) = mat(1,0,0; 0,cos gamma,-sin gamma; 0,sin gamma,cos gamma)$],
  [Difference current vs fixed axes: *current axes* apply each successive rotation relative to the moving frame (post-multiplication); *fixed axes* apply rotations relative to the original fixed frame (pre-multiplication).],
  [Matlab rotation about the $y$-axis: `yRot(beta)` with `Ry = [cos(beta),0,sin(beta); 0,1,0; -sin(beta),0,cos(beta)]`.],
  [A vector rotated first by $R_y(phi)$ then by $R_z(theta)$: $R = R_y(phi) R_z(theta)$.],
  [Order matters because rotation matrices do not generally commute: $R_a R_b != R_b R_a$; changing the order changes the final orientation.],
  [For fixed axes we pre-multiply because each new rotation is applied relative to the original fixed frame.],
  [A 3D rotation has *3* independent parameters: a $3 times 3$ matrix (9 values) is reduced by orthogonality and unit determinant to 3 degrees of freedom.],
  [Euler angles are a sequence of 3 rotations about axes; in aeronautics: roll $(psi)$, pitch $(theta)$, yaw $(phi)$ with fixed axes, $R = R_z(phi) R_y(theta) R_x(psi)$.],
  [Gimbal lock in RPY: at pitch $theta = plus.minus pi/2$ the roll and yaw axes align, losing one degree of freedom; different angle sets map to the same rotation.],
  [Axis–angle form: a unit vector $bold(k) = (k_x, k_y, k_z)$ and an angle $theta$, giving $R_k(theta)$.],
  [Rodrigues' rotation formula: $bold(p)' = cos(theta) bold(p) + sin(theta)(bold(k) times bold(p)) + (1 - cos(theta))(bold(k) dot bold(p)) bold(k)$.],
  [Axis–angle avoids gimbal lock because it locally represents rotations without singularities: no two axes can align to cause a degree-of-freedom loss.],
  [Quaternion: $q = q_0 + q_1 i + q_2 j + q_3 k = [q_0, bold(q)]$; $q_0$ scalar part, $bold(q) = (q_1, q_2, q_3)$ vector part.],
  [Conjugate $q^* = q_0 - q_1 i - q_2 j - q_3 k$; inverse $q^(-1) = q^* / (|q|^2)$ (for unit quaternions $q^(-1) = q^*$).],
  [If $q_1, q_2$ represent rotations, their composition is $q = q_1 q_2$; applied to $bold(p)$: $bold(p)' = q_1 (q_2 p q_2^*) q_1^* = (q_1 q_2) p (q_1 q_2)^*$.],
  [Two advantages over Euler angles in robotics: avoid gimbal lock (non-singular representation); efficient composition and interpolation (slerp).],
  [Homogeneous coordinates represent rotation and translation in a single $4 times 4$ matrix.],
  [General homogeneous transformation matrix: $A = mat(R, o; 0^top, 1)$ with $R$ rotation matrix and $o$ translation vector.],
  [Inverse of a homogeneous transformation: $A^(-1) = mat(R^top, -R^top o; 0^top, 1)$.],
  [Homogeneous transformations form the Special Euclidean group $S E(3) = RR^3 times.r S O(3)$.],
)
