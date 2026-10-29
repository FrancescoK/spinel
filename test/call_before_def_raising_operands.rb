# A call before its method's def raises after the operands ahead of it,
# and one of those that raises (a division or a modulo by zero) raises
# first: in a constant's value, a condition and a local's value. One that
# cannot raise answers the call's NameError, whatever operator or slot
# takes the call's value.
class V
  def self.twice(i) = i * 2
  p twice(3)
  n = 0
  # an Integer quotient by a zero raises first
  begin
    X1 = 1 / n + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    X2 = 7 % n + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  # a Float modulo raises at 0 too
  begin
    X3 = 7.0 % n + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    X4 = 7.divmod(n) + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  # a Float quotient answers Infinity: the call raises
  begin
    X5 = 7.fdiv(n) + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    X6 = 7.0 / n + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  # a nonzero literal divisor cannot raise
  begin
    X7 = 7 / 2 + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  # a condition's operands run in order too
  begin
    p 1 if 1 / n + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  # a local's value, an operand of an Integer or a Float operator
  begin
    x = 2 + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    x = 2 + zz(3)
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    x = 2.0 + zz(1)
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    x = 1 / n + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  # a Rational's, a Hash's, an Array's and a String's operators, unary
  # operators and a typed parameter take the call's value
  begin
    x = Rational(1, 2) + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    x = {a: 1}[zz]
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    x = [1, 2][zz]
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    x = "a" + zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    x = -zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    x = !zz
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  begin
    x = twice(zz)
  rescue ZeroDivisionError, NameError => e
    p e.class
  end
  def self.zz(*) = 1
end
