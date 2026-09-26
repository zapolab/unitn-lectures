# Pattern riutilizzabili — indice

Catalogo compatto: leggi solo questo file, apri un pattern solo se ti serve.
Copia `patterns/<nome>.typ` in `_<nome>.typ` nella dir lezione.

`tipo`:
- `modulo` → `#import "_<nome>.typ": *`
- `snippet` → `#include "_<nome>.typ"`

Una voce per riga: `nome | tipo | uso | firma / cosa fa`.
I pattern qui sono pubblici solo dopo promozione manuale (v. `PROMPT.md` Fase 6).

- `geom3d` | modulo | `#import "_geom3d.typ": *` | 3D isometrico cetz; firme: `proj(p)`, `vadd(a,b)`/`smul(s,a)`/`mv(R,v)`, `I3`, `Rx(a)`/`Ry(a)`/`Rz(a)`, `axis(o,v,l,c:,dash:,len:)`, `frameR(o,R,lx,ly,lz,c:,dash:,len:)`, `rotarc(o,a,b,label,r:,c:)`; ri-esporta `canvas`/`draw`.
- `fletcher-flowchart` | snippet | `#include "_fletcher-flowchart.typ"` | diagrammi nodi+archi (flowchart, architetture, UML, alberi) con fletcher; diagramma più largo della colonna → `#scale`.
- `cetz-boxes` | modulo | `#import "_cetz-boxes.typ": cbox` | blocchi etichettati su cetz per architetture/schemi a blocchi; firma `cbox(x, y, w, h, t, fs:, fill:, stroke:)`, coordinate canvas cetz (y verso l'alto), linebreak nel testo con ` \ `; richiede `canvas`/`draw` da cetz.
