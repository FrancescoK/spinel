# A boxed object that reaches an Enumerable method of the builtins answers it
# only when its class includes Enumerable or defines the method: an #each or a
# #to_a alone gives a class none of them, and CRuby raises NoMethodError where
# the walk converted the object through its to_a (or walked its each) and ran
# the block.
class Rows              # to_a alone
  def initialize(rows) = @rows = rows
  def to_a = @rows
end

class Eacher            # each alone
  def initialize(rows) = @rows = rows
  def each(&b) = @rows.each(&b)
end

class Coll              # includes Enumerable
  include Enumerable
  def initialize(rows) = @rows = rows
  def each(&b) = @rows.each(&b)
end

class Own               # defines the method itself
  def initialize(v) = @v = v
  def each(&b) = [@v].each(&b)
  def any? = @v
  def map = :own_map
end

class Holder
  def initialize(k)
    @c = case k
         when 0 then [1, 5]
         when 1 then Rows.new([2, 6])
         when 2 then Eacher.new([3, 7])
         when 3 then Coll.new([4, 8])
         else Own.new("x")
         end
  end

  def any = @c.any? { |x| x > 3 }
  def all = @c.all? { |x| x > 0 }
  def mapped = @c.map { |x| x + 1 }
  def found = @c.find { |x| x > 3 }
  def chosen = @c.select { |x| x > 3 }
  def dropped = @c.reject { |x| x > 3 }
  def folded = @c.inject { |a, x| a + x }
  def parted = @c.partition { |x| x > 3 }
  def tallied = @c.tally
end

def try
  p yield
rescue NoMethodError => e
  puts "NoMethodError: #{e.message[/\A.*? an instance of \w+/]}"
end

(0..4).each do |k|
  h = Holder.new(k)
  puts "-- #{k}"
  try { h.any }
  try { h.all }
  try { h.mapped }
  try { h.found }
  try { h.chosen }
  try { h.dropped }
  try { h.folded }
  try { h.parted }
  try { h.tallied }
end
