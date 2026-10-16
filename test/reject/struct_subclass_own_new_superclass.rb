# A Struct subclass that defines its own `new` may answer anything from it:
# its `new(:a)` as a superclass stays refused (#9292)
class Options < Struct
  def self.new(*a) = super
end

class R < Options.new(:a)
end

p R.new(1).a
