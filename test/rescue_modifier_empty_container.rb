# An empty `[]` or `{}` as the fallback of a rescue modifier takes the
# other arm's container type, as it does as an arm of a ternary. Emitted
# bare it was an Integer array, or a Hash of its own default type, and gcc
# refused it in the slot the other arm gives the result.
def parts(domain)
  arr = domain.split(".") rescue []
  arr.join("|")
end
puts parts("a.b.c")
puts parts(nil).inspect

def joined(domain) = (domain.split(".") rescue []).join("|")
puts joined("x.y")
puts joined(nil).inspect

class Host
  def initialize(name)
    @labels = name.split(".") rescue []
  end

  def labels = @labels
end
p Host.new("www.example.org").labels
p Host.new(nil).labels

def first_label(domain)
  arr = domain.split(".")
  arr = arr.first(1) rescue []
  arr
end
p first_label("a.b")

def counts(list)
  h = list.split(",").map { |s| [s, s.size] }.to_h rescue {}
  h
end
p counts("ab,c")
p counts(nil)

# the argument-less constructors are empty containers too
def parts_new(domain) = (domain.split(".") rescue Array.new)
p parts_new("m.n")
p parts_new(nil)

def counts_new(list) = (list.split(",").to_h { |s| [s, s.size] } rescue Hash.new)
p counts_new("ab,c")
p counts_new(nil)
