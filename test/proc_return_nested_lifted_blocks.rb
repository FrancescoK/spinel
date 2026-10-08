# A `return` in a block lifted to a proc inside another lifted block leaves the
# method, not just the inner proc: the inner proc reaches the method's frame
# through the outer proc's home.
class Gadget; def each; yield ["a", "b"]; end; end

def find(outer)
  outer.each do |inner|
    inner.each { |s| v = s.to_s; return v if v == "b" }
  end
  ""
end

def find_int(outer)
  outer.each do |inner|
    inner.each { |s| return s.to_s.size + 40 if s == "b" }
  end
  0
end

def find_none(outer)
  outer.each do |inner|
    inner.each { |s| return "never" if s == "zzz" }
  end
  "fell through"
end

def deeper(outer)
  outer.each do |a|
    a.each do |b|
      b.each { |s| return s.upcase if s == "c" }
    end
  end
  nil
end

puts find([["a", "b"]]), find(Gadget.new)
p find_int([["a", "b"]]), find_int(Gadget.new)
puts find_none([["a", "b"]]), find_none(Gadget.new)
p deeper([[["a", "c"]]])
