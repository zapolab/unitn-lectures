# COMPITO

Agente CLI non interattivo. Input:
- `@PROMPT.md @<pdf>` → usa quel PDF.
- `PROMPT.md <corso> <lezione>` → in `lectures/<corso>/source/<lezione>/` prendi TUTTI i `.pdf` (ignora `build/`), riassumili insieme come un'unica lezione nell'ordine naturale dei file, e dichiara all'inizio quali e in che ordine li hai usati.

Output (obbligatorio):
- `<corso>-<lezione>.typ` nella dir della lezione.
- PDF compilato DIRETTAMENTE in `lectures/<corso>/<corso>-<lezione>.pdf`.
- Artefatti interni (`fig/`, `build/`, `_estrazione.md`, `_mappa_concetti.md`) nella dir della lezione.
- Non modificare/spostare/cancellare i PDF originali.
- Nome file: solo lettere/cifre/trattini, zeri iniziali della dir lezione inclusi. `<corso>` = nome della dir che contiene `source/`; `<lezione>` = nome della dir dentro `source/`.

# REGOLE

Fonte unica = PDF. Vietato aggiungere, correggere, completare, integrare da tue conoscenze o da web. Ogni frase tracciabile a una slide. Ambiguità o estrazione corrotta → `#warn([DA VERIFICARE], [<cosa e dove>])`, niente invenzioni.

Scope = solo contenuto tecnico (concetti, definizioni, modelli, architetture, algoritmi, formule, esempi). Escludi presentazione corso, docenti, calendario, orari, aule, esami, voti, testi, FAQ, tool/piattaforme, link, ringraziamenti, slide mute. Nelle slide miste estrai solo la parte concettuale.
Un intero capitolo amministrativo va omesso anche se lungo.

Lingua = lingua delle slide. Termini tecnici nella lingua originale (no traduzioni).

Niente riferimenti a pagine/slide nel PDF finale (né numeri, né "vedi sopra", né "come visto prima"), in nessuna forma (titoli, didascalie, header, box, note). La tracciabilità è solo un controllo interno; l'unica numerazione nel PDF è quella generata da Typst.

# PROCEDURA

## 0. Ricognizione
`ls -la` nella dir lezione e `pdfinfo "<pdf>"` (pagine, dimensioni, cifratura). Verifica gli strumenti e scegli la catena di fallback: `command -v pdftotext pdfimages pdftoppm pdftocairo mutool magick convert tesseract python3 typst`.
- Testo: `pdftotext -layout` → `mutool draw -F txt` → PyMuPDF.
- Immagini raster: `pdfimages` → PyMuPDF `page.get_images()`.
- Render/ritagli: `pdftoppm`/`pdftocairo` → PyMuPDF `page.get_pixmap(clip=...)`; crop con ImageMagick `magick` → `convert`.

## 1. Estrazione
Testo PAGINA PER PAGINA:
`for p in $(seq 1 $N); do echo "=== PAGE $p ==="; pdftotext -layout -nopgbrk -f $p -l $p "<pdf>" -; done`
Dove conta il layout (tabelle, colonne, elenchi) usa anche `pdftotext -bbox-layout -f $p -l $p "<pdf>" -` o `mutool draw -F stext -o - "<pdf>" $p` per l'ordine di lettura e la posizione di blocchi/etichette. PDF cifrato o scansione → render + OCR solo come ultima risorsa, marcato `DA VERIFICARE`. Costruisci `_estrazione.md` (interno) con mappa pagina↔contenuto, pagine mute, figure. Verifica che `typst` esista; se manca, produci comunque il `.typ` e segnalalo.

## 2. Figure
Preferisci ridisegno Typst (grid/stack/place/rect/line/circle/polygon/curve), stesse etichette e struttura del PDF.

Figure larghe/dense: `#figure(placement: top, scope: "parent", ...)` con parsimonia; `#place.flush()` prima di un cambio di sezione. Didascalia = testo slide o descrizione oggettiva, di una riga.

