# The String-only surface reached through an UNTYPED (poly) receiver. A seed
# that leaves a parameter untyped is honest -- the parameter really is untyped
# -- so these must compile, and the result type the analysis publishes has to
# be the one the emitter actually produces.
#
# #4004: casecmp is nil-or-Integer, and WHICH is decided by the argument. The
# emitter boxes the result when the argument is poly (a string compares,
# anything else is nil), but the poly-receiver rule typed the call Integer
# unconditionally -- so the consumer read an sp_RbVal unboxed and the C
# compiler reported it against generated code, in its voice rather than
# spinel's.
# spinel: rbs-seed-run
class K
  def zero_p(a, b)
    a.casecmp(b).zero?
  end

  def eq_zero(a, b)
    a.casecmp(b) == 0
  end

  def ci(a, b)
    a.casecmp?(b)
  end

  def raw(a, b)
    a.casecmp(b)
  end

  def nil_p(a, b)
    a.casecmp(b).nil?
  end

  # found while testing #4004: a byte-offset search had no arm for a poly
  # NEEDLE, so it fell through to "no such method" naming String, and
  # byterindex was missing from the poly surface altogether
  def bidx(a, b)
    a.byteindex(b)
  end

  def bidx_from(a, b)
    a.byteindex(b, 1)
  end

  def bridx(a, b)
    a.byterindex(b)
  end

  # and #crypt put its poly salt straight into the const char* slot
  def salt(a, b)
    a.crypt(b).class
  end
end

k = K.new
p k.zero_p("Alice", "alice")
p k.zero_p("Alice", "bob")
begin
  p k.zero_p("Alice", 5)
rescue NoMethodError => e
  p [e.class, e.message]
end
p k.eq_zero("Alice", "alice")
p k.eq_zero("Alice", 5)
p k.ci("Alice", "alice")
p k.ci("Alice", 5)
p k.raw("Alice", "alice")
p k.raw("Alice", 5)
p k.nil_p("Alice", "alice")
p k.nil_p("Alice", 5)
p k.bidx("abcb", "b")
p k.bidx_from("abcb", "b")
p k.bridx("abcb", "b")
p k.salt("abc", "sa")
