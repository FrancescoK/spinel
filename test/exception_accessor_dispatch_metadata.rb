[nil, true, false, 5, "s"].each do |x|
  begin
    x.key
  rescue NoMethodError => e
    p [e.message, e.receiver.equal?(x), e.name, e.args, e.private_call?]
  end
end
begin
  StandardError.new.key
rescue NoMethodError => e
  p [e.receiver.class, e.name, e.args]
end
class Al
  def params = [:al]
  alias key params
end
key_error = KeyError.new("missing", key: :b)
[Al.new, key_error].each { |x| p x.key }

vals = [nil, true, false, 1.5, :s]
vals.each do |x|
  p (x.key rescue $!.message)
  p (x.args rescue $!.message)
  p (x.reason rescue $!.message)
  p (x.private_call? rescue $!.message)
end

class Parent
  def params = [:parent]
  alias key params
end
class Child < Parent; end
class Reader
  attr_reader :payload
  alias key payload
  def initialize = @payload = :reader
end
ke = KeyError.new("missing", key: :actual)
[Child.new, Reader.new, ke].each { |x| p x.key }

$calls = 0
def value
  $calls += 1
  ["temporary", 1][0]
end
begin
  value.key
rescue NoMethodError => e
  p [e.message, e.receiver, e.name, e.args, $calls]
end

class Err < StandardError
  attr_reader :payload
  def initialize
    @payload = "kept"
    super("error")
  end
end
ge = Err.new
begin
  ge.key
rescue NoMethodError => e
  p [e.receiver.equal?(ge), e.receiver.class, (e.receiver.payload rescue :no_payload), e.name, e.args, e.private_call?]
end
se = StandardError.new("ordinary")
begin
  se.reason
rescue NoMethodError => e
  p [e.receiver.equal?(se), (e.receiver.message rescue :no_message), e.name, e.args, e.private_call?]
end
begin
  se.args
rescue NoMethodError => e
  p [e.receiver.equal?(se), e.name, e.args, e.private_call?]
end

class Al3
  def params = [:al3]
  alias key params
end
e3 = begin; {a: 1}.fetch(:b); rescue KeyError => ex; ex; end
[Al3.new, e3].each { |x| p (x.key rescue $!.message) }
