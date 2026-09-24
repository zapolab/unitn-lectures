# COMPITO

Agente CLI non interattivo. Input:
- `@PROMPT.md @<pdf>` → usa quel PDF.
- `PROMPT.md <corso> <lezione> [istruzioni extra]` → in `lectures/<corso>/source/<lezione>/` prendi TUTTI i `.pdf` (ignora `build/`), riassumili insieme come un'unica lezione nell'ordine naturale dei file, e dichiara all'inizio quali e in che ordine li hai usati.
- Le **istruzioni extra** (tutto ciò che segue `<corso> <lezione>`, o il path) sono vincoli aggiuntivi dell'utente, es. "tralascia i laboratori", "ignora le slide Matlab". Restringono lo scope rispetto a queste regole, **prevalgono in caso di conflitto** e vanno **registrate nel report finale**.

Output (obbligatorio):
- `<corso>-<lezione>.typ` nella dir della lezione.
- PDF compilato DIRETTAMENTE in `lectures/<corso>/<corso>-<lezione>.pdf`.
- Artefatti interni nella dir della lezione: `build/`, `_preamble.typ`, `_<nome>.typ` (pattern copiati), `_pagine.tsv`, `_estrazione_raw.txt`, `_estrazione_layout.txt`, `_crosscheck.txt`, `_mappa.md`.
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

Fonte unica = PDF. Non aggiungere né completare con conoscenze tue o dal web: ogni frase deve restare tracciabile a una slide. Ammesse **correzioni minime e locali** solo se l'errore è evidente e autocontenuto nel PDF (refusi, calcoli, incoerenze di notazione/unità nella stessa slide, artefatti di estrazione testo vs render). Non introdurre fatti nuovi; se servirebbe conoscenza esterna o cambierebbe il senso → **non correggere**, usa `#warn([DA VERIFICARE], [<cosa e dove>])`. Registra le correzioni nel report.

