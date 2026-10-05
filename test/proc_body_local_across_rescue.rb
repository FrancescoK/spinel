# A local of a lambda, proc, Fiber or Thread body written inside a begin
# keeps the write after the rescue, the ensure and a retry
parse = lambda do |s|
  n = 0
  v = begin
    n = s.size
    Integer(s)
  rescue ArgumentError
    -1
  end
  [v, n]
end
p parse.call("12"), parse.call("zz")

attempts = lambda do |limit|
  tries = 0
  begin
    tries += 1
    raise "again" if tries < limit
  rescue
    retry
  end
  tries
end
p attempts.call(3), attempts.call(1)

closing = proc do
  done = false
  rate = 1.5
  mark = :open
  begin
    begin
      done = true
      rate = 2.5
      mark = :shut
      raise "no"
    ensure
      p [done, rate, mark]
    end
  rescue
    p [done, rate, mark]
  end
end
closing.call

# the body's own parameter
doubled = proc do |k|
  begin
    k *= 2
    raise "no" if k > 4
  rescue
    k += 1
  end
  k
end
p doubled.call(1), doubled.call(3)

# a stabby lambda's parameter, and one after a splat
bump = ->(k) do
  begin
    k += 10
    raise "no"
  rescue
  end
  k
end
p bump.(1)

last = proc do |*rest, z|
  begin
    z = z * 2
    raise "no"
  rescue
  end
  [rest, z]
end
p last.call(1, 2, 3)

# the rescue modifier
count = lambda do |s|
  seen = 0
  v = (seen += 1; Integer(s)) rescue 0
  [v, seen]
end
p count.call("5"), count.call("x")

def run_later
  l = lambda do
    step = 0
    begin
      step = 1
      Integer("z")
    rescue
      step += 10
    end
    step
  end
  l.call
end
p run_later

f = Fiber.new do |v|
  got = 0
  begin
    got = v
    v = 9
    raise "no"
  rescue
  end
  [got, v]
end
p f.resume(4)

r = Thread.new do
  step = 0
  begin
    step = 1
    raise "no"
  rescue
    step += 10
  end
  step
end.value
p r

# a begin in a block spliced into the body, and in a parameter's default
total = lambda do
  sum = 0
  [1, 2, 3].each do |e|
    begin
      sum += e
      raise "no" if e == 2
    rescue
      sum += 100
    end
  end
  sum
end
p total.call

padded = proc do |a, b = (begin; a += 1; Integer("z"); rescue; a * 2; end)|
  [a, b]
end
p padded.call(3)

# a body with a begin of its own, made under the method's begin
def guarded
  r = nil
  begin
    l = lambda do
      n = 1
      begin
        n = 2
        raise "no"
      rescue
        n += 10
      end
      n
    end
    r = l.call
    raise "outer"
  rescue
    r = [r, :outer]
  end
  r
end
p guarded

# a block spliced under a method's rescue, in a lambda
def quieted
  yield
rescue
  :rescued
end
spliced = lambda do
  n = 0
  quieted { n = 9; raise "no" }
  n
end
p spliced.call
