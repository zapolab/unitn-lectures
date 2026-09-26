#!/usr/bin/env bash
# estrai.sh — ricognizione lezione: triage pagine + testo pulito + render selettivo.
# Uso: estrai.sh [lesson_dir]   (default: .)
# Produce:
#   _pagine.tsv            triage per pagina: tipo, flag render, metriche
#   _estrazione_raw.txt    testo pagina per pagina pulito (spazi collassati, header/footer ripetuti rimossi)
#   _estrazione_layout.txt testo -layout SOLO per le pagine tabella/misto
#   build/pg-*.png         render SOLO delle pagine con figure/tabelle/scan
#   build/sheet-*.png      contact sheet delle sole pagine renderizzate (tile 3x3)
#   build/formula-sheet-*.png  contact sheet delle pagine testo a contenuto matematico (tile 3x3, alta densita')
# Il triage usa PyMuPDF (pymupdf). Se assente, avvisa e renderizza tutte le pagine (legacy).
# Solo CPU/tempo, nessun costo token.
set -euo pipefail

args=()
while [ $# -gt 0 ]; do
  args+=("$1")
  shift
done
d="${args[0]:-.}"; cd "$d"
mkdir -p build
command -v pdftotext >/dev/null || { echo "ERRORE: pdftotext mancante"; exit 1; }

shopt -s nullglob
pdfs=( $(ls -v *.pdf 2>/dev/null) )
[ ${#pdfs[@]} -eq 0 ] && { echo "ERRORE: nessun PDF in $d"; exit 1; }

rm -f build/pg-*.png build/sheet-*.png build/formula-sheet-*.png build/_fx-*.png build/_*.tsv build/_*.txt build/_*.png
: > _pagine.tsv
: > _estrazione_raw.txt
: > _estrazione_layout.txt

have_fitz=0
python3 -c 'import pymupdf' 2>/dev/null && have_fitz=1

# ---- 1. triage per pagina (PyMuPDF) ----
if [ "$have_fitz" -eq 1 ]; then
  python3 - "$PWD" "${pdfs[@]}" <<'PY'
import sys, os, statistics
import pymupdf

wd = sys.argv[1]
pdfs = sys.argv[2:]
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

nfig = ntab = nscan = ntesto = nrender = 0
out = open("_pagine.tsv", "w", encoding="utf-8")
out.write("# _pagine.tsv — triage estrai.sh. Col: idx file pagina tipo render chars img% draw tab\n")
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
    if tipo == "figura": nfig += 1
    elif tipo == "tabella": ntab += 1
    elif tipo == "scan": nscan += 1
    else: ntesto += 1
    nrender += render
    out.write("%04d\t%s\t%d\t%s\t%d\t%d\t%.1f\t%d\t%d\n" % (idx, f, p, tipo, render, ch, ip, nd, nt))
out.close()
print("Triage: %d figura, %d tabella, %d scan, %d testo | render %d" %
      (nfig, ntab, nscan, ntesto, nrender))
PY
else
  echo "ATTENZIONE: pymupdf assente -> nessun triage, renderizzo tutte le pagine (legacy)."
  idx=0
  for f in "${pdfs[@]}"; do
    n=$(pdfinfo "$f" | awk '/^Pages:/{print $2}')
    for p in $(seq 1 "$n"); do
      idx=$((idx+1))
      printf '%04d\t%s\t%s\ttesto\t1\t0\t0\t0\t0\n' "$idx" "$f" "$p" >> _pagine.tsv
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
while IFS=$'\t' read -r i f p tipo render ch ip nd nt; do
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

# ---- 4b. formula sheet: contact sheet delle pagine testo a contenuto matematico ----
# Le pagine `testo` non vengono renderizzate singolarmente: per verificare formule e
# matrici a vista si costruisce un unico contact sheet delle pagine con piu' indicatori
# matematici (matrici, atan2, sqrt, notazione c_/s_, ecc.).
python3 - "$PWD" <<'PY'
import sys, os, re
wd = sys.argv[1]; os.chdir(wd)
meta = {}
with open("_pagine.tsv", encoding="utf-8") as fh:
    for ln in fh:
        if ln.startswith("#") or not ln.strip():
            continue
        c = ln.rstrip("\n").split("\t")
        meta[int(c[0])] = {"file": c[1], "page": int(c[2]), "tipo": c[3], "render": int(c[4])}
# testo per pagina: l'indice globale e' l'ordine dei marker "=== PAGE ==="
pages = {}
seq = 0; cur = None
for ln in open("_estrazione_raw.txt", encoding="utf-8", errors="ignore"):
    if re.match(r"=== PAGE \d+ ===", ln):
        seq += 1; cur = seq; pages[cur] = []
    elif ln.startswith("====="):
        cur = None
    elif cur is not None:
        pages[cur].append(ln)
strong = re.compile(r"(?:cos|sin)\s*\(|atan2|√|[αβγδθφψηεξ]|[=≠≤≥]|\bR[xyz]?\b")
def score(txt):
    return len(strong.findall(txt))
sel = []
for idx, m in meta.items():
    if m["tipo"] != "testo" or m["render"] == 1:
        continue
    sc = score("\n".join(pages.get(idx, [])))
    if sc >= 4:
        sel.append((idx, m["file"], m["page"], sc))
sel.sort(key=lambda x: -x[3])
sel = sel[:18]
sel.sort(key=lambda x: x[0])
with open("build/_formula_pages.tsv", "w", encoding="utf-8") as out:
    for idx, f, p, sc in sel:
        out.write("%s\t%s\t%s\t%s\n" % (idx, f, p, sc))
print("Formula sheet: %d pagine testo a contenuto matematico" % len(sel))
PY
if [ -s build/_formula_pages.tsv ] && command -v pdftoppm >/dev/null && command -v convert >/dev/null && command -v identify >/dev/null; then
  : > build/_fx_list.txt
  while IFS=$'\t' read -r i f p sc; do
    pdftoppm -r 150 -f "$p" -l "$p" -png -singlefile "$f" "build/_fx-$i" >/dev/null 2>&1 || true
    if [ -f "build/_fx-$i.png" ]; then echo "build/_fx-$i.png" >> build/_fx_list.txt; fi
  done < build/_formula_pages.tsv
  if [ -s build/_fx_list.txt ]; then
    mapfile -t imgs < build/_fx_list.txt
    w=$(identify -format '%w' "${imgs[0]}"); h=$(identify -format '%h' "${imgs[0]}")
    convert -size "${w}x${h}" xc:'#DDDDDD' build/_fxblank.png
    tile=3; per=$((tile*tile)); total=${#imgs[@]}; idx=0; sheet=0
    while [ $idx -lt $total ]; do
      rows=()
      for r in $(seq 0 $((tile-1))); do
        cols=()
        for c in $(seq 0 $((tile-1))); do
          k=$((idx + r*tile + c))
          if [ $k -lt $total ]; then cols+=("${imgs[$k]}"); else cols+=("build/_fxblank.png"); fi
        done
        row=$(printf 'build/_fxrow%d_%d.png' "$sheet" "$r")
        convert "${cols[@]}" +append "$row"; rows+=("$row")
      done
      convert "${rows[@]}" -append -bordercolor '#DDDDDD' -border 6 "build/formula-sheet-$sheet.png"
      idx=$((idx+per)); sheet=$((sheet+1))
    done
    echo "Formula sheet: build/formula-sheet-*.png ($sheet fogli, ${total} pagine)"
  fi
  rm -f build/_fx-*.png build/_fxblank.png build/_fxrow*.png build/_fx_list.txt
fi
rm -f build/_formula_pages.tsv

echo "Testo: _estrazione_raw.txt ($(wc -l < _estrazione_raw.txt) righe), _estrazione_layout.txt ($(wc -l < _estrazione_layout.txt) righe)"
echo "Triage: _pagine.tsv ($(grep -c -v '^#' _pagine.tsv) pagine, $(awk -F'\t' '!/^#/ && $5==1' _pagine.tsv | wc -l) da renderizzare)"
