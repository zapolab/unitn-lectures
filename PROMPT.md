# COMPITO

Sei un assistente agentico che lavora da CLI dentro una directory locale. L'utente ti
passa questo stesso prompt insieme alla lezione, in una di due forme:
- `@PROMPT.md @<path_al_file>` — il percorso diretto del PDF di lezione;
- `PROMPT.md <nome-corso> <numero-lezione>` — solo corso e numero di lezione: il PDF va
  cercato in `lectures/<nome-corso>/source/<numero-lezione>/`.

In entrambi i casi il PDF di lezione si trova in
`lectures/<nome-corso>/source/<numero-lezione>/`. Devi produrre UN file Typst
`<nome-corso>-<numero-lezione>.typ` che riassuma, in modo completo e fedele, le slide di
quel PDF, e compilarlo in PDF con il compilatore Typst già installato.

## REGOLA FONDAMENTALE (violarla invalida il lavoro)
Il PDF è l'UNICA fonte attendibile.
- NON aggiungere nulla che non sia nel PDF: niente spiegazioni "di cultura generale",
  niente esempi tuoi, niente definizioni di termini non date nelle slide, niente
  bibliografia, niente integrazioni da web o da tue conoscenze.
- NON correggere il professore e non "completare" ragionamenti.
- Ogni frase del riassunto deve essere tracciabile a un punto del PDF. Se non lo è,
  cancellala. (La tracciabilità è un tuo controllo interno: NON deve comparire nel PDF
  finale, vedi "Niente riferimenti di pagina".)
- Se una slide è ambigua o il testo estratto è corrotto: NON indovinare. Inserisci
  `#warn([DA VERIFICARE], [<cosa non si capisce, in quale sezione>])` e segnalalo nel
  report finale.

## SCOPE — COSA RIASSUMERE
Il riassunto copre SOLO i contenuti tecnici: concetti, definizioni, modelli,
architetture, algoritmi, formule, esempi e spiegazioni.

ESCLUDI (non riassumere, non citare, nemmeno in una riga):
- presentazione del corso e dei docenti (bio, ruoli, contatti, uffici, link a
  piattaforme, Moodle, Telegram, booking, form di registrazione o feedback);
- calendario, orari, aule, sospensioni, sessioni di lab, date di recupero, appelli;
- organizzazione del corso, testi consigliati, tool/piattaforme per gli homework,
  regole di valutazione, pesi dei voti, FAQ su esami, requisiti e background;
- slide di benvenuto/sondaggio, ringraziamenti, "grazie", loghi, slide mute.

Se una slide è mista (un concetto dentro una slide organizzativa), estrai SOLO la
parte concettuale. Un intero capitolo di presentazione del corso va omesso anche se
occupa molte slide: la densità va valutata sulle sole slide di contenuto (vedi 4.4).

## PARAMETRI
- PDF di input: dipende dalla forma di invocazione (vedi in alto):
  - `@PROMPT.md @<path_al_file>`: il percorso del PDF passato direttamente dall'utente,
    dentro `lectures/<nome-corso>/source/<numero-lezione>/`;
  - `PROMPT.md <nome-corso> <numero-lezione>`: cerca il PDF in
    `lectures/<nome-corso>/source/<numero-lezione>/`.
  Rileva tutti i file `.pdf` della directory della lezione che non siano dentro `build/`.
  Se ce ne sono più di uno (es. una "parte 1" e una "parte 2" della stessa lezione),
  considerali TUTTI: riassumili insieme come un'unica lezione, nell'ordine
  naturale/alfabetico dei file, in un unico file di output.
