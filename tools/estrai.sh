#!/usr/bin/env bash
# estrai.sh — ricognizione lezione: triage pagine + testo pulito + render selettivo + cross-check OCR.
# Uso: estrai.sh [--ocr] [--ocr-all] [--ocr-lang LANG] [lesson_dir]   (default: .)
# Produce:
#   _pagine.tsv            triage per pagina: tipo, flag render/ocr, metriche
#   _estrazione_raw.txt    testo pagina per pagina pulito (spazi collassati, header/footer ripetuti rimossi)
#   _estrazione_layout.txt testo -layout SOLO per le pagine tabella/misto
#   build/pg-*.png         render SOLO delle pagine con figure/tabelle/scan (o flaggate OCR)
#   build/sheet-*.png      contact sheet delle sole pagine renderizzate (tile 3x3)
#   _crosscheck.txt        divergenze OCR vs layer testuale (con --ocr; vuoto se nessuna)
# Il triage usa PyMuPDF (pymupdf). Se assente, avvisa e renderizza tutte le pagine (legacy).
# Solo CPU/tempo, nessun costo token.
set -euo pipefail

ocr=0
ocr_all=0
ocr_lang=eng
args=()
while [ $# -gt 0 ]; do
  case "$1" in
    --ocr) ocr=1 ;;
    --ocr-all) ocr=1; ocr_all=1 ;;
    --ocr-lang) shift; ocr_lang="${1:-eng}" ;;
    *) args+=("$1") ;;
  esac
  shift
done
d="${args[0]:-.}"; cd "$d"
mkdir -p build
command -v pdftotext >/dev/null || { echo "ERRORE: pdftotext mancante"; exit 1; }

