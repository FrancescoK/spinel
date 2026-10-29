# A def inside a loop, a block or a retried begin replaces the method for
# the passes after it: the first pass calls the version defined before the
# loop, every later one the def's.
def k = 1
[1, 2].each { p k; def k = 3 }

def j = 1
2.times do
  p j
  def j = 3
end

class C
  def v = 1
  2.times do
    p new.v
    def v = 3
  end
end

def q = 1
i = 0
while (p(q); i < 1)
  def q = 3
  i += 1
end

module M
  def m = 1
end
class D
  def m = 0
end
2.times do
  p D.new.m
  class D
    include M
  end
end

def f = g
def g = 5
2.times do |n|
  def f = g if n == 5
  p f
  def g = 7
end

def z = 1
tries = 0
begin
  p z
  def z = 9
  raise "again" if tries.zero?
rescue
  tries += 1
  retry
end