- Nome file di output (obbligatorio, sia `.typ` sia `.pdf`):
  `<nome-corso>-<numero-lezione>`
  - `<nome-corso>` = nome della directory del corso, cioè la directory che contiene
    `source/` (la directory `lectures/<nome-corso>/` → `<nome-corso>`).
  - `<numero-lezione>` = nome della directory della lezione dentro `source/`
    (la directory `lectures/<nome-corso>/source/<numero-lezione>/` → `<numero-lezione>`),
    **così com'è, zeri iniziali inclusi**.
  - In generale: `lectures/<nome-corso>/source/<numero-lezione>/` →
    `<nome-corso>-<numero-lezione>.typ` → `<nome-corso>-<numero-lezione>.pdf`.
  - Vincoli caratteri: solo lettere, cifre e trattini, nessuno spazio, nessun underscore.
- Posizioni:
  - il file `.typ` e tutti gli artefatti (`fig/`, `build/`, `_estrazione.md`,
    `_mappa_concetti.md`) vanno nella stessa directory del PDF di partenza, cioè
    `lectures/<nome-corso>/source/<numero-lezione>/`; `build/` serve solo per artefatti
    temporanei (render/ritagli), NON per l'output compilato;
  - il PDF compilato va generato DIRETTAMENTE in
    `lectures/<nome-corso>/<nome-corso>-<numero-lezione>.pdf` (nessun passaggio
    intermedio in `build/`, nessuna copia successiva).
- NON modificare, spostare o cancellare il PDF originale.

---

# FASE 0 — RICOGNIZIONE AMBIENTE

1. `ls -la` nella directory della lezione
   (`lectures/<nome-corso>/source/<numero-lezione>/`) per vedere cosa c'è.
   `pdfinfo "<pdf>"` per numero pagine, dimensioni, eventuale cifratura.
2. Verifica gli strumenti disponibili e scegli la catena di fallback:
   `command -v pdftotext pdfimages pdftoppm pdftocairo mutool magick convert tesseract python3 typst`
   - Testo: `pdftotext -layout` → `mutool draw -F txt` → `python3 -c "import fitz"` (PyMuPDF)
   - Immagini raster: `pdfimages` → PyMuPDF `page.get_images()`
   - Render/ritagli: `pdftoppm`/`pdftocairo` → PyMuPDF `page.get_pixmap(clip=...)`
   - Cropping raster: ImageMagick 7 `magick` → IM6 `convert`
3. Se il PDF è cifrato o solo-immagini (scansione): `pdftotext` restituirà poco/nulla.
   In quel caso NON inventare: usa il render di pagina + OCR solo come ultima risorsa,
   e marca tutto l'OCR come `DA VERIFICARE`.
4. Se manca `typst`: fermati e scrivi nel report che il compilatore non è disponibile
   (il file `.typ` va comunque prodotto).

# FASE 1 — ESTRAZIONE FEDELE (pagina per pagina)

1. Estrai il testo PAGINA PER PAGINA, non in blocco, così da poter attribuire ogni
   informazione alla sua origine (uso interno, non finirà nel PDF):
   ```
   for p in $(seq 1 $N); do echo "=== PAGE $p ==="; pdftotext -layout -nopgbrk -f $p -l $p "<pdf>" -; done
   ```
2. Dove il layout conta (tabelle, colonne, elenchi), usa anche
   `pdftotext -bbox-layout -f $p -l $p "<pdf>" -` o `mutool draw -F stext -o - "<pdf>" $p`
   per capire l'ordine di lettura e la posizione di blocchi/etichette.
3. Costruisci una mappa **solo interna** slide↔contenuto (foglio di lavoro
   `_estrazione.md`, che NON è un deliverable e non deve entrare nel PDF):
   - attenzione: una pagina PDF può contenere più slide, e una slide può essere spezzata
     su più pagine.
   - annota per ogni pagina: titolo, testo utile, figure presenti, contenuti ridondanti,
     pagine "mute" (solo titolo/logo/foto decorativa).
4. Questa mappa serve a te per la Fase 3 (antiduplicazione) e per il report finale.

