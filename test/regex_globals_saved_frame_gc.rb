# A method that matches saves its caller's `$~` and `$1`..`$9` on entry and puts
# them back on the way out. The callee's own match overwrites the registers, so
# the saved copy holds the only references to the caller's capture strings; a
# collection inside the callee must not free them.
# spinel: gc-minor
def churn(t)
  t =~ /zz/
  a = []
  20000.times { |i| a << "x#{i}" * 3 }
  a.size
end

s = "hello" + " world"
s =~ /(hel+)o (w\w+)/
churn("abc")
b = []
20000.times { |i| b << "y#{i}" * 3 }
p $1, $2

# the whole MatchData, and the text around the match
def inner(t)
  t =~ /b/
  c = []
  2000.times { |i| c << "z#{i}" * 3 }
  c.size
end

"a1b2" =~ /a/
inner("a1b2")
d = []
2000.times { |i| d << "w#{i}" * 3 }
p $~, $~[0], $`, $'

# two frames deep: each level's registers survive the other's collections
def outer(t)
  t =~ /(\d)(\w)/
  inner(t)
  e = []
  2000.times { |i| e << "v#{i}" * 3 }
  [$1, $2, $~.pre_match]
end

"k" * 3 =~ /(k)(k)/
p outer("q" + "7r")
p $1, $2
