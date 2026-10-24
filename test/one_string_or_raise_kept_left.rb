# A String-or-nil method result kept through `or raise` (and `||` with a
# non-String right arm): the kept left is boxed as the String it is, nil
# raises. One answer in every String representation.
def find(name)
  name == "sh" ? "/bin/" + name : nil
end

def run(name)
  bin = find(name) or raise ArgumentError, "#{name} not found"
  puts bin
end

class Finder
  def self.which(name) = name.empty? ? nil : "/usr/bin/" + name
  def initialize(name) = @name = name
  def binary = @binary ||= self.class.which(@name)

  def path
    bin = binary or raise ArgumentError, "no #{@name.inspect}"
    bin.upcase
  end
end

run("sh")
begin
  run("nope")
rescue ArgumentError => e
  puts e.message
end
puts Finder.new("git").path
begin
  Finder.new("").path
rescue ArgumentError => e
  puts e.message
end
v = find("sh") || 0
p v
v = find("x") || 0
p v
