# COMPITO

Agente CLI non interattivo. Input:
- `@PROMPT.md @<pdf>` → usa quel PDF.
- `PROMPT.md <corso> <lezione>` → in `lectures/<corso>/source/<lezione>/` prendi TUTTI i `.pdf` (ignora `build/`), riassumili insieme come un'unica lezione nell'ordine naturale dei file, e dichiara all'inizio quali e in che ordine li hai usati.

Output (obbligatorio):
- `<corso>-<lezione>.typ` nella dir della lezione.
- PDF compilato DIRETTAMENTE in `lectures/<corso>/<corso>-<lezione>.pdf`.
- Artefatti interni (`build/`, `_preamble.typ`, `_estrazione.md`, `_estrazione_raw.txt`, `_mappa_concetti.md`) nella dir della lezione.
- Non modificare/spostare/cancellare i PDF originali.
- Nome file: solo lettere/cifre/trattini, zeri iniziali della dir lezione inclusi. `<corso>` = nome della dir che contiene `source/`; `<lezione>` = nome della dir dentro `source/`.

# REGOLE

Fonte unica = PDF. Vietato aggiungere, correggere, completare, integrare da tue conoscenze o da web. Ogni frase tracciabile a una slide. Ambiguità o estrazione corrotta → `#warn([DA VERIFICARE], [<cosa e dove>])`, niente invenzioni.

Ambito di lettura consentito = ristretto. NON sei libero di girare le directory: non esplorare né leggere nulla fuori da `lectures/<corso>/source/<lezione>/`. NON usare `git` (log, storia, diff, show) per ricavare istruzioni, preamble, struttura o contenuto. Gli unici file che ti è consentito leggere e utilizzare sono:
- `PROMPT.md` e `STYLE.md` (le regole);
- gli strumenti condivisi in `tools/` (sola lettura/esecuzione: `tools/preamble.typ`, `tools/estrai.sh`, `tools/qa.sh`);
- il/i PDF sorgente presenti nella sola directory della lezione corrente;
- tutti i file e le directory dentro `lectures/<corso>/source/<lezione>/`.

Vietato leggere `.typ`, PDF, `_estrazione.md`, `_mappa_concetti.md` o qualsiasi artefatto di altre lezioni o altri corsi. `tools/` è l'unica eccezione fuori dalla dir lezione.

Scope = solo contenuto tecnico (concetti, definizioni, modelli, architetture, algoritmi, formule, esempi). Escludi presentazione corso, docenti, calendario, orari, aule, esami, voti, testi, FAQ, tool/piattaforme, link, ringraziamenti, slide mute. Nelle slide miste estrai solo la parte concettuale.
Un intero capitolo amministrativo va omesso anche se lungo.

Lingua = lingua delle slide. Termini tecnici nella lingua originale (no traduzioni).

Niente riferimenti a pagine/slide nel PDF finale (né numeri, né "vedi sopra", né "come visto prima"), in nessuna forma (titoli, didascalie, header, box, note). La tracciabilità è solo un controllo interno; l'unica numerazione nel PDF è quella generata da Typst.

# PROCEDURA

## 0. Ricognizione
`ls -la` nella dir lezione e `pdfinfo "<pdf>"` (pagine, dimensioni, cifratura). Verifica gli strumenti: `command -v pdftotext pdftoppm pdftocairo mutool tesseract python3 typst`.
- Testo: `pdftotext -layout` → `mutool draw -F txt` → PyMuPDF.
- Render (solo per *leggere* slide/figure, mai per produrre figure): `pdftoppm`/`pdftocairo` → PyMuPDF `page.get_pixmap()`. OCR `tesseract` solo per testo in scansioni.
- `bash tools/estrai.sh .` fa testo + contact sheet in un colpo (Fase 1). I contact sheet sono supporto di lettura, non figure di output.

## 1. Estrazione
Scaffold automatico: `bash tools/estrai.sh .` → `_estrazione_raw.txt` (testo pagina per pagina di tutti i PDF in ordine naturale) + `build/sheet-*.png`. In alternativa, manuale:
`for p in $(seq 1 $N); do echo "=== PAGE $p ==="; pdftotext -layout -nopgbrk -f $p -l $p "<pdf>" -; done`
Dove conta il layout (tabelle, colonne, elenchi) usa anche `pdftotext -bbox-layout -f $p -l $p "<pdf>" -` o `mutool draw -F stext -o - "<pdf>" $p` per l'ordine di lettura e la posizione di blocchi/etichette. PDF cifrato o scansione → render + OCR solo come ultima risorsa, marcato `DA VERIFICARE`. Costruisci `_estrazione.md` (interno) con mappa pagina↔contenuto, pagine mute, figure. Verifica che `typst` esista; se manca, produci comunque il `.typ` e segnalalo.

