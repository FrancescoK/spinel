# A boxed numeric accumulator validates division and modulo operands before
# conversion, including after an addition widens an initially native local.
# spinel: share
# spinel: gc-minor
def checked_div_mod(value, divisor)
  value += [0, "unused"][0]
  begin
    value /= divisor
    p value
  rescue TypeError => e
    p [e.class, value]
  end
  begin
    value %= divisor
    p value
  rescue TypeError => e
    p [e.class, value]
  end
end

[nil, "2", true, :two, [], {}].each do |divisor|
  checked_div_mod(7, divisor)
  checked_div_mod(7.5, divisor)
end
checked_div_mod(7, 2)
checked_div_mod(7.5, 2.0)

class DivisorCoercion
  def coerce(value) = [value, 2]
end
checked_div_mod(7, DivisorCoercion.new)
