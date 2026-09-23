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

# DEFINIZIONI

Termini univoci, definiti qui una volta e referenziati altrove. Non ri-enumerare le esclusioni: cita il termine.

- **Contenuto in-scope**: concetti, definizioni, modelli, architetture, algoritmi, formule, comandi, esempi, figure con etichette/legenda, esercizi/laboratori/homework.
- **Contenuto amministrativo (out-of-scope)**: presentazione e autori del corso, calendario/orari, aule, esami/voti, testi consigliati, FAQ, piattaforme e strumenti di erogazione del corso (LMS, Teams, moduli di consegna), URL, ringraziamenti.
- **Slide muta**: priva di contenuto in-scope *e* di figure con etichette/legenda leggibili. Una figura con etichette non è muta: si ridisegna.
- **Link**: URL. Mai riprodotti; se la slide è solo un link, si omette. Una risorsa tecnica può essere nominata a parole.
- **Strumento tecnico** (linguaggi, DBMS, IDE, librerie, framework, editor oggetto della lezione) → contenuto in-scope. **Piattaforma di corso** (LMS, Teams, consegne) → contenuto amministrativo.

# PRECEDENZA

Rete di sicurezza per i casi non previsti dalle definizioni, in ordine:

1. **Scope > integralità/completezza**: il contenuto amministrativo si omette anche dentro un elenco o una sezione mista.
2. **Fedeltà > completezza**.
3. **Render > testo estratto**: in caso di divergenza vince l'aspetto visivo della slide, con `#warn`.
4. Nel dubbio su un elemento tecnico → includi e annota; nel dubbio su uno amministrativo → escludi.

"Elenchi integrali" e "zero contenuto perso" valgono **solo per il contenuto in-scope**: la rimozione di elementi amministrativi non è un taglio e si registra nel report.

# REGOLE

Fonte unica = PDF. Non aggiungere né completare con conoscenze tue o dal web: ogni frase deve restare tracciabile a una slide. Sono ammesse **correzioni minime e locali**, solo se l'errore è evidente e autocontenuto nel PDF: refusi, errori di calcolo, incoerenze di notazione/unità nella stessa slide, artefatti di estrazione (testo corrotto vs render). Le correzioni non devono introdurre fatti nuovi; se servirebbe conoscenza esterna o cambierebbe il senso → **non correggere**, usa `#warn([DA VERIFICARE], [<cosa e dove>])`. Le correzioni effettuate si elencano nel report finale.

Ambito di lettura consentito = ristretto. NON sei libero di girare le directory: non esplorare né leggere nulla fuori da `lectures/<corso>/source/<lezione>/`. NON usare `git` (log, storia, diff, show) per ricavare istruzioni, preamble, struttura o contenuto. Gli unici file che ti è consentito leggere e utilizzare sono:
- `PROMPT.md` e `STYLE.md` (le regole);
- gli strumenti condivisi in `/workspace/tools/`: `estrai.sh` e `qa.sh` si **eseguono**, `preamble.typ` si **copia**; non si leggono. Il loro comportamento non ti interessa, utilizzali seguendo la PROCEDURA;
- il/i PDF sorgente presenti nella sola directory della lezione corrente;
- tutti i file e le directory dentro `lectures/<corso>/source/<lezione>/`.

Vietato leggere `.typ`, PDF, `_estrazione.md`, `_mappa_concetti.md` o qualsiasi artefatto di altre lezioni o altri corsi. `/workspace/tools/` è l'unica eccezione fuori dalla dir lezione.

Scope = solo **contenuto in-scope** (v. Definizioni). Escludi il **contenuto amministrativo** e le **slide mute** (v. Definizioni). Nelle slide miste estrai solo la parte in-scope.
Un intero capitolo amministrativo va omesso anche se lungo.

Lingua = lingua delle slide. Termini tecnici nella lingua originale (no traduzioni).

Niente riferimenti a pagine/slide nel PDF finale (né numeri, né "vedi sopra", né "come visto prima"), in nessuna forma (titoli, didascalie, header, box, note). La tracciabilità è solo un controllo interno; l'unica numerazione nel PDF è quella generata da Typst.

Fedeltà: la slide renderizzata è la fonte di verità, l'estrazione testuale è un ausilio. Per codice, comandi, formule, identificatori, numeri, tabelle ed etichette di figure la trascrizione va verificata visivamente; se testo estratto e render divergono, si usa il render e si segnala con `#warn`. Correggere un artefatto di estrazione usando il contenuto visivo dello stesso PDF è trascrizione fedele, non aggiunta esterna.

Attenzione all'ambiente: l'output dei tool può essere redatto o alterato. Prima di dichiarare corrotta un'estrazione, verifica con una rappresentazione alternativa (render, `od`, lunghezza del valore): non concludere da un singolo output testuale.

