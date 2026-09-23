#import "_preamble.typ": *
#show: doc.with(title: "Motivations and Introduction", label: "DATABASES-01")
#titleblock("Motivations and Introduction", "DATABASES — Lezione 1")

== Data is important

=== Information age

- We live in the information age.
- Every minute of the day, a large amount of data is generated online.
- According to an estimation, a typical individual creates between 50,000 to 100,000 data points daily.
- Data constitutes the basic infrastructure of our lives, making things simpler, possible, better (and worse).

=== Examples

- Knowing when is the next bus is.
- Knowing in which room the DB lesson is.
- Knowing whether an invoice was paid.
- Being able to retrieve the results of my latest health check.
- Knowing ...

=== Why data matters

#cmp((1fr, 1.35fr),
  [Informed Decision-Making], [Data allows to see what actually works; data allows to see the effects of policies and actions.],
  [Personalization and Convenience], [Algorithms use data to tailor experiences (for instance: movie recommendations, fastest route to avoid traffic).],
  [Scientific Discovery, Problem Solving, Healthcare], [Some disciplines rely heavily on data (track diseases, develop new medicines, model climate change).],
  [Efficiency and Automation], [Data helps streamline operations, optimize supply chains, and automate repetitive tasks, saving time and resources across industries.],
)

== Example: Managing a Company

Areas to take care of to manage a company:
#list(
  [Client and Prospects],
  [Orders and Sales],
  [Inventory, Production,],
  [Quotations, Invoicing, Accounting],
  [Projects and performance],
  [Human Resources, Presence, Timesheets],
  [Knowledge & Documents],
)

Approaches:
#list(
  [On people's computers],
  [On shared folders],
  [On a shared system],
)

== Data is important: Example

- Profit & Loss projection
- Systems performance tracking
- Projection of inventory lock stock alerts
- User engagement and experience, Retention metrics
- Which products actually work, which functions actually work

== Data is important to make informed decisions

- 2006, Clive Humby: "Data is the new oil"
  - Raw data has little value by itself
  - Refining unlocks insights
- From data to structured information
  - We need a "refinery"

== Databases

#defbox([Database], [
  A structured collection of data stored in a computer system, managed by specialized software (DBMS) for efficient, reliable, and multi-user access.
])

DBMS: Database Management System

== Managing large and complex data is difficult

In the early days, applications to store data were built directly on top of file systems.

=== File-system problems

#cmp((1fr, 1.35fr),
  [Data redundancy and inconsistency], [Data is stored in multiple file formats resulting in duplication of information in different files.],
  [Difficulty in accessing data], [Need to write a new program to carry out each new task.],
  [Data isolation], [Multiple files and formats.],
  [Integrity problems], [Integrity constraints (e.g., account balance $> 0$) become "buried" in program code rather than being stated explicitly; hard to add new constraints or change existing ones.],
)

=== Atomicity, concurrency, security

#cmp((1fr, 1.35fr),
  [Atomicity of updates], [Failures may leave database in an inconsistent state with partial updates carried out. Example: transfer of funds from one account to another should either complete or not happen at all.],
  [Concurrent access by multiple users], [Concurrent access needed for performance; uncontrolled concurrent accesses can lead to inconsistencies. Ex: two people reading a balance (say 100) and updating it by withdrawing money (say 50 each) at the same time.],
  [Security problems], [Hard to provide user access to some, but not all, data.],
)

== How big? How Complex?

Walmart's Retail Link database manages its supply chain and inventory management:
#list(
  [Inventory levels],
  [Sales data],
  [Supply chain logistics],
)

Used to:
#list(
  [Assess product performance],
  [Inventory replenishment],
  [Pricing strategies],
  [Demand forecasting],
)

Scale:
#list(
  [Billions of transactions per day],
  [Integrating data from thousands of suppliers and millions of products],
)

Fun story about Walmart: Strawberry Pop-Tarts increase in sales, like seven times their normal sales rate, ahead of a hurricane. And the pre-hurricane top-selling item was beer.

== How we use databases at Shair.Tech

- As the basic infrastructure of our products (BringTheFood)
- As the data storage for monitoring applications (Analytics and Statistics)
- As the data management systems for business information (Redmine, CRM)
- As an efficient system to store and extract data for reporting purposes

== Databases at Shair.Tech

#scale(75%, reflow: true)[#figure(
  caption: [Data-flow architecture: system components and their databases.],
  {
    import "@preview/fletcher:0.5.8": diagram, node, edge
    let green = rgb("#2E9E28")
    let yellow = rgb("#F2C318")
    let blue = rgb("#8FC7E8")
    let brd = 0.7pt + rgb("#1B4965")
    let ln = 0.8pt + rgb("#2E7D32")
    let w(t) = text(fill: white, size: 6pt, t)
    let k(t) = text(size: 6pt, t)
    diagram(
      node-stroke: brd,
      edge-stroke: ln,
      spacing: 1.1em,
      node-inset: 3.5pt,
      node-corner-radius: 2pt,
      node((0, 0), fill: green)[#w[BringTheFood]],
      node((2, 0), fill: green)[#w[BringTheFood]],
      node((5, 0), fill: green, width: 56pt)[#w[Report Generator]],
      node((1, 1), fill: yellow, width: 26pt)[#k[DB]],
      node((0, 2), fill: blue, width: 42pt)[#k[Log File]],
      node((2, 2), fill: blue, width: 42pt)[#k[Log File]],
      node((4, 1), fill: green, width: 70pt)[#w[Extractions]],
      node((5, 1), fill: yellow, width: 26pt)[#k[DB]],
      node((1, 3), fill: green, width: 58pt)[#w[Log Parser]],
      node((1, 4), fill: yellow, width: 26pt)[#k[DB]],
      node((4, 4), fill: yellow, width: 26pt)[#k[DB]],
      node((5, 4), fill: green, width: 74pt)[#w[Management Tools (Redmine, CRM, ...)]],
      node((1, 5), fill: green, width: 58pt)[#w[Analytics]],
      edge((0, 0), (0, 2), "->"),
      edge((2, 0), (2, 2), "->"),
      edge((0, 0), (1, 1), "->"),
      edge((2, 0), (1, 1), "->"),
      edge((1, 1), (4, 1), "->"),
      edge((4, 1), (5, 1), "->"),
      edge((5, 1), (5, 0), "->"),
      edge((0, 2), (1, 3), "->"),
      edge((2, 2), (1, 3), "->"),
      edge((1, 3), (1, 4), "->"),
      edge((1, 4), (1, 5), "->"),
      edge((4, 4), (5, 4), "->"),
    )
  },
)]
