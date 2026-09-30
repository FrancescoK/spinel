# A block called through `b || fallback` takes what that call passes: the
# block-site analysis reads only a call on the block's own read, so the
# block's parameter stayed the Integer of `b.call(9)` and the String's
# pointer read as a number (#6275).
def or_called(&b)
  b.call(9)
  (b || ->(a) { p [:fallback, a] }).call("or called")
end
or_called { |a| p a }

def or_brackets(&b)
  b[1]
  (b || proc { |x| x })["s"]
end
or_brackets { |x| p x }

def and_called(&b)
  b.call(10)
  (b && b).call("s")
end
and_called { |a| p a }

def asks(&b)
  p (b || 1).nil?
  b.call(3)
end
asks { |v| p v }
