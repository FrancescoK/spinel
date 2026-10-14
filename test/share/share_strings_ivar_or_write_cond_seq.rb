# An instance variable's `||=` of a conditional whose arm is a sequence
# ending in another variable's String, under --share-strings: the arm
# hands that String on, so the write and the variable are one String,
# and the other arm is a String of its own.
c = ARGV.size == 0
@j = +"j"
k = @j
@q = nil
@q ||= c ? (@z = 1; @j) : +"n"
@q << "!"
p @q, @j, k, @q.equal?(@j), @z
@r = nil
@r ||= !c ? (@z = 2; @j) : +"n"
@r << "?"
p @r, @j, @r.equal?(@j), @z

# the other outcome of the condition: each variable takes the other arm
c = !c
@j = +"j"
k = @j
@q = nil
@z = nil
@q ||= c ? (@z = 1; @j) : +"n"
@q << "!"
p @q, @j, k, @q.equal?(@j), @z
@r = nil
@r ||= !c ? (@z = 2; @j) : +"n"
@r << "?"
p @r, @j, @r.equal?(@j), @z
