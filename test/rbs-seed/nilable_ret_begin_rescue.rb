# A method signed `-> String?` / `-> Integer?` gets a concrete C slot -- a
# nullable String is a NULL `const char *`. A begin/rescue body builds its
# value in one accumulator assigned by both arms, and that accumulator is
# typed from the union (poly), so the tail had to narrow into the declared
# slot. The if/else and ternary forms of the same union already did (#4154).
# spinel: rbs-seed-run
class Box
  def self.f(x)
    begin
      raise ArgumentError, "no" if x.nil?
      x.to_s
    rescue ArgumentError
      nil
    end
  end

  def self.g(x)
    begin
      raise ArgumentError, "no" if x.nil?
      Integer(x)
    rescue ArgumentError
      nil
    end
  end
end

p Box.f(1)
p Box.f(nil)
p Box.g("7")
p Box.g(nil)
