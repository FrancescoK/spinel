# A send whose name is a variable, not an interpolation, is lowered to arms
# over the names the program spells, and any other name raises
# NoMethodError at the dispatch, so it reaches the methods its arms name and
# no other, as a computed name's send does: `lookup`'s `env` stays apart
# from `shout`'s String (#9627).
class Greeter
  def hello = "hi"
  def bye = "bye"
end
def run(target, name) = target.send(name)
def run_public(target, name) = target.public_send(name)
puts run(Greeter.new, ARGV.empty? ? :hello : :bye)
puts run_public(Greeter.new, ARGV.empty? ? :bye : :hello)
begin
  run(Greeter.new, ARGV.empty? ? :nope : :hello)
rescue NoMethodError => e
  puts e.message
end

def shout(s) = s.upcase!
def lookup(env = ENV) = env["HOME"]
t = +"x"
shout(t)
p t, lookup.nil?
