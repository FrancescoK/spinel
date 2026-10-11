# A method that yields is spliced into its caller. A parameter of a loop in
# it that an inner block captures, when that block runs through a call on a
# value of more than one class and the loop can `next`, is declared in the
# caller too.
class Bag
  def initialize(*items) = @items = items
  def each(&block) = @items.each(&block)
end

def find_methods(classes)
  methods = []
  ["A", "B", "C"].each do |ancestor|
    ancestors = classes[ancestor]
    next unless ancestors
    ancestors.each do |store|
      methods << "#{store}:#{ancestor}"
    end
  end
  methods.each { |item| yield item }
end

find_methods({ "A" => ["s1"], "B" => Bag.new("s2", "s3") }) { |m| p m }

# an Integer loop parameter, under a rescue
def totals(table)
  out = []
  begin
    [1, 2, 3].each do |n|
      row = table[n]
      next unless row
      row.each { |x| out << x * n }
    end
  rescue ArgumentError
    out = []
  end
  out.each { |v| yield v }
end

totals({ 1 => [5], 2 => Bag.new(6, 7) }) { |v| p v }

# the inner block writes the parameter
def renamed(groups)
  out = []
  ["x", "y", "z"].each do |name|
    g = groups[name]
    next unless g
    g.each { |v| name = "#{name}#{v}" }
    out << name
  end
  out.each { |o| yield o }
end

renamed({ "x" => [1, 2], "y" => Bag.new(3) }) { |o| p o }

# blocks that outlive their iteration keep its parameter
def later(groups)
  kept = []
  ["x", "y"].each do |name|
    g = groups[name]
    next unless g
    g.each { |v| kept << -> { "#{name}=#{v}" } }
  end
  kept.each { |f| yield f.call }
end

later({ "x" => [1, 2], "y" => Bag.new(3) }) { |o| p o }
