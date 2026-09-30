# A method whose tail concats its own recursive result: the element-nil
# analysis follows the concat argument back into the method, and has to
# stop at its depth bound instead of recursing without end.
def values(n)
  if n == 0
    [1.0]
  else
    [2.0].concat(values(n - 1))
  end
end
p values(1)

