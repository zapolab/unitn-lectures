# Estrazione interna — ROBOTICS 04 (Geometric Background)

PDF: `04lect.pdf` — 22 pagine, beamer 362.835 x 272.126 pt, non cifrato, testo estraibile.
Estrazione: `pdftotext -layout` pagina per pagina. Figure ispezionate con `pdftoppm -r 150`.

| Pag | Contenuto | Uso |
|-----|-----------|-----|
| 1 | Titolo "Geometric Background", corso, docente | SCARTATA (presentazione) |
| 2 | Outline: "Pose of a Rigid Body in 3D Euclidean Space", "Rotation Matrices" | divider |
| 3 | Flashback 2D: due frame stesso origine, rotazione α, point P polari (ρ,θ), equazioni, R(α). Fig: frame 2D | contenuto |
| 4 | Pose of a Rigid Body: robots = rigid bodies; definizione pose; frame attaccato; coordinate invarianti. Fig: corpo + due frame | contenuto |
| 5 | Frame identificato da origine O' (bound vector) + unit vector x',y',z'. Formule o', x',y',z'. Fig | contenuto |
| 6 | Point P, P', OO'; P = P' + OO'; come calcolare coordinate. Fig | contenuto |
| 7 | px = P·x, py = P·y, pz = P·z. Fig (ripetuta) | contenuto |
| 8 | Sviluppo componenti con scalar product, equazioni px,py,pz | contenuto |
| 9 | Risultato matriciale [p] = R[p'] + [OO'], due forme di R | contenuto |
| 10 | Outline (ripetuta) | divider |
| 11 | Rotation Matrix: R da coordinate unit vector; elementi via scalar product. Fig/matrix | contenuto |
| 12 | Rotation Matrix (1): RR^T "which is...?" | contenuto |
| 13 | Rotation Matrix (1): frame ortonormale → R^T R = I3 → R^T = R^-1. Key Property: orthogonal, det=1 destro, det=-1 sinistro | contenuto |
| 14 | SO(3): 4 proprietà, non commutatività, gruppo non-abeliano SO(3) | contenuto |
| 15 | Elementary Rotations: rotazione α su z, x',y',z', Rz(α) | contenuto |
| 16 | Elementary Rotations (1): Ry(β), Rx(γ), Rk(-θ)=Rk^T(θ) | contenuto |
| 17 | Geometric Interpretation: R = rotazione attorno a un asse per allineare reference frame e body frame | contenuto |
| 18 | Representation of a Vector: origini coincidenti, p e p', p=...=Rp', p'=R^T p. Fig | contenuto |
| 19 | Example: generalizzazione 3D del 2D, rotazione α su z, equazioni, p'=Rz(α)^T p. Fig | contenuto |
| 20 | Rotation of a Vector: operatore, ||p||^2 = p^T p = (p')^T R^T R p' = (p')^T p'; preserva la norma | contenuto |
| 21 | Example: rotazione di p' di α su z, p polari (ρ, α+θ), equazioni, p=Rz(α)p'. Fig | contenuto |
| 22 | Summary: tre significati geometrici della rotation matrix | contenuto |

Pagine scartate: solo p.1 (titolo/presentazione). p.2 e p.10 sono divider (Outline) usati come struttura.
