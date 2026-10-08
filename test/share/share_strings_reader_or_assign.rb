# A reader stored by ||= must keep its shared String, including the
# mutation and frozen mark, through explicit, implicit and method readers.
class SharedReaderOrAssign
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def custom = @text

  def check
    explicit = nil
    explicit ||= self.text
    implicit = nil
    implicit ||= text
    method = nil
    method ||= custom
    reflected = nil
    reflected ||= instance_variable_get(:@text)
    explicit << "!"
    implicit << "?"
    method << "."
    reflected << ":"
    p [@text, explicit, implicit, method, reflected]
    p [explicit.equal?(self.text), implicit.equal?(self.text), method.equal?(self.text), reflected.equal?(self.text)]
  end
end

SharedReaderOrAssign.new(+"a\0b").check
box = SharedReaderOrAssign.new(+"outside")
kept = nil
kept ||= box.text
kept << "!"
p [box.text, kept, kept.equal?(box.text)]

frozen_box = SharedReaderOrAssign.new("f\0rozen".b.freeze)
frozen_value = nil
frozen_value ||= frozen_box.text
p [frozen_value.frozen?, frozen_value.bytes, frozen_value.equal?(frozen_box.text)]
begin
  frozen_value << "!"
rescue => error
  p error.class
end
