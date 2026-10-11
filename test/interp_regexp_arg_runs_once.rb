# An interpolated regexp (or an inline Regexp.new) passed to a String method
# outside the match family runs its interpolation once, as CRuby does. The
# match family's arm built the pattern ahead of the statement for every name
# and then declined the call, so sub, gsub, scan, split, index, slice,
# partition and start_with? ran the `#{}` a second time, and so did a nil
# receiver's =~, which the arm built the pattern for and then declined.
$k = 0
def t = ($k += 1; "b")

s = +"abcb"
p s.sub(/#{t}/, "x")
p s.gsub(/#{t}/, "x")
p s.gsub(/#{t}/, "b" => "z")
p s.scan(/#{t}/)
p s.split(/#{t}/)
p s.index(/#{t}/)
p s.rindex(/#{t}/)
p s[/#{t}/]
p s.slice(/#{t}/)
p s.partition(/#{t}/)
p s.rpartition(/#{t}/)
p s.start_with?(/#{t}/)
p s.index(Regexp.new(t))
p s.match?(/#{t}/)
p s =~ /#{t}/
p(nil =~ /#{t}/)
p(nil =~ Regexp.new(t))
t2 = +"abcb"
p t2.gsub!(/#{t}/, "x")
p t2.sub!(/#{t}/, "y")
p $k
