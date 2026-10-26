# `self.origin = nil` whose value the method answers, beside a branch that
# assigns an Origin: the writer's parameter is `Origin?`, and the nil went
# in as the boxed temp holding the assignment's value, which C refused to
# initialize a `sp_Origin *` from.
class Origin
  def name; "o"; end
end

class Story
  #: (Origin? value) -> nil
  def origin=(value)
    @origin = value
    nil
  end
  def origin; @origin; end

  def note=(v)
    @note = v
    :ignored
  end
  def note; @note; end

  def set(o)
    if o
      self.origin = o
    else
      self.origin = nil
    end
  end

  def set_note(flag)
    flag ? (self.note = "n") : (self.note = nil)
  end
end

s = Story.new
p s.set(Origin.new).name
p s.origin.name
p s.set(nil)
p s.origin
p s.set_note(true)
p s.set_note(false)
p s.note