Ambito di lettura = ristretto. Non esplorare nulla fuori da `lectures/<corso>/source/<lezione>/`. NON usare `git`. Gli unici file leggibili:
- `PROMPT.md` e `STYLE.md` (le regole);
- strumenti in `/workspace/tools/`: `estrai.sh` e `qa.sh` si **eseguono**, `preamble.typ` si **copia**; non si leggono. Di `/workspace/tools/patterns/` si legge `INDEX.md` (indice compatto) e il singolo `patterns/<nome>.typ` quando serve (per conoscerne l'API); il pattern scelto si copia in `_<nome>.typ`;
- il/i PDF sorgente della sola lezione corrente;
- i file dentro `lectures/<corso>/source/<lezione>/`.
Vietato leggere `.typ`, PDF, `_pagine.tsv`, `_estrazione_raw.txt`, `_mappa.md` o artefatti di altre lezioni/corsi. `/workspace/tools/` è l'unica eccezione fuori dalla dir lezione.

Scope = solo **contenuto in-scope** (v. Definizioni). Escludi contenuto amministrativo e slide mute. Nelle slide miste estrai solo la parte in-scope. Un intero capitolo amministrativo si omette anche se lungo.

Lingua = lingua delle slide. Termini tecnici nella lingua originale (no traduzioni).

Niente riferimenti a pagine/slide nel PDF finale (né numeri, né "vedi sopra"/"come visto prima") in nessuna forma. La tracciabilità è un controllo interno; l'unica numerazione è quella di Typst.

Fedeltà: il render è la fonte di verità, l'estrazione testuale un ausilio. Per codice, comandi, formule, identificatori, numeri, tabelle ed etichette di figure trascrivi verificando a vista; se testo estratto e render divergono, usa il render e segnala con `#warn`. Correggere un artefatto di estrazione col contenuto visivo dello stesso PDF è trascrizione fedele, non aggiunta.

Attenzione all'ambiente: l'output dei tool può essere redatto o alterato. Prima di dichiarare corrotta un'estrazione, verifica con una rappresentazione alternativa (render, `od`, lunghezza del valore): non concludere da un singolo output.

**Economia visiva**: guarda solo le pagine renderizzate (`build/sheet-*.png`). Per formule/matrici usa `build/formula-sheet-*.png` (le pagine `testo` non vengono renderizzate una a una): verifica lì matrici e formule, non pagina per pagina. Budget per lezione: al più 3 `sheet-*` + i `formula-sheet-*` + **≤6 render mirati**. Leggi ogni immagine una sola volta; per un'etichetta illeggibile preferisci `mutool draw -F stext`/crop a un render full-page. Vietato ri-renderizzare pagine già viste. Dopo la compilazione usa `qa.sh`: renderizza **solo le pagine con overflow reale** segnalate da `qa_geom` (gutter ≥ 1 cella o margine oltre tolleranza; ignora il margine entro tolleranza), al più 3 render di controllo.

**Path assoluti**: tutti i comandi usano path assoluti. Radice repo = `/workspace`. Vietato `../` e path relativi (soprattutto verso `/workspace/tools/` e verso l'output). I placeholder `<corso>`/`<lezione>` restano, dentro path assoluti: `/workspace/lectures/<corso>/source/<lezione>/` e `/workspace/lectures/<corso>/<corso>-<lezione>.pdf`.

# PROCEDURA

## 0. Ricognizione
`ls -la` nella dir lezione e `pdfinfo "<pdf>"` (pagine, dimensioni, cifratura). Testo: `pdftotext` → `mutool draw -F txt` → PyMuPDF. `mutool draw -F stext` (bbox/ordine di lettura) solo su pagine/aree rilevanti, mai su pagine intere. Render (solo per *leggere*, mai per produrre figure): `pdftoppm`/`pdftocairo` → PyMuPDF.

## 1. Estrazione e triage
`bash /workspace/tools/estrai.sh /workspace/lectures/<corso>/source/<lezione>` produce (costo solo CPU/tempo, zero token):
- `_pagine.tsv` — triage per pagina: `tipo` (testo/figura/tabella/scan), `render`, `ocr`. **Leggilo**: dice cosa guardare.
- `_estrazione_raw.txt` — testo pagina per pagina, spazi collassati e header/footer ripetuti rimossi. Fonte per le pagine `testo`.
- `_estrazione_layout.txt` — `-layout` solo per pagine `tabella`/`misto` (colonne allineate).
- `build/sheet-*.png` — contact sheet 3×3 delle **sole** pagine da renderizzare (figure/tabelle/scan).
- `build/formula-sheet-*.png` — contact sheet 3×3 delle pagine `testo` a contenuto matematico: usalo per verificare formule/matrici a vista.
In caso di dubbi estremi (testo sospetto, valori alterati, scansione, PDF cifrato): `bash /workspace/tools/estrai.sh --ocr /workspace/lectures/<corso>/source/<lezione>`; esegue OCR selettivo sulle pagine sospette e scrive `_crosscheck.txt` (`solo testo` = token del layer assenti nel render). Esamina le divergenze.
Costruisci `_mappa.md` (v. Fase 3). Verifica che `typst` esista; se manca, produci comunque il `.typ` e segnalalo.

## 2. Figure
Leggi `build/sheet-*.png` (9 pagine/foglio) **una sola volta**: contengono le pagine con figure/tabelle/scan. Se un'etichetta è illeggibile, render mirato **solo per leggere**: `pdftoppm -r 150 -f P -l P "<pdf>" build/pg`; in alternativa `mutool draw -F stext -o - "<pdf>" P`. Non salvare ritagli come figure.
Se dal testo emerge una figura/tabella su una pagina non renderizzata, rendila tu e guardala. Tutte le figure vanno **ridisegnate in Typst** (niente `image("*.png|jpg")`, screenshot, foto): usa pacchetti/pattern di `STYLE.md`, stesse etichette e struttura. Non descrivere ciò che non hai visto.

## 3. Antidup (`_mappa.md`)
`_mappa.md` compatto, una riga per concetto: `concetto | sezione | stato`. Un concetto = una sezione. Se ricompare con info nuove → sotto-blocco `=== Approfondimento: <aspetto>` nella prima sezione; se ripetizione → nessun nuovo blocco, eventualmente `#link(<sec>)[vedi §...]`. Non riordinare i divider: la prima occorrenza resta dove sta.

## 4. Typst (a blocchi)
Segui `STYLE.md` per vincoli tecnici, layout, firme degli helper, pattern, struttura, lunghezza. Scrivi il `.typ` **a blocchi** (skeleton + append/edit per sezione), mantenendo coerenza; dopo la prima stesura correggi SOLO con edit mirati (sostituzione del frammento errato), **mai riscrivere il file intero** dopo un errore. In testa:
```typst
#import "_preamble.typ": *
#show: doc.with(title: "<TITOLO LEZIONE>", label: "<corso>-<lezione>")
#titleblock("<TITOLO LEZIONE>", "<corso> — Lezione <n>")
```
`cp /workspace/tools/preamble.typ /workspace/lectures/<corso>/source/<lezione>/_preamble.typ`; `#titleblock` è obbligatorio. Se serve un pattern: `cp /workspace/tools/patterns/<nome>.typ /workspace/lectures/<corso>/source/<lezione>/_<nome>.typ` e usalo secondo `patterns/INDEX.md` (`modulo` → `#import`, `snippet` → `#include`). Importa i pacchetti `@preview` necessari. Non ricopiare il preamble; usa gli helper documentati in `STYLE.md`.
Ordine sezioni = ordine dei divider: `==` macro-argomento, `===` concetto. Stile telegrafico completo, zero riempitivi.

## 5. Compilazione e QA
Dalla dir lezione:
`typst compile /workspace/lectures/<corso>/source/<lezione>/<corso>-<lezione>.typ /workspace/lectures/<corso>/<corso>-<lezione>.pdf`
(nessun output intermedio in `build/`; `--font-path ./fonts` se font locali). Zero errori e zero warning; i warning di glifo si risolvono sostituendo il carattere con math mode o testo. Itera finché pulito.
Poi `bash /workspace/tools/qa.sh /workspace/lectures/<corso>/source/<lezione>` (riferimenti vietati, trappole Typst, titoli duplicati, figure, compile, DA VERIFICARE, PDF finale, controllo geometrico `qa_geom`). Correggi i FAIL e ricompila. `qa_geom` riporta l'**entità** dell'overflow: renderizza solo le pagine con overflow reale (gutter ≥ 1 cella o margine oltre tolleranza) e correggi; ignora il margine entro tolleranza.

## 6. Pattern riutilizzabili
Se ricavi un pattern di figura/struttura **generale e testato** (compile pulita), **non scriverlo in `STYLE.md`**: registralo come `/workspace/tools/patterns/<nome>.typ` (snippet completo, compilabile) e aggiungi una riga a `/workspace/tools/patterns/INDEX.md` (`nome | tipo | uso | firma`). Non duplicare i pattern esistenti; aggiungi solo quelli riutilizzabili in altre lezioni. Se la dir dei pattern non è scrivibile, non forzare: descrivi il pattern nel report finale. Nel report finale elenca i pattern aggiunti.

# REPORT FINALE (nel messaggio, non nel .typ)
1. File creati (percorsi completi) e nome adottato con deduzione di `<corso>`/`<lezione>`.
2. PDF usati e ordine; strumenti e limiti.
3. Pagine/slide scartate con motivo (incluso contenuto amministrativo omesso); pagine renderizzate.
4. Figure incluse (file ↔ origine) ed eventuali escluse con motivo.
5. `DA VERIFICARE` e contenuti non fedeli (cosa servirebbe per risolverli).
6. Correzioni minime effettuate (dove e perché); mismatch OCR risolti se il cross-check è stato eseguito.
7. Conteggio pagine finali vs target.