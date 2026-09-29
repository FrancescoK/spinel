def ev(object, spec, &block)
  case spec
  in Symbol => sym
    block.call(sym, object)
  in Proc => pr
    pr.call(object)
  in [Symbol => name, Integer => n, *rest]
    block.call(name, n + rest.size)
  in {op: Symbol => op, arg: Integer => arg}
    block.call(op, arg)
  end
end

def ints(list, &block)
  case list
  in [Integer => first, *mid, Integer => last]
    block.call(first, mid, last)
  end
end

def found(list, &block)
  case list
  in [*pre, 3 => three, *post]
    block.call(pre, three, post)
  end
end

def keyed(h, &block)
  case h
  in {a: Integer => a, **rest}
    block.call(a, rest)
  end
end

p ev(1, :to_s) { |s, o| "#{s} #{o}" }
p ev(1, proc { |o| o + 1 }) { |s, o| "#{s} #{o}" }
p ev(2, [:add, 3, 4, 5]) { |s, o| "#{s} #{o}" }
p ev(3, {op: :mul, arg: 7}) { |s, o| "#{s} #{o}" }
p ints([1, 2, 3, 4]) { |a, b, c| "#{a} #{b} #{c}" }
p found([1, 2, 3, 4, 5]) { |a, b, c| "#{a} #{b} #{c}" }
p keyed({a: 1, b: 2}) { |a, r| "#{a} #{r}" }

def split(v, &block)
  x, (y, z) = v
  block.call(x, y, z)
end
p split([1, [:a, "b"]]) { |a, b, c| [a, b, c] }
