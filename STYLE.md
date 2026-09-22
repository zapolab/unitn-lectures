# SCRITTURA DEL FILE TYPST

## Vincoli tecnici
- Typst ≥0.12 (target 0.15.x). **Offline**: niente `#import "@preview/..."`, solo Typst standard.
- Font ammessi (CLI embedded): `New Computer Modern`, `New Computer Modern Math`, `DejaVu Sans Mono`, `Libertinus Serif`. Niente emoji/Unicode esotico → simboli matematici sempre in math mode (`$arrow.r$`, `$alpha$`, ecc.).
- Nessun testo/commento fuori dal `.typ`.

## Layout: A4, due colonne, massima densità
Preamble di base (adatta solo se la compilazione lo richiede):

```typst
#let ink=rgb("#1F2328"); #let primary=rgb("#1B4965"); #let accent=rgb("#B45309")
#let defcol=rgb("#2A6F6A"); #let danger=rgb("#9B1C1C"); #let panel=rgb("#F2F5F7")
#let headbg=rgb("#E9EFF3"); #let rule=rgb("#C7D3DB"); #let muted=rgb("#5A6B76")

#set page(paper: "a4", margin: (x: 13mm, top: 12mm, bottom: 13mm), columns: 2,
  numbering: "1",
  header: context {
    set text(size: 6.6pt, fill: muted)
    block(width: 100%)[
      #grid(columns: (1fr, auto), [<TITOLO LEZIONE>], [<corso>-<n.lezione>])
      #v(0.75pt) #line(length: 100%, stroke: 0.4pt + rule)
    ]
  })

#set text(font: "New Computer Modern", size: 8.4pt, lang: "it", fill: ink, hyphenate: true)
#set par(justify: true, leading: 0.55em, spacing: 0.5em, first-line-indent: 0em)
#show raw: set text(font: "DejaVu Sans Mono", size: 7pt)
#set list(indent: 0.85em, marker: [•], spacing: 0.6em, tight: true)
#set enum(indent: 0.85em, spacing: 0.6em, tight: true)
#show list.item: set par(leading: 0.42em, spacing: 0.35em)
#show enum.item: set par(leading: 0.42em, spacing: 0.35em)

// blocco indivisibile: slitta intero se non entra
#let keep(body) = block(breakable: false, width: 100%, body)

// titoli mai orfani
#set heading(numbering: none)
#show heading: it => block(breakable: false, sticky: true, above: 0.8em, below: 0.35em)[
  #text(size: if it.level<=1{11pt} else if it.level==2{9.4pt} else {8.6pt},
        weight: "bold", fill: primary, it.body)
  #if it.level<=1 [#v(1.5pt) #line(length: 100%, stroke: 0.7pt + rule)]
]

// box indivisibili
#let callout(title, body, col: accent, bg: panel) = keep(block(
  width: 100%, inset: (x: 4pt, y: 4pt), radius: 1pt, fill: bg,
  stroke: (top: 0pt+col, right: 0pt+col, bottom: 0pt+col, left: 1.4pt+col))[
  #text(size: 7.9pt, weight: "bold", fill: col)[#title]#h(0.35em)#body
])
#let keypt(t,b) = callout(t,b, col: accent, bg: rgb("#FDF4E7"))
#let defbox(t,b) = callout(t,b, col: defcol, bg: rgb("#EDF5F4"))
#let warn(t,b)   = callout(t,b, col: danger, bg: rgb("#FBEDED"))

// tabelle indivisibili, solo filetti orizzontali
#let cmp(cols, ..cells) = keep({
  let c = cells.pos()
  grid(columns: cols, inset: (x: 4pt, y: 3pt), align: left,
    stroke: (x,y) => if y>0 {(top: 0.35pt+rule)} else {none},
    ..c.enumerate().map(((i,v)) => if calc.rem(i,cols)==0 {text(weight:"bold", fill:primary, v)} else {v}))
})
#let tbl(cols, head: (), ..cells) = keep({
  let c = cells.pos(); let hs = head
  grid(columns: cols, inset: (x: 4pt, y: 3pt), align: left,
    fill: (x,y) => if hs != () and y==0 {headbg} else {none},
    stroke: (x,y) => if y>0 {(top: 0.35pt+rule)} else {none},
    ..if hs != () {hs.map(v => text(weight:"bold", fill:primary, v))} else {()},
    ..c)
})

#set figure(gap: 4pt, supplement: [Fig.], numbering: "1")
#show figure.caption: set text(size: 6.9pt, fill: muted)
```

