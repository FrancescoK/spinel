# Under --share-strings a yield hands its block `+s`, which is s itself in
# CRuby (s is not frozen): the block's append changes s.
def y(s)
  yield(+s)
end
s = +"abc"
y(s) { |t| t << "!" }
p s
