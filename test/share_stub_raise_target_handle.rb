# A base class's stub that only raises (NotImplementedError), which every
# subclass overrides, answers no value: a call reaching it and the
# override hands on the override's String itself, so the program compiles
# and the change through it shows in the slot (#9258)
class Gadget
  def save
    self.code = make_code
  end

  def code=(v)
    raise NotImplementedError
  end

  def make_code
    raise NotImplementedError
  end

  def make_label = fail("abstract")

  def relabel
    self.label = make_label
  end

  def label=(v)
    raise NotImplementedError
  end
end

class Widget < Gadget
  attr_reader :code, :label

  def label=(v)
    @label = v
  end

  def code=(v)
    @code = v
  end

  def make_code
    @code = +"w"
  end

  def make_label
    @label = +"t"
  end
end

w = Widget.new
w.save
w.code << "!"
p w.code
w.relabel
w.label << "?"
p w.label
