# SCRITTURA DEL FILE TYPST

## Vincoli tecnici
- Typst 0.15.x. Pacchetti `@preview` (versione pinnata esatta): il primo `compile` li scarica, poi restano in cache. Import nel `.typ` della lezione, non nel preamble.
- Font ammessi (CLI embedded): `New Computer Modern`, `New Computer Modern Math`, `DejaVu Sans Mono`, `Libertinus Serif`. Niente emoji/Unicode esotico → simboli matematici sempre in math mode (`$arrow.r$`, `$alpha$`, ecc.).
- Nessun testo/commento fuori dal `.typ`.
- **Figure sempre vettoriali Typst** (pattern o pacchetti); niente raster.

## Pacchetti consigliati
Elenco per evitare fetch ripetuti. Pinna la versione; sintassi/opzioni: manualistica solo se serve.

| pacchetto | versione | cosa fa | import |
|-----------|----------|---------|--------|
| `fletcher` | 0.5.8 | diagrammi nodi+archi: flowchart, architetture, state machine, UML, alberi | `#import "@preview/fletcher:0.5.8": diagram, node, edge` |
| `cetz` | 0.5.2 | disegno vettoriale stile TikZ: canvas, linee, forme, grafi custom | `#import "@preview/cetz:0.5.2"` |
| `cetz-plot` | 0.1.4 | grafici di dati (line/bar/scatter) su cetz | `#import "@preview/cetz-plot:0.1.4"` |
| `tablex` | 0.0.9 | tabelle avanzate: celle unite, allineamenti, spezzabili | `#import "@preview/tablex:0.0.9": tablex, cellx, rowspanx, colspanx` |
| `lovelace` | 0.3.1 | pseudocodice/algoritmi | `#import "@preview/lovelace:0.3.1": *` |
| `showybox` | 2.0.4 | box stilizzati (oltre a `defbox/keypt`) | `#import "@preview/showybox:2.0.4": showybox` |

## Layout: A4, due colonne, massima densità
Definito in `/workspace/tools/preamble.typ`. Nella dir lezione:
1. `cp /workspace/tools/preamble.typ /workspace/lectures/<corso>/source/<lezione>/_preamble.typ`;
2. in testa al `.typ`:

```typst
#import "_preamble.typ": *
#show: doc.with(title: "<TITOLO LEZIONE>", label: "<corso>-<lezione>")
#titleblock("<TITOLO LEZIONE>", "<corso> — Lezione <n>")
```

`doc` applica page/testo/heading/figure. **Non ricopiare il preamble.** Niente indice iniziale: si parte dal contenuto.

## Helper (firma + esempio)
Il preamble si copia, non si legge: qui ci sono tutte le firme. Non sondarle per tentativi.

- `doc.with(title: "…", label: "<corso>-<lezione>")` — applica il layout al body.
- `titleblock(title, sub)` — blocco titolo a piena larghezza, obbligatorio in cima.
  ```typst
  #titleblock("Reti di calcolatori", "RETI — Lezione 3")
  ```
- `keep(body)` — rende indivisibile un blocco (usalo su elenchi/paragrafi brevi a rischio taglio).
  ```typst
  #keep[#list([primo], [secondo])]
  ```
- `callout(title, body)` / `keypt(title, body)` / `defbox(title, body)` / `warn(title, body)` — box colorati.
  ```typst
  #defbox("Definizione", [Un automa è …])
  #warn("DA VERIFICARE", [valore illeggibile, p. 12])
  ```
- `cmp(cols, ..cells)` — confronto a griglia, prima cella di ogni riga in grassetto. `cols` è un **array** di specifiche di colonna; è tollerato anche un intero = N colonne `1fr`.
  ```typst
  #cmp((1fr, 1fr))[Protocollo][TCP][UDP][Affidabile][Sì][No]
  #cmp(2)[A][B][C][D]        // forma breve, 2 colonne
  ```
- `tbl(ncols, head: (), ..cells)` — tabella con intestazione (riga di testa su sfondo).
  ```typst
  #tbl(3, head: ([Nome], [Tipo], [Uso]), [TCP], [stream], [web], [UDP], [datagram], [realtime])
  ```
- `asciifig(text, cap)` — figura ASCII (solo strutture semplici, max ~56 caratteri di larghezza).
  ```typst
  #asciifig("main() --ISR--> main() --> Time", [Timeline foreground/ISR.])
  ```

## Pattern riutilizzabili
Mattoni canonici, testati. Usali; non reinventarli.

- `asciifig(text, cap)` — `raw(text, block: true)` + didascalia di una riga.
- `titleblock(title, sub)` — v. sopra.
- **fletcher** per architetture/flowchart (scalato dentro la colonna):
  ```typst
  #import "@preview/fletcher:0.5.8": diagram, node, edge
  #scale(75%, reflow: true)[#figure(caption: [..], diagram(
    node-stroke: 0.7pt + rgb("#1B4965"), edge-stroke: 0.8pt + rgb("#2E7D32"), spacing: 1.4em,
    node((0,0), fill: rgb("#2E9E28"))[Start],
    node((1,0), [Decision]),
    edge((0,0), (1,0), "->", [label]),
  ))]
  ```
