class Foo; end
if ENV["PATH"]
  def Foo.x = 1
end
p Foo.x
