#import "_preamble.typ": *
#import "@preview/fletcher:0.5.8": diagram, node, edge

#show: doc.with(title: "MariaDB and Basics SQL", label: "DATABASES-02")
#titleblock("MariaDB and Basics SQL", "DATABASES — Lezione 2")

= Relational DBMS - Main Options

- MariaDB
- PostgreSQL
- SQLite3

We will stick to MariaDB, since it is simpler to manage.

= Differences

#cmp(
  (auto, 1fr),
  "administrator", [commands to view and manage structure (listing tables, viewing table schema, displaying and creating users, managing access and permissions, ...)],
  "user", [SQLite3 typically usable for small/medium systems; for larger installations use either MariaDB or PostgreSQL],
  "you", [learning: no difference, topics apply to all systems],
)

= DBMS High-level Architecture

Most of the DBMS systems are based on a client-server architecture:

- There is a server, which manages the databases (DBMS)
- Clients connect to interact with the databases

#scale(78%, reflow: true)[
  #figure(caption: [DBMS client-server architecture])[
    #diagram(
      node-stroke: 0.7pt + rgb("#1B4965"),
      edge-stroke: 0.8pt + rgb("#2E7D32"),
      spacing: 1.7em,
      node((0, 0), [Client_1]),
      node((1.1, 0), [Client_2]),
      node((0.55, 1.1), [Port]),
      node((1.8, 1.1), [DBMS]),
      edge((0, 0), (0.55, 1.1), "->"),
      edge((1.1, 0), (0.55, 1.1), "->"),
      edge((0.55, 1.1), (1.8, 1.1), "->"),
    )
  ]
]

= SQLite3 is a notable exception

- SQLite3 is an exception, since it is a library providing structured access to a file (e.g., `sqlite3`, `dbeaver`)
- Good fallback option to get started

#asciifig(
" sqlite3                 DBeaver
    |                       |
    | direct file access    | JDBC / file driver
    v                       v
    +-----------------------+
    |  SQLite Database      |
    |  (file: database.db)  |
    +-----------------------+",
[SQLite3 accesses the database file directly or via a driver],
)

= Remarks

- On small setups, client and server run on the same computer
- On Linux-based systems, connections happen via port or socket
- Default ports: 3306 (MariaDB), 5432 (PostgreSQL)

= In practice

Installing a DBMS requires to:

- Install the server (which usually comes with a CLI client)
- Install any other client you might want (e.g. DBeaver, phpMyAdmin)
- starting/enabling the server (where required)

= Installing MariaDB

- Installing the server and a CLI client (MariaDB getting-started guide)
- Installing a graphical client (DBeaver)
- Other options (Arch Wiki: list of applications — database tools; MySQL — graphical tools)

= Fallback option

DBeaver with SQLite3.

= Specific Installation Guides: Linux

```text
# ArchLinux

# Install package
sudo pacman -S mariadb

# Configure system
mariadb-install-db --user=mysql --basedir=/usr \
    --datadir=/var/lib

# Start server (and make sure it starts after reboot)
systemctl start mariadb
systemctl enable mariadb

# Secure installation
mariadb-secure-installation
```

= Specific Installation Guides: OSX

Installation on OSX requires homebrew (or docker)

- Installing Homebrew
- MariaDB Formula

```text
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Home
brew install mariadb
# mariadb-secure-installation
brew services start mariadb
```

#warn([DA VERIFICARE], [comando troncato nell'originale: l'URL della slide termina con "…/Home"; il resto è tagliato dalla slide.])

= Specific Installation Guides: Windows

- Instructions here (MariaDB installing guide)
- Graphical installer

= Specific Installation Guides: Docker/Podman

- Prerequisite: docker or podman
- Containers are volatile and you can start from scratch every time you want, by launching the command above
- If you start a stopped container or persist data with a volume, nothing will be lost

```text
podman pull docker.io/library/mariadb

podman run --name mariadb \
           --env MARIADB_ROOT_PASSWORD=1234567 \
           --replace \
           --detach \
           -p [IP_ADDRESS]:3306:3306 \
           mariadb:latest
```

= Persisting data with podman/docker

```text
mkdir ./mariadb-storage

podman run podman --name mariadb \
                  --env MARIADB_ROOT_PASSWORD=12345678 \
                  --replace \
                  --detach \
                  --volume ./mariadb-storage:/var/lib/mysql
                  -p [IP_ADDRESS]:3306:3306 \
                  mariadb
```

#warn([DA VERIFICARE], [`podman` ripetuto ("podman run podman") e `\` mancante dopo `--volume ...:/var/lib/mysql` nella slide originale.])

= Connecting to the server

Client can connect to the server, specifying host, user, port (usually when different from defaults):

```text
mariadb -h [IP_ADDRESS] -P 3306 -p -u root
```

= Explanation

#cmp(
  (auto, 1fr),
  [$-h$], "host",
  [$-P$], "port",
  [$-p$], "ask for a password",
  [$-u$ root], "connects as the root user",
)

= Part II

Using a DBMS as a "naive" Excel replacement

= Databases

- Databases are made of tables
- Tables have columns with types
- Tables are populated with data
- Fine-grained access control allows to specify which user can do on which databases and tables

#tbl(
  (1.1fr, 1.2fr, 1fr, auto),
  head: ("Name", "Surname", "Phone", "..."),
  "John", "Doe", "+1...", "",
  "Jane", "Doe", "+2...", "",
)

= Creating a database and a user

```text
-- mariadb -h [IP_ADDRESS] -P 3306 -p -u root

create database contacts;

create user 'contacts'@'localhost' identified by '12345678';

grant all privileges on contacts.* to 'contacts'@'%';
```

= Creating a Table

```text
USE contacts;
-- CAREFUL HERE!
DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
 name VARCHAR(50),
 surname VARCHAR(50),
 phone VARCHAR(20),
 country VARCHAR(50),
 age INT,
 signup_date DATE,
 status VARCHAR(20)
);
DESCRIBE contacts;
```

= Populating data

- insert: SQL provides an insert command to enter data
- from dumps: given a DB we can save the commands to create in a file it and, then, of course, use the file to create a copy of the database
- from CSV files

= Insert Example

```text
USE contacts;

INSERT INTO
  contacts
  (name, surname, phone, country, age, signup_date, status)
VALUES
  ('John', 'Doe', '+1-555-0101', 'USA', 28, '2025-01-15', 'Active
  ('Emma', 'Smith', '+44-20-7946-0912', 'UK', 34,
   '2025-02-20', '

SELECT * from contacts;
```

#warn([DA VERIFICARE], [valori della INSERT troncati a destra dalla slide originale (righe `'Active` e `'2025-02-20', '`).])

= Loading from a dump

```text
use contacts;
source dump.sql;
```

= Exercise

- Use the insert command to insert some records
- Use the load command to load a dump

= SQL Basics

```text
select <columns>
from <table>
where <condition>;
```

= Some queries

- name like ...
- age between 30 and 40
- where signup_date >
- where month(signup_date)
- min, max, avg
- ...
