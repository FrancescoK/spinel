# even? / odd? on a value that is an Integer or an instance of a program
# class with its own odd?: the Integer answers its parity, the class's
# method runs, by name and through send. The call compiled to the Integer
# parity alone, an int stored into the boxed result.

class Options
  def initialize(h) = @h = h
  def odd? = @h[:odd?]
  def even? = :never
end

def odd_of(t) = t.odd?
def even_of(t) = t.even?
def sent(t, m) = t.send(m)

p odd_of(3)
p odd_of(Options.new({ odd?: "yes" }))
p even_of(4)
p even_of(Options.new({}))
p sent(7, :odd?)
p sent(Options.new({ odd?: 1 }), :odd?)
