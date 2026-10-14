# A case/in over a slot that holds nil as a NULL pointer -- a typed Hash, a typed
# or poly Array, an Exception, a Proc, a Regexp -- answers as the nil it is:
# `in nil` and `in NilClass` match it, and `in Hash`, `in Hash => h`, `in []`,
# `in {}` and the find pattern do not. The class patterns folded to a constant
# for these kinds, so a nil took the Hash arm and the hash read crashed, and
# `in nil` never matched. The class tests (`is_a?`, `kind_of?`, `instance_of?`,
# `===`) over an Exception slot ignored the nil in the same way. Each shape runs
# with the slot nil and then set.
# spinel: share
# spinel: gc-stress
class Pt
  attr_reader :x
  def initialize(x); @x = x; end
  def deconstruct_keys(k) = {x: @x}
  def deconstruct = [@x]
end

class Holder
  def initialize
    @h = nil
    @sh = nil
    @ia = nil
    @sa = nil
    @s = nil
    @o = nil
    @ih = nil
    @sy = nil
  end

  def set
    @h = { "a" => 1 }
    @sh = { "a" => "b" }
    @ia = [1, 2]
    @sa = ["x", "y"]
    @s = "str"
    @o = Pt.new(3)
    @ih = { 1 => 2 }
    @sy = { a: 1 }
  end

  def hash_pat
    case @h
    in {a: 1} then :a1
    in Hash => hh then [:hash, hh.size]
    in nil then :nil
    end
  end
  def hash_nil_first
    case @h
    in nil then :nil
    in Hash then :hash
    end
  end
  def hash_const
    case @h
    in Hash then :hash
    in NilClass then :nilclass
    end
  end
  def hash_obj
    case @h
    in Object then :obj
    in nil then :nil
    end
  end
  def hash_bind
    case @h
    in x then x.nil? ? :nil : :some
    end
  end
  def hash_empty
    case @h
    in {} then :empty
    in nil then :nil
    else :other
    end
  end
  def sh_pat
    case @sh
    in {a: 1} then :a1
    in Hash => hh then [:hash, hh.size]
    in nil then :nil
    end
  end
  def ih_pat
    case @ih
    in Hash => hh then [:hash, hh.size]
    in nil then :nil
    end
  end
  def sy_pat
    case @sy
    in {a: 1} then :a1
    in Hash => hh then [:hash, hh.size]
    in nil then :nil
    end
  end
  def ia_pat
    case @ia
    in [1, 2] then :one_two
    in Array => aa then [:arr, aa.size]
    in nil then :nil
    end
  end
  def ia_find
    case @ia
    in [*, 2, *] then :found
    in nil then :nil
    else :other
    end
  end
  def ia_const
    case @ia
    in Array then :arr
    in nil then :nil
    end
  end
  def ia_cap
    case @ia
    in Array => aa then aa.size
    in nil then :nil
    end
  end
  def sa_pat
    case @sa
    in ["x", "y"] then :xy
    in Array => aa then [:arr, aa.size]
    in nil then :nil
    end
  end
  def sa_find
    case @sa
    in [*, "y", *] then :found
    in nil then :nil
    else :other
    end
  end
  def s_pat
    case @s
    in "str" then :lit
    in String => ss then [:str, ss.size]
    in nil then :nil
    end
  end
  def s_const
    case @s
    in String then :str
    in nil then :nil
    end
  end
  def o_pat
    case @o
    in Pt(x: 3) then :pt3
    in Pt => oo then [:pt, oo.x]
    in nil then :nil
    end
  end
  def o_const
    case @o
    in Pt then :pt
    in nil then :nil
    end
  end
  def o_hash
    case @o
    in {x: 3} then :x3
    in nil then :nil
    else :other
    end
  end
  def o_arr
    case @o
    in [3] then :a3
    in nil then :nil
    else :other
    end
  end
  def when_hash
    case @h
    when Hash then :hash
    when nil then :nil
    end
  end
  def when_nil
    case @h
    when nil then :nil
    when Hash then :hash
    end
  end
  def when_arr
    case @ia
    when Array then :arr
    when nil then :nil
    end
  end
  def when_str
    case @s
    when String then :str
    when nil then :nil
    end
  end
  def when_obj
    case @o
    when Pt then :pt
    when nil then :nil
    end
  end
  def when_nilclass
    case @h
    when NilClass then :nilclass
    when Hash then :hash
    end
  end
  def alt_pat
    case @h
    in nil | Array then :nil_or_arr
    in Hash then :hash
    end
  end
  def alt_arr
    case @ia
    in nil | String then :nil_or_str
    in Array then :arr
    end
  end
  def cap_alt
    case @ia
    in nil | Hash => z then :nil_or_hash
    in Array => z then :arr
    end
  end
  def arr_in
    case @ia
    in [Integer => a, Integer => b] then [a, b]
    in nil then :nil
    end
  end
  def nested
    case {k: @h}
    in {k: Hash => v} then [:hash, v.size]
    in {k: nil} then :nil
    end
  end
  def nested_arr
    case [@h]
    in [Hash => v] then [:hash, v.size]
    in [nil] then :nil
    end
  end
  def rassign
    @h => Hash => v
    v.size
  rescue NoMatchingPatternError
    :nomatch
  end
  def in_bool
    [(@h in Hash), (@h in nil), (@ia in Array), (@ia in nil), (@s in String), (@s in nil), (@o in Pt), (@o in nil)]
  end
  def all
    [hash_pat, hash_nil_first, hash_const, hash_obj, hash_bind, hash_empty, sh_pat, ih_pat, sy_pat,
     ia_pat, ia_find, ia_const, ia_cap, sa_pat, sa_find, s_pat, s_const, o_pat, o_const, o_hash, o_arr,
     when_hash, when_nil, when_arr, when_str, when_obj, when_nilclass, alt_pat, alt_arr, cap_alt, arr_in,
     nested, nested_arr, rassign, in_bool]
  end
