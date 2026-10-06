# A Hash held in a boxed value answers respond_to?(:to_hash), as CRuby's
# does: the runtime's list of Hash names had to_h but not to_hash, so the
# implicit-conversion check `x.respond_to?(:to_hash)` -- the one
# ActiveSupport's HashWithIndifferentAccess#initialize makes -- read false.
def conv?(x) = x.respond_to?(:to_hash)
p conv?({a: 1}), conv?({"s" => [1]}), conv?(Hash.new(0))
p conv?(nil), conv?([1]), conv?("s"), conv?(3)
p({a: 1}.respond_to?(:to_hash))
