# Proc arguments retain the handles handed on by String value routes.
class ProcStrings
  attr_accessor :text
  Pair = Struct.new(:text)

  def run
    self.text = "a#{ARGV.size}"
    copy = proc { |v| v }.call(self.text)
    copy.clear
    p [self.text, copy, self.text.equal?(copy)]

    pair = Pair.new(+"member")
    copy = ->(v) { v }.call(pair.text)
    copy << "!"
    p [pair.text, copy, pair.text.object_id == copy.object_id]

    @text = +"instance"
    copy = proc { |v| v }[@text]
    @text << "!"
    p [@text, copy]

    $proc_text = +"global"
    copy = proc { |v| v }.yield($proc_text)
    copy << "!"
    p [$proc_text, copy]

    value = +"route"
    copy = proc { |v, extra| v }.call(value.then { |s| s }, "allocate#{ARGV.size}")
    copy << "!"
    p [value, copy, value.equal?(copy)]
  end
end
ProcStrings.new.run
