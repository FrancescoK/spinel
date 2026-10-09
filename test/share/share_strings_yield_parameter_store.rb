# spinel: gc-minor
# Yield and block-argument bindings keep a stored parameter's String handle.
def stored_yield
  yield 0, +"a"
  yield 1, 2
end
kept = []
stored_yield { |i, v| kept[i] = v }
kept[0] << "b"
p kept

def stored_blockarg(&b)
  b.call(+"block")
  b.call(5)
end
args = []
stored_blockarg { |v| args << v }
args[0] << "!"
p args

def stored_optional
  yield
  yield +"given"
  yield 3
end
optional = []
stored_optional { |v = (+"default")| optional << v }
optional[0] << "!"
optional[1] << "?"
p optional

def stored_post
  yield 1, +"post"
  yield 2, 7
end
post = []
stored_post { |*before, v| post << v }
post[0] << "!"
p post

def stored_keyword
  yield v: +"keyword"
  yield v: 9
end
keywords = []
stored_keyword { |v:| keywords << v }
keywords[0] << "!"
p keywords

def stored_gathered(values)
  yield(*values)
end
gathered = []
stored_gathered([+"gathered", 1]) { |v, i| gathered[i] = v }
stored_gathered([2, 0]) { |v, i| gathered[i] = v }
gathered[1] << "!"
p gathered