## NIENTE RIFERIMENTI DI PAGINA (vincolo di formattazione)
Il riassunto finale NON deve contenere, in nessuna forma:
- numeri di pagina PDF o delle slide (niente `p. 12`, `p. 12–14`, "slide 31");
- riferimenti tipo "come visto prima", "vedi slide N", "a pagina N";
- marcatori di pagina nei titoli, nelle didascalie, negli header, nei box, nelle note.
La numerazione che appare sul PDF finale è solo quella generata da Typst
(`numbering: "1"`), e riguarda il riassunto stesso.
La posizione delle informazioni resta come nota interna nella mappa di lavoro.

# FASE 2 — FIGURE

Obiettivo: ricostruire le figure che servono alla comprensione con mezzi Typst
(blocchi, frecce, colori della palette), NON incollare ritagli di slide. I ritagli
delle slide sono spesso brutti, a bassa risoluzione e fuori stile: vanno riformulati.

## 2.1 Cosa ridisegnare in Typst (preferito, di norma)
- Schemi concettuali, diagrammi a blocchi, flussi, alberi, timeline, mappe,
  architetture, pipeline, classificazioni → **ridisegnali**.
- Il contenuto resta fedele: stessi nodi, stessa struttura, stesse etichette/testo delle
  slide. Puoi ricomporli in modo più pulito (griglia, allineamento, colori della palette),
  ma NON aggiungere, togliere o reinterpretare informazioni.
- Solo primitive standard: `grid`, `stack`, `place`, `rect`, `circle`, `line`, `polygon`,
  `curve`, `align`, `box`. Niente pacchetti esterni.
- Esempio di nodo e freccia:
  ```typst
  #let node(body, col: primary, bg: panel) = box(
    inset: (x: 5pt, y: 4pt), radius: 2pt, fill: bg,
    stroke: 0.6pt + col, text(size: 7.6pt, body))
  // freccia: $arrow.r$  (oppure una linea con punta)
  ```
- Diagrammi complessi: semplifica mantenendo struttura ed etichette, non inventare.
- Includi con `#figure` e didascalia di una riga (titolo/etichetta della slide, o
  descrizione oggettiva). Per figure larghe/dense:
  `#figure(placement: top, scope: "parent", ...)`; usalo con parsimonia (lascia spazio
  bianco). Prima di un cambio di sezione importante: `#place.flush()`.

## 2.2 Ritaglio raster: eccezione ammessa
Solo se il contenuto è intrinsecamente raster e ridisegnarlo sarebbe infedele o inutile:
fotografie, screenshot, grafici di dati reali (assi/curve misurate), immagini scientifiche.

```
mkdir -p fig && pdfimages -png -p "<pdf>" fig/p
pdftoppm -r 220 -png -f 12 -l 12 "<pdf>" build/pg
magick build/pg-12.png -crop 1400x900+300+780 +repage fig/i3.png   # IM7
```
- `pdfimages` non vede le figure vettoriali: ritaglia la pagina. Se hai PyMuPDF,
  `page.get_pixmap(clip=fitz.Rect(x0,y0,x1,y1), dpi=220)` è più preciso.
- Rinomina in `fig/i<KK>.png` (progressivo, SENZA pagina: i nomi non devono suggerire
  riferimenti di pagina). Ritaglia solo l'area utile (niente bordi bianchi).
- DPI: 220–300 se contiene testo/etichette piccole, altrimenti in stampa è illeggibile.
- Includi con `#figure(image("fig/i3.png", width: 100%), caption: [...])`; didascalia
  = testo della slide se presente, altrimenti descrizione oggettiva. Mai inventare,
  mai numeri di pagina.

## 2.3 ASCII art
Consentita SOLO per strutture semplici (alberi, timeline, flusso a 3–5 nodi), larghezza
max ~56 caratteri (colonna A4 a 7pt mono), dentro `#raw("...", block: true)`, contenuto
derivato dal PDF. Per tutto il resto preferisci il ridisegno Typst.

## 2.4 Modello non multimodale
Se non puoi vedere le immagini: ridisegna comunque lo schema partendo dalla struttura e
dalle etichette testuali estratte; se mancano informazioni, ritaglia e usa come didascalia
solo il testo che le slide associano alla figura (titolo, etichetta, riga sotto). Non
descrivere ciò che non hai visto.

