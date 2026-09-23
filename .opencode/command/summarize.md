---
description: Riassume una lezione (PDF in lectures/<corso>/source/<lezione>/) in Typst + PDF
---

@PROMPT.md

Argomenti del comando: corso = `$1`, lezione = `$2`.
Se `$1` è un file `.pdf`, trattalo come forma `@<pdf>`; altrimenti corso=`$1`, lezione=`$2`.
Applica la procedura di PROMPT.md alla lettera (incluso STYLE.md).
Uso: /summarize DATABASES 02 oppure /summarize /path/file.pdf.
