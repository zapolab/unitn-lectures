// geom3d.typ — pattern (modulo) 3D isometrico su cetz.
// Uso: copia in _geom3d.typ nella dir lezione, poi:  #import "_geom3d.typ": *
// I nomi pubblici (proj, vadd, smul, mv, I3, Rx/Ry/Rz, axis, frameR, rotarc)
// e canvas/draw sono ri-esportati da questo modulo.
// L'arc di cetz richiede start < stop: rotarc normalizza il verso.

#import "@preview/cetz:0.5.2": canvas, draw

// proiezione isometrica
#let proj(p) = ((p.at(0) - p.at(1)) * 0.82, p.at(2) - (p.at(0) + p.at(1)) * 0.42)

// algebra vettoriale (in cetz la somma diretta di tuple va in panico: usa vadd)
#let vadd(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1), a.at(2) + b.at(2))
#let smul(s, a) = (s * a.at(0), s * a.at(1), s * a.at(2))

// matrice 3x3 per vettore
#let mv(R, v) = (
  R.at(0).at(0) * v.at(0) + R.at(0).at(1) * v.at(1) + R.at(0).at(2) * v.at(2),
  R.at(1).at(0) * v.at(0) + R.at(1).at(1) * v.at(1) + R.at(1).at(2) * v.at(2),
  R.at(2).at(0) * v.at(0) + R.at(2).at(1) * v.at(1) + R.at(2).at(2) * v.at(2),
)

// matrici di rotazione 3x3 (angle Typst)
#let I3 = ((1, 0, 0), (0, 1, 0), (0, 0, 1))
#let Rx(t) = ((1, 0, 0), (0, calc.cos(t), -calc.sin(t)), (0, calc.sin(t), calc.cos(t)))
#let Ry(t) = ((calc.cos(t), 0, calc.sin(t)), (0, 1, 0), (-calc.sin(t), 0, calc.cos(t)))
#let Rz(t) = ((calc.cos(t), -calc.sin(t), 0), (calc.sin(t), calc.cos(t), 0), (0, 0, 1))

// asse orientato con punta e etichetta
#let axis(o, v, l, c: rgb("#1B4965"), dash: none, len: 1.0) = {
  let oo = proj(o)
  let e = proj(vadd(o, smul(len, v)))
  if dash == none {
    draw.line(oo, e, stroke: c, mark: (end: ">", fill: c))
  } else {
    draw.line(oo, e, stroke: (paint: c, dash: dash), mark: (end: ">", fill: c))
  }
  draw.content(proj(vadd(o, smul(len * 1.24, v))), l, fill: c)
}

// frame ruotato: o origine, R matrice 3x3, lx/ly/lz etichette assi
#let frameR(o, R, lx, ly, lz, c: rgb("#1B4965"), dash: none, len: 1.0) = {
  axis(o, mv(R, (1, 0, 0)), lx, c: c, dash: dash, len: len)
  axis(o, mv(R, (0, 1, 0)), ly, c: c, dash: dash, len: len)
  axis(o, mv(R, (0, 0, 1)), lz, c: c, dash: dash, len: len)
}

// arco di rotazione da a a b attorno a o (a, b NON paralleli all'asse)
#let rotarc(o, a, b, label, r: 0.5, c: rgb("#B3261E")) = {
  let oo = proj(o)
  let pa = proj(vadd(o, a))
  let pb = proj(vadd(o, b))
  let a1 = calc.atan2(pa.at(1) - oo.at(1), pa.at(0) - oo.at(0))
  let a2 = calc.atan2(pb.at(1) - oo.at(1), pb.at(0) - oo.at(0))
  let d = a2 - a1
  if d > 180deg { d -= 360deg }
  if d < -180deg { d += 360deg }
  let s = a1
  let e = a1 + d
  if e < s { let t = s; s = e; e = t }
  draw.arc(oo, start: s, stop: e, radius: r, stroke: c, mark: (end: ">", fill: c))
  let m = s + (e - s) / 2
  draw.content((oo.at(0) + (r + 0.18) * calc.cos(m), oo.at(1) + (r + 0.18) * calc.sin(m)), label, fill: c)
}