# FASE 3 — ANTIDUPLICAZIONE (passo critico)

Tieni su disco un file di stato `_mappa_concetti.md` con righe:
`concetto | dove appare (uso interno) | sezione/ancora coinvolta | stato (completo/parziale)`

- Un concetto = UNA sezione = UNA ancora. Prima di scrivere, cerca il concetto nella mappa.
- Se il concetto ricompare:
  - stesse informazioni → NON riscrivere: nessun nuovo blocco, nessun marcatore.
  - informazioni NUOVE → aggiungi il dettaglio DENTRO la sezione esistente, in un
    sotto-blocco (es. `=== Approfondimento: <aspetto>`), senza numeri di pagina.
  - ripetizione con parole diverse → nessun doppione, al massimo `#link(<sec-nome>)[...]`.
- Rimandi incrociati: dai a ogni sezione `==` una label (`<sec-nome>`) e usa
  `#link(<sec-nome>)[vedi §Nome]` invece di rispiegare. Nessun riferimento a pagine.
- L'antidup NON autorizza a riordinare i divider: la sezione della prima occorrenza
  resta al suo posto nell'ordine dei divider; si sposta solo il dettaglio, non il
  capitolo (vedi 4.3).
- Alla fine, nessuna sezione deve avere titolo duplicato o contenuto sovrapposto.
  Verificalo esplicitamente (grep dei titoli).

# FASE 4 — SCRITTURA DEL FILE TYPST

## 4.1 Vincoli tecnici
- Typst ≥ 0.12 (assumi 0.15.x). TARGET OFFLINE: **nessun `#import "@preview/...`**,
  niente pacchetti esterni (richiederebbero rete). Solo Typst standard.
- Font: usa SOLO i font embedded del CLI: `New Computer Modern` (testo),
  `New Computer Modern Math`, `DejaVu Sans Mono` (mono), `Libertinus Serif`.
  (Verifica con `typst fonts`.) Conseguenza: **nessuna emoji, nessun simbolo Unicode
  esotico** (rischia il "tofu"). Tutti i simboli matematici vanno scritti in math mode
  Typst: `$arrow.r$`, `$alpha$`, `$subset$`, `$infinity$`, `$sum_(i=1)^n$`, ecc.
- Niente testo fuori dal file `.typ` e niente commenti "da assistente" nel documento.

## 4.2 Layout: massima densità, A4, due colonne
Preamble da usare come base (adattalo solo se la compilazione lo richiede):

