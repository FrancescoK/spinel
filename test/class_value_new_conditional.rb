# A class chosen by a conditional, `case` or `||` and sent `new` right
# there: each class it can choose gets an arm, and a sole keyword hash
# binds an initialize's keywords by name.

class Pk
  def initialize(x, k: nil)
    @v = [x, k]
  end

  def to_s = "Pk #{@v.inspect}"
end

class Qk
  def initialize(x, k: nil)
    @v = [x, k]
  end

  def to_s = "Qk #{@v.inspect}"
end

class Ko
  def initialize(k: nil)
    @k = k
  end

  def to_s = "Ko #{@k.inspect}"
end

class Kp
  def initialize(k: nil)
    @k = k
  end

  def to_s = "Kp #{@k.inspect}"
end

class Ho
  def initialize(opts)
    @opts = opts
  end

  def to_s = "Ho #{@opts.inspect}"
end

k = ARGV.length
puts (ARGV.empty? ? Pk : Qk).new(1, k: k)
puts (ARGV.empty? ? Qk : Pk).new(2)
puts((if ARGV.empty? then Pk else Qk end).new(3, k: k))
puts((case ARGV.size when 0 then Qk else Pk end).new(4, k: k))
none = ARGV.empty? ? nil : Qk
puts (none || Pk).new(5, k: k)

puts (ARGV.empty? ? Ko : Kp).new(k: k)
c = ARGV.empty? ? Kp : Ko
puts c.new(k: k)
puts((case ARGV.size when 0 then Ko else Kp end).new(k: k))
puts [Ko, Kp][k].new(k: k)

puts (ARGV.empty? ? Ho : Ko).new(k: k)
puts (ARGV.empty? ? Ko : Ho).new(k: k)

KwS = Struct.new(:k)
PosS = Struct.new(:a, :b, keyword_init: false)
p KwS.new(k: 1).k
p PosS.new(1, 2).a
p (ARGV.empty? ? KwS : Ko).new(k: "s").k
p (ARGV.empty? ? PosS : Ko).new(k: k).to_a
