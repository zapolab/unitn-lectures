// fletcher-flowchart — architetture/flowchart/UML/alberi.
// Compilato pulito con fletcher 0.5.8. Il #raw("") tiene il contatore figure
// allineato a quello di #figure (v. STYLE §Numerazione figure).
#import "@preview/fletcher:0.5.8": diagram, node, edge

#figure(caption: [Titolo], [#raw("")
  #scale(75%, reflow: true)[
    #diagram(
      node-stroke: 0.7pt + rgb("#1B4965"),
      edge-stroke: 0.8pt + rgb("#2E7D32"),
      spacing: 1.4em,
      node((0, 0), fill: rgb("#2E9E28"))[Start],
      node((1, 0), [Decision]),
      edge((0, 0), (1, 0), "->", [label]),
    )
  ]
])
