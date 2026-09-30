# `extend M` in a Struct.new / Data.define block whose class is held in a
# local gives the class M's methods, as it does for the constant-held form.
module CM
  def make = new(5)
  def hi = :hi
end

k = Struct.new(:a) do
  extend CM
end
p k.make.a
p k.hi

d = Data.define(:a) do
  extend CM
end
p d.make.a

K = Struct.new(:a) do
  extend CM
end
p K.make.a
