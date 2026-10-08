# A Struct member keeps its String handle through clamp and substitution.
class StructClamp
  St = Struct.new(:v)

  def run
    o = St.new(+"aabc")
    t = o.v.clamp("a", "z")
    puts o.v.frozen?.to_s + " " + t.frozen?.to_s
    begin
      o.v.gsub!("a", "o")
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    puts o.v.frozen?.to_s + " " + t.frozen?.to_s
    p([o.v, t])
  end
end

StructClamp.new.run

# The same argument-taking transforms use one reader evaluation.
class ClampReader
  attr_accessor :value
  def initialize
    @value = +"aabc"
    @reads = 0
  end
  def read
    @reads += 1
    @value
  end
  def reads = @reads
end
o = ClampReader.new
t = o.value.clamp("a", "z")
o.read.sub!("a", "b")
o.read.tr!("b", "c")
o.read.delete!("c")
p [o.value, t, o.reads, t.equal?(o.value)]

s = StructClamp::St.new(+"aabc")
t = s.v.clamp("a", "z")
s.v.sub!("a", "b")
s.v.tr!("b", "c")
s.v.delete!("c")
p [s.v, t, t.equal?(s.v)]

# An attribute reader takes the same transform route; String.new keeps
# its separate copy while the source field is changed in place.
o.value = "aab#{ARGV.size}"
copy = String.new(o.value)
o.value.gsub!("a", "o")
p [o.value, copy]
