#!/usr/bin/env bash
# estrai.sh — ricognizione lezione: testo per pagina + contact sheet figure + cross-check OCR.
# Uso: estrai.sh [--ocr] [--ocr-lang LANG] [lesson_dir]   (default: .)
# Produce:
#   _estrazione_raw.txt   testo pagina per pagina (tutti i PDF, ordine naturale)
#   build/sheet-*.png     contact sheet figure (tile 3x3)
#   _crosscheck.txt       divergenze OCR vs layer testuale (solo con --ocr; vuoto se nessuna)
# Il cross-check OCR è spento di default: attivalo con --ocr solo in caso di dubbi estremi.
# Solo CPU/tempo, nessun costo token.
set -euo pipefail

ocr=0
ocr_lang=eng
args=()
while [ $# -gt 0 ]; do
  case "$1" in
    --ocr) ocr=1 ;;
    --ocr-lang) shift; ocr_lang="${1:-eng}" ;;
    *) args+=("$1") ;;
  esac
  shift
done
d="${args[0]:-.}"; cd "$d"
mkdir -p build fig
command -v pdftotext >/dev/null || { echo "ERRORE: pdftotext mancante"; exit 1; }

shopt -s nullglob
pdfs=( $(ls -v *.pdf 2>/dev/null) )
[ ${#pdfs[@]} -eq 0 ] && { echo "ERRORE: nessun PDF in $d"; exit 1; }

rm -f build/_txt_p*.txt build/_ocr_p*.txt build/_ocr_p*.png build/_pagemap.tsv
: > _estrazione_raw.txt
if [ "$ocr" -eq 1 ]; then : > build/_pagemap.tsv; fi
idx=0
i=0
for f in "${pdfs[@]}"; do
  i=$((i+1))
  n=$(pdfinfo "$f" | awk '/^Pages:/{print $2}')
  echo "===== FILE $i: $f ($n pagine) =====" >> _estrazione_raw.txt
  for p in $(seq 1 "$n"); do
    idx=$((idx+1))
    tag=$(printf '%04d' "$idx")
    echo "=== PAGE $p ===" >> _estrazione_raw.txt
    pdftotext -layout -nopgbrk -f "$p" -l "$p" "$f" - >> _estrazione_raw.txt || true
    if [ "$ocr" -eq 1 ]; then
      pdftotext -layout -nopgbrk -f "$p" -l "$p" "$f" "build/_txt_p$tag.txt" 2>/dev/null || true
      printf '%s\t%s\t%s\n' "$tag" "$f" "$p" >> build/_pagemap.tsv
    fi
  done
  if command -v pdftoppm >/dev/null; then
    pdftoppm -r 90 -png "$f" "build/_p$i" >/dev/null 2>&1 || true
  fi
done

# ---- contact sheet ----
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

# ---- cross-check OCR (solo con --ocr) ----
if [ "$ocr" -eq 1 ]; then
  if command -v tesseract >/dev/null && command -v pdftoppm >/dev/null && command -v python3 >/dev/null; then
    : > _crosscheck.txt
    while IFS=$'\t' read -r tag f p; do
      [ -n "${tag:-}" ] || continue
      pdftoppm -r 300 -f "$p" -l "$p" -png -singlefile "$f" "build/_ocr_p$tag" >/dev/null 2>&1 || true
      if [ -f "build/_ocr_p$tag.png" ]; then
        tesseract "build/_ocr_p$tag.png" "build/_ocr_p$tag" -l "$ocr_lang" >/dev/null 2>&1 || true
      fi
    done < build/_pagemap.tsv
    if ! ls build/_ocr_p*.txt >/dev/null 2>&1; then
      echo "Cross-check OCR: nessun output OCR (language pack '$ocr_lang' mancante?)"
    fi
    python3 - "$PWD/build" <<'PY'
import sys, os, re, math
from difflib import SequenceMatcher

build = sys.argv[1]
tokre = re.compile(r"[a-z0-9_][a-z0-9_./:%-]*")

def toks(s):
    return set(tokre.findall(s.lower()))

def close(a, b):
    if abs(len(a) - len(b)) > 2:
        return False
    return SequenceMatcher(None, a, b).ratio() >= 0.72

pages = []
mapf = os.path.join(build, "_pagemap.tsv")
with open(mapf, encoding="utf-8", errors="ignore") as fh:
    for line in fh:
        line = line.rstrip("\n")
        if not line:
            continue
        tag, f, p = line.split("\t")
        tf = os.path.join(build, "_txt_p%s.txt" % tag)
        of = os.path.join(build, "_ocr_p%s.txt" % tag)
        if not (os.path.exists(tf) and os.path.exists(of)):
            continue
        t = toks(open(tf, encoding="utf-8", errors="ignore").read())
        o = toks(open(of, encoding="utf-8", errors="ignore").read())
        only_t = set(w for w in t - o if not any(close(w, x) for x in o))
        only_o = set(w for w in o - t if not any(close(w, x) for x in t))
        pages.append([tag, f, p, only_t, only_o])

npages = len(pages)
thr = max(3, math.ceil(0.25 * npages)) if npages else 3
counts = {}
for _, _, _, _, oo in pages:
    for w in oo:
        counts[w] = counts.get(w, 0) + 1

flagged = []
noise_pages = 0
for tag, f, p, ot, oo in pages:
    if not ot:
        if oo:
            noise_pages += 1
        continue
    oo = sorted(w for w in oo if counts.get(w, 0) < thr)
    flagged.append((tag, f, p, sorted(ot), oo))

out = os.path.join(os.path.dirname(build), "_crosscheck.txt")
with open(out, "w", encoding="utf-8") as fh:
    if flagged:
        fh.write("# Divergenze OCR vs layer testuale. 'solo testo' = token del layer assente nel render/OCR (direzione utile).\n")
        fh.write("# 'solo OCR' elencato solo nelle pagine con 'solo testo' (altrove e' rumore grafico: logo, decorazioni, errori OCR).\n")
        for tag, f, p, ot, oo in flagged:
            fh.write("=== %s pagina %s (idx %s) ===\n" % (f, p, tag))
            fh.write("  solo testo: %s\n" % " ".join(ot[:40]))
            if oo:
                fh.write("  solo OCR:   %s\n" % " ".join(oo[:40]))
        if noise_pages:
            fh.write("# %d pagine con sole divergenze OCR (probabile rumore grafico) omesse.\n" % noise_pages)
print("Cross-check OCR: %d pagine con 'solo testo'; %d pagine con solo rumore OCR" % (len(flagged), noise_pages))
PY
    rm -f build/_txt_p*.txt build/_ocr_p*.txt build/_ocr_p*.png build/_pagemap.tsv
  else
    rm -f build/_txt_p*.txt build/_pagemap.tsv _crosscheck.txt
    echo "Cross-check OCR saltato: manca tesseract, pdftoppm o python3"
  fi
else
  rm -f build/_txt_p*.txt build/_pagemap.tsv _crosscheck.txt
fi

echo "Testo: _estrazione_raw.txt ($(wc -l < _estrazione_raw.txt) righe)"
echo "Pagine renderizzate: ${npages:-0}"
