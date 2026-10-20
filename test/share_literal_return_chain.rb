# frozen_string_literal: true
# Forty methods each answer the next one's answer through two returns, and
# the last answers a literal. Following the returns asks each method on
# both paths; the walk keeps its depth through a return's value and stops
# within a budget, where a walk that restarted its depth at each return
# asked 2**40 times. The literal is held by a Hash beside a String that is
# changed in place.
class Word
  def m0(x)
    return m1(x) if x
    return m1(!x)
  end
  def m1(x)
    return m2(x) if x
    return m2(!x)
  end
  def m2(x)
    return m3(x) if x
    return m3(!x)
  end
  def m3(x)
    return m4(x) if x
    return m4(!x)
  end
  def m4(x)
    return m5(x) if x
    return m5(!x)
  end
  def m5(x)
    return m6(x) if x
    return m6(!x)
  end
  def m6(x)
    return m7(x) if x
    return m7(!x)
  end
  def m7(x)
    return m8(x) if x
    return m8(!x)
  end
  def m8(x)
    return m9(x) if x
    return m9(!x)
  end
  def m9(x)
    return m10(x) if x
    return m10(!x)
  end
  def m10(x)
    return m11(x) if x
    return m11(!x)
  end
  def m11(x)
    return m12(x) if x
    return m12(!x)
  end
  def m12(x)
    return m13(x) if x
    return m13(!x)
  end
  def m13(x)
    return m14(x) if x
    return m14(!x)
  end
  def m14(x)
    return m15(x) if x
    return m15(!x)
  end
  def m15(x)
    return m16(x) if x
    return m16(!x)
  end
  def m16(x)
    return m17(x) if x
    return m17(!x)
  end
  def m17(x)
    return m18(x) if x
    return m18(!x)
  end
  def m18(x)
    return m19(x) if x
    return m19(!x)
  end
  def m19(x)
    return m20(x) if x
    return m20(!x)
  end
  def m20(x)
    return m21(x) if x
    return m21(!x)
  end
  def m21(x)
    return m22(x) if x
    return m22(!x)
  end
  def m22(x)
    return m23(x) if x
    return m23(!x)
  end
  def m23(x)
    return m24(x) if x
    return m24(!x)
  end
  def m24(x)
    return m25(x) if x
    return m25(!x)
  end
  def m25(x)
    return m26(x) if x
    return m26(!x)
  end
  def m26(x)
    return m27(x) if x
    return m27(!x)
  end
  def m27(x)
    return m28(x) if x
    return m28(!x)
  end
  def m28(x)
    return m29(x) if x
    return m29(!x)
  end
  def m29(x)
    return m30(x) if x
    return m30(!x)
  end
  def m30(x)
    return m31(x) if x
    return m31(!x)
  end
  def m31(x)
    return m32(x) if x
    return m32(!x)
  end
  def m32(x)
    return m33(x) if x
    return m33(!x)
  end
  def m33(x)
    return m34(x) if x
    return m34(!x)
  end
  def m34(x)
    return m35(x) if x
    return m35(!x)
  end
  def m35(x)
    return m36(x) if x
    return m36(!x)
  end
  def m36(x)
    return m37(x) if x
    return m37(!x)
  end
  def m37(x)
    return m38(x) if x
    return m38(!x)
  end
  def m38(x)
    return m39(x) if x
    return m39(!x)
  end
  def m39(x)
    return m40(x) if x
    return m40(!x)
  end
  def m40(x) = "w"
end
w = Word.new.m0(ARGV.empty?)
h = { k: w }
x = ARGV.size > 5 ? w : +"mutable"
x << "!" unless x.frozen?
p w.frozen?, h[:k].equal?(w), x
