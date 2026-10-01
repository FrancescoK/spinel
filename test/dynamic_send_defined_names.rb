# A `send` / `public_send` whose name is only known at runtime dispatches
# over a closed set of candidate names. That set was the program's symbol
# and string LITERALS; a name the program defines but never spells as a
# literal -- the writer behind `public_send("#{name}=", value)`
# (activesupport's deprecators), a method named by concatenation -- had no
# arm and the send was refused. The methods the program defines (defs,
# attr readers and writers) are candidates too.
class Dep
  attr_accessor :silenced, :behavior
  def initialize = @silenced = false
  def greet = "hi from dep"
end
class Deps
  def initialize = @all = [Dep.new, Dep.new]
  def each(&b) = @all.each(&b)
  def set_option(name, value)
    each { |d| d.public_send("#{name}=", value) }
  end
  def first = @all.first
end
ds = Deps.new
ds.set_option(:silenced, true)
ds.set_option("behavior", :raise)
p ds.first.silenced, ds.first.behavior
m = "gre" + "et"
p ds.first.send(m), ds.first.__send__(m)
begin
  ds.first.send("no" + "pe")
rescue NoMethodError => e
  puts "NoMethodError: #{e.message[0, 23]}"
end
