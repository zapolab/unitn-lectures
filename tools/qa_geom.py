#!/usr/bin/env python3
# qa_geom.py — controllo geometrico del PDF finale (overflow di colonna/margine).
# Uso: qa_geom.py <pdf>
# Rileva celle di testo nella banda del gutter (tra le due colonne) o oltre i
# margini laterali. Non bloccante: stampa OK oppure WARN con le pagine sospette,
# che sono le sole da renderizzare per la verifica visiva. Sempre exit 0.
#
# Geometria attesa (preamble: margin x 13mm, top 12mm, bottom 13mm, 2 colonne):
#   - header nella banda superiore (y1 < 12mm)   -> ignorato
#   - numero di pagina nella banda inferiore (y0 > H-13mm) -> ignorato
#   - titleblock a piena larghezza su pagina 1 (y1 < 62pt) -> ignorato
#   - gutter: banda [mid-4, mid+4] (1em/2 = 4.2pt)
import sys
import pymupdf

MM = 72 / 25.4
MX = 13 * MM          # margine laterale
TOP = 12 * MM         # margine superiore (header)
BOT = 13 * MM         # margine inferiore (numero pagina)
GUT = 4.0             # semi-ampiezza banda gutter


def titleblock_bottom(pg, W):
    # pagina 1: la riga a piena larghezza piu' in basso nella fascia alta chiude
    # il titleblock (l'altra, piu' in alto, e' la rule dell'header).
    ys = []
    for d in pg.get_drawings():
        r = d["rect"]
        if r.height < 2 and r.width > 0.8 * (W - 2 * MX) and 20 < r.y0 < 150:
            ys.append(r.y0)
    return (max(ys) + 2) if ys else 62.0


def main(path):
    doc = pymupdf.open(path)
    pages = {}
    for n, pg in enumerate(doc, 1):
        W, H = pg.rect.width, pg.rect.height
        mid = W / 2
        title_y = titleblock_bottom(pg, W) if n == 1 else 0.0
        for x0, y0, x1, y1, t, *_ in pg.get_text("words"):
            if y1 < TOP or y0 > H - BOT:
                continue
            if n == 1 and y1 < title_y:
                continue
            if x0 < mid + GUT and x1 > mid - GUT:
                pages.setdefault(n, {"gutter": [], "margine": []})["gutter"].append(t)
            elif x1 > W - MX + 2 or x0 < MX - 2:
                pages.setdefault(n, {"gutter": [], "margine": []})["margine"].append(t)
    doc.close()

    if not pages:
        print("OK     qa_geom: nessun overflow di colonna/margine")
        return

    tot = sum(len(v["gutter"]) + len(v["margine"]) for v in pages.values())
    print("WARN   qa_geom: %d pagine con possibile overflow (%d celle in gutter/oltre margine)"
          % (len(pages), tot))
    for n in sorted(pages):
        g, m = pages[n]["gutter"], pages[n]["margine"]
        sample = (g + m)[:3]
        print("       p.%d: gutter %d, margine %d es. %s"
              % (n, len(g), len(m), ", ".join(map(repr, sample))))


if __name__ == "__main__":
    try:
        main(sys.argv[1])
    except IndexError:
        print("Uso: qa_geom.py <pdf>")
    sys.exit(0)
