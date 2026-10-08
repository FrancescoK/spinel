# A String constant supplied to raise is its message, not a class name.
module RaisedStrings
  TEXT = "frozen"
  MUTABLE = +"mutable"
end
class RaiseStringConstant
  TEXT = "local"
  def run
    value = begin
      raise TEXT
    rescue => e
      p e.class
      e.message
    end
    p [TEXT.equal?(value), value.frozen?]
    begin
      value.setbyte(0, 65)
    rescue FrozenError
      puts "frozen"
    end
    p [TEXT, value]

    value = begin
      fail RaisedStrings::TEXT, cause: nil
    rescue => e
      p [e.class, e.cause]
      e.message
    end
    p [RaisedStrings::TEXT.equal?(value), value.frozen?]

    value = begin
      raise RaisedStrings::MUTABLE
    rescue => e
      e.message
    end
    value << "!"
    p [RaisedStrings::MUTABLE, value, RaisedStrings::MUTABLE.equal?(value)]

    begin
      raise TEXT, "extra"
    rescue => e
      p e.class
    end
    begin
      raise TEXT, cause: 1
    rescue => e
      p e.class
    end
  end
end
RaiseStringConstant.new.run
