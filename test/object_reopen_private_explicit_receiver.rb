# A private method of a program's Object reopening is refused on an explicit
# receiver, as CRuby refuses it: NoMethodError naming the receiver's class.
# A bare call, and a call on self, still reach it.
# spinel: decisions
class Object
  def foo = 1
  private :foo
  def bar = foo + 1
end
class K; def t = foo; end
[-> { 5.foo }, -> { K.new.foo }, -> { "s".foo }, -> { [1].foo }].each do |f|
  begin
    p f.call
  rescue NoMethodError => e
    p e.message
  end
end
x = [5, "a", K.new][ARGV.size]
begin
  p x.foo
rescue NoMethodError => e
  p e.message
end
p K.new.t, foo, 5.bar
