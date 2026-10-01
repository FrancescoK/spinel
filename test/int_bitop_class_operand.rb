# An Integer's &, | and ^ with a Class or Module operand is CRuby's TypeError
# ("Class can't be coerced into Integer"), and a shift's is the conversion
# error ("no implicit conversion of Class into Integer"); a constant defined
# nowhere raises its NameError as it is read. The typed path put the operand
# into the C operator as an sp_Class, and the C did not build; a boxed Class
# operand was read as the integer 0.
[-> { 1 & String }, -> { 1 | Comparable }, -> { 6 ^ Integer },
 -> { 1 << String }, -> { 4 >> Comparable },
 -> { (2**70) & String }, -> { (2**70) << String }].each do |f|
  begin
    f.call
  rescue TypeError => e
    p e.message
  end
end
begin
  p(1 & Zork)
rescue NameError => e
  p e.message
end
begin
  p(3 | Regexp::Missing)
rescue NameError => e
  p e.message
end
x = [String, 1][0]
[-> { 1 & x }, -> { 1 ^ x }, -> { 1 << x }].each do |f|
  begin
    f.call
  rescue TypeError => e
    p e.message
  end
end
p 6 & 3, 6 | 3
