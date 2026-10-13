# `sum { |g| ... }` over a boxed Array whose block parameter is typed: here
# the grapheme clusters of a String, materialized boxed because the sum's
# value is boxed (`scale` is a keyword splatted from a Hash), while `g` is a
# String everywhere it is read. The loop bound each boxed element to the
# String-typed parameter as it was, and the C did not build.
def char_width(c) = c.ord >= 0x1100 ? 2 : 1

def width(text, scale:)
  scale * text.each_grapheme_cluster.sum { |g| char_width(g) }
end

p char_width("x")
text = "XY寿司"
p width(text, **{scale: 2})
