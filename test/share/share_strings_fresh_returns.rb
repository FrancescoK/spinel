# Flag-only: the settled return-tail walk recognizes a fresh String on every path,
# including explicit returns, branches, rescue/else and raising tails.
def fresh_leaf(n)
  return "literal" if n == 0
  return nil if n == 1
  if n == 2
    " value ".strip
  elsif n == 3
    "interpolation #{n}"
  else
    raise ArgumentError, "outside"
  end
end

def fresh_forward(n)
  fresh_leaf(n)
end

def fresh_rescue(n)
  fresh_forward(n)
rescue ArgumentError
  "rescued"
else
  "else #{n}"
end

def fresh_modifier(n)
  fresh_forward(n) rescue nil
end

def fresh_case(n)
  case n
  when 0 then "zero"
  when 1 then fresh_forward(2)
  else nil
  end
end

[0, 1, 2, 3].each do |n|
  a = fresh_forward(n)
  p a
  p fresh_case(n)
  p fresh_rescue(n)
end
p fresh_rescue(4)
p fresh_modifier(2), fresh_modifier(4)
x = fresh_forward(4) rescue "fallback"
p x
x = fresh_forward(4) rescue nil
p x

require "stringio"
def fresh_native
  StringIO.new("native").read
end
p fresh_native

# A borrowed result is not fresh. The existing return handle carries it.
$held = +"held"
def held_result = $held
a = held_result
a << "!"
p [$held, a, $held.equal?(a)]
