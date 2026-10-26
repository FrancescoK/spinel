# An alias of a method defined under a run-time condition binds the def it
# follows, not the dispatcher the conditional defs become
unless $nope
  class G
    def hi = "hi"
  end
  class G
    alias_method :old_hi, :hi
    def hi = old_hi + "!"
  end

  class K
    def hi = "k"
    alias old_hi hi
    def hi = old_hi + "?"
  end

  class C3
    def hi = "a"
    alias_method "hi1", "hi"
    def hi = hi1 + "b"
    alias_method :hi2, :hi
    def hi = hi2 + "c"
  end

  class S
    class << self
      def hi = "s"
      alias_method :old_hi, :hi
      def hi = old_hi + "."
    end
  end

  class R
    def hi = "r"
    alias_method :old_hi, :hi
    def hi = old_hi + "1"
    def old_hi = "x"
  end

  class V
    def hi = "v"
    private alias_method :old_hi, :hi
    def hi = old_hi + "~"
  end

  class W
    def hi = "w"
    private :hi
    public :hi
    alias_method :old_hi, :hi
    def hi = old_hi + "+"
  end

  # the name rebound between a def and the alias: the alias takes that
  class O
    def hi = "a"
    def other = "o"
    alias_method :hi, :other
    alias_method :old_hi, :hi
    def hi = old_hi + "!"
  end

  class B
    def hi = "a"
    begin
      def hi = "b"
    end
    alias_method :old_hi, :hi
    def hi = old_hi + "!"
  end

  class D
    def hi = "a"
  end
  begin
    class D
      define_method(:hi) { "d" }
    end
  end
  class D
    alias_method :old_hi, :hi
    def hi = old_hi + "!"
  end

  # an undef in another class leaves this one's alias alone
  class U
    def hi = "u"
  end
  class U2
    def hi = 1
    undef hi
  end
  class U
    alias_method :old_hi, :hi
    def hi = old_hi + "!"
  end

  # define_singleton_method between them rebinds a class method
  class DS
    def self.hi = "first"
    define_singleton_method(:hi) { "ds" }
    class << self
      alias_method :old_hi, :hi
    end
    def self.hi = old_hi + "!"
  end
  # but leaves an instance method's alias alone
  class DI
    def hi = "di"
    define_singleton_method(:hi) { "single" }
    alias_method :old_hi, :hi
    def hi = old_hi + "!"
  end
  class DT
    def self.hi = "first"
  end
  class DT
    define_singleton_method(:hi) { "dt" }
    class << self
      alias_method :old_hi, :hi
    end
    def self.hi = old_hi + "!"
  end
end
p G.new.hi
p K.new.hi
p C3.new.hi
p S.hi
p R.new.hi
p R.new.old_hi
p V.new.hi
p W.new.hi
p O.new.hi
p B.new.hi
p D.new.hi
p U.new.hi
p DS.hi
p DT.hi
p DI.new.hi
