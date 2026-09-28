def peek(opts)
  opts = opts.dup
  opts[:on]
end

def take(opts)
  opts = opts.dup
  opts.delete(:on)
  opts[:on].inspect
end

show = method(:puts)
h = { on: 1 }
show.call(peek(h))
show.call(take(h))
show.call(h[:on])
