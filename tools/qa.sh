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
out=$(typst compile "$typ" /tmp/_qa_build.pdf 2>&1 || true)
if [ -n "$out" ]; then echo "$out"; note FAIL "compile con errori/warning"; fail=1
else note OK "compile pulita"; fi

# 5. DA VERIFICARE raccolti
n=$(grep -c 'DA VERIFICARE' "$typ" || true)
note INFO "DA VERIFICARE: $n"

# 5b. cross-check OCR
if [ -f _crosscheck.txt ]; then
  nc=$(grep -c '^===' _crosscheck.txt 2>/dev/null || true)
  if [ "${nc:-0}" -gt 0 ]; then note INFO "_crosscheck.txt: $nc pagine con divergenze OCR da verificare"
  else note OK "_crosscheck.txt: nessuna divergenza OCR"; fi
else note INFO "_crosscheck.txt assente (cross-check OCR non eseguito)"; fi

# 6. PDF finale
parent=$(basename "$(cd ../.. && pwd)")   # corso = dir che contiene source/
lesson=$(basename "$(pwd)")               # lezione
pdf="../../$parent-$lesson.pdf"
[ -f "$pdf" ] && note OK "PDF: $pdf ($(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/{print $2}') pagine)" \
             || { note FAIL "PDF mancante: $pdf"; fail=1; }

exit $fail
