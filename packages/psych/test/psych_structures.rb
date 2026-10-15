# Block and flow collections, quoted and block scalars, comments, anchors and
# merge keys, and the document markers, read as Psych reads them.
require "psych"

docs = [
  "a: 1\nb: [1, two, 3.0]\nc: {x: y}\n",
  "- a\n- b: 1\n  c: 2\n- [x]\n- - y\n  - z\n",
  "a:\n- 1\n- 2\nb:\n  - 3\nc: 4\n",
  "a:\n  b:\n    c: d\n  e: f\ng: h\n",
  "empty:\nnext: 1\nnil_item:\n-\n- 2\n",
  "k: |\n  l1\n  l2\nstrip: |-\n  x\nkeep: |+\n  y\n\nfold: >\n  a\n  b\n\n  c\n  \nmore: >-\n  a\n   b\n  c\n",
  "- |2\n   indented\n  base\n- >\n\n  lead\n",
  "s: 'multi\n  line'\nd: \"a\n\n  b\"\nplain: multi\n  word\ncont: \"a\\\n  b\"\n",
  "url: http://a.b/c?d=e#f\nhash: a#b # a comment\n# a full line\n'quoted key': 1\n\"double\": 2\n",
  "[\n  a, [b, c],\n  {d: e}, 'f g',\n]\n",
  "{a: [1, 2], b: {c: d}, e, 'f': }",
  "[a: 1, b]",
  "base: &b {x: 1, y: 2}\nderived:\n  <<: *b\n  y: 3\n",
  "%YAML 1.1\n---\na: 1\n...\n",
  "--- |\n  literal root\n",
  "--- 1\n--- 2\n",
  "first: a\nfirst: b\n",
  "a: !!str 1\nb: !!int '2'\nc: ! 3\nd: ! ''\n! '': nil key\ne: !custom x\nf: !!binary aGVsbG8=\n",
  "? complex\n: v\n? |-\n  two\n  lines\n: w\n"
]
docs.each { |d| p Psych.safe_load(d, aliases: true) }
