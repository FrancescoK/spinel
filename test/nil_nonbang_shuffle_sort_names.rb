# The non-bang shuffle and sort of a typed Array copied the receiver and ran
# the bang form on the copy, so a nil receiver raised under `shuffle!` or
# `sort!` where CRuby names the call (#9347). The Integer Array's sort
# dereferenced the NULL. The slots are filled by `setup`, which the nil calls
# never reach.
def raises(label)
  yield
  puts "#{label}: answered"
rescue NoMethodError => e
  puts "#{label}: #{e.message}"
end

class IA
  def setup = (@r = [3, 1, 2])
  def sorted = @r.sort
  def shuffled = @r.shuffle
  def sorted_bang = @r.sort!
  def shuffled_bang = @r.shuffle!
end
class FA
  def setup = (@r = [2.5, 1.5])
  def sorted = @r.sort
  def shuffled = @r.shuffle
  def sorted_bang = @r.sort!
  def shuffled_bang = @r.shuffle!
end
class SA
  def setup = (@r = ["b", "a"])
  def sorted = @r.sort
  def shuffled = @r.shuffle
  def sorted_bang = @r.sort!
  def shuffled_bang = @r.shuffle!
end
class PA
  def setup = (@r = [3, 1.5, 2])
  def sorted = @r.sort
  def shuffled = @r.shuffle
  def sorted_bang = @r.sort!
  def shuffled_bang = @r.shuffle!
end
[IA, FA, SA].each do |k|
  %i[sorted shuffled sorted_bang shuffled_bang].each do |m|
    raises("#{k} #{m}") { k.new.public_send(m) }
  end
end
%i[sorted shuffled sorted_bang shuffled_bang].each { |m| raises("PA #{m}") { PA.new.public_send(m) } }

# on a filled slot they answer as before
[IA, FA, SA].each do |k|
  o = k.new; o.setup
  p o.sorted
  p o.shuffled.sort
  p o.sorted_bang
  p o.shuffled_bang.sort
end
pa = PA.new; pa.setup
p pa.sorted
p pa.shuffled.sort
p pa.sorted_bang
p pa.shuffled_bang.sort
