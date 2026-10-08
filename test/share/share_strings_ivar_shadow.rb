# An ivar's mutation shim writes its shadow before publishing the result.
class ShadowString
  def identity(value) = value

  def run
    @text = +"original"
    copy = public_send(:identity, @text)
    @text.clear
    p [@text, copy, @text.equal?(copy)]
    @text << "reset"
    @text.insert(0, "!")
    p [@text, copy]
    @text.replace("replacement")
    p [@text, copy]
    @text.setbyte(0, 82)
    p [@text, copy]
    @text.freeze
    begin
      @text.clear
    rescue FrozenError
      puts "frozen"
    end
    p [@text, copy, copy.frozen?]
  end
end
ShadowString.new.run
