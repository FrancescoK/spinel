# A group name a Regexp lacks raises IndexError where a name selects a
# capture -- String#[] and slice, MatchData#[], $~[] -- typed or boxed, once
# the pattern matched; a failed match stays nil, as CRuby answers.
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
s = "Hello World"
t { s[/(?<x>W.)/, "y"] }
t { s[/(?<x>W.)/, :y] }
t { s[/(?<x>Z.)/, "y"] }
t { s.slice(/(?<x>W.)/, "y") }
t { m = s.match(/(?<x>W.)/); m["y"] }
t { m = s.match(/(?<x>W.)/); m[:x] }
t { s =~ /(?<x>W.)/; $~["y"] }
t { s =~ /(?<x>W.)/; $~[:x] }
t { s[/(W.)/, "x"] }
t { [+"Hello World", 1][0][/(?<x>W.)/, "y"] }
t { [+"Hello World", 1][0][/(?<x>Z.)/, "y"] }
t { if /(?<w>W.)/ =~ s then w end }
