# SCRITTURA DEL FILE TYPST

## Vincoli tecnici
- Typst ≥0.12 (target 0.15.x). **Offline**: niente `#import "@preview/..."`, solo Typst standard.
- Font ammessi (CLI embedded): `New Computer Modern`, `New Computer Modern Math`, `DejaVu Sans Mono`, `Libertinus Serif`. Niente emoji/Unicode esotico → simboli matematici sempre in math mode (`$arrow.r$`, `$alpha$`, ecc.).
- Nessun testo/commento fuori dal `.typ`.

## Layout: A4, due colonne, massima densità
Il layout è definito una volta in `tools/preamble.typ` (colori, page A4 2 colonne, font, heading, callout, tabelle, figure). Nella dir lezione:
1. copia `cp ../../../../tools/preamble.typ _preamble.typ`;
2. in testa al `.typ`:

```typst
#import "_preamble.typ": *
#show: doc.with(title: "<TITOLO LEZIONE>", label: "<corso>-<lezione>")
#titleblock("<TITOLO LEZIONE>", "<corso> — Lezione <n>")   // opzionale
```

`doc` applica al body tutte le regole di pagina/testo/heading/figure. **Non ricopiare il preamble nel `.typ`.** Niente indice/elenco argomenti iniziale: si parte diretti col contenuto.

Helper esportati (dettagli e firme in `tools/preamble.typ`):
- `keep(body)`, `callout/keypt/defbox/warn(title, body)`, `cmp(cols, ..cells)`, `tbl(cols, head: (), ..cells)`;
- pattern diagrammi: `gb`, `flow`, `vflow`, `cellbox`, `asciifig`, `titleblock` (vedi sotto).

## Pattern riutilizzabili
Pattern canonici, testati e generali. Usali come mattoni per i diagrammi; non reinventarli.

- `gb(body, fill: white, sz: 5.6pt)` — box che riempie la cella di griglia (blocchi di schemi).
- `flow(..items)` — flusso orizzontale, frecce `$arrow.r$` inserite automaticamente tra i blocchi.
- `vflow(..items)` — flusso verticale, frecce `$arrow.b$` automatiche.
- `cellbox(v, fill: white)` — cella di array/buffer (es. circular buffer).
- `asciifig(text, cap)` — figura ASCII: `raw(text, block: true)` + didascalia di una riga.
- `titleblock(title, sub)` — blocco titolo a piena larghezza in cima.

```typst
#flow(gb[CPU], gb[Registri], gb[Device])
#vflow(gb[A], gb[B], gb[C])
#asciifig("main() --ISR--> main() --> Time", [Timeline foreground/ISR.])
```

Vincoli dei pattern:
- ASCII solo per strutture semplici (alberi, timeline, flusso 3–5 nodi), larghezza max ~56 caratteri, derivata dal PDF.
- griglie/buffer: `grid(columns: range(n).map(_ => 1fr), column-gutter: 0pt, ..cells.map(cellbox))`.
- etichette/frecce: stesse del PDF; nessun contenuto inventato.
- **Nuovi pattern**: se durante una lezione ne emerge uno generale e verificato (compile pulita), aggiungilo a questo elenco con firma + un esempio, senza duplicare quelli esistenti.

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
- Codice/espressioni: inline con backtick; blocchi con ` ```typst ` (o linguaggio reale) non indentati. `raw` è a 6.4pt per stare nella colonna: spezza le righe lunghe (~62 caratteri max), senza alterare il contenuto.

## Lunghezza (compressione)
Dipende dal **contenuto**, non dal numero di slide — slide vuote/foto non contano, slide dense (definizioni, elenchi, formule, tabelle, figure) sì.
- A parità di contenuto → lunghezza comparabile.
- Indicativo: ~3–5 pagine A4 a due colonne per lezione media; 6–8 se molto densa; 2–3 se poco tecnica. Sono indizi, non vincoli.
- Vincolo reale: **zero contenuto perso** — tutte le definizioni, elenchi, formule, tabelle, figure devono comparire integralmente.
- Non gonfiare per raggiungere pagine, non tagliare per rientrare in un rapporto: unica misura è il contenuto.
- Non forzare la compressione se, dopo la compressione, resta un solo paragrafo/blocco isolato in una nuova pagina: accetta la pagina in più invece di tagliare contenuto o comprimere oltre.

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