```typst
// ===== PALETTE (costante, unico punto di modifica) =====
#let ink     = rgb("#1F2328")   // testo
#let primary = rgb("#1B4965")   // struttura: titoli, righe, header
#let accent  = rgb("#B45309")   // punti chiave / attenzione / esempi
#let defcol  = rgb("#2A6F6A")   // definizioni, teoremi, formule
#let danger  = rgb("#9B1C1C")   // "DA VERIFICARE"
#let panel   = rgb("#F2F5F7")   // sfondo box generico
#let headbg  = rgb("#E9EFF3")   // sfondo intestazione tabelle
#let rule    = rgb("#C7D3DB")   // linee sottili
#let muted   = rgb("#5A6B76")   // didascalie

#set page(
  paper: "a4",
  margin: (x: 13mm, top: 12mm, bottom: 13mm),
  columns: 2,
  numbering: "1",
  header: context {
    set text(size: 6.6pt, fill: muted)
    block(width: 100%)[
      #grid(columns: (1fr, auto),
        [<TITOLO LEZIONE>],
        [<nome-corso>-<numero-lezione>])
      #v(0.75pt)
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
// righe avvolte della stessa entry più strette del margine tra entry
#show list.item: set par(leading: 0.42em, spacing: 0.35em)
#show enum.item: set par(leading: 0.42em, spacing: 0.35em)

// ===== BLOCCO INDIVISIBILE =====
// Tiene un blocco intero: se non entra nella colonna/pagina corrente, slitta
// intero nella successiva invece di spezzarsi.
#let keep(body) = block(breakable: false, width: 100%, body)

// ===== TITOLI (non restano orfani in fondo alla colonna) =====
#set heading(numbering: none)
#show heading: it => block(
  breakable: false, sticky: true, above: 0.8em, below: 0.35em,
)[
  #text(size: if it.level <= 1 { 11pt } else if it.level == 2 { 9.4pt } else { 8.6pt },
        weight: "bold", fill: primary, it.body)
  #if it.level <= 1 [#v(1.5pt) #line(length: 100%, stroke: 0.7pt + rule)]
]

// ===== BOX (indivisibili) =====
#let callout(title, body, col: accent, bg: panel) = keep(block(
  width: 100%, inset: (x: 4pt, y: 4pt), radius: 1pt, fill: bg,
  stroke: (top: 0pt + col, right: 0pt + col, bottom: 0pt + col, left: 1.4pt + col),
)[
  #text(size: 7.9pt, weight: "bold", fill: col)[#title]#h(0.35em)#body
])
#let keypt(t, b) = callout(t, b, col: accent,  bg: rgb("#FDF4E7"))
#let defbox(t, b) = callout(t, b, col: defcol,  bg: rgb("#EDF5F4"))
#let warn(t, b)  = callout(t, b, col: danger,   bg: rgb("#FBEDED"))

// ===== TABELLE (indivisibili, solo filetti orizzontali) =====
// `cmp`: confronto chiave/valore; prima colonna in grassetto.
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
// `tbl`: matrice con riga di intestazione (array di celle).
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

// ===== FIGURE =====
#set figure(gap: 4pt, supplement: [Fig.], numbering: "1")
#show figure.caption: set text(size: 6.9pt, fill: muted)
```

