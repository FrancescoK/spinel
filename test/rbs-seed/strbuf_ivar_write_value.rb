# An ivar write in VALUE position evaluates to the slot. When a mutation
# elsewhere makes that slot a strbuf (a live sp_String rather than a const
# char *), the write's value is that handle, and boxing it has to box the
# handle. It was boxed as a plain string, whose C parameter is a const char *,
# so the generated C did not compile -- and only with the RBS seed, which is
# what pins the ivar to String and keeps the slot out of poly.
# spinel: rbs-seed-check
class Box
  def initialize
    @body = nil
    @n = 0
  end

  def write(key, value)
    case key
    when :body
      @body = value.nil? ? nil : value.to_s
    when :n
      @n = value.to_i
    end
  end

  def stamp
    b = @body
    b << "!" unless b.nil?
    b
  end

  def body
    @body
  end
end

b = Box.new
b.write(:body, String.new("hi"))   # literals are frozen here (frozen_string_literal semantics), and the value form now keeps the argument itself
b.stamp
puts b.body
puts b.write(:n, 2).to_s
puts b.write(:body, String.new("z")).to_s
puts b.body
