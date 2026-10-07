# Flag-only: under --share-strings, a yield hands its block a copy of `+s`,
# which is s itself in CRuby: refused.
def y(s)
  yield(+s)
end
s = +"abc"
y(s) { |t| t << "!" }
p s
