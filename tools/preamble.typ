// _preamble.typ — preamble condiviso + pattern diagrammi riutilizzabili.
// Uso nella lezione:
//   #import "_preamble.typ": *
//   #show: doc.with(title: "<TITOLO>", label: "<corso>-<lezione>")
//   #titleblock("<TITOLO>", "<corso> — Lezione <n>")   // opzionale
//   <contenuto>
// Solo Typst standard, nessuna dipendenza esterna.

// ---- colori ----
#let ink=rgb("#1F2328"); #let primary=rgb("#1B4965"); #let accent=rgb("#B45309")
#let defcol=rgb("#2A6F6A"); #let danger=rgb("#9B1C1C"); #let panel=rgb("#F2F5F7")
#let headbg=rgb("#E9EFF3"); #let rule=rgb("#C7D3DB"); #let muted=rgb("#5A6B76")

// ---- blocchi indivisibili ----
#let keep(body) = block(breakable: false, width: 100%, body)

// ---- box indivisibili ----
#let callout(title, body, col: accent, bg: panel) = keep(block(
  width: 100%, inset: (x: 4pt, y: 4pt), radius: 1pt, fill: bg,
  stroke: (top: 0pt+col, right: 0pt+col, bottom: 0pt+col, left: 1.4pt+col))[
  #text(size: 7.9pt, weight: "bold", fill: col)[#title]#h(0.35em)#body
])
#let keypt(t,b) = callout(t,b, col: accent, bg: rgb("#FDF4E7"))
#let defbox(t,b) = callout(t,b, col: defcol, bg: rgb("#EDF5F4"))
#let warn(t,b)   = callout(t,b, col: danger, bg: rgb("#FBEDED"))

// ---- tabelle indivisibili, solo filetti orizzontali ----
#let cmp(cols, ..cells) = keep({
  let c = cells.pos(); let n = cols.len()
  grid(columns: cols, inset: (x: 4pt, y: 3pt), align: left,
    stroke: (x,y) => if y>0 {(top: 0.35pt+rule)} else {none},
    ..c.enumerate().map(((i,v)) => if calc.rem(i,n)==0 {text(weight:"bold", fill:primary, v)} else {v}))
})
#let tbl(cols, head: (), ..cells) = keep({
  let c = cells.pos(); let hs = head
  grid(columns: cols, inset: (x: 4pt, y: 3pt), align: left,
    fill: (x,y) => if hs != () and y==0 {headbg} else {none},
    stroke: (x,y) => if y>0 {(top: 0.35pt+rule)} else {none},
    ..if hs != () {hs.map(v => text(weight:"bold", fill:primary, v))} else {()},
    ..c)
})

// ---- blocco titolo a piena larghezza (opzionale) ----
#let titleblock(title, sub) = place(top, scope: "parent", float: true)[
  #text(14.5pt, weight: "bold", fill: primary)[#title]
  #v(2pt) #text(7.3pt, fill: muted)[#sub]
  #v(4pt) #line(length: 100%, stroke: 1pt + primary)
]

// ---- pattern diagrammi ----

// box che riempie la cella di griglia (blocchi/schemi)
#let gb(body, fill: rgb("#FFFFFF"), sz: 5.6pt, pad: 2pt) = block(
  width: 100%, inset: (x: 2.5pt, y: pad), radius: 1.5pt, fill: fill,
  stroke: 0.5pt + ink, text(size: sz, align(center, body)))

// flusso orizzontale: frecce inserite automaticamente tra i blocchi
#let flow(..items) = {
  let a = items.pos(); let cells = ()
  for (i, x) in a.enumerate() {
    if i > 0 { cells.push($arrow.r$) }
    cells.push(x)
  }
  grid(columns: range(cells.len()).map(_ => auto), column-gutter: 4pt, align: center, ..cells)
}

// flusso verticale: frecce discendenti tra i blocchi
#let vflow(..items) = {
  let a = items.pos(); let rows = ()
  for (i, x) in a.enumerate() {
    if i > 0 { rows.push($arrow.b$) }
    rows.push(x)
  }
  grid(columns: 1, row-gutter: 2pt, align: center, ..rows)
}

// cella di un array/buffer (es. circular buffer)
#let cellbox(v, fill: white) = block(
  width: 100%, inset: (x: 0pt, y: 3pt), stroke: 0.5pt + rule, fill: fill,
  text(size: 6pt, align(center, v)))

// figura ASCII: raw monospazio + didascalia, una riga
#let asciifig(text, cap) = figure(raw(text, block: true), caption: cap)

// ---- setup documento (set/show scoped al body) ----
#let doc(title: "", label: "", body) = {
  set page(paper: "a4", margin: (x: 13mm, top: 12mm, bottom: 13mm), columns: 2,
    numbering: "1",
    header: context {
      set text(size: 6.6pt, fill: muted)
      block(width: 100%)[
        #grid(columns: (1fr, auto), [#title], [#label])
        #v(0.75pt) #line(length: 100%, stroke: 0.4pt + rule)
      ]
    })
  set text(font: "New Computer Modern", size: 8.4pt, lang: "it", fill: ink, hyphenate: true)
  set par(justify: true, leading: 0.55em, spacing: 0.5em, first-line-indent: 0em)
  show raw: set text(font: "DejaVu Sans Mono", size: 6.4pt)
  set list(indent: 0.85em, marker: [•], spacing: 0.6em, tight: true)
  set enum(indent: 0.85em, spacing: 0.6em, tight: true)
  show list.item: set par(leading: 0.42em, spacing: 0.35em)
  show enum.item: set par(leading: 0.42em, spacing: 0.35em)

  set heading(numbering: none)
  show heading: it => block(breakable: false, sticky: true, above: 0.8em, below: 0.35em)[
    #text(size: if it.level<=1 {11pt} else if it.level==2 {9.4pt} else {8.6pt},
          weight: "bold", fill: primary, it.body)
    #if it.level<=1 [#v(-0.7em) #line(length: 100%, stroke: 0.7pt + rule)]
  ]

  set figure(gap: 4pt, supplement: [Fig.], numbering: "1")
  show figure.caption: set text(size: 6.9pt, fill: muted)

  body
}
