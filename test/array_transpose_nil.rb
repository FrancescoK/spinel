# A nullable typed Array must reject transpose on nil, while an empty Array works.
def transpose_ints(a)
  p a.transpose
rescue => e
  p e.class
end
transpose_ints([1])
transpose_ints(nil)
transpose_ints([])
def transpose_floats(a)
  p a.transpose
rescue => e
  p e.class
end
transpose_floats([1.0])
transpose_floats(nil)
transpose_floats([])
def transpose_strings(a)
  p a.transpose
rescue => e
  p e.class
end
transpose_strings(["x"])
transpose_strings(nil)
transpose_strings([])
