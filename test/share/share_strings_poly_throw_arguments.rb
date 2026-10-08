# spinel: gc-minor
# A throw hands its value to catch, including a fresh polymorphic return
# hidden in a conditional. Both aliases must keep the selected handle.
class ThrownString
  def value = +"ab"
end
class ThrownNumber
  def value = 7
end
objects = [ThrownString.new, ThrownNumber.new]
result = catch(:value) { throw :value, objects[0].value }
items = [result, result]
items[0] << "x"
p items
result = catch(:conditional) { throw :conditional, (true ? objects[0].value : objects[1].value) }
other = result
other << "y"
p result, other
result = catch(:outer) do
  catch(:inner) { throw :outer, objects[0].value }
end
other = result
other << "z"
p result, other
p catch(:literal) { throw :literal, +"literal" }
# A rescued abort retains its message through the existing exception facts.
# Raise its SystemExit directly so the fixture has no stderr output.
result = begin
  raise SystemExit, objects[0].value
rescue SystemExit => error
  error.message
end
other = result
other << "+"
p result, other
