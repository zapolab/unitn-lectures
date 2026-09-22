#!/usr/bin/env bash
# estrai.sh — ricognizione lezione: testo per pagina + contact sheet figure.
# Uso: estrai.sh [lesson_dir]   (default: .)
# Produce: _estrazione_raw.txt (testo pagina per pagina), build/sheet-*.png (montage).
set -euo pipefail
d="${1:-.}"; cd "$d"
mkdir -p build fig
command -v pdftotext >/dev/null || { echo "ERRORE: pdftotext mancante"; exit 1; }

shopt -s nullglob
pdfs=( $(ls -v *.pdf 2>/dev/null) )
[ ${#pdfs[@]} -eq 0 ] && { echo "ERRORE: nessun PDF in $d"; exit 1; }

: > _estrazione_raw.txt
i=0
for f in "${pdfs[@]}"; do
  i=$((i+1))
  n=$(pdfinfo "$f" | awk '/^Pages:/{print $2}')
  echo "===== FILE $i: $f ($n pagine) =====" >> _estrazione_raw.txt
  for p in $(seq 1 "$n"); do
    echo "=== PAGE $p ===" >> _estrazione_raw.txt
    pdftotext -layout -nopgbrk -f "$p" -l "$p" "$f" - >> _estrazione_raw.txt || true
  done
  if command -v pdftoppm >/dev/null; then
    pdftoppm -r 90 -png "$f" "build/_p$i" >/dev/null 2>&1 || true
  fi
done

if command -v convert >/dev/null && ls build/_p*.png >/dev/null 2>&1; then
  imgs=( $(ls -v build/_p*.png) )
  w=$(identify -format '%w' "${imgs[0]}"); h=$(identify -format '%h' "${imgs[0]}")
  convert -size "${w}x${h}" xc:'#DDDDDD' build/_blank.png
  tile=3; per=$((tile*tile)); total=${#imgs[@]}; idx=0; sheet=0
  while [ $idx -lt $total ]; do
    rows=()
    for r in $(seq 0 $((tile-1))); do
      cols=()
      for c in $(seq 0 $((tile-1))); do
        k=$((idx + r*tile + c))
        if [ $k -lt $total ]; then cols+=("${imgs[$k]}"); else cols+=("build/_blank.png"); fi
      done
      row=$(printf 'build/_row%d_%d.png' "$sheet" "$r")
      convert "${cols[@]}" +append "$row"; rows+=("$row")
    done
    convert "${rows[@]}" -append -bordercolor '#DDDDDD' -border 6 "build/sheet-$sheet.png"
    idx=$((idx+per)); sheet=$((sheet+1))
  done
  rm -f build/_blank.png build/_row*.png
  npages=${total}; rm -f build/_p*.png
  echo "Contact sheet: build/sheet-*.png ($sheet fogli, tile ${tile}x${tile})"
fi
echo "Testo: _estrazione_raw.txt ($(wc -l < _estrazione_raw.txt) righe)"
echo "Pagine renderizzate: ${npages:-0}"
