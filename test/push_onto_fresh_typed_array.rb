# A push onto a typed Array a builtin call just built, given an element of
# another kind: no variable holds that Array to widen, so the push answers
# the general Array it becomes.
def version(name) = (name.to_s.scan(/\d+/) << 99).join('.')
p version(:V1_9_3)
p("1 2".split << 3)
p("ab".bytes << "z")
p([1, 2].map { |x| x * 2 }.push(:s, 3))
p("a b".split.append(1.5).length)
"a b".split << 1
p(("1-2".split("-") << 3).map(&:to_s))
# a String onto the Array a map built
p [1, 2].map { |x| x }.push("s")
