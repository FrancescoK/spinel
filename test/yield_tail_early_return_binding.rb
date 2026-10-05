# An inline result carries both an early return and the tail yield's value,
# through class methods, argument gathering and forwarded blocks.
def early_pick(flag)
  return [1, :early] if flag
  yield
end
p early_pick(true) { :tail }
p early_pick(false) { :tail }
p early_pick(false) { "string" }
p early_pick(false) { next 7 }

class EarlyBinding
  def self.pick(flag, optional = 2, *rest, post, key: 3, **kw, &block)
    return [optional, rest, post, key, kw, block.call] if flag
    yield
  end

  def pick(flag, optional = @missing, key:, **kw)
    return [optional, key, kw] if flag
    yield
  end
end
args = [true, 4, 5, 6]
kw = {key: 7, extra: 8}
p EarlyBinding.pick(*args, **kw) { :tail }
p EarlyBinding.pick(false, 6, **{}) { :tail }
p EarlyBinding.new.pick(true, *[], key: 9, "extra" => 10) { :tail }
p EarlyBinding.new.pick(false, 4, key: 9) { "string" }

def early_rest(*rest, post, **kw)
  return [rest, post, kw] if ($early_rest = !$early_rest)
  yield
end
def early_explicit(&)
  block = proc { "proc" }
  early_rest(*[1], extra: 2, &block)
end
p early_explicit { :ignored }
p early_explicit { :ignored }

def early_forward(...)
  early_pick(...)
end
def early_anonymous(*, **, &)
  early_forward(*, **, &)
end
p early_anonymous(true) { :forward }
p early_anonymous(false) { :forward }
p EarlyBinding.new.public_send(:pick, true, key: 1) { :send }
p EarlyBinding.new.public_send(:pick, false, key: 1) { :send }
p send(:early_pick, true) { :send }
p send(:early_pick, false) { :send }

# The dead body at a bad call still has to compile before arity is checked.
begin
  send(:early_pick, *[], true, false) { :tail }
rescue ArgumentError => e
  puts e.message
end
class EarlyKeywords
  def self.pick(key: 1, &block)
    return [key, block.call] if ($early_key = !$early_key)
    yield
  end
end
begin
  empty = []
  EarlyKeywords.pick(*empty, unknown: 2) { :tail }
rescue ArgumentError => e
  puts e.message
end
