# Flag-only: a constant whose String is shared reads through its holder in an
# identity test (`equal?`). Before its assignment has run that read is a
# NameError like any other, and after it the test answers true.
def get = S
def same? = get.equal?(S)
def mixed = [S, 1][0].equal?(get)

[:same?, :mixed].each do |m|
  begin
    p send(m)
  rescue NameError => e
    puts e.message
  end
end

S = +"s"
p same?, mixed
S << "!"
p S, get

# the same through a class held in a variable and through a call: the
# receiver runs once and the error names the class
class Foo; end
$n = 0
def pick
  $n += 1
  Foo
end
k = Foo
begin
  k::BUF << "x"
rescue NameError => e
  p e.message
end
begin
  pick::BUF << "x"
rescue NameError => e
  p e.message
end
p $n
class Foo
  BUF = +"a"
end
k::BUF << "y"
pick::BUF << "z"
p Foo::BUF, $n
