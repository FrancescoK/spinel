# A modifier rescue whose fallback answers no value of its own (a modifier
# if around a return) is nil when the fallback falls through; the C did not
# build for its value form.
def g
  [1, 2].each do |v|
    (raise "x" rescue (return :early if v == 1))
  end
  :late
end
p g
def h(v)
  x = (raise "x" rescue (return :early if v == 1))
  [x, :fell]
end
p h(1), h(2)
p((raise "y" rescue (puts "f" if false)))