Raster solo per contenuto intrinsecamente raster (foto, screenshot, grafici di dati reali, immagini scientifiche): `pdfimages -png -p "<pdf>" fig/p`, oppure ritaglio pagina con `pdftoppm -r 220 ... build/pg` + `magick ... -crop ... fig/i<KK>.png`, oppure PyMuPDF `page.get_pixmap(clip=fitz.Rect(...), dpi: 220)`. Salva in `fig/i<KK>.png` (progressivo, niente pagina nel nome), ritaglia solo l'area utile (niente bordi bianchi), DPI 220–300 se c'è testo/etichette piccole. Niente contenuto inventato, niente numeri di pagina, niente emoji/Unicode esotico.

ASCII art solo per strutture semplici (alberi, timeline, flusso 3–5 nodi), larghezza max ~56 caratteri, in `#raw("...", block: true)`, derivata dal PDF.

Se non puoi vedere le immagini: ridisegna lo schema dalle etichette/struttura testuali estratte; se mancano info, ritaglia e usa come didascalia solo il testo che le slide associano alla figura. Non descrivere ciò che non hai visto.

## 3. Antidup
`_mappa_concetti.md`: `concetto | dove | sezione | stato`. Un concetto = una sezione. Se ricompare con info nuove → sotto-blocco `=== Approfondimento: <aspetto>` nella prima sezione; se è ripetizione → nessun nuovo blocco, eventualmente `#link(<sec>)[vedi §...]`. Non riordinare i divider: la prima occorrenza resta dove sta.

## 4. Typst
Segui `STYLE.md` per vincoli tecnici, layout (preamble, font, keep, callout/defbox/keypt/warn, cmp/tbl), stile di scrittura e criteri di lunghezza/compressione. In sintesi:

Ordine sezioni = ordine dei divider del PDF; == macro-argomento, === concetto.
Stile telegrafico completo, zero riempitivi.
Elenchi integrali, numeri/formule/unità/notazione copiati esattamente.
Niente indice/"Sections" iniziale.

Non ripetere qui le regole di `STYLE.md`: applicale direttamente al file .typ.

## 5. Compilazione
Dalla dir lezione:
`typst compile <corso>-<lezione>.typ ../../<corso>-<lezione>.pdf`
(nessun output intermedio in `build/`; `--font-path ./fonts` se hai font locali). Zero errori e zero warning: i warning di glifo mancante si risolvono sostituendo il carattere con math mode o testo. Itera finché pulito.

# CHECKLIST
- Tutte le pagine lette; pagine scartate elencate nel report.
- Nome file conforme, zeri inclusi.
- Nessun riferimento a pagine/slide (`grep -nE 'p\. [0-9]|slide [0-9]|pag\. [0-9]'`).
- Nessun titolo duplicato.
- Ogni `fig/...` referenziato esiste; nessun orfano.
- Zero contenuto esterno al PDF o amministrativo.
- Nessun blocco spezzato; nessun paragrafo orfano di 1–2 righe a fondo colonna.
- Nessuna tabella a griglia completa: `#cmp`/`#tbl` con soli filetti orizzontali.
- Lunghezza coerente col contenuto: zero contenuto perso, nessun gonfiaggio né taglio per rientrare in un rapporto slide/pagina.
- Tutti i `DA VERIFICARE` raccolti.
- PDF finale in `lectures/<corso>/<corso>-<lezione>.pdf` leggibile.

# REPORT FINALE (nel messaggio, non nel .typ)
1. File creati (percorsi completi) e nome adottato con deduzione di `<corso>`/`<lezione>`.
2. PDF usati e ordine; strumenti e limiti.
3. Pagine/slide scartate con motivo.
4. Figure incluse (file ↔ origine) ed eventuali escluse con motivo.
5. `DA VERIFICARE` e contenuti non fedeli (cosa servirebbe per risolverli).
6. Conteggio pagine finali vs target.