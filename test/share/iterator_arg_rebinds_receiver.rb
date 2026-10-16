# A String iterator given a block answers its receiver, the String it was
# called on, even when an argument (`t.scan((t = +"xy"; /./)) { }`), a
# block that assigns the local, an instance variable or a global (directly
# or through a method it calls), or a lambda the block calls rebinds the
# variable the call is over: the call runs ahead of the statement, and the
# answer is not the String the variable names after it, nor a copy of the
# receiver; also where the answer is boxed into an Array or the receiver is
# another iterator's answer.
def k1(t, acc)
  r = t.scan((t = +"xy"; /./)) { |m| acc << m }
  [acc, t, r]
end
p k1(+"abc", [])

def k2(t, acc)
  r = t.each_line((t = +"q\nr"; "\n")) { |m| acc << m }
  [acc, t, r]
end
p k2(+"a\nb", [])

def k3(t, acc)
  r = t.scan(/./) { |m| acc << m }
  r << "!"
  [acc, t, r, r.equal?(t)]
end
p k3(+"ab", [])

def k4(t, acc)
  r = t.scan((t = +"xy"; /./)) { |m| acc << m }
  r << "!"
  [t, r]
end
o = +"abc"
p k4(o, [])
p o

class C
  def k(acc)
    @t = +"abc"
    r = @t.scan(/./) { |m| acc << m; @t = +"xy" }
    q = @t.each_char { |m| }
    q << "!"
    [acc, @t, r, q.equal?(@t)]
  end
end
p C.new.k([])

$g = +"abc"
acc = []
r = $g.scan(($g = +"xy"; /./)) { |m| acc << m }
p [acc, $g, r]

class D
  def initialize = @t = +"abc"
  def reset = @t = +"R"
  def k(acc)
    r = @t.scan(/./) { |m| acc << m; reset }
    x = [@t.each_char { |m| reset }, 1]
    [acc, @t, r, x]
  end
end
p D.new.k([])

def greset = $h = +"G"
$h = +"abc"
r = $h.each_char { |m| greset }
p [$h, r]

def k5(t, acc)
  x = [t.scan((t = +"xy"; /./)) { |m| acc << m }, 1]
  [acc, t, x]
end
p k5(+"abc", [])

def k6(t, acc)
  r = t.each_line((t = +"q\nr"; "\n")) { |m| acc << m }
  r << "!"
  [acc, t, r]
end
p k6(+"a\nb", [])

def k7(t, acc)
  r = t.each_char { |m| acc << m }.scan((t = +"xy"; /./)) { |m| acc << m }
  [acc, t, r]
end
p k7(+"ab", [])

def k8(t, acc)
  l = -> { t = +"L" }
  r = t.scan(/./) { |m| acc << m; l.call }
  [acc, t, r]
end
p k8(+"ab", [])

class E
  def k(acc)
    @t = +"a\nb"
    r = @t.each_line((@t = +"q\nr"; "\n")) { |m| acc << m }
    r << "!"
    [acc, @t, r]
  end
end
p E.new.k([])

def k9(t)
  r = t.each_char { |c| t = +"B" }
  r << "!"
  [t, r]
end
o9 = +"ab"
p k9(o9), o9

def k10(t)
  x = [t.each_char { |c| t = +"B" }, 1]
  x[0] << "!"
  [t, x]
end
o10 = +"ab"
p k10(o10), o10

def k11(t)
  r = t.tap { t = +"B" }
  r << "!"
  [t, r]
end
o11 = +"ab"
p k11(o11), o11
