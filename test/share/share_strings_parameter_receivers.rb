# A boxed accumulator is not a String when its callers supply only Arrays
# or nil. Defaults and recursive forwarding use the same argument layout.
def keep_a(keep = nil)
  keep_b(keep, 0)
end
def keep_b(keep, depth)
  keep_c(keep, depth)
end
def keep_c(keep, depth)
  keep_d(keep, depth)
end
def keep_d(keep, depth)
  keep_e(keep, depth)
end
def keep_e(keep, depth)
  keep_b(keep, depth - 1) if depth > 0
  keep << "x" if keep
end
p keep_a([])
p keep_a(nil)
p keep_a
values = ["z"]
p keep_a(values)

# A boxed to_s must honor user methods even when their name is not unique.
class FirstText
  def to_s = "first"
end
class SecondText
  def to_s = "second"
end
x = [FirstText.new, SecondText.new][ARGV.size]
p x.to_s

# FFI forwards Array-or-nil keep parameters through several native writers.
require "fiddle"
pointer = Fiddle::Pointer["hello"]
p pointer.to_s
