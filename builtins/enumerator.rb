# Enumerator block methods walked one element at a time.
#
# The C emitters for map, select, each_slice and the rest take an Enumerator
# receiver through to_a first, which never returns for an endless one
# (Enumerator.new { |y| loop { y << ... } }, [1, 2].cycle): a block that
# means to `break` out of it never ran. When such a call's block does break,
# the analyzer rewrites `enum.m(args) { ... }` into `__enumw_m(enum, args)
# { ... }` (desugar_enum_walk_calls). These are ordinary top-level methods:
# their `recv.each` walks the Enumerator lazily, and a `break` in the
# caller's block leaves the helper with the break value, as it leaves the
# method in Ruby. Spliced only into a program that can make an Enumerator.

def __enumw_map(recv)
  acc = []
  recv.each { |x| acc << yield(x) }
  acc
end

def __enumw_select(recv)
  acc = []
  recv.each { |x| acc << x if yield(x) }
  acc
end

def __enumw_reject(recv)
  acc = []
  recv.each { |x| acc << x unless yield(x) }
  acc
end

def __enumw_filter_map(recv)
  acc = []
  recv.each do |x|
    v = yield(x)
    acc << v if v
  end
  acc
end

def __enumw_each_with_object(recv, memo)
  recv.each { |x| yield x, memo }
  memo
end

def __enumw_inject0(recv)
  first = true
  acc = nil
  recv.each do |x|
    if first
      acc = x
      first = false
    else
      acc = yield(acc, x)
    end
  end
  acc
end

def __enumw_inject1(recv, init)
  acc = init
  recv.each { |x| acc = yield(acc, x) }
  acc
end

def __enumw_with_index(recv, off = 0)
  i = off
  recv.each do |x|
    yield x, i
    i += 1
  end
  recv
end

# str.each_char.with_index { } (and each_line / each_byte / each_codepoint)
# with a block that breaks: the String's pieces walked with a counter, the
# String itself the answer when no break is taken (desugar's rewrite of the
# walk onto the piece array keeps the element types exact)
def __enumw_str_chars_with_index(str, off = 0)
  i = off
  str.chars.each do |x|
    yield x, i
    i += 1
  end
  str
end

def __enumw_str_lines_with_index(str, off = 0)
  i = off
  str.lines.each do |x|
    yield x, i
    i += 1
  end
  str
end

def __enumw_str_bytes_with_index(str, off = 0)
  i = off
  str.bytes.each do |x|
    yield x, i
    i += 1
  end
  str
end

def __enumw_str_codepoints_with_index(str, off = 0)
  i = off
  str.codepoints.each do |x|
    yield x, i
    i += 1
  end
  str
end

def __enumw_each_slice(recv, n)
  buf = []
  recv.each do |x|
    buf << x
    if buf.size == n
      yield buf
      buf = []
    end
  end
  yield buf unless buf.empty?
  recv
end

def __enumw_each_cons(recv, n)
  buf = []
  recv.each do |x|
    buf << x
    buf.shift if buf.size > n
    yield buf.dup if buf.size == n
  end
  recv
end

def __enumw_each_entry(recv)
  recv.each { |x| yield x }
  recv
end
