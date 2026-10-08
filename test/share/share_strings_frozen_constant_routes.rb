# Frozen constants keep their identity when a route hands them to an alias.
module ConstantStrings
  TEXT = "frozen"
end
class ConstantStringRoutes
  TEXT = "local"
  def run
    value = catch(:text) { throw :text, TEXT }
    p [TEXT.equal?(value), TEXT.object_id == value.object_id, value.frozen?]
    begin
      value << "!"
    rescue FrozenError
      puts "frozen"
    end
    p [TEXT, value]

    value = catch(:qualified) { throw :qualified, ConstantStrings::TEXT }
    p [ConstantStrings::TEXT.equal?(value), value.frozen?]
    begin
      value << "!"
    rescue FrozenError
      puts "frozen"
    end
    p [ConstantStrings::TEXT, value]

    value = proc { |s| s }.call(TEXT)
    p [TEXT.equal?(value), value.frozen?]
    begin
      value.setbyte(0, 65)
    rescue FrozenError
      puts "frozen"
    end
    p [TEXT, value]
  end
end
ConstantStringRoutes.new.run
