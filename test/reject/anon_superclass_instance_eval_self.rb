# Inside instance_eval a bare `superclass` asks the class whose superclass is
# an anonymous class, not a method of the program, so it stays refused though
# it is written in an instance method.
class FromAnon < Struct.new(:a)
end

class Probe
  def look
    FromAnon.instance_eval { superclass }
  end
end
p Probe.new.look