**Economia di lettura visiva**: i render sono costosi. Leggi i contact sheet una sola volta; per le pagine solo-testo usa `_estrazione_raw.txt`. Renderizza solo le pagine con tabelle/figure da verificare, a bassa risoluzione (110–130 dpi) in ricognizione e 150–200 dpi solo per etichette illeggibili; raggruppa più pagine in un unico comando. Non ri-leggere immagini già analizzate. Dopo la compilazione non rileggere il PDF pagina per pagina: usa `qa.sh` e al più 1–2 render di controllo mirati.

**Path assoluti**: tutti i comandi usano path assoluti. Radice repo = `/workspace`. Vietato `../` e path relativi nei comandi (soprattutto verso `/workspace/tools/` e verso l'output). I placeholder `<corso>`/`<lezione>` restano, ma sempre dentro path assoluti: `/workspace/lectures/<corso>/source/<lezione>/` e `/workspace/lectures/<corso>/<corso>-<lezione>.pdf`.

# PROCEDURA

## 0. Ricognizione
`ls -la` nella dir lezione e `pdfinfo "<pdf>"` (pagine, dimensioni, cifratura). Verifica gli strumenti: `command -v pdftotext pdftoppm pdftocairo mutool tesseract python3 typst`.
- Testo: `pdftotext -layout` → `mutool draw -F txt` → PyMuPDF.
- `mutool draw -F stext` (bbox/ordine di lettura) solo quando necessario e limitato alle pagine/aree rilevanti: mai su pagine intere.
- Render (solo per *leggere* slide/figure, mai per produrre figure): `pdftoppm`/`pdftocairo` → PyMuPDF `page.get_pixmap()`. OCR `tesseract` solo in caso di dubbi estremi (cross-check manuale) o per testo in scansioni.
- `bash /workspace/tools/estrai.sh /workspace/lectures/<corso>/source/<lezione>` fa testo + contact sheet in un colpo (Fase 1). I contact sheet sono supporto di lettura, non figure di output.

## 1. Estrazione
Scaffold automatico: `bash /workspace/tools/estrai.sh /workspace/lectures/<corso>/source/<lezione>` → `_estrazione_raw.txt` (testo pagina per pagina di tutti i PDF in ordine naturale) + `build/sheet-*.png`. In alternativa, manuale:
`for p in $(seq 1 $N); do echo "=== PAGE $p ==="; pdftotext -layout -nopgbrk -f $p -l $p "<pdf>" -; done`
Dove conta il layout (tabelle, colonne, elenchi) usa anche `pdftotext -bbox-layout -f $p -l $p "<pdf>" -` o `mutool draw -F stext -o - "<pdf>" $p` per l'ordine di lettura e la posizione di blocchi/etichette. PDF cifrato o scansione → render + OCR, marcato `DA VERIFICARE`. **Verifica visiva obbligatoria**: per codice, comandi, formule, identificatori, numeri, tabelle ed etichette di figure trascrivi dal render (contact sheet; render mirato a 150–200 dpi se illeggibile). **Solo in caso di dubbio estremo** (testo sospetto, valori che paiono alterati, scansione, PDF cifrato) attiva il cross-check OCR con `bash /workspace/tools/estrai.sh --ocr /workspace/lectures/<corso>/source/<lezione>`: confronta `pdftotext` con `tesseract` e scrive `_crosscheck.txt` elencando `solo testo` (token del layer assenti nel render). Costruisci `_estrazione.md` (interno) con mappa pagina↔contenuto, pagine mute, figure. Verifica che `typst` esista; se manca, produci comunque il `.typ` e segnalalo. Le firme degli helper sono in `STYLE.md`.

## 2. Figure
Leggi `build/sheet-*.png` (9 pagine/foglio) per la ricognizione visiva. Se un'etichetta è illeggibile, render mirato **solo per leggere**: `pdftoppm -r 150 -f P -l P "<pdf>" build/pg`; in alternativa `mutool draw -F stext -o - "<pdf>" P`. Non salvare ritagli come figure.

Tutte le figure vanno **ridisegnate in Typst** (niente `image("*.png|jpg")`, screenshot, foto). Usa i pacchetti di `STYLE.md` — oppure i pattern di `STYLE.md`. Stesse etichette e struttura del PDF. Riusa il pattern di numerazione di `STYLE.md`.

Se non puoi vedere l'originale: ridisegna lo schema dalle etichette/struttura testuali estratte; se mancano info, usa come didascalia solo il testo che le slide associano alla figura. Non descrivere ciò che non hai visto.

## 3. Antidup
`_mappa_concetti.md`: `concetto | dove | sezione | stato`. Un concetto = una sezione. Se ricompare con info nuove → sotto-blocco `=== Approfondimento: <aspetto>` nella prima sezione; se è ripetizione → nessun nuovo blocco, eventualmente `#link(<sec>)[vedi §...]`. Non riordinare i divider: la prima occorrenza resta dove sta.

## 4. Typst
Segui `STYLE.md` per vincoli tecnici, layout, pattern, stile e criteri di lunghezza/compressione. In sintesi:

`cp /workspace/tools/preamble.typ /workspace/lectures/<corso>/source/<lezione>/_preamble.typ` e in testa al `.typ`:
```typst
#import "_preamble.typ": *
#show: doc.with(title: "<TITOLO LEZIONE>", label: "<corso>-<lezione>")
#titleblock("<TITOLO LEZIONE>", "<corso> — Lezione <n>")
```
`#titleblock` è obbligatorio. Importa i pacchetti `@preview` necessari (lista in `STYLE.md`). Non ricopiare il preamble nel `.typ`; usa gli helper (`cmp/tbl/callout/defbox/keypt/warn`, `gb/flow/vflow/cellbox/asciifig/titleblock`).

Ordine sezioni = ordine dei divider del PDF; == macro-argomento, === concetto.
Stile telegrafico completo, zero riempitivi.
Elenchi: tutti gli elementi **in-scope**, in ordine, compressi ma non tagliati (gli elementi amministrativi si omettono, v. Definizioni). Numeri/formule/unità/notazione copiati esattamente.
Niente indice/"Sections" iniziale.

Non ripetere qui le regole di `STYLE.md`: applicale direttamente al file .typ.

## 5. Compilazione e QA
Dalla dir lezione:
`typst compile /workspace/lectures/<corso>/source/<lezione>/<corso>-<lezione>.typ /workspace/lectures/<corso>/<corso>-<lezione>.pdf`
(nessun output intermedio in `build/`; `--font-path ./fonts` se hai font locali). Zero errori e zero warning: i warning di glifo mancante si risolvono sostituendo il carattere con math mode o testo. Itera finché pulito.

Poi `bash /workspace/tools/qa.sh /workspace/lectures/<corso>/source/<lezione>` (riferimenti vietati, titoli duplicati, figure mancanti/orfane, compile pulita, DA VERIFICARE, PDF finale). Correggi i FAIL e ricompila.

## 6. Pattern riutilizzabili
Se durante la lezione ricavi un pattern di figura/struttura **generale e testato** (compile pulita), aggiungilo a `STYLE.md` §Pattern riutilizzabili: firma + un esempio, in stile compatto. Non duplicare i pattern già presenti. Non aggiungere snippet specifici, aggiungi solo quelli che ritieni che possano essere riutilizzabili in altre lezioni.

# CHECKLIST
- Tutte le pagine lette; pagine scartate elencate nel report.
- Lettura visiva economica: contact sheet una volta, render mirati solo per tabelle/figure, nessuna ri-lettura.
- Comandi con path assoluti (nessun `../` / path relativo).
- Contact sheet (`build/sheet-*.png`) usati per le figure; render mirati solo se illeggibili.
- Nome file conforme, zeri inclusi.
- Preamble importato da `_preamble.typ` (non ricopiato).
- Nessun riferimento a pagine/slide (`grep -nE 'p\. [0-9]|slide [0-9]|pag\. [0-9]'`).
- Nessun titolo duplicato.
- Nessuna immagine raster nel `.typ` (solo figure vettoriali Typst).
- Zero contenuto esterno al PDF o amministrativo.
- Nessun blocco spezzato; nessun paragrafo orfano di 1–2 righe a fondo colonna.
- Nessuna tabella a griglia completa: `#cmp`/`#tbl` con soli filetti orizzontali.
- Lunghezza coerente col contenuto: zero **contenuto in-scope** perso, nessun gonfiaggio né taglio per rientrare in un rapporto slide/pagina.
- Tutti i `DA VERIFICARE` raccolti.
- Se è stato generato, `_crosscheck.txt` esaminato; divergenze risolte o annotate.
- Correzioni minime registrate nel report.
- `bash /workspace/tools/qa.sh /workspace/lectures/<corso>/source/<lezione>` senza FAIL; PDF finale in `lectures/<corso>/<corso>-<lezione>.pdf` leggibile.

# REPORT FINALE (nel messaggio, non nel .typ)
1. File creati (percorsi completi) e nome adottato con deduzione di `<corso>`/`<lezione>`.
2. PDF usati e ordine; strumenti e limiti.
3. Pagine/slide scartate con motivo (incluso il contenuto amministrativo omesso).
4. Figure incluse (file ↔ origine) ed eventuali escluse con motivo.
5. `DA VERIFICARE` e contenuti non fedeli (cosa servirebbe per risolverli).
6. Correzioni minime effettuate (dove e perché); mismatch OCR risolti se il cross-check è stato eseguito.
7. Conteggio pagine finali vs target.