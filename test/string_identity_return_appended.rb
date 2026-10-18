# A method that appends to its parameter and returns it hands back the
# caller's String, so the result and the variable passed in are one object.
# The result is a copy today: an append through it that stays within the
# buffer's spare room still reaches the caller's String by chance, and a
# longer one is lost (x.size 2, CRuby 102). Refused without --share-strings.
def build4(x)
  x << "!"
  x
end
x = +"p"
r4 = build4(x)
r4 << "?" * 100
p x.size, r4.size
