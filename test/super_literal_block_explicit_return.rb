# A literal-block super answers the parent's explicit return or the block.
class Parent
  def run(n)
    return 7 if n < 0
    yield
  end
end
class Child < Parent
  def run(n) = super(n) { "text" }
end
class Forwarded < Parent
  def run(n) = super { :symbol }
end
p Child.new.run(-1)
p Child.new.run(1)
p Forwarded.new.run(-1)
p Forwarded.new.run(1)
