# Under --share-strings a method whose body ends in a loop that never
# completes (`while true` or `until false` with no break of its own,
# `begin ... end while true`) hands on the String its `return`s answer: the
# loop itself answers nothing. A break of the loop's own, even inside a
# rescue, lets it answer nil; a break inside a nested loop or a block
# leaves the outer loop as it is.
def bang(a)
  while true
    return a.upcase!
  end
end

def param(a)
  until false
    return a
  end
end

def bang_do_while(a)
  begin
    return a.upcase!
  end while true
end

def inner_break(a)
  while true
    i = 0
    while true
      i += 1
      break if i > 2
    end
    [1, 2].each { |x| break if x == 1 }
    a.each_char { |ch| break if ch == "b" }
    return a.upcase!
  end
end

def breaks(a, g)
  while true
    begin
      raise "x" if g
    rescue
      break
    end
    return a.upcase!
  end
end

def raises(a)
  while true
    raise ArgumentError, "empty" if a.empty?
    return a.upcase!
  end
end

def redoes(a)
  n = 0
  while true
    n += 1
    redo if n < 3
    return a.upcase!
  end
end

def retries(a)
  n = 0
  while true
    begin
      n += 1
      raise "again" if n < 3
      return a.upcase!
    rescue
      retry
    end
  end
end

def throws(a)
  while true
    throw :done if a.empty?
    return a.upcase!
  end
end

def fresh_or_param(a, g)
  while true
    return a + "x" if g
    return a
  end
end

def in_arm(a, g)
  if g
    a.downcase
  else
    while true
      return a.upcase!
    end
  end
end

def grows(a)
  n = 0
  while true
    n += 1
    return a if n > 2
    a << "y"
  end
end

s = +"ab"; r = bang(s); r << "!"; p s, r.equal?(s)
s = +"ab"; r = bang(s); s << "?"; p r, s
s = +"AB"; p bang(s), s
s = +"ab"; r = param(s); r << "!"; p s, r.equal?(s)
s = +"ab"; r = bang_do_while(s); r << "!"; p s, r.equal?(s)
s = +"ab"; r = inner_break(s); r << "!"; p s, r.equal?(s)
s = +"ab"; r = breaks(s, false); r << "!"; p s, r.equal?(s)
s = +"ab"; p breaks(s, true), s
s = +"ab"; r = raises(s); r << "!"; p s, r.equal?(s)
begin
  raises(+"")
rescue ArgumentError => e
  p e.message
end
s = +"ab"; r = redoes(s); r << "!"; p s, r.equal?(s)
s = +"ab"; r = retries(s); r << "!"; p s, r.equal?(s)
s = +"ab"; r = throws(s); r << "!"; p s, r.equal?(s)
p catch(:done) { throws(+"") }
s = +"ab"; r = fresh_or_param(s, false); r << "!"; p s, r.equal?(s)
s = +"ab"; r = fresh_or_param(s, true); r << "!"; p s, r, r.equal?(s)
s = +"ab"; r = in_arm(s, false); r << "!"; p s, r.equal?(s)
s = +"CD"; r = in_arm(s, true); r << "!"; p s, r, r.equal?(s)
s = +"ab"; r = grows(s); r << "!"; p s, r.equal?(s)
