# spinel: gc-minor
# spinel: gc-stress
# A String that is aliased and mutated is a handle in the default build. A
# block a reopening's proc form yields it to reads its bytes, and one that
# keeps what it reads (returns it, stores it, captures it) is handed a copy
# of them: the handle's live bytes are freed once every other reference to
# the String is dropped. Each shape drops them, allocates, runs the GC, and
# then reads what the block kept.
class String
  def pm(a) = yield(a)
  def after(a)
    r = yield(a)
    a = nil
    GC.start
    r
  end
end

def churn
  junk = Array.new(3000) { |i| "junk#{i}" * 4 }
  GC.start
  junk.size
end

def handle
  s = +"hello"
  s << " world"
  s
end

$keep = []
$h = {}

def keep_return
  s = handle
  t = s
  k = (+"ab").pm(s) { |v| v }
  s = nil
  t = nil
  k
end

def keep_push
  s = handle
  t = s
  (+"ab").pm(s) { |v| $keep << v; 0 }
  s = nil
  t = nil
end

def keep_hash
  s = handle
  t = s
  (+"ab").pm(s) { |v| $h[:a] = v; 0 }
  s = nil
  t = nil
end

def keep_lambda
  s = handle
  t = s
  l = (+"ab").pm(s) { |v| -> { v + "!" } }
  s = nil
  t = nil
  l
end

def keep_after
  s = handle
  t = s
  k = (+"ab").after(s) { |v| v }
  s = nil
  t = nil
  k
end

r = keep_return
keep_push
keep_hash
l = keep_lambda
a = keep_after
churn
p r
p $keep
p $h
p l.call
p a
