# Under --share-strings (#6765), an attribute assignment that is the last
# expression (or the `return`) of a method an --rbs signature declares
# `-> nil` is a dropped statement, not a kept value: the method is a `void`
# C function and answers nothing, so no consumer takes the String it
# stores as a copy. The rule counted it as a kept value and refused it
# ("an attribute assignment in value position ... would be a copy"), as it
# refused every generated writer of a Rails application's models.
# spinel: rbs-seed-check
class ShrvwRec
  def raw
    @raw
  end

  def raw=(value)
    @t = nil
    @raw = value
  end

  def name=(value)
    self.raw = value
  end

  def title=(value)
    if value.empty?
      self.raw = "untitled"
    else
      self.raw = value
    end
  end

  def label=(value)
    return self.raw = value if value.size > 3
    self.raw = value.upcase
  end
end

buf = +"2026-"
buf << "10-13"
r = ShrvwRec.new
r.name = buf
buf << "!"
p r.raw
r.title = ""
p r.raw
r.title = buf
buf << "?"
p r.raw
r.label = "abcd"
p r.raw
r.label = "ab"
p r.raw
