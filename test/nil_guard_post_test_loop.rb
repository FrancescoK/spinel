# `begin ... end while t` runs its body once before the test, so the
# condition does not guard that body: a call there on a String local that
# is nil raises NoMethodError. The nil fact took the condition for a guard,
# as it is for `while t`, so no nil test was planned and an append did
# nothing on the nil String. Each method is called with a String first.
def post_append(c)
  t = +""
  t << "4"
  t << "2"
  t = nil if c
  i = 0
  begin
    t << "a"
    i += 1
  end while t && i < 2
  t
end

def post_replace(c)
  t = +""
  t << "4"
  t << "2"
  t = nil if c
  i = 0
  begin
    t.replace("z")
    i += 1
  end while t && i < 2
  t
end

def post_size(c)
  t = +""
  t << "4"
  t << "2"
  t = nil if c
  n = 0
  begin
    n += t.size
  end while t && n < 4
  n
end

def post_each_char(c)
  t = +""
  t << "4"
  t << "2"
  t = nil if c
  n = 0
  begin
    t.each_char { |ch| n += ch.to_i }
  end while t && n < 10
  n
end

# a nil written in the body ends the loop at its test
def cleared
  t = +""
  t << "4"
  t << "2"
  i = 0
  begin
    t << "a"
    i += 1
    t = nil if i == 2
  end while t && i < 5
  [i, t]
end

# `while t` tests first: its body is guarded and does not run for nil
def pre_test(c)
  t = +""
  t << "4"
  t << "2"
  t = nil if c
  i = 0
  while t && i < 2
    t << "a"
    i += 1
  end
  t
end

p post_append(false)
begin
  p post_append(true)
rescue NoMethodError => e
  p e.class
end

p post_replace(false)
begin
  p post_replace(true)
rescue NoMethodError => e
  p e.class
end

p post_size(false)
begin
  p post_size(true)
rescue NoMethodError => e
  p e.class
end

p post_each_char(false)
begin
  p post_each_char(true)
rescue NoMethodError => e
  p e.class
end

p cleared
p pre_test(false)
p pre_test(true)