Opzionale — blocco titolo a piena larghezza in cima:
```typst
#place(top, scope: "parent", float: true)[
  #text(14.5pt, weight: "bold", fill: primary)[<TITOLO LEZIONE>]
  #v(2pt) #text(7.3pt, fill: muted)[<corso> — Lezione <n>]
  #v(4pt) #line(length: 100%, stroke: 1pt + primary)
]
```
Niente indice/elenco argomenti iniziale: si parte diretti col contenuto.

## Struttura del contenuto
- Segui la struttura delle slide (titoli capitolo → `=`/`==`); non inventare organizzazione.
- **Ordine = ordine dei divider del PDF.** Non riorganizzare per tema, non anticipare capitoli. Eccezione: antidup (Fase 3) — dettagli nuovi su concetti già visti si accodano alla sezione originale, senza spostare interi capitoli.
- `==` macro-argomento, `===` concetto puntuale, senza riferimenti di pagina.
- Un concetto per sezione; dettagli aggiuntivi trovati dopo → si accodano.
- Stile **telegrafico completo**: zero riempitivi ("in questa slide...", "come già detto"), frasi brevi/frammenti ok, niente ripetizione del titolo nel corpo.
- `#defbox` → definizioni/teoremi/formule chiave, testo il più fedele possibile alle slide.
- `#keypt` → solo se le slide stesse evidenziano attenzione/errori tipici/punti d'esame (non aggiungerne di tua iniziativa).
- `#cmp`/`#tbl` → confronti, classificazioni, cicli (più compatti di elenchi puntati).
- Parti di presentazione/amministrazione del corso (docenti, orari, voti, FAQ): non riassumerle, non farle comparire.
- Elenchi delle slide: conservati integralmente (7 punti → 7 punti, compressi ma non tagliati).
- Numeri, formule, unità, notazione, nomi: copiati esatti. Dubbi → `#warn([DA VERIFICARE], ...)`.
- Lingua del riassunto = lingua delle slide; terminologia tecnica resta nella lingua originale (di norma inglese), mai tradotta.
- Didascalie figure: dal PDF o descrizione oggettiva, mai inventate, mai numeri di pagina.
- Codice/espressioni: inline con backtick; blocchi con ` ```typst ` non indentati.

## Lunghezza (compressione)
Dipende dal **contenuto**, non dal numero di slide — slide vuote/foto non contano, slide dense (definizioni, elenchi, formule, tabelle, figure) sì.
- A parità di contenuto → lunghezza comparabile.
- Indicativo: ~3–5 pagine A4 a due colonne per lezione media; 6–8 se molto densa; 2–3 se poco tecnica. Sono indizi, non vincoli.
- Vincolo reale: **zero contenuto perso** — tutte le definizioni, elenchi, formule, tabelle, figure devono comparire integralmente.
- Non gonfiare per raggiungere pagine, non tagliare per rientrare in un rapporto: unica misura è il contenuto.

Come comprimere:
- fondi punti quasi sinonimi in un unico punto con sotto-voci separate da `;`;
- preferisci `#cmp`/`#tbl` a elenchi per confronti/proprietà;
- elimina connettivi discorsivi e ripetizioni del titolo;
- `===` solo se il concetto ha contenuto autonomo reale;
- `#defbox`/`#keypt` solo dove le slide li giustificano (costosi in spazio);
- figure ridisegnate, larghezza colonna, didascalia di una riga.

Per evitare spezzoni:
- tabelle/box/figure sono già indivisibili (`keep`) — non stiparci contenuto che non entra, lascia slittare il blocco intero;
- avvolgi in `#keep(...)` anche elenchi/paragrafi brevi (≤4 righe) a rischio taglio a fondo colonna;
- non usare `#keep` su blocchi alti quanto una colonna intera (creerebbe buchi bianchi) — in quel caso dividi tu il contenuto in blocchi più piccoli e coerenti.