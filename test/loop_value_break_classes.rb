# A loop's value is nil or what a break hands it, not every class (#8530):
# a call on it still reaches the classes the breaks give, and a for loop's
# value is the collection it walked.
class Found
  def label(tag) = "found:#{tag}"
end

class Fallback
  def label(tag) = "fallback:#{tag}"
end

def first_found(list)
  i = 0
  while i < list.size
    break Found.new if list[i] > 2
    i += 1
  end
end

def until_found(list)
  i = 0
  until i >= list.size
    break Fallback.new if list[i] < 0
    i += 1
  end
end

def walk(items)
  for x in items
    break Found.new if x.nil?
  end
end

def at_least_once(n)
  i = 0
  begin
    i += 1
    break Fallback.new if i == n
  end while i < 10
end

p first_found([1, 5])&.label("a")
p first_found([1, 2])&.label("b")
p until_found([3, -1])&.label("c")
p until_found([3])&.label("d")
p walk([Found.new, Fallback.new]).map { |o| o.label("e") }
p walk([Found.new, nil])&.label("f")
p at_least_once(3)&.label("g")

# a break in a block inside the loop leaves the block's call, not the loop
def in_block(list)
  r = nil
  while r.nil?
    r = list.each { |x| break Fallback.new if x == 0 }
  end
  r
end
v = in_block([1, 0])
p v.label("h")
p in_block([1]).size

# the value a loop leaves through a next in it is still nil
def skip_all(n)
  i = 0
  while i < n
    i += 1
    next Found.new
  end
end
p skip_all(2)
