# Estrazione — DATABASES / 02

PDF: `02-mariadb-and-basics-sql.pdf` (29 pagine, 453.54x255.12 pt, non cifrato).
Strumenti: `pdftotext -layout`, `mutool draw -F txt`, `pdftoppm` + `tesseract` (cross-check).
Nota ambiente: il canale visivo (immagini) ha alterato alcuni valori (es. `127.0.0.1` invece di `[IP_ADDRESS]`); la trascrizione si basa su layer testuale + OCR da disco, concordanti.

## Mappa pagina -> contenuto

| pag | contenuto | esito |
|-----|-----------|-------|
| 1 | Titolo, autore, data | omessa (amministrativo) |
| 2 | Relational DBMS - Main Options | inclusa |
| 3 | Differences | inclusa (omesso bullet esame) |
| 4 | DBMS High-level Architecture + figura client-server | inclusa |
| 5 | SQLite3 is a notable exception + figura | inclusa |
| 6 | Remarks | inclusa |
| 7 | In practice | inclusa |
| 8 | Installing MariaDB (solo link) | nomi risorse, URL omessi |
| 9 | Fallback option — "DBeaver with SQLite3" | inclusa (didascalia) |
| 10 | Specific Installation Guides: Linux (solo link) | omessa (solo link) |
| 11 | Specific Installation Guides: Linux (comandi Arch) | inclusa |
| 12 | Specific Installation Guides: OSX (homebrew/docker + link) | inclusa |
| 13 | Specific Installation Guides: OSX (comandi, troncati) | inclusa + warn |
| 14 | Specific Installation Guides: Windows (link) | nomi, URL omessi |
| 15 | Specific Installation Guides: Docker/Podman | inclusa |
| 16 | Docker/Podman (comando) | inclusa |
| 17 | Persisting data with podman/docker (comando) | inclusa + warn |
| 18 | Connecting to the server | inclusa |
| 19 | Explanation | inclusa |
| 20 | Part II (divider) | inclusa |
| 21 | Databases + tabella esempio | inclusa |
| 22 | Creating a database and a user | inclusa |
| 23 | Creating a Table | inclusa |
| 24 | Populating data | inclusa |
| 25 | Insert Example (valori troncati) | inclusa + warn |
| 26 | Loading from a dump | inclusa |
| 27 | Exercise | inclusa |
| 28 | SQL Basics | inclusa |
| 29 | Some queries | inclusa (correzione refuso) |

## Figure

- p4: Client_1, Client_2 -> Port -> DBMS (client-server). Ridisegnata con fletcher.
- p5: sqlite3 / DBeaver -> SQLite Database (file: database.db); etichette archi "direct file access", "JDBC / file driver". Ridisegnata con fletcher.
- p21: tabella Name/Surname/Phone/… (John Doe +1…, Jane Doe +2…). Ridisegnata con `#tbl`.

## Pagine mute / scartate

- p1: presentazione (amministrativo).
- p10: sola lista di URL (link) -> omessa per regola.
- p9: nessuna figura con etichette visibile; resta solo la didascalia testuale.

## Divergenze OCR / note

- OCR concorda col layer testuale su `[IP_ADDRESS]` (pp16,17,18,22). Il canale visivo mostrava `127.0.0.1`: scartato.
- `_crosscheck.txt`: 7 pagine con "solo testo", tutte rumore OCR (logo/etichette), nessuna redazione sospetta.
- p13: comando troncato a fine riga (overflow della slide).
- p25: valori INSERT troncati a destra (overflow della slide).
- p29: "signupdate" vs "signup_date" -> corretto (refuso, v. report).