shopt -s nullglob
pdfs=( $(ls -v *.pdf 2>/dev/null) )
[ ${#pdfs[@]} -eq 0 ] && { echo "ERRORE: nessun PDF in $d"; exit 1; }

rm -f build/pg-*.png build/sheet-*.png build/_*.tsv build/_*.txt build/_*.png
: > _pagine.tsv
: > _estrazione_raw.txt
: > _estrazione_layout.txt

have_fitz=0
python3 -c 'import pymupdf' 2>/dev/null && have_fitz=1

# ---- 1. triage per pagina (PyMuPDF) ----
if [ "$have_fitz" -eq 1 ]; then
  python3 - "$PWD" "$ocr" "$ocr_all" "${pdfs[@]}" <<'PY'
import sys, os, statistics
import pymupdf

wd = sys.argv[1]
ocr = int(sys.argv[2])
ocr_all = int(sys.argv[3])
pdfs = sys.argv[4:]
os.chdir(wd)

metrics = []
idx = 0
for f in pdfs:
    doc = pymupdf.open(f)
    for p in range(doc.page_count):
        idx += 1
        page = doc[p]
        pa = page.rect.get_area()
        d = page.get_text("dict")
        ip = 0.0
        mx = 0.0
        for b in d["blocks"]:
            if b.get("type") == 1:
                a = pymupdf.Rect(b["bbox"]).get_area()
                ip += a
                mx = max(mx, a)
        ch = len(page.get_text("text").strip())
        nd = len(page.get_drawings())
        nt = 0
        for t in page.find_tables().tables:
            if pymupdf.Rect(t.bbox).get_area() < 0.8 * pa and t.row_count >= 2 and t.col_count >= 2:
                nt += 1
        metrics.append([idx, f, p + 1, ch, 100 * ip / pa, nd, nt, 100 * mx / pa])
    doc.close()

medch = statistics.median([m[3] for m in metrics]) or 1
medi = statistics.median([m[4] for m in metrics])
medd = statistics.median([m[5] for m in metrics])
thri = max(4.0, 1.6 * medi)
thrd = max(6, medd + 4)

nfig = ntab = nscan = ntesto = nrender = nocr = 0
out = open("_pagine.tsv", "w", encoding="utf-8")
out.write("# _pagine.tsv — triage estrai.sh. Col: idx file pagina tipo render ocr chars img% draw tab\n")
for idx, f, p, ch, ip, nd, nt, mx in metrics:
    if mx > 70:
        tipo = "scan"
    elif nt > 0:
        tipo = "tabella"
    elif ip > thri or nd > thrd:
        tipo = "figura"
    else:
        tipo = "testo"
    render = 0 if tipo == "testo" else 1
    sel = (tipo == "scan") or (ch < max(80, 0.4 * medch))
    if ocr_all:
        sel = True
    ocrflag = 1 if (ocr and sel) else 0
    if tipo == "figura": nfig += 1
    elif tipo == "tabella": ntab += 1
    elif tipo == "scan": nscan += 1
    else: ntesto += 1
    nrender += render
    nocr += ocrflag
    out.write("%04d\t%s\t%d\t%s\t%d\t%d\t%d\t%.1f\t%d\t%d\n" % (idx, f, p, tipo, render, ocrflag, ch, ip, nd, nt))
out.close()
print("Triage: %d figura, %d tabella, %d scan, %d testo | render %d, OCR %d" %
      (nfig, ntab, nscan, ntesto, nrender, nocr))
PY
else
  echo "ATTENZIONE: pymupdf assente -> nessun triage, renderizzo tutte le pagine (legacy)."
  idx=0
  for f in "${pdfs[@]}"; do
    n=$(pdfinfo "$f" | awk '/^Pages:/{print $2}')
    for p in $(seq 1 "$n"); do
      idx=$((idx+1))
      printf '%04d\t%s\t%s\ttesto\t1\t0\t0\t0\t0\t0\n' "$idx" "$f" "$p" >> _pagine.tsv
    done
  done
fi

# mappa idx -> tipo (per decidere il layout)
declare -A TIPO
while IFS=$'\t' read -r i rest; do
  case "$i" in \#*|"") continue ;; esac
  TIPO[$((10#$i))]="$rest"
done < <(awk -F'\t' '!/^#/ && NF {print $1"\t"$4}' _pagine.tsv)

# ---- 2. testo per pagina (raw pulito + layout per tabelle) ----
idx=0
i=0
for f in "${pdfs[@]}"; do
  i=$((i+1))
  n=$(pdfinfo "$f" | awk '/^Pages:/{print $2}')
  echo "===== FILE $i: $f ($n pagine) =====" >> _estrazione_raw.txt
  for p in $(seq 1 "$n"); do
    idx=$((idx+1))
    echo "=== PAGE $p ===" >> _estrazione_raw.txt
    pdftotext -nopgbrk -f "$p" -l "$p" "$f" - >> _estrazione_raw.txt || true
    t="${TIPO[$idx]:-testo}"
    if [ "$t" = "tabella" ] || [ "$t" = "misto" ]; then
      echo "=== PAGE $p ===" >> _estrazione_layout.txt
      pdftotext -layout -nopgbrk -f "$p" -l "$p" "$f" - >> _estrazione_layout.txt || true
    fi
  done
done

# ---- 3. pulizia testo grezzo: collassa spazi + rimuovi header/footer ripetuti ----
python3 - _estrazione_raw.txt <<'PY'
import sys, re, math, collections

path = sys.argv[1]
lines = open(path, encoding="utf-8", errors="ignore").read().splitlines()
npages = sum(1 for ln in lines if ln.startswith("=== PAGE"))
thr = max(2, math.ceil(0.6 * npages))

def key(ln):
    return re.sub(r"\d", "", re.sub(r"[ \t]+", " ", ln).strip().lower())

def is_num(ln):
    return re.fullmatch(r"[ \t]*\d{1,4}[ \t]*", ln) is not None

counts = collections.Counter()
for ln in lines:
    if ln.startswith("=") or not ln.strip():
        continue
    k = key(ln)
    if k and len(ln) <= 80:
        counts[k] += 1
repeated = {k for k, c in counts.items() if c >= thr}
# righe solo-numero (numeri di pagina nei footer): molte -> sono footer
drop_num = sum(1 for ln in lines if not ln.startswith("=") and is_num(ln)) >= thr

# sezioni: una per pagina, per togliere header/footer solo ai bordi del blocco
blocks = []
cur = []
for ln in lines:
    if ln.startswith("="):
        if cur:
            blocks.append(cur)
        cur = [ln]
    else:
        cur.append(ln)
if cur:
    blocks.append(cur)

out = []
blank = 0
for block in blocks:
    body = [ln for ln in block if not ln.startswith("=")]
    markers = [ln for ln in block if ln.startswith("=")]
    # indici dei bordi non vuoti
    nn = [j for j, ln in enumerate(body) if ln.strip()]
    drop = set()
    if drop_num and nn:
        line0 = body[nn[0]]
        if is_num(line0):
            drop.add(nn[0])
        last = nn[-1]
        if last not in drop and is_num(body[last]):
            drop.add(last)
    body = [ln for j, ln in enumerate(body) if j not in drop]
    block = markers + body
    for ln in block:
        if ln.startswith("="):
            out.append(ln)
            blank = 0
            continue
        if not ln.strip():
            blank += 1
            if blank <= 1:
                out.append("")
            continue
        blank = 0
        if len(ln) <= 80 and key(ln) in repeated:
            continue
        if drop_num and is_num(ln):
            continue
        out.append(re.sub(r"[ \t]+", " ", ln).rstrip())

open(path, "w", encoding="utf-8").write("\n".join(out) + "\n")
PY

# ---- 4. render selettivo + contact sheet delle sole pagine renderizzate ----
idx=0
while IFS=$'\t' read -r i f p tipo render ocrflag ch ip nd nt; do
  case "$i" in \#*|"") continue ;; esac
  if [ "$render" = "1" ]; then
    pdftoppm -r 120 -f "$p" -l "$p" -png -singlefile "$f" "build/pg-$i" >/dev/null 2>&1 || true
  fi
done < _pagine.tsv

if command -v convert >/dev/null && ls build/pg-*.png >/dev/null 2>&1; then
  imgs=( $(ls -v build/pg-*.png) )
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
  echo "Contact sheet: build/sheet-*.png ($sheet fogli, tile ${tile}x${tile}, ${total} pagine renderizzate)"
fi

# ---- 5. cross-check OCR selettivo (solo con --ocr) ----
if [ "$ocr" -eq 1 ]; then
  if command -v tesseract >/dev/null && command -v pdftoppm >/dev/null && command -v python3 >/dev/null; then
    : > _crosscheck.txt
    : > build/_pagemap.tsv
    while IFS=$'\t' read -r i f p tipo render ocrflag ch ip nd nt; do
      case "$i" in \#*|"") continue ;; esac
      [ "$ocrflag" = "1" ] || continue
      tag="$i"
      pdftotext -nopgbrk -f "$p" -l "$p" "$f" "build/_txt_p$tag.txt" 2>/dev/null || true
      pdftoppm -r 300 -f "$p" -l "$p" -png -singlefile "$f" "build/_ocr_p$tag" >/dev/null 2>&1 || true
      if [ -f "build/_ocr_p$tag.png" ]; then
        tesseract "build/_ocr_p$tag.png" "build/_ocr_p$tag" -l "$ocr_lang" >/dev/null 2>&1 || true
      fi
      printf '%s\t%s\t%s\n' "$tag" "$f" "$p" >> build/_pagemap.tsv
    done < _pagine.tsv
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
with open(os.path.join(build, "_pagemap.tsv"), encoding="utf-8") as fh:
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
thr = max(2, math.ceil(0.25 * npages)) if npages else 2
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
        fh.write("# Divergenze OCR vs layer testuale (solo pagine sospette). 'solo testo' = token del layer assente nel render/OCR (direzione utile).\n")
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
    rm -f build/_txt_p*.txt build/_ocr_p*.txt build/_ocr_p*.png build/_pagemap.tsv _crosscheck.txt
    echo "Cross-check OCR saltato: manca tesseract, pdftoppm o python3"
  fi
else
  rm -f build/_txt_p*.txt build/_ocr_p*.txt build/_ocr_p*.png build/_pagemap.tsv _crosscheck.txt
fi

echo "Testo: _estrazione_raw.txt ($(wc -l < _estrazione_raw.txt) righe), _estrazione_layout.txt ($(wc -l < _estrazione_layout.txt) righe)"
echo "Triage: _pagine.tsv ($(grep -c -v '^#' _pagine.tsv) pagine, $(awk -F'\t' '!/^#/ && $5==1' _pagine.tsv | wc -l) da renderizzare)"