- `proj`/`triad`/`arc3` — frame 3D isometrico su `cetz` per geometria/robotica; helper locali alla lezione.
  ```typst
  #let proj(p) = ((p.at(0) - p.at(1)) * 0.82, p.at(2) - (p.at(0) + p.at(1)) * 0.42)
  #let triad(o, ex, ey, ez, lx, ly, lz, c: black, dash: none, len: 1.0) = {
    let oo = proj(o)
    let st = if dash == none { (stroke: c, mark: (end: ">", fill: c)) }
             else { (stroke: (paint: c, dash: dash), mark: (end: ">", fill: c)) }
    draw.line(oo, proj(vadd(o, smul(len, ex))), ..st)
    draw.content(proj(vadd(o, smul(len * 1.16, ex))), lx, fill: c)
  }
  #canvas({ triad((0,0,0), (2,0,0), (0,2,0), (0,0,2), $x_0$, $y_0$, $z_0$)
             draw.line(..arc3((0,0,1), (1,0,0), 40deg, 0.7), mark: (end: ">")) })
  ```
- Diagrammi/grafi complessi (architetture, flowchart, alberi, UML): `fletcher`/`cetz`, niente coordinate assolute a mano. Diagramma più largo della colonna → `#scale(75%, reflow: true)[#figure(...)]`.
- Etichette/frecce: stesse del PDF; nessun contenuto inventato.

### Numerazione figure
`asciifig` (e ogni `raw` dentro un `#figure`) usa un contatore separato da `#figure`: mescolarli duplica i numeri. In **ogni** `#figure` con fletcher/cetz aggiungi un `#raw("")` (vuoto) nel body, così entra nello stesso contatore:
```typst
#figure(caption: [..], [#raw("") #scale(72%, reflow: true)[#diagram(…)]])
```

## Struttura del contenuto
- Segui la struttura delle slide (titoli capitolo → `=`/`==`); non inventare organizzazione.
- **Ordine = ordine dei divider del PDF**; eccezione: antidup (Fase 3) — i dettagli nuovi su concetti già visti si accodano alla sezione originale, senza spostare capitoli.
- `==` macro-argomento, `===` concetto puntuale, senza riferimenti di pagina. Un concetto per sezione.
- Stile **telegrafico completo**: zero riempitivi ("in questa slide...", "come già detto"), frammenti ok, niente ripetizione del titolo nel corpo.
- `#defbox` → definizioni/teoremi/formule chiave, fedeli alle slide; `#keypt` → solo se le slide evidenziano attenzione/errori/punti d'esame; `#cmp`/`#tbl` → confronti/classificazioni/cicli (più compatti degli elenchi).
- Elenchi: integrali per la parte **in-scope** (v. `PROMPT.md` §Definizioni), compressi ma non tagliati.
- Codice/espressioni: inline con backtick; blocchi con ` ```typst ` (o linguaggio reale) non indentati. `raw` è a 6.4pt: spezza le righe lunghe (~62 caratteri max), senza alterare il contenuto.
- Didascalie figure: dal PDF o descrizione oggettiva, mai inventate, mai numeri di pagina.

## Lunghezza (compressione)
Dipende dal **contenuto**, non dal numero di slide: slide vuote/foto non contano, slide dense (definizioni, elenchi, formule, tabelle, figure) sì.
- A parità di contenuto → lunghezza comparabile. Indicativo: ~3–5 pagine A4 a due colonne per lezione media; 6–8 se molto densa; 2–3 se poco tecnica. Indizi, non vincoli.
- Vincolo reale: **zero contenuto in-scope perso**. Non gonfiare, non tagliare per rientrare in un rapporto.
- Non forzare la compressione se resta un solo paragrafo isolato in una nuova pagina: accetta la pagina in più.

Come comprimere:
- fondi punti quasi sinonimi con sotto-voci separate da `;`;
- preferisci `#cmp`/`#tbl` a elenchi per confronti/proprietà;
- elimina connettivi e ripetizioni del titolo;
- `===` solo se il concetto ha contenuto autonomo reale;
- `#defbox`/`#keypt` solo dove le slide li giustificano;
- figure ridisegnate, larghezza colonna, didascalia di una riga.

Per evitare spezzoni:
- tabelle/box/figure sono già indivisibili (`keep`): non stiparci contenuto che non entra, lascia slittare il blocco intero;
- avvolgi in `#keep(...)` elenchi/paragrafi brevi (≤4 righe) a rischio taglio;
- non usare `#keep` su blocchi alti quanto una colonna (creerebbe buchi bianchi): dividi tu in blocchi più piccoli e coerenti.