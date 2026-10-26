# spinel: wasm-abort-refuse: a return out of a proc
def m
  pr = proc { return 1 }
  pr.call
  2
end
p m
