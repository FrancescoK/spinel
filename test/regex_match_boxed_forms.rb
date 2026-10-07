# Three Regexp forms the arms took only partly. `x !~ re` with a pattern
# held in a variable and a boxed receiver read the box as a const char *.
# Regexp#match(str, pos) with a block answered the MatchData, where the call
# is typed by the block's value, and did not build. Regexp#match?(str, pos)
# passed a subject of any class raw. None of them built.

def t(k)
  re = k == 0 ? /b/ : /z/
  [[+"ab", 1][k], [:ab, 1][k], [nil, 1][k]].each do |r|
    p r !~ re
  end
  begin
    [7, 1][k] !~ re
  rescue NoMethodError => e
    p e.class
  end
  m = /(x)y/
  p(m.match("axyxy", 2) { |md| md.begin(0) })
  p(m.match("axy", 2) { |md| 1 })
  p(m.match(+"axy", 0) { |md| md[1] + "!" })
  s = [+"axy", 1][k]
  p m.match?(s, 1)
  p m.match?(s, 2)
  p m.match?([nil, 1][k], 0)
  # a nil subject answers nil and the block does not run, with and without pos
  p(m.match([nil, 1][k], 0) { |md| p :ran; md[0] })
  p(m.match([nil, 1][k]) { |md| p :ran; md[0] })
end

t(ARGV.size)
