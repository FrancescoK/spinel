# Optional C-extension symbols must not rename ordinary Ruby methods.
def cext(n)
  n + 1
end
def cext_value(n)
  n * 2
end
f = method(:cext_value)
puts f.call(cext(2))
