# A class method `name` (or to_s / inspect) the class defines of its own
# answers the call on the class, whatever it returns: the call was typed as
# Module#name's String, and a value of another kind stopped the C build.

module Store
  def self.name = Thread.current[:store_name]
  def self.to_s = 42
end

class Pick
  def self.inspect = (ARGV.empty? ? :pick : "Pick")
end

class Plain
end

Thread.current[:store_name] = "main"
p Store.name
puts Store.name
p Store.to_s
p Pick.inspect
p Plain.name
p Plain.name.frozen?
