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

# 3. figure: ogni fig/ referenziato esiste; nessun orfano
refs=$(grep -oE 'fig/[A-Za-z0-9_.-]+' "$typ" | sort -u || true)
for r in $refs; do [ -f "$r" ] || { note FAIL "fig mancante: $r"; fail=1; }; done
if [ -d fig ]; then
  shopt -s nullglob
  for f in fig/*; do grep -q "$f" "$typ" || note WARN "fig orfano: $f"; done
fi
[ -n "$refs" ] && note OK "figure referenziate: $(echo "$refs" | wc -l)"

# 4. compilazione pulita (zero errori/warning)
out=$(typst compile "$typ" /tmp/_qa_build.pdf 2>&1 || true)
if [ -n "$out" ]; then echo "$out"; note FAIL "compile con errori/warning"; fail=1
else note OK "compile pulita"; fi

# 5. DA VERIFICARE raccolti
n=$(grep -c 'DA VERIFICARE' "$typ" || true)
note INFO "DA VERIFICARE: $n"

# 6. PDF finale
parent=$(basename "$(cd ../.. && pwd)")   # corso = dir che contiene source/
lesson=$(basename "$(pwd)")               # lezione
pdf="../../$parent-$lesson.pdf"
[ -f "$pdf" ] && note OK "PDF: $pdf ($(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/{print $2}') pagine)" \
             || { note FAIL "PDF mancante: $pdf"; fail=1; }

exit $fail