Elementi opzionali:
- Blocco titolo a piena larghezza (all'inizio documento), sopra le colonne:
  ```typst
  #place(top, scope: "parent", float: true)[
    #text(14.5pt, weight: "bold", fill: primary)[<TITOLO LEZIONE>]
    #v(2pt)
    #text(7.3pt, fill: muted)[<nome-corso> — Lezione <numero-lezione>]
    #v(4pt) #line(length: 100%, stroke: 1pt + primary)
  ]
  ```
- NON generare alcun indice/elenco degli argomenti ("Sections: …") all'inizio del
  documento: non serve. Il documento inizia direttamente con il contenuto.

## 4.3 Struttura del contenuto
- Segui la struttura delle slide: se il PDF ha titoli di capitolo/sezione, quelli
  diventano `= / ==`; non inventare un'organizzazione tua.
- **Ordine dei contenuti = ordine dei divider del PDF.** I divider (le slide di
  capitolo) definiscono l'ordine delle sezioni `= / ==`: riportale nella stessa sequenza
  in cui compaiono nel PDF. Non riorganizzare per tema e non anticipare capitoli
  successivi. L'unica eccezione è l'antidup (Fase 3): se un concetto ricompare più
  avanti, il dettaglio NUOVO si accoda alla sezione della prima occorrenza; non si
  spostano interi capitoli né si scambia l'ordine dei divider.
- `==` = macro-argomento, `===` = concetto puntuale. I titoli NON portano riferimenti
  di pagina.
- Un concetto per sezione; i dettagli aggiuntivi trovati più avanti nel PDF si accodano
  nella sezione esistente (vedi Fase 3).
- Stile di scrittura: **telegrafico completo**, non discorsivo. Zero riempitivi
  ("in questa slide si vede che…", "come già detto", "in conclusione"). Frasi brevi,
  frammenti ammessi. Niente ripetizione del titolo della slide nel corpo.
- DEFINIZIONI/TEOREMI/FORMULE CHIAVE → `#defbox("Definizione", [...])`, con il testo
  il più vicino possibile a quello delle slide (la formulazione originale va preferita
  alla tua parafrasi).
- Attenzione/conseguenze/errori tipici/punti d'esame → `#keypt("Attenzione", [...])` se
  e solo se le slide lo evidenziano (non aggiungerli tu).
- Confronti, classificazioni, tabelle, cicli → `#cmp(...)` / `#tbl(...)`: niente griglie
  complete (solo filetti orizzontali), molto più compatte di un elenco puntato.
- Presentazione/amministrazione del corso: NON riassumerla (vedi SCOPE); non lasciare
  che il PDF finale contenga docenti, orari, voti, testi o FAQ.
- Elenchi delle slide: VANNO CONSERVATI INTEGRALMENTE. Se una slide ha 7 punti, tutti e 7
  devono comparire (compresso, non tagliato).
- Numeri, formule, unità, notazione, apici/pedici, nomi di autori/termini: copiati
  ESATTAMENTE. In caso di dubbio sul testo estratto → verifica con un ritaglio di pagina
  e aggiungi `#warn([DA VERIFICARE], ...)`.
- Lingua: rileva la lingua delle slide. Se le slide sono in inglese, scrivi l'intero
  riassunto in inglese; se sono in italiano, scrivi in italiano. In ogni caso le
  terminologie tecniche restano nella lingua originale delle slide.
- Terminologia: mantieni i termini tecnici nella lingua originale delle slide (di solito
  inglese). Non tradurre, non italianizzare, non sinonimi.
- Didascalie delle figure: dal PDF (titolo/etichetta) o descrizione oggettiva. Mai
  contenuto inventato, mai numeri di pagina.
- Codice/espressioni: inline con backtick, blocchi con ```typst non indentato.

## 4.4 Quanto deve essere lungo (compressione)
La lunghezza dipende dal **contenuto**, non dal numero di slide. Non esiste un rapporto
fisso "slide ↔ pagine": slide con solo titolo, logo, foto o una riga non contano; slide
dense (definizioni, elenchi lunghi, formule, tabelle, figure) contano molto. La misura è
la quantità di informazione tecnica effettivamente presente.
Regola operativa: **a parità di contenuto, lunghezza comparabile**.
- Se due lezioni contengono lo stesso numero di concetti, definizioni, elenchi, tabelle e
  figure, il PDF deve avere all'incirca lo stesso numero di pagine.
- Ordine di grandezza sul contenuto medio di una lezione: ~3–5 pagine A4 a due colonne.
  Lezioni eccezionalmente dense possono arrivare a 6–8; lezioni quasi solo motivazionali
  possono stare in 2–3. Questi numeri sono indizi, non vincoli.
- Il vincolo vero non è il numero di pagine, ma **zero contenuto perso**: tutte le
  definizioni, gli elenchi, le formule, le tabelle e le figure delle slide di contenuto
  devono comparire. Se un elenco delle slide ha N punti, tutti gli N punti devono esserci.
- Non gonfiare per raggiungere un numero di pagine e non tagliare per rientrare in un
  rapporto slide/pagina: l'unica misura è il contenuto.
Come comprimere senza perdere informazione:
- fondi i punti di elenco quasi sinonimi in un unico punto con sotto-voci separate da `;`;
- preferisci `#cmp`/`#tbl` a due/tre colonne per tabelle, confronti e liste di proprietà
  (`proprietà ↔ valore`, `A ↔ B`);
- elimina i connettivi discorsivi e le ripetizioni del titolo nel corpo;
- usa `===` solo se il concetto ha davvero contenuto autonomo, altrimenti resta nello
  stesso paragrafo;
- box `#defbox` / `#keypt` solo per ciò che le slide evidenziano come tale: sono
  costosi in spazio verticale;
- figure: ridisegnale (vedi Fase 2), larghezza che sfrutti la colonna, didascalia di
  una riga.
Come evitare gli spezzoni (leggibilità):
- ogni tabella, box e figura è già indivisibile (`keep`): non incollarci dentro contenuto
  che non ci sta. Se un blocco non entra nella colonna/pagina, lascialo slittare intero
  nella successiva, non forzarlo a spezzarsi.
- avvolgi in `#keep(...)` anche gli elenchi brevi e i paragrafi brevi (≤ ~4 righe) che
  finirebbero tagliati con 1–2 righe in fondo alla colonna/pagina.
- NON avvolgere in `#keep` blocchi alti quanto una colonna: creerebbero buchi bianchi.
  In quel caso spezza tu il contenuto in blocchi più piccoli e coerenti.

# FASE 5 — COMPILAZIONE E VERIFICA

1. Dalla directory della lezione (`lectures/<nome-corso>/source/<numero-lezione>/`),
   compila direttamente nella directory del corso:
   `typst compile <nome-corso>-<numero-lezione>.typ ../../<nome-corso>-<numero-lezione>.pdf`
   (nessun output in `build/`, nessuna copia successiva;
   aggiungi `--font-path ./fonts` se hai font locali). Itera finché: **zero errori e
   zero warning** (in particolare warning di glifo mancante: sostituisci il carattere
   con math mode o testo).
2. Checklist obbligatoria prima di dichiarare finito:
   - [ ] Ogni pagina del PDF è stata letta; elenca le pagine scartate/irrilevanti.
   - [ ] Nome file conforme a `<nome-corso>-<numero-lezione>` (zeri iniziali come da
         directory).
   - [ ] Nessun riferimento di pagina/slide nel PDF (grep: `p\. ` non deve comparire
         come marcatore; controlla a occhio i titoli e le didascalie).
   - [ ] Nessun titolo duplicato (grep dei titoli).
   - [ ] Ogni file `fig/...` referenziato esiste davvero (`ls fig/`).
   - [ ] Nessuna immagine referenziata ma mancante; nessun file orfano inspiegato.
   - [ ] Zero contenuti non presenti nel PDF.
   - [ ] Zero contenuti di presentazione/amministrazione del corso (docenti, orari,
         esami, testi, FAQ, form, link): nessuno deve essere finito nel PDF.
   - [ ] Nessuna tabella/box/figura/elenco spezzato tra colonne o pagine: apri il PDF
         e controlla i bordi di colonna/pagina; se qualcosa è tagliato, avvolgilo in
         `#keep(...)` e ricompila.
   - [ ] Nessun paragrafo orfano di 1–2 righe a fondo colonna/pagina.
   - [ ] Nessuna tabella a griglia completa: `#cmp`/`#tbl` con soli filetti orizzontali.
   - [ ] Tutti i `DA VERIFICARE` raccolti in un elenco finale.
   - [ ] Lunghezza coerente con il contenuto (4.4): nessun contenuto perso, nessun
         gonfiaggio, nessun taglio per rientrare in un rapporto slide/pagina.
   - [ ] `lectures/<nome-corso>/<nome-corso>-<numero-lezione>.pdf` esiste ed è
         leggibile: nessuna figura microscopica, nessun box tagliato.
3. Rileggi almeno le sezioni più dense confrontandole con il testo estratto: correggi
   ogni drift di parafrasi verso il testo originale.

# REPORT FINALE (nel messaggio di risposta, non nel .typ)
1. File creati (`.typ`, `.pdf`, `fig/`, `_mappa_concetti.md`, `_estrazione.md`) con i
   percorsi completi, e nome file adottato con la deduzione di `<nome-corso>` e
   `<numero-lezione>` dalla struttura `lectures/<nome-corso>/source/<numero-lezione>/`.
2. Strumenti usati per l'estrazione e loro limiti incontrati.
3. Elenco delle pagine/slide scartate con motivazione.
4. Elenco figure incluse (file ↔ origine interna) ed eventuali figure escluse con
   motivazione.
5. Elenco `DA VERIFICARE`.
6. Eventuali contenuti che NON sei riuscito a rendere fedelmente (OCR, formule, tabelle
   illeggibili) e cosa servirebbe per risolverli.
7. Conteggio pagine finali vs target 4.4.
