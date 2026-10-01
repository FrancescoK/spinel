# A runtime-name send at the top level reaches the top-level defs (private
# methods of Object): `self.send(name)`, a receiverless `send(name)` and
# `method(name).call` dispatch over them, and an unknown name raises
# NoMethodError as in CRuby (#6484)
def greet(x) = "hi #{x}"
def by_name(x) = "name=#{x}"
def by_tag(x) = "tag=#{x}"
name = :greet
p method(name).call("a")
puts method(name).call("b")
p send(name, "c")
p self.send(name, "d")
p %w[name tag].map { |k| method("by_#{k}".to_sym).call("a") }
begin
  send(:"no_such_#{name}", 1)
rescue NoMethodError => e
  puts e.class
end
class K
  def twice(x) = x * 10
  def go(n) = send(n, 3)
end
p K.new.go(:twice)
