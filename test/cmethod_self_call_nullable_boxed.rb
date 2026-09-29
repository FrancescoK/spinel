# a class method's receiverless call to another class method that can
# answer nil boxes as nil, not as the Integer sentinel
Setup = Data.define(:reu)

class Setup
  def self.read(v)
    new(reu: reu(v))
  rescue IndexError
    raise ArgumentError, "unknown"
  end

  def self.reu(size_kb)
    return nil if size_kb.zero?

    size_kb
  end
end

p Setup.new(reu: :none).reu
read = Setup.read([0].first)
p read.reu
p read.reu.nil?
puts(read.reu ? "truthy" : "falsy")
p Setup.read([8].first).reu

class Gauge
  def self.ratio(x) = x.zero? ? nil : x / 2.0
  def self.take(v) = v
  def self.read(x) = take(ratio(x))
end
Gauge.take(:none)
p Gauge.read([0].first), Gauge.read([0].first).nil?, Gauge.read([3].first)

# a same-named top-level def does not stand in for the class method
def pick(k) = k + 1
class Picker
  def self.pick(k) = k.zero? ? nil : k
  def self.read(v) = Setup.new(reu: pick(v))
end
p pick(1)
r = Picker.read([0].first).reu
p r, r.nil?
