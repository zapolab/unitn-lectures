---
description: Riassume una lezione (PDF in lectures/<corso>/source/<lezione>/) in Typst + PDF
---

@PROMPT.md

Argomenti del comando: corso = `$1`, lezione = `$2`.
Istruzioni extra opzionali (tutto ciò che segue i primi due argomenti): `$ARGUMENTS`.
Se `$1` è un file `.pdf`, trattalo come forma `@<pdf>`; altrimenti corso=`$1`, lezione=`$2`.
Le istruzioni extra sono vincoli aggiuntivi dell'utente (es. "tralascia questo e quello"):
restringono lo scope rispetto a PROMPT.md, prevalgono in caso di conflitto e vanno registrate nel report finale.
Applica la procedura di PROMPT.md alla lettera (incluso STYLE.md).
Uso: /summarize DATABASES 02 [istruzioni] oppure /summarize /path/file.pdf [istruzioni].
