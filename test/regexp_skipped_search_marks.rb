# A search that finds no byte a match can start with ends before its first
# step. The next search on the same pattern goes on from the keys that one
# was given, and still reads the marks earlier searches left as unvisited:
# a run of such searches between matches leaves every match where it was.
# (Each pattern below has an empty-matching loop, so a search reserves more
# than one key per step.)

pats = [/(?:x*)*(?:a|b)/, /(x*)*(a|b)/, /(?:(?:y?)*z?)+[ab]c?/]
pats.each do |re|
  p("xxa" =~ re)
  hits = 0
  3000.times do |i|
    hits += 1 if "zzzz" =~ re
    hits += 1 if i % 500 == 0 && "xxb" =~ re
  end
  p hits
  p("xxa" =~ re, "b" =~ re, re.match("qqxa")&.begin(0))
  p "zz-a-zz-b".scan(re).size
end
