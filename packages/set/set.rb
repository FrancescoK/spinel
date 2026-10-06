# Spinel bundled `set`.
#
# A Set backed by an Array, preserving insertion order. Elements are kept
# unique by #eql? (with #hash) like CRuby's Hash-backed Set -- a value object
# that defines #eql?/#hash is deduplicated and found by #include? even across
# distinct instances, and 1 and 1.0 are distinct members (1.eql?(1.0) is
# false). This covers the standard Set surface (construction, iteration,
# membership, set algebra, comparison, classify/divide/flatten) rather than
# every CRuby corner.

class Set
  include Enumerable

  # A Set may hold itself (`s.add(s)`), directly or through an Array, a Hash or
  # any object that leads back to it, and #==, #inspect and #flatten all walk
  # their elements. Without a memory of what they are already inside, each of
  # them follows the cycle until the C stack runs out. The runtime keeps that
  # memory for Array and Hash -- a per-fiber path of the objects (or object
  # pairs) the current walk is inside, restored by every non-local exit -- and
  # a Set's walks, which are written in Ruby, join it through these bindings.
  # Each `enter` answers the mark that `leave` takes back, or -1 when the walk
  # is already inside this Set, which is the cue to stop. No `ensure` is
  # needed: a raise, throw or break out of a walk lands on a handler that
  # restores the path to the depth it had when that handler was armed.
  module RecursionGuard
    native_func :enter_inspect, [:any], :int, "sp_poly_recur_enter_inspect"
    native_func :enter_eq, [:any, :any], :int, "sp_poly_recur_enter_eq"
    native_func :enter_flatten, [:any], :int, "sp_poly_recur_enter_flatten"
    native_func :leave, [:int], :nil, "sp_poly_recur_leave"
  end

  # Set[1, 2, 3] builds a Set from the given elements (CRuby's Set.[]).
  def self.[](*args)
    new(args)
  end

  def initialize(enum = nil)
    @data = []
    if enum
      Set.check_enum(enum)
      # materialize first: the operand may be an Enumerator (or any other
      # Enumerable), whose #each is not reachable through a poly slot (#3625)
      src = enum.to_a
      if block_given?
        src.each { |x| add(yield(x)) }
      else
        src.each { |x| add(x) }
      end
    end
  end

  # dup and clone must not share the element array with the original.
  def initialize_copy(orig)
    @data = orig.to_a
  end

  # A frozen Set refuses every mutation, as CRuby's does: the element array is
  # a private ivar, so freezing the Set itself has to be what the check reads.
  def check_frozen
    raise FrozenError, "can't modify frozen Set: #{inspect}" if frozen?
  end

  # An unfrozen String joins as a frozen copy, as CRuby's Set (and a Hash, for
  # its keys) takes it: changing the String afterwards changes neither the
  # member nor whether the Set holds it, and the member itself is frozen. A
  # frozen String joins as itself. add, add? and map! push through here. The
  # test reads the member back from @data, whose elements are boxed: asked of
  # x, where x is a user object's own type, frozen? would mark that class as
  # one whose instances can be frozen, and guard every store to its ivars.
  def push_member(x)
    @data.push(x)
    e = @data[-1]
    @data[-1] = -e if e.is_a?(String) && !e.frozen?
  end
  private :push_member

  def add(x)
    check_frozen
    push_member(x) unless include?(x)
    self
  end

  def <<(x)
    add(x)
  end

  # add? returns nil when the element was already present.
  def add?(x)
    check_frozen
    return nil if include?(x)
    push_member(x)
    self
  end

  def delete(x)
    check_frozen
    @data.delete_if { |e| e.eql?(x) }
    self
  end

  # delete? returns nil when the element was absent.
  def delete?(x)
    check_frozen
    return nil unless include?(x)
    @data.delete_if { |e| e.eql?(x) }
    self
  end

  def include?(x)
    @data.any? { |e| e.eql?(x) }
  end
  alias member? include?
  alias === include?

  def each
    # CRuby's Set#each answers an Enumerator when called without a block; the
    # yield below would raise LocalJumpError instead (#3624).
    return @data.dup.each unless block_given?
    _i = 0
    while _i < @data.size
      x = @data[_i]
      yield x
      _i += 1
    end
    self
  end

  def size
    @data.size
  end
  alias length size

  def empty?
    @data.empty?
  end

  def clear
    check_frozen
    @data = []
    self
  end

  def to_a
    @data.dup
  end

  def map
    r = []
    _i = 0
    while _i < @data.size
      x = @data[_i]
      r.push(yield(x))
      _i += 1
    end
    r
  end
  alias collect map

  # In-place block methods. map!/collect! replace the elements (re-deduplicating);
  # keep_if/delete_if always return self; select!/reject! return self when
  # anything changed and nil otherwise (CRuby's Set contract).
  def map!
    check_frozen
    r = []
    _i = 0
    while _i < @data.size
      x = @data[_i]
      v = yield(x); r.push(v) unless r.any? { |e| e.eql?(v) }
      _i += 1
    end
    @data = []
    r.each { |v| push_member(v) }
    self
  end
  alias collect! map!

  def keep_if
    check_frozen
    r = []
    _i = 0
    while _i < @data.size
      x = @data[_i]
      r.push(x) if yield(x)
      _i += 1
    end
    @data = r
    self
  end

  def delete_if
    check_frozen
    r = []
    _i = 0
    while _i < @data.size
      x = @data[_i]
      r.push(x) unless yield(x)
      _i += 1
    end
    @data = r
    self
  end

  def select!
    check_frozen
    n = @data.size
    r = []
    _i = 0
    while _i < @data.size
      x = @data[_i]
      r.push(x) if yield(x)
      _i += 1
    end
    @data = r
    @data.size == n ? nil : self
  end
  alias filter! select!

  def reject!
    check_frozen
    n = @data.size
    r = []
    _i = 0
    while _i < @data.size
      x = @data[_i]
      r.push(x) unless yield(x)
      _i += 1
    end
    @data = r
    @data.size == n ? nil : self
  end

  def merge(enum)
    check_frozen
    Set.check_enum(enum)
    # materialize first: a Range (or any other Enumerable) reaching this poly
    # slot does not dispatch #each through it (#3619)
    enum.to_a.each { |x| add(x) }
    self
  end

  def replace(enum)
    check_frozen
    Set.check_enum(enum)
    @data = []
    enum.to_a.each { |x| add(x) }
    self
  end

  # CRuby rebuilds the hash index here; the array-backed set has no index,
  # so reset only has to return self.
  def reset
    self
  end

  def subtract(enum)
    check_frozen
    Set.check_enum(enum)
    enum.to_a.each { |x| @data.delete_if { |e| e.eql?(x) } }
    self
  end

  # The combining ops reject a non-enumerable operand with ArgumentError rather
  # than letting the #each/#include? call fail as NoMethodError, matching CRuby.
  def self.check_enum(x)
    # a Range reaching this poly slot answers respond_to?(:each) with false,
    # though its members are exactly what every caller here iterates (#3619)
    raise ArgumentError, "value must be enumerable" unless x.respond_to?(:each) || x.is_a?(Range)
    x
  end

  # Set operators build fresh sets; the operand only needs #include? /#each.
  # The intersection ENUMERATES the operand and keeps what the receiver holds
  # -- so a Hash operand contributes its [key, value] pairs, and the result
  # follows the operand's order, as CRuby's does. Asking the operand for
  # #include? instead read a Hash by key (#3676).
  def &(other)
    Set.check_enum(other)
    r = Set.new
    other.to_a.each { |x| r.add(x) if include?(x) }
    r
  end
  alias intersection &

  def |(other)
    Set.check_enum(other)
    r = Set.new(@data)
    other.to_a.each { |x| r.add(x) }
    r
  end
  alias union |
  alias + |

  # The difference enumerates the operand too, for the same reason.
  def -(other)
    Set.check_enum(other)
    r = Set.new(@data)
    other.to_a.each { |x| r.delete(x) }
    r
  end
  alias difference -

  def ^(other)
    (self | other) - (self & other)
  end

  def ==(other)
    return true if self.equal?(other)
    return false unless other.is_a?(Set)
    return false unless size == other.size
    mark = RecursionGuard.enter_eq(self, other)
    # A pair already being compared answers "equal", which is what lets two
    # distinct self-containing Sets finish. CRuby answers false here, for a
    # reason Spinel's array-backed Set cannot reproduce: its Set is a hash
    # table, and the element's hash was stored while the Set was still empty,
    # so the membership probe misses.
    return true if mark < 0
    r = subset?(other)
    RecursionGuard.leave(mark)
    r
  end
  alias eql? ==

  # Content-based, order-independent: equal sets hash equal (#3069).
  # XOR of the element hashes is commutative, so insertion order is moot.
  def hash
    h = size
    @data.each { |x| h ^= x.hash }
    h
  end

  # The containment predicates take a Set and nothing else: CRuby answers
  # ArgumentError("value must be a set") for anything else, where passing an
  # Array reached `other.subset?` and refused to compile at all.
  def self.check_set(x)
    raise ArgumentError, "value must be a set" unless x.is_a?(Set)
    x
  end

  def subset?(other)
    Set.check_set(other)
    @data.all? { |x| other.include?(x) }
  end
  alias <= subset?

  def superset?(other)
    Set.check_set(other)
    # Walk the operand rather than calling ITS #subset?: the parameter's type
    # is bound from every call site, so a rejected Array argument still had to
    # answer a Set-only method for the program to compile.
    other.all? { |x| include?(x) }
  end
  alias >= superset?

  def proper_subset?(other)
    Set.check_set(other)
    size < other.size && subset?(other)
  end
  alias < proper_subset?

  def proper_superset?(other)
    Set.check_set(other)
    size > other.size && other.all? { |x| include?(x) }
  end
  alias > proper_superset?

  def <=>(other)
    return nil unless other.is_a?(Set)
    return 0 if size == other.size && subset?(other)
    return -1 if subset?(other)
    return 1 if superset?(other)
    nil
  end

  def disjoint?(other)
    @data.each { |x| return false if other.include?(x) }
    true
  end

  def intersect?(other)
    !disjoint?(other)
  end

  # classify { |x| key } -> { key => Set of members }
  def classify
    # The nil pre-write pins k to a boxed (poly) key; see divide.
    h = {}
    @data.each do |x|
      k = nil
      k = yield(x)
      h[k] = Set.new unless h.key?(k)
      h[k].add(x)
    end
    h
  end

  # divide { |x| key } -> Set of member Sets grouped by the block value.
  # divide { |x, y| rel } -> Set of member Sets, each a strongly connected
  # component of the relation graph (mutual reachability, matching CRuby's
  # tsort-based form; a one-way relation does not merge its endpoints).
  def divide(&func)
    if func.arity == 2
      # 2-arity: strongly connected components of the relation graph (mutual
      # reachability, matching CRuby's tsort-based form; a one-way relation
      # does not merge its endpoints). reach is a flat n*n boolean closure.
      a = @data.dup
      n = a.size
      reach = []
      n.times do |i|
        n.times do |j|
          rel = i == j
          rel = true if func.call(a[i], a[j])
          reach.push(rel)
        end
      end
      n.times do |k|
        n.times do |i|
          n.times do |j|
            reach[i * n + j] = true if reach[i * n + k] && reach[k * n + j]
          end
        end
      end
      rep = []
      n.times do |i|
        ri = i
        j = 0
        while j < i
          if reach[i * n + j] && reach[j * n + i]
            ri = rep[j]
            break
          end
          j += 1
        end
        rep.push(ri)
      end
      groups = {}
      n.times do |i|
        k = rep[i]
        groups[k] = Set.new unless groups.key?(k)
        groups[k].add(a[i])
      end
      res = Set.new
      groups.each_value { |s| res.add(s) }
      res
    else
      # 1-arity: group by the block value. The nil pre-write pins k to a
      # boxed (poly) key: call sites with different block value types share
      # this body, and a concretely-typed k would collapse them to one type.
      h = {}
      @data.each do |x|
        k = nil
        k = func.call(x)
        h[k] = Set.new unless h.key?(k)
        h[k].add(x)
      end
      r = Set.new
      h.each_value { |s| r.add(s) }
      r
    end
  end

  # flatten recursively merges nested Set elements into a flat Set. A Set that
  # holds itself has no flat form, so CRuby raises rather than looping.
  def flatten
    mark = RecursionGuard.enter_flatten(self)
    raise ArgumentError, "tried to flatten recursive Set" if mark < 0
    r = Set.new
    @data.each do |x|
      if x.is_a?(Set)
        x.flatten.each { |y| r.add(y) }
      else
        r.add(x)
      end
    end
    RecursionGuard.leave(mark)
    r
  end

  # flatten!: in-place flatten; returns self when any nested Set was merged,
  # nil when the set was already flat (CRuby's contract). Rebuilds @data
  # through add rather than assigning flatten.to_a into it -- that write
  # would make @data's inferred type depend on itself (to_a dups @data)
  # and widen the ivar to poly.
  def flatten!
    check_frozen
    nested = false
    @data.each { |x| nested = true if x.is_a?(Set) }
    return nil unless nested
    f = flatten
    @data = []
    f.each { |y| add(y) }
    self
  end

  def inspect
    mark = RecursionGuard.enter_inspect(self)
    return "Set[...]" if mark < 0
    r = "Set[" + @data.map { |x| x.inspect }.join(", ") + "]"
    RecursionGuard.leave(mark)
    r
  end
  alias to_s inspect
end
