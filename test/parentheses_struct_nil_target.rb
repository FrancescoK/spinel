# An empty-parentheses value is nil for a computed Struct assignment target.
# spinel: gc-stress
Words = Struct.new(:left, :right)
strings = Words.new(+"fixed", +"right")
key = :left
strings[key], strings[:right] = (), +"done"
p strings.left
p strings.right
