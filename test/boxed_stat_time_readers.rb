# A File::Stat held where nil may be too (an ivar a default argument seeds)
# answers mtime and atime, a Time each: the boxed dispatch had no
# arm for them, its value was void, and an interpolation of the result did
# not compile (rfd's Item#mtime).
class Item
  def initialize(path, stat = nil)
    @path = path
    @stat = stat
    @stat = File.lstat(path) unless stat
  end

  def mtime = @stat.mtime.strftime('%Y')
  def times = [@stat.mtime, @stat.atime].map(&:class)
  def newer?(t) = @stat.mtime > t
end

i = Item.new('.')
puts "year: #{i.mtime.size}"
p i.times
p i.newer?(Time.at(0))

# a class of the program's own mtime keeps its arm beside the stat's
class Stamp
  def mtime = :stamp
end
def boxed(x) = x
p [boxed(Stamp.new), boxed(File.stat('.'))].map { |s| s.mtime.class }
