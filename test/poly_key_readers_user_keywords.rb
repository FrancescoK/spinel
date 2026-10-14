# A user method named delete, dig or values_at that takes keywords, called
# on a receiver of more than one type. The builtin arms of the dispatch read
# the keywords from a temp that was never set, so the compile failed: an
# undeclared temp in the C, a crash in the compiler, or "cannot box type".
# A Hash at the same call takes the keywords as one Hash key, as CRuby does.
class Container
  def delete(checkout_path:) = [:delete, checkout_path]
  def dig(key, depth:) = [:dig, key, depth]
  def values_at(key, also:) = [:values_at, key, also]
end

def pick(kind)
  case kind
  when :container then Container.new
  when :hash
    { checkout_path: "/w", { checkout_path: "/w" } => :gone,
      a: { { depth: 1 } => :deep }, { also: :b } => :hit }
  end
end

container = pick(:container)
p container.delete(checkout_path: "/w")
p container.dig(:a, depth: 1)
p container.values_at(:a, also: :b)

hash = pick(:hash)
p hash.values_at(:checkout_path, also: :b)
p hash.dig(:a, depth: 1)
p hash.delete(checkout_path: "/w")
p hash.size
