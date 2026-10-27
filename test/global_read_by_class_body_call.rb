# A method that a class body calls before a global's first write reads the
# global's nil: the call is a read that can run first, so the global's slot
# holds nil until the write, as one written nil would.
def show
  p $count
  nil
end

class Counter
  show
end
$count = 5
p $count + 1