end

def mk_ia(f) = f ? [1, 2] : nil
def t_ia(f)
  v = mk_ia(f)
  [(case v
    in nil then :nil
    in Array then :cls
    end),
   (case v
    in Array => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Array then :alt
    end),
   (v in nil), (v in Array),
   (case v
    when nil then :wnil
    when Array then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_fa(f) = f ? [1.5, 2.5] : nil
def t_fa(f)
  v = mk_fa(f)
  [(case v
    in nil then :nil
    in Array then :cls
    end),
   (case v
    in Array => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Array then :alt
    end),
   (v in nil), (v in Array),
   (case v
    when nil then :wnil
    when Array then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_sa(f) = f ? ["x", "y"] : nil
def t_sa(f)
  v = mk_sa(f)
  [(case v
    in nil then :nil
    in Array then :cls
    end),
   (case v
    in Array => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Array then :alt
    end),
   (v in nil), (v in Array),
   (case v
    when nil then :wnil
    when Array then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_pa(f) = f ? [1, "a"] : nil
def t_pa(f)
  v = mk_pa(f)
  [(case v
    in nil then :nil
    in Array then :cls
    end),
   (case v
    in Array => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Array then :alt
    end),
   (v in nil), (v in Array),
   (case v
    when nil then :wnil
    when Array then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_oa(f) = f ? [Object.new] : nil
def t_oa(f)
  v = mk_oa(f)
  [(case v
    in nil then :nil
    in Array then :cls
    end),
   (case v
    in Array => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Array then :alt
    end),
   (v in nil), (v in Array),
   (case v
    when nil then :wnil
    when Array then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_sih(f) = f ? { "a" => 1 } : nil
def t_sih(f)
  v = mk_sih(f)
  [(case v
    in nil then :nil
    in Hash then :cls
    end),
   (case v
    in Hash => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Hash then :alt
    end),
   (v in nil), (v in Hash),
   (case v
    when nil then :wnil
    when Hash then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_ssh(f) = f ? { "a" => "b" } : nil
def t_ssh(f)
  v = mk_ssh(f)
  [(case v
    in nil then :nil
    in Hash then :cls
    end),
   (case v
    in Hash => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Hash then :alt
    end),
   (v in nil), (v in Hash),
   (case v
    when nil then :wnil
    when Hash then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_iih(f) = f ? { 1 => 2 } : nil
def t_iih(f)
  v = mk_iih(f)
  [(case v
    in nil then :nil
    in Hash then :cls
    end),
   (case v
    in Hash => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Hash then :alt
    end),
   (v in nil), (v in Hash),
   (case v
    when nil then :wnil
    when Hash then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_syh(f) = f ? { a: 1 } : nil
def t_syh(f)
  v = mk_syh(f)
  [(case v
    in nil then :nil
    in Hash then :cls
    end),
   (case v
    in Hash => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Hash then :alt
    end),
   (v in nil), (v in Hash),
   (case v
    when nil then :wnil
    when Hash then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_sph(f) = f ? { a: 1, b: "s" } : nil
def t_sph(f)
  v = mk_sph(f)
  [(case v
    in nil then :nil
    in Hash then :cls
    end),
   (case v
    in Hash => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Hash then :alt
    end),
   (v in nil), (v in Hash),
   (case v
    when nil then :wnil
    when Hash then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_ex(f) = f ? RuntimeError.new("e") : nil
def t_ex(f)
  v = mk_ex(f)
  [(case v
    in nil then :nil
    in RuntimeError then :cls
    end),
   (case v
    in RuntimeError => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | RuntimeError then :alt
    end),
   (v in nil), (v in RuntimeError),
   (case v
    when nil then :wnil
    when RuntimeError then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_pr(f) = f ? proc { 1 } : nil
def t_pr(f)
  v = mk_pr(f)
  [(case v
    in nil then :nil
    in Proc then :cls
    end),
   (case v
    in Proc => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Proc then :alt
    end),
   (v in nil), (v in Proc),
   (case v
    when nil then :wnil
    when Proc then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

def mk_re(f) = f ? /a/ : nil
def t_re(f)
  v = mk_re(f)
  [(case v
    in nil then :nil
    in Regexp then :cls
    end),
   (case v
    in Regexp => z then z.nil? ? :bad : :cls
    in nil then :nil
    end),
   (case v
    in NilClass then :nilclass
    in Object then :obj
    end),
   (case v
    in nil | Regexp then :alt
    end),
   (v in nil), (v in Regexp),
   (case v
    when nil then :wnil
    when Regexp then :wcls
    end),
   (case v
    when NilClass then :wnilclass
    when Object then :wobj
    end),
   (case v
    in [*, 1, *] then :find
    in [] then :empty
    in [_, _] then :two
    in { x: } then :hk
    in {} then :eh
    in nil then :nil
    else :other
    end)]
end

# The class tests over an Exception slot: nil is a NilClass, an Object, a
# BasicObject and a Kernel, and the class itself for instance_of?.
def exc_kind(f, k)
  v = mk_ex(f)
  [v.is_a?(NilClass), NilClass === v, v.kind_of?(NilClass), v.instance_of?(NilClass),
   v.is_a?(Object), Object === v, v.is_a?(BasicObject), v.is_a?(Kernel),
   v.is_a?(RuntimeError), RuntimeError === v, v.instance_of?(RuntimeError), v.instance_of?(StandardError),
   v.is_a?(k), v.kind_of?(k), v.instance_of?(k), k === v, v.nil?]
end

x = Holder.new
a = x.all
x.set
b = x.all
a.each_with_index { |v, i| puts "holder nil #{i}: #{v.inspect}" }
b.each_with_index { |v, i| puts "holder set #{i}: #{v.inspect}" }
puts "ia nil: #{t_ia(false).inspect}"
puts "ia set: #{t_ia(true).inspect}"
puts "fa nil: #{t_fa(false).inspect}"
puts "fa set: #{t_fa(true).inspect}"
puts "sa nil: #{t_sa(false).inspect}"
puts "sa set: #{t_sa(true).inspect}"
puts "pa nil: #{t_pa(false).inspect}"
puts "pa set: #{t_pa(true).inspect}"
puts "oa nil: #{t_oa(false).inspect}"
puts "oa set: #{t_oa(true).inspect}"
puts "sih nil: #{t_sih(false).inspect}"
puts "sih set: #{t_sih(true).inspect}"
puts "ssh nil: #{t_ssh(false).inspect}"
puts "ssh set: #{t_ssh(true).inspect}"
puts "iih nil: #{t_iih(false).inspect}"
puts "iih set: #{t_iih(true).inspect}"
puts "syh nil: #{t_syh(false).inspect}"
puts "syh set: #{t_syh(true).inspect}"
puts "sph nil: #{t_sph(false).inspect}"
puts "sph set: #{t_sph(true).inspect}"
puts "ex nil: #{t_ex(false).inspect}"
puts "ex set: #{t_ex(true).inspect}"
puts "pr nil: #{t_pr(false).inspect}"
puts "pr set: #{t_pr(true).inspect}"
puts "re nil: #{t_re(false).inspect}"
puts "re set: #{t_re(true).inspect}"
puts "exc_kind RuntimeError nil: #{exc_kind(false, RuntimeError).inspect}"
puts "exc_kind RuntimeError set: #{exc_kind(true, RuntimeError).inspect}"
puts "exc_kind Object nil: #{exc_kind(false, Object).inspect}"
puts "exc_kind Object set: #{exc_kind(true, Object).inspect}"
puts "exc_kind NilClass nil: #{exc_kind(false, NilClass).inspect}"
puts "exc_kind NilClass set: #{exc_kind(true, NilClass).inspect}"
puts "exc_kind StandardError nil: #{exc_kind(false, StandardError).inspect}"
puts "exc_kind StandardError set: #{exc_kind(true, StandardError).inspect}"
