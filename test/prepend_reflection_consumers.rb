# Prepend copies stay out of reflection and computed-name dispatch.
module Layer
  def m = "layer " + super
end
class Subject
  def m = "class"
  def n = 1
  def __prep_0_m = "user"
end

def class_snapshot(obj)
  p Subject.instance_methods(false).sort
  p Subject.public_instance_methods(false).sort
  p Subject.instance_methods.grep(/^(m|n|__prep.*)$/).sort
  p Subject.public_instance_methods.grep(/^(m|n|__prep.*)$/).sort
  p obj.methods.grep(/^(m|n|__prep.*)$/).sort
  p [obj.respond_to?(:m), Subject.method_defined?(:m)]
  p [obj.respond_to?(:"__prep 0 m"), Subject.method_defined?(:"__prep 0 m")]
  p Subject.instance_method(:m).name
  p Subject.instance_method(:m).bind(obj).call
  name = ["m"].join
  p obj.send(name)
  hidden = ["__prep", "0", "m"].join(" ")
  p [obj.respond_to?(hidden), Subject.method_defined?(hidden)]
  begin
    obj.send(hidden)
  rescue NoMethodError
    puts "absent"
  end
end
obj = Subject.new
class_snapshot(obj)
class Subject; prepend Layer; end
class_snapshot(obj)

module Body
  def m = "module"
  def n = 2
  def __prep_0_m = "module user"
  prepend Layer
end
class Host
  include Body
end
host = Host.new
p Body.instance_methods(false).sort
p Body.public_instance_methods(false).sort
p host.methods.grep(/^(m|n|__prep.*)$/).sort
p [host.respond_to?(:m), Body.method_defined?(:m)]
p [host.respond_to?(:"__prep 0 m"), Body.method_defined?(:"__prep 0 m")]
p Body.instance_method(:m).name
p Body.instance_method(:n).bind(host).call
name = ["m"].join
p host.send(name)
hidden = ["__prep", "0", "m"].join(" ")
p [host.respond_to?(hidden), Body.method_defined?(hidden)]
begin
  host.send(hidden)
rescue NoMethodError
  puts "absent"
end

module L
  def m = "L " + super
end
class K
  def m = "k"
  def __prep_0_m = "user0"
  def __prep_1_m = "user1"
end
k = K.new
def go(k)
  [k.m, k.__prep_0_m, k.__prep_1_m, k.respond_to?(:__prep_0_m), K.method_defined?(:__prep_0_m),
   K.instance_methods(false).sort, k.public_methods(false).sort, k.send(:__prep_0_m),
   k.public_send(:__prep_1_m), k.method(:__prep_0_m).call,
   k.respond_to?(:"__prep 0 m"), K.method_defined?(:"__prep 0 m"),
   (k.send(:"__prep 0 m") rescue "NoMethodError"), K.private_instance_methods(false).sort]
end
p go(k)
class K; prepend L; end
p go(k)

def hidden_sends(obj, hidden)
  p((obj.send(:"__prep 0 m") rescue "NoMethodError"))
  p((obj.public_send(:"__prep 0 m") rescue "NoMethodError"))
  p((obj.__send__(:"__prep 0 m") rescue "NoMethodError"))
  p((obj.send(hidden) rescue "NoMethodError"))
  p((obj.public_send(hidden) rescue "NoMethodError"))
  p((obj.__send__(hidden) rescue "NoMethodError"))
end
hidden_sends(k, :"__prep 0 m")
hidden_sends(k, ["__prep", "0", "m"].join(" "))

# Bare and boxed sends also treat the hidden spelling as absent.
module HiddenSendLayer
  def m = "L " + super
end
class HiddenSendSubject
  def m = "k"
  def bare
    send(:"__prep 0 m")
  rescue NoMethodError
    "absent"
  end
end
hidden_subject = HiddenSendSubject.new
class HiddenSendSubject; prepend HiddenSendLayer; end
p hidden_subject.bare
[hidden_subject, 1].each do |obj|
  begin
    p obj.send(:"__prep 0 m")
  rescue NoMethodError
    puts "absent"
  end
end
