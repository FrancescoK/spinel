# A class method taking a block, called on a class value known only at run
# time: read out of a Hash, an Array or an ivar, or picked by a ternary.

class WAV
  def self.open(path, rate:)
    yield "wav #{path} #{rate}"
  end

  def self.each_chunk(n, &blk)
    n.times { |i| blk.call("wav chunk #{i}") }
  end

  def self.keep(&blk)
    @kept = blk
    nil
  end

  def self.run_kept(x) = @kept.call("wav #{x}")
end

class AIFF
  def self.open(path, rate:)
    r = yield "aiff #{path} #{rate}"
    "aiff got #{r}"
  end

  def self.each_chunk(n, &blk)
    blk.call("aiff chunks #{n}")
  end

  def self.keep(&blk)
    @kept = blk
    nil
  end

  def self.run_kept(x) = @kept.call("aiff #{x}")
end

class Mono < WAV
  def self.open(path, rate:)
    yield "#{name} #{path} #{rate}"
  end
end

CONTAINERS = { ".wav" => WAV, ".aiff" => AIFF, ".mono" => Mono }.freeze

%w[.wav .aiff .mono].each do |ext|
  container = CONTAINERS.fetch(ext)
  container.open("out", rate: 44_100) { |writer| puts writer }
  puts container.open("v", rate: 1) { |w| w.size }
  container.each_chunk(2) { |c| puts c }
  pr = proc { |c| puts "proc #{c}" }
  container.each_chunk(1, &pr)
  container.keep { |x| puts "kept #{x}" }
  container.run_kept(ext)
end

list = [WAV, AIFF]
list[1].open("arr", rate: 2) { |w| puts w }

class Holder
  def initialize(k) = @k = k
  def go = @k.open("ivar", rate: 3) { |w| puts w }
end
Holder.new(list[ARGV.size]).go

k = ARGV.empty? ? AIFF : WAV
k.open("tern", rate: 4) { |w| puts w }
x = k.open("tern2", rate: 5) { |w| w.upcase }
puts x
k.keep { |v| puts "tern kept #{v}" }
k.run_kept("t")

# the same name as an instance method: a Class and an instance both answer
class Band
  def self.each_part(n)
    n.times { |i| yield "Band.#{i}" }
  end

  def each_part(n)
    n.times { |i| yield "band##{i}" }
  end
end

[Band, Band.new, 42].each do |v|
  v.each_part(2) { |p| puts p }
rescue NoMethodError
  puts "NoMethodError"
end
