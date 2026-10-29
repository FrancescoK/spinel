# A local a catch block writes before its throw keeps the value
# `catch` sets a setjmp the throw longjmps to; a local written in the block
# and read after it was not volatile, so after the throw it read back the
# value it had at the catch (0 here, 5 in CRuby).

def run
  i = 0
  catch(:done) do
    while true
      i += 1
      throw :done if i > 4
    end
  end
  i
end
p run

i = 0
catch(:done) do
  while true
    i += 1
    throw :done if i > 4
  end
end
p i

total = 0
r = catch(:found) do
  [3, 4, 5].each do |x|
    total += x
    throw :found, x if x == 4
  end
  nil
end
p r, total
