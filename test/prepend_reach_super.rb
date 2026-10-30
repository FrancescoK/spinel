# Calls through super look up the live definition when they run.

module L4
  def speak = "L " + super
end
class D4
  def speak = "d"
end
d = D4.new
class E4 < D4; def speak = "e " + super(); end; p E4.new.speak
class D4
  prepend L4
end
class E4 < D4; def speak = "e " + super(); end; p E4.new.speak

module L11
  def speak(x = 1) = "L#{x} " + super
end
class D11
  def speak(x = 2) = "d#{x}"
end
class E11 < D11
  def speak(x = 3) = "e#{x} " + super
end
e = E11.new
p e.speak, e.speak(9)
class D11
  prepend L11
end
p e.speak, e.speak(9)

module L12
  def speak = "L " + super
end
class D12
  def self.speak = "d"
end
class E12 < D12
  def self.speak = "e " + super
end
p E12.speak
class << D12
  prepend L12
end
p E12.speak
