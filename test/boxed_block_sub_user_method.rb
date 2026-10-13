# A block-form sub or gsub on a boxed receiver is the String's only when
# the box holds a String: a class of the program with its own sub answers
# for its objects. The String scan took every boxed receiver as a String,
# and wrote its C string into the boxed result (the C did not compile).
class Other
  def sub(*) = 1
  def gsub(pat) = yield(pat.source)
end

def run(line)
  s = line.sub(/b/) { "B" }
  g = line.gsub(/b/) { |m| m.upcase * 2 }
  p s, g
end

run("abcb")
run(Other.new)
