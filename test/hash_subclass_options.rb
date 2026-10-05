# A plain `class Options < Hash` with readers of its own (#7449): its
# instance is a Hash, so Hash's methods, p, ==, case/when and each answer as
# CRuby's do. The shapes test/reject/ refused while a Hash subclass was built
# as a plain object -- a subclass that only calls its own methods, `[]=` on
# one, a `Class.new(Hash) do ... end` -- are here too.
class Options < Hash
  def verbose? = self[:verbose] == true
  def level = fetch(:level, 1)
  def name = self[:name] || "anon"
  def describe = "#{name}@#{level}#{verbose? ? '!' : ''}"
end

o = Options.new
o[:verbose] = true
o[:name] = "x"
p o.verbose?, o.level, o.name, o.describe, o.size, o.keys
p o
puts o.class, o.is_a?(Hash), o.instance_of?(Hash), Hash === o
o.each { |k, v| puts "#{k}=#{v}" }
p o.map { |k, v| k }
m = o.merge(level: 3)
p m.class, m.level, m.describe, m
p o.to_h.class, o.to_h
s = o.select { |k, v| k == :name }
p s.class, s
p o == {verbose: true, name: "x"}, {verbose: true, name: "x"} == o
case o
when Options then puts "an Options"
end
puts o
puts "#{o}"

class Registry < Hash
end
r = Registry.new
r[:a] = 1
p r.size

class Opts < Hash
  def describe = "opts"
end
op = Opts.new
p op.describe, op, op.to_s, op == {}, op.respond_to?(:describe), op.respond_to?(:fetch)

Counter = Class.new(Hash) do
  def bump(k) = self[k] = fetch(k, 0) + 1
  def first_key = keys.first
end
c = Counter.new
c.bump(:a); c.bump(:a); c.bump(:b)
p c, c.class, c.is_a?(Hash), c.first_key
