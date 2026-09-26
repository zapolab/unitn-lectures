// cetz-boxes — blocchi etichettati su cetz (architetture, schemi a blocchi).
// tipo: modulo. Copia in _cetz-boxes.typ, poi:
//   #import "_cetz-boxes.typ": cbox
//   #canvas({ cbox(x, y, w, h, [testo]); ... })
// Coordinate in unità canvas cetz; y cresce verso l'alto. Richiede cetz 0.5.2.
// Testo su più righe: usa " \ " come linebreak dentro il content.
#import "@preview/cetz:0.5.2": canvas, draw

#let cbox(x, y, w, h, t, fs: 5.5pt, fill: none, stroke: 0.5pt + rgb("#1B4965")) = {
  draw.rect((x, y), (x + w, y + h), fill: fill, stroke: stroke)
  draw.content((x + w / 2, y + h / 2), text(size: fs, t))
}