## 2. Figure
Leggi `build/sheet-*.png` (9 pagine/foglio) per la ricognizione visiva. Se un'etichetta è illeggibile, render mirato **solo per leggere**: `pdftoppm -r 150 -f P -l P "<pdf>" build/pg`; in alternativa `mutool draw -F stext -o - "<pdf>" P`. Non salvare ritagli come figure.

Tutte le figure vanno **ridisegnate in Typst** (niente `image("*.png|jpg")`, screenshot, foto). Usa i pacchetti di `STYLE.md` — oppure i pattern di `STYLE.md`. Stesse etichette e struttura del PDF.

Se non puoi vedere l'originale: ridisegna lo schema dalle etichette/struttura testuali estratte; se mancano info, usa come didascalia solo il testo che le slide associano alla figura. Non descrivere ciò che non hai visto.

## 3. Antidup
`_mappa_concetti.md`: `concetto | dove | sezione | stato`. Un concetto = una sezione. Se ricompare con info nuove → sotto-blocco `=== Approfondimento: <aspetto>` nella prima sezione; se è ripetizione → nessun nuovo blocco, eventualmente `#link(<sec>)[vedi §...]`. Non riordinare i divider: la prima occorrenza resta dove sta.

## 4. Typst
Segui `STYLE.md` per vincoli tecnici, layout, pattern, stile e criteri di lunghezza/compressione. In sintesi:

`cp ../../../../tools/preamble.typ _preamble.typ` e in testa al `.typ`:
```typst
#import "_preamble.typ": *
#show: doc.with(title: "<TITOLO LEZIONE>", label: "<corso>-<lezione>")
#titleblock("<TITOLO LEZIONE>", "<corso> — Lezione <n>")
```
`#titleblock` è obbligatorio. Importa i pacchetti `@preview` necessari (lista in `STYLE.md`). Non ricopiare il preamble nel `.typ`; usa gli helper (`cmp/tbl/callout/defbox/keypt/warn`, `gb/flow/vflow/cellbox/asciifig/titleblock`).

Ordine sezioni = ordine dei divider del PDF; == macro-argomento, === concetto.
Stile telegrafico completo, zero riempitivi.
Elenchi integrali, numeri/formule/unità/notazione copiati esattamente.
Niente indice/"Sections" iniziale.

Non ripetere qui le regole di `STYLE.md`: applicale direttamente al file .typ.

## 5. Compilazione e QA
Dalla dir lezione:
`typst compile <corso>-<lezione>.typ ../../<corso>-<lezione>.pdf`
(nessun output intermedio in `build/`; `--font-path ./fonts` se hai font locali). Zero errori e zero warning: i warning di glifo mancante si risolvono sostituendo il carattere con math mode o testo. Itera finché pulito.

Poi `bash tools/qa.sh .` (riferimenti vietati, titoli duplicati, figure mancanti/orfane, compile pulita, DA VERIFICARE, PDF finale). Correggi i FAIL e ricompila.

## 6. Pattern riutilizzabili
Se durante la lezione ricavi un pattern di figura/struttura **generale e testato** (compile pulita), aggiungilo a `STYLE.md` §Pattern riutilizzabili: firma + un esempio, in stile compatto. Non duplicare i pattern già presenti. Non aggiungere snippet specifici, aggiungi solo quelli che ritieni che possano essere riutilizzabili in altre lezioni.

# CHECKLIST
- Tutte le pagine lette; pagine scartate elencate nel report.
- Contact sheet (`build/sheet-*.png`) usati per le figure; render mirati solo se illeggibili.
- Nome file conforme, zeri inclusi.
- Preamble importato da `_preamble.typ` (non ricopiato).
- Nessun riferimento a pagine/slide (`grep -nE 'p\. [0-9]|slide [0-9]|pag\. [0-9]'`).
- Nessun titolo duplicato.
- Nessuna immagine raster nel `.typ` (solo figure vettoriali Typst).
- Zero contenuto esterno al PDF o amministrativo.
- Nessun blocco spezzato; nessun paragrafo orfano di 1–2 righe a fondo colonna.
- Nessuna tabella a griglia completa: `#cmp`/`#tbl` con soli filetti orizzontali.
- Lunghezza coerente col contenuto: zero contenuto perso, nessun gonfiaggio né taglio per rientrare in un rapporto slide/pagina.
- Tutti i `DA VERIFICARE` raccolti.
- `bash tools/qa.sh .` senza FAIL; PDF finale in `lectures/<corso>/<corso>-<lezione>.pdf` leggibile.

# REPORT FINALE (nel messaggio, non nel .typ)
1. File creati (percorsi completi) e nome adottato con deduzione di `<corso>`/`<lezione>`.
2. PDF usati e ordine; strumenti e limiti.
3. Pagine/slide scartate con motivo.
4. Figure incluse (file ↔ origine) ed eventuali escluse con motivo.
5. `DA VERIFICARE` e contenuti non fedeli (cosa servirebbe per risolverli).
6. Conteggio pagine finali vs target.