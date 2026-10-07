# Flag-only: a reflective ivar read consumed as a shared String keeps
# the slot's handle. A plain String slot can still supply a fresh handle.
class ReflectString
  TEXT = +"constant"

  def run
    @text = TEXT
    t = instance_variable_get(:@text)
    TEXT.setbyte(0, 67)
    p [TEXT, t]
    u = self.instance_variable_get("@text")
    u << "!"
    p [TEXT, t, u]
  end
end
ReflectString.new.run

class ReflectPlain
  def initialize
    @text = +"plain"
  end
end
x = ReflectPlain.new
s = x.instance_variable_get(:@text)
t = s
t << "!"
p [s, t, x.instance_variable_get(:@text)]
