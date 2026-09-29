# `@h ||= Hash.new(0)` (and the class variable form) builds the hash the
# slot holds, keeping the default.
class Counter
  def bump(k)
    @c ||= Hash.new(0)
    @c[k] += 1
  end
  def c = @c
end
c = Counter.new
c.bump(:a); c.bump(:a); c.bump(3)
p c.c

class Words
  def bump(k)
    @c ||= Hash.new(0)
    @c[k] += 1
  end
  def c = @c
end
w = Words.new
w.bump("x"); w.bump("x"); w.bump("y")
p w.c

class Plain
  def bump(k)
    @c ||= Hash.new
    @c[k] = (@c[k] || 0) + 1
  end
  def c = @c
end
pl = Plain.new
pl.bump(:q); pl.bump(:q)
p pl.c

class Meta
  def self.bump(k)
    @c ||= Hash.new(0)
    @c[k] += 1
  end
  def self.c = @c
end
Meta.bump(:z); Meta.bump(:z)
p Meta.c

class Shared
  @@c = nil
  def self.bump(k)
    @@c ||= Hash.new(0)
    @@c[k] += 1
  end
  def self.c = @@c
end
Shared.bump(:z); Shared.bump(:w)
p Shared.c
