# Under --share-strings (#6765), a method an --rbs signature declares
# `-> String` (or `-> String?`) answers the String's shared form, as an
# inferred method does: the signature says what the method answers, a String,
# and not how C returns it. A tail that reads a String out of a box (a
# narrowed nilable value, an element of a mixed Array, an Integer-or-String
# parameter) answered the box's bytes, so the String the caller took from
# them was a copy that a change in place never reached; the rule refused each
# of these ("that route cannot carry the shared handle yet: it would hand on
# a copy"). The unboxing of such a tail now publishes the handle the box
# holds, as a read of a shared String does.
module ShrsrConf
  class << self
    attr_accessor :secret_key_base
  end
end

class ShrsrApp
  def secret_key_base
    key = ShrsrConf.secret_key_base
    key.nil? ? "" : key
  end

  def part(pairs, index)
    pairs[index]
  end

  def db_time(value)
    return nil if value.nil?
    return value if value.is_a?(String)
    format("%04d", value)
  end
end

class ShrsrTails
  def ifs(f)
    k = ShrsrConf.secret_key_base
    if f
      k
    else
      "d"
    end
  end

  def ternary(f)
    k = ShrsrConf.secret_key_base
    f ? k : "d"
  end

  def orop
    k = ShrsrConf.secret_key_base
    k || "d"
  end

  def early(f)
    k = ShrsrConf.secret_key_base
    return k if f
    "d"
  end

  def elsifs(n)
    k = ShrsrConf.secret_key_base
    if n == 1
      "one"
    elsif n == 2
      k
    else
      ShrsrConf.secret_key_base
    end
  end

  def looped(arr)
    i = 0
    while i < arr.size
      return arr[i] if i == 1
      i += 1
    end
    "none"
  end

  def memo
    @memo ||= ShrsrConf.secret_key_base
    @memo
  end

  def cased(n)
    k = ShrsrConf.secret_key_base
    case n
    when 1 then k
    else "d"
    end
  end
end

class ShrsrLogic
  def initialize(s)
    @s = s
  end

  def orlocal
    k = ShrsrConf.secret_key_base
    t = @s
    k || t
  end
end

class ShrsrRec
  def created_at_raw
    @created_at_raw
  end

  def created_at=(value)
    self.created_at_raw = ShrsrApp.new.db_time(value)
  end

  def created_at_raw=(value)
    @t = nil
    @created_at_raw = value
  end
end

def shrsr_pass(s)
  s
end

buf = +"ab"
buf << "c"
puts shrsr_pass(buf)
ShrsrConf.secret_key_base = "k1"
puts shrsr_pass(ShrsrApp.new.secret_key_base)
ShrsrConf.secret_key_base = buf
kept = shrsr_pass(ShrsrApp.new.secret_key_base)
buf << "d"
puts kept

pairs = [+"x", 7, nil]
pairs[0] << "y"
seg = shrsr_pass(ShrsrApp.new.part(pairs, 0))
seg << "z"
puts seg, pairs[0]

stamp = +"2026-"
stamp << "10-13"
r = ShrsrRec.new
r.created_at = stamp
stamp << "!"
p r.created_at_raw
r.created_at = 12
p r.created_at_raw

tails = ShrsrTails.new
buf.replace("abc")
ShrsrConf.secret_key_base = buf
[
  [:ifs, -1], [:ternary, -1], [:orop, -1], [:early, -1], [:elsifs, 2], [:cased, 1],
].each do |name, arg|
  got = case name
        when :ifs then shrsr_pass(tails.ifs(true))
        when :ternary then shrsr_pass(tails.ternary(true))
        when :orop then shrsr_pass(tails.orop)
        when :early then shrsr_pass(tails.early(true))
        when :elsifs then shrsr_pass(tails.elsifs(arg))
        else shrsr_pass(tails.cased(arg))
        end
  got << "!"
  puts "#{name}: #{got} #{buf}"
  buf.replace("abc")
end
got = shrsr_pass(tails.looped([1, buf]))
got << "!"
puts "looped: #{got} #{buf}"
buf.replace("abc")
got = shrsr_pass(tails.memo)
got << "!"
puts "memo: #{got} #{buf}"

ShrsrConf.secret_key_base = nil
buf.replace("abc")
logic = ShrsrLogic.new(buf)
got = shrsr_pass(logic.orlocal)
got << "!"
puts "orlocal: #{got} #{buf} #{got.equal?(buf)}"
