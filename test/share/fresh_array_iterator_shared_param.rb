# A fresh String Array (a split, or one sorted) walked by flat_map or map
# whose block hands each String to a method whose parameter shares: the
# iterator answers the block's values, so nothing else names the elements.

class Listing
  def initialize(line)
    @line = line
  end

  def sorted_flat
    @line.split(" ").sort.flat_map { |f| entry_for(f) }.compact
  end

  def flat
    @line.split(" ").flat_map { |f| entry_for(f) }.compact
  end

  def sorted_map
    @line.split(" ").sort.map { |f| entry_for(f) }
  end

  def entry_for(file)
    return [{ name: send(:label) }] if file == "z"

    { name: file }
  end

  def tagged
    @line.split(" ").sort.flat_map { |f| tag(f) }.compact
  end

  def tag(file)
    return [{ name: "-" }] if file.empty?

    file << "!"
    { name: file } if file.size > 1
  end

  def label = +"z"
end

l = Listing.new("b a z")
s = l.send(:label)
s << "!"
p s
p l.sorted_flat
p l.flat
p l.sorted_map
p l.tagged
s = "b a c"
p s.split(" ").sort.each { |x| x.upcase! }.join("-")
p s.split(" ").sort.map! { |x| x << "!" }
a = s.split(" ").sort
a.map! { |x| x.upcase! || x }
p a
p s.split(" ").sort.flat_map { |x| [x << "?", 1] }
