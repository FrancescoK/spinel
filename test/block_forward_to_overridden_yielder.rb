# A literal block handed to a yield-inlined method that forwards it with
# `&blk` to a yielding method a subclass overrides. The forwarder is spliced
# at the call site, but the forwarded call dispatches on the receiver's class
# and hands the block to the proc-form clone as a real proc -- so the block's
# captures of enclosing locals need cells. Missing them refused the program
# ("uncaptured outer variable").

class Store
  def fetch(key)
    yield
  end
end

class MemStore < Store
  def fetch(key)
    "mem:" + yield
  end
end

# 1. Top-level forwarder, block reads a captured local.
def via(direct, &blk)
  return yield if direct
  Store.new.fetch("k", &blk)
end

name = "x"
puts via(false) { name + "!" }
puts via(true) { name + "?" }

# 2. Instance-method forwarder, block reads a captured local.
class Ctl
  def initialize(store)
    @store = store
  end

  def get(direct, &blk)
    if direct
      yield
    else
      @store.fetch("k", &blk)
    end
  end

  def run(direct)
    label = "n"
    puts get(direct) { label + "!" }
    puts label
  end
end

Ctl.new(Store.new).run(false)
Ctl.new(Store.new).run(true)
puts MemStore.new.fetch("k") { "y" }

# 3. The base method ignores its block and only the override yields; the
#    dispatch still makes the block a proc, forwarded or given directly.
class Plain
  def fetch(key) = "none"
end

class Yielding < Plain
  def fetch(key) = "y:" + yield
end

def via_plain(direct, &blk)
  return yield if direct
  Plain.new.fetch("k", &blk)
end

word = "w"
puts via_plain(false) { word + "!" }
puts via_plain(true) { word + "?" }
puts Plain.new.fetch("k") { word + "." }
puts Yielding.new.fetch("k") { word }
