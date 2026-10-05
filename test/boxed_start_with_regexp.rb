# start_with? with a Regexp on a String or Symbol held in a mixed Array
# (a boxed receiver) asks whether the pattern matches at the start, as
# on a String, alone or among String candidates.
s = [+"Hello World", 1][0]
p s.start_with?(/H./), s.start_with?(/W/), s.start_with?(/\w+ W/)
p s.start_with?(/x/, "He"), s.start_with?("x", /Hel+/), s.start_with?("x", /y/)
p s.start_with?(/H(e)/), $~[1]
p s.start_with?("Hel"), s.end_with?("ld")
y = [:hello, 1][0]
p y.start_with?(/h./), y.start_with?(/l/)
