# Assigning to a method's &block parameter. CRuby lets the local be
# rebound while `yield` and `block_given?` keep seeing the block the caller
# passed; Spinel refused the assignment where it was written. It is now the
# rewrite the limitations doc used to ask for, done by the compiler: the
# parameter's VALUE moves to a fresh local that the writes and later reads
# use, and yield / block_given? are left on the caller's block. The shapes:
# activesupport's BroadcastLogger#dispatch (wrap the block in a proc that
# yields once, then forward the proc), the `blk ||= proc { }` default, a
# plain reassignment read back through call, and a method that never yields.

def dispatch(*args, &block)
  if block_given?
    called, result = false, nil
    block = proc { |*a|
      if called then result
      else
        called = true
        result = yield(*a)
      end
    }
  end
  [1, 2, 3].map { |n| run_one(n, args.first, &block) }
end

def run_one(n, tag)
  block_given? ? yield(n, tag) : "no block for #{n}"
end

def fetch(key, &blk)
  blk ||= proc { |k| "default #{k * 2}" }
  blk.call(key)
end

def twice(&b)
  b = proc { |x| x * 2 }
  [b.call(21), block_given?]
end

def quiet(&cb)
  cb = nil
  cb.nil?
end

p dispatch(:x) { |n, tag| "got #{n} #{tag.inspect}" }
p dispatch(:y)
p fetch(21)
p fetch(21) { |k| "given #{k}" }
p twice { 1 }
p twice
p quiet { 1 }

# The shape the old refusal was pinned on: a conditional write, a read of
# the parameter afterwards, and a yield that still sees the caller's block.
def cond_write(&b)
  b = nil if ARGV.length > 5
  return 7 unless b
  yield 1
end
p cond_write { |n| n + 1 }
