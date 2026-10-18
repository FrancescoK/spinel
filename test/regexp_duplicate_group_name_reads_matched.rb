# A group name that repeats across alternation branches reads the group that
# took part in the match, as CRuby does: the last of them that matched, and
# the last declared only when none did. Every reader took the last declared,
# so it read nil (or "" in a replacement) when an earlier branch matched.
re = /(?:(?<name>.*)::)#<Class:\k<name>>|#<Class:(?<name>.*)>(?:::)?/

# the replacement's \k<name>
p "A::B::#<Class:A::B>".sub(re, '\k<name>.')
p "#<Class:A::B>".sub(re, '\k<name>.')
p "A::#<Class:A>::C".sub(re, '\k<name>.')
p "A::#<Class:A>::C #<Class:D>".gsub(re, '<\k<name>>')

# $~ and MatchData readers
p "A::#<Class:A>::C".sub(re) { $~[:name] + "!" }
m = re.match("A::B::#<Class:A::B>")
p m[:name], m["name"], m.named_captures, m.named_captures(symbolize_names: true)
p m.begin(:name), m.end(:name), m.offset(:name), m.byteoffset(:name)
p m.match(:name), m.match_length(:name)
p m.deconstruct_keys([:name]), m.deconstruct_keys(nil)
case m
in {name: String => nm}
  p nm
end
m2 = re.match("#<Class:Z>")
p m2[:name], m2.named_captures, m2.begin(:name)

# a name whose groups all missed reads nil
re2 = /(?<v>a)|(?<v>b)|c/
m3 = re2.match("c")
p m3[:v], m3.named_captures
p "c".sub(re2, '[\k<v>]')

# the named-capture locals of `=~`
if /(?<w>x)|(?<w>y)/ =~ "x"
  p w
end
if /(?<w>x)|(?<w>y)/ =~ "y"
  p w
end

# a backreference in the pattern tries each group of the name
p "xx" =~ /(?<a>x)(?<a>y)?\k<a>/
p "xyx" =~ /\A(?<a>x)(?<a>y)?\k<a>\z/
p "xyy" =~ /\A(?<a>x)(?<a>y)?\k<a>\z/
