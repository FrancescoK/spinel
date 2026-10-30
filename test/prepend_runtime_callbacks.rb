# Runtime callbacks select the definition live before and after a prepend.

# Initialize callbacks.
module InitializeCallbackLayer
  def initialize(x) = super(x * 10)
end
class InitializeCallback
  attr_reader :x
  def initialize(x) = @x = x
end
p InitializeCallback.new(1).x
class InitializeCallback; prepend InitializeCallbackLayer; end
p InitializeCallback.new(1).x

# Sort callbacks.
module SortCallbackLayer
  def <=>(o) = -super
end
class SortCallback
  attr_reader :v
  def initialize(v) = @v = v
  def <=>(o) = v <=> o.v
end
sort_a = [SortCallback.new(1), SortCallback.new(3), SortCallback.new(2)]
p sort_a.sort.map(&:v)
class SortCallback; prepend SortCallbackLayer; end
p sort_a.sort.map(&:v)

# Equality callbacks.
module EqualityCallbackLayer
  def ==(o) = true
end
class EqualityCallback
  def ==(o) = false
end
equality_a = EqualityCallback.new
p equality_a != equality_a, [equality_a].include?(EqualityCallback.new)
class EqualityCallback; prepend EqualityCallbackLayer; end
p equality_a != equality_a, [equality_a].include?(EqualityCallback.new)

# Comparable callbacks.
module ComparableCallbackLayer
  def <=>(o) = -super
end
class ComparableCallback
  include Comparable
  attr_reader :v
  def initialize(v) = @v = v
  def <=>(o) = v <=> o.v
end
p ComparableCallback.new(1) < ComparableCallback.new(2)
class ComparableCallback; prepend ComparableCallbackLayer; end
p ComparableCallback.new(1) < ComparableCallback.new(2)

# Interpolation callbacks.
module InterpolationCallbackLayer
  def to_s = "L" + super
end
class InterpolationCallback
  def to_s = "k"
end
interpolation_k = InterpolationCallback.new
p "#{interpolation_k}"
class InterpolationCallback; prepend InterpolationCallbackLayer; end
p "#{interpolation_k}"

# Case callbacks.
module CaseCallbackLayer
  def ===(o) = true
end
class CaseCallback
  def ===(o) = false
end
case_k = CaseCallback.new
def case_t(case_k) = case 1 when case_k then "hit" else "miss" end
p case_t(case_k)
class CaseCallback; prepend CaseCallbackLayer; end
p case_t(case_k)

# Hash callbacks.
module HashCallbackLayer
  def hash = 1
  def eql?(o) = true
end
class HashCallback
  def hash = object_id.hash
  def eql?(o) = equal?(o)
end
hash_h = {HashCallback.new => 1}
hash_h[HashCallback.new] = 2
p hash_h.size
class HashCallback; prepend HashCallbackLayer; end
hash_g = {HashCallback.new => 1}
hash_g[HashCallback.new] = 2
p hash_g.size

# Proc callbacks.
module ProcCallbackLayer
  def to_proc = proc { |x| x * 100 }
end
class ProcCallback
  def to_proc = proc { |x| x + 1 }
end
proc_k = ProcCallback.new
p [1].map(&proc_k)
class ProcCallback; prepend ProcCallbackLayer; end
p [1].map(&proc_k)

# Coerce callbacks.
module CoerceCallbackLayer
  def coerce(n) = [CoerceCallback.new(n * 100), self]
end
class CoerceCallback
  attr_reader :v
  def initialize(v) = @v = v
  def +(o) = CoerceCallback.new(v + o.v)
  def coerce(n) = [CoerceCallback.new(n), self]
end
p (1 + CoerceCallback.new(2)).v
class CoerceCallback; prepend CoerceCallbackLayer; end
p (1 + CoerceCallback.new(2)).v

# Inspect callbacks.
module InspectCallbackLayer
  def inspect = "L"
end
class InspectCallback
  def inspect = "k"
end
inspect_k = InspectCallback.new
p inspect_k
class InspectCallback; prepend InspectCallbackLayer; end
p inspect_k
