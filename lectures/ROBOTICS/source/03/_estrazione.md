# _estrazione.md — mapping interno (NON deliverable)

PDF: 03lect.pdf, 132 pagine fisiche, footer 1/107. Beamer 4:3, molti overlay
(una slide logica spezzata su piu' pagine). Testo estratto con `pdftotext -layout`.

## Struttura logica (divider/footer)
- p1: title slide (SCARTATA)
- p2, p9-10, p22, p42, p74, p80, p87-88, p94, p101, p108, p115, p124: Outline (navigazione, SCARTATE)
- p3-8: Fundamental Rotation Matrices + Matlab + scriptDraw
- p11-21: Composition of Rotation Matrices (current/fixed axes, esempi)
- p23-34: Parametrisation, Euler, RPY, Gimbal Lock
- p35-41: Axis and Rotation (axis-angle)
- p43-73: Quaternions (definition, vector products, product, conjugate, inverse, unit-length, rotations, matrix<->quat, composition, summary)
- p75-79: Homogeneous Transformations (frame position, direct/inverse, homogeneous coordinates)
- p81-86: Matlab Examples Homogeneous (homogeneousTrans, scriptDrawHom, scriptDrawHom1, scriptTestTriad, scriptTransformTest, scriptTransformTriads)
- p89-132: "Some questions for you" (Q&A recap) -> TUTTO DUPLICATO, escluso per antidup

## Pagine con overlay (build progressivi, contenuto incrementale):
- p28-34 (Gimbal Lock: stessa slide, bullet aggiunti)
- p38-41 (Axis and Rotation)
- p43-46 (Quaternions intro)
- p47-48 (Definition)
- p50-54 (Vector products / product)
- p57-59 (complex)
- p61-62, 69-73 (summary)

## Figure presenti
- Diagrammi di frame ruotati (p5,13,14,15,17,18,19,20,21,25,31,35,60,61,75,76)
- Plot Matlab (p8,26,82,83,84,85,86)
- Nessuna figura raster "scientifica": tutti schemi concettuali -> RIDISEGNATI (Fase 2.1)
- Nessun raster incollato.

## Testo corrotto/ambiguo
- Matrici estratte con layout rotto (righe fuori ordine). Ricostruite dalle formule
  standard esplicite nel testo + listing Matlab.
- p36: una cella stampata "ry sθ" (refuso di estrazione), p64/p65 confermano "ky sθ".
- p76: riga footer interlacciata col testo ("involves both a matrix transpose and a
  matrix-vector product").
- p27/p30: formule atan2 estratte su piu' righe, ricostruite.
