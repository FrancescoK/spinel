# A Regexp index on a String or Symbol held in a mixed Array (a boxed
# receiver) answers the first match or nil and sets $~, as on a String.
s = [+"Hello World", 1][0]
p s[/W\w+/], s.slice(/l+/), s[/zz/]
x = s[/W(o)/]
p x, $~[0], $1
s[/zz/]
p $~
p s[/(W)(o)/, 2], s[1..3], s[-3]
y = [:hello, 1][0]
p y[/l+/], y[/z/], y[1..2]
