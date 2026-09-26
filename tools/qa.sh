#!/usr/bin/env bash
# qa.sh — controlli finali sulla lezione. Uso: qa.sh [lesson_dir]   (default: .)
# Non modifica il PDF di output: compila su file temporaneo.
set -uo pipefail
d="${1:-.}"; cd "$d"
fail=0
note(){ printf '%-6s %s\n' "$1" "$2"; }

typ=$(ls -1 *.typ 2>/dev/null | grep -v '^_preamble\.typ$' | head -1)
[ -z "${typ:-}" ] && { echo "ERRORE: nessun .typ nella dir"; exit 2; }

# 1. riferimenti vietati a pagine/slide
if grep -nE 'p\. [0-9]|slide [0-9]|pag\. [0-9]|vedi sopra|come visto' "$typ"; then
  note FAIL "riferimenti a pagine/slide"; fail=1
else note OK "nessun riferimento a pagine/slide"; fi

# 1b. trappole Typst (zero token: becca prima della compilazione)
# Ignora blocchi ``` e codice inline `...`: lì ** e rg() possono essere legittimi.
logic=$(awk 'BEGIN{f=0} /^[ \t]*```/{f=!f; next} !f' "$typ" | sed -E 's/`[^`]*`//g')
if printf '%s\n' "$logic" | grep -nE '\*\*'; then
  note FAIL "grassetto markdown ** (in Typst usa *x*)"; fail=1
else note OK "nessun ** markdown"; fi
if printf '%s\n' "$logic" | grep -nE '\bltimes\b|times\.circle|\brg\('; then
  note FAIL "funzioni inesistenti: ltimes/times.circle/rg"; fail=1
else note OK "nessuna funzione Typst inesistente"; fi

# 2. titoli duplicati
dups=$(grep -oE '^=+ .*' "$typ" | sed 's/^=* //' | sort | uniq -d)
if [ -n "$dups" ]; then note FAIL "titoli duplicati:"; echo "$dups"; fail=1
else note OK "nessun titolo duplicato"; fi

# 3. figure: nessun raster, solo vettoriale Typst
if grep -nE 'image\(|fig/' "$typ"; then
  note FAIL "immagine raster / dir fig nel .typ (vietate)"; fail=1
else note OK "nessuna immagine raster"; fi

# 3b. titleblock obbligatorio
if grep -q '#titleblock(' "$typ"; then note OK "titleblock presente"
else note FAIL "titleblock mancante"; fail=1; fi

# 4. compilazione pulita (zero errori/warning)
mkdir -p build
qa_tmp="build/_qa_build.pdf"
out=$(typst compile "$typ" "$qa_tmp" 2>&1 || true)
rm -f "$qa_tmp"
if [ -n "$out" ]; then echo "$out"; note FAIL "compile con errori/warning"; fail=1
else note OK "compile pulita"; fi

# 5. artefatti di triage
if [ -f _pagine.tsv ]; then
  ntot=$(grep -c -v '^#' _pagine.tsv 2>/dev/null || true)
  nren=$(awk -F'\t' '!/^#/ && $5==1' _pagine.tsv 2>/dev/null | wc -l)
  note INFO "_pagine.tsv: $ntot pagine, $nren da renderizzare"
else note INFO "_pagine.tsv assente"; fi
[ -f _mappa.md ] && note OK "_mappa.md presente" || note INFO "_mappa.md assente"

# 6. PDF finale
parent=$(basename "$(cd ../.. && pwd)")   # corso = dir che contiene source/
lesson=$(basename "$(pwd)")               # lezione
pdf="../../$parent-$lesson.pdf"
[ -f "$pdf" ] && note OK "PDF: $pdf ($(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/{print $2}') pagine)" \
             || { note FAIL "PDF mancante: $pdf"; fail=1; }

# 7. controllo geometrico (overflow gutter/margine) — WARN non bloccante
if [ -f "$pdf" ]; then
  python3 /workspace/tools/qa_geom.py "$pdf"
else note INFO "qa_geom saltato: PDF assente"; fi

exit $fail
