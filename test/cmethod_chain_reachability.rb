# A class-side call chain where each class method calls the next twice, inherited
# by a subclass: deciding whether an inherited method reaches an override walks
# each callee once (a visited set), not once per path (2**24 paths here).
class Base
  def self.m0(x)
    m1(x) + m1(x + 1)
  end
  def self.m1(x)
    m2(x) + m2(x + 1)
  end
  def self.m2(x)
    m3(x) + m3(x + 1)
  end
  def self.m3(x)
    m4(x) + m4(x + 1)
  end
  def self.m4(x)
    m5(x) + m5(x + 1)
  end
  def self.m5(x)
    m6(x) + m6(x + 1)
  end
  def self.m6(x)
    m7(x) + m7(x + 1)
  end
  def self.m7(x)
    m8(x) + m8(x + 1)
  end
  def self.m8(x)
    m9(x) + m9(x + 1)
  end
  def self.m9(x)
    m10(x) + m10(x + 1)
  end
  def self.m10(x)
    m11(x) + m11(x + 1)
  end
  def self.m11(x)
    m12(x) + m12(x + 1)
  end
  def self.m12(x)
    m13(x) + m13(x + 1)
  end
  def self.m13(x)
    m14(x) + m14(x + 1)
  end
  def self.m14(x)
    m15(x) + m15(x + 1)
  end
  def self.m15(x)
    m16(x) + m16(x + 1)
  end
  def self.m16(x)
    m17(x) + m17(x + 1)
  end
  def self.m17(x)
    m18(x) + m18(x + 1)
  end
  def self.m18(x)
    m19(x) + m19(x + 1)
  end
  def self.m19(x)
    m20(x) + m20(x + 1)
  end
  def self.m20(x)
    m21(x) + m21(x + 1)
  end
  def self.m21(x)
    m22(x) + m22(x + 1)
  end
  def self.m22(x)
    m23(x) + m23(x + 1)
  end
  def self.m23(x)
    m24(x) + m24(x + 1)
  end
  def self.m24(x)
    x
  end
end

class Sub < Base
end

puts Sub.m0(1)
