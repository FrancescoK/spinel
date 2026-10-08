# Encoding mutation is visible through the exception and value routes.
class EncodingStrings
  attr_accessor :text
  Pair = Struct.new(:text)

  def run
    self.text = "message#{ARGV.size}"
    copy = begin
      raise self.text
    rescue => e
      e.message
    end
    p self.text.object_id == copy.object_id
    self.text.force_encoding("ASCII-8BIT")
    p [self.text.encoding, copy.encoding]
    copy.force_encoding("UTF-8")
    p [self.text.encoding, copy.encoding]

    @text = "instance#{ARGV.size}"
    alias_text = @text
    @text.force_encoding("ASCII-8BIT")
    p [@text.encoding, alias_text.encoding]

    pair = Pair.new("member#{ARGV.size}")
    alias_text = pair.text
    pair.text.force_encoding("ASCII-8BIT")
    p [pair.text.encoding, alias_text.encoding]

    value = "route#{ARGV.size}"
    alias_text = value
    value.then { |s| s }.force_encoding("ASCII-8BIT")
    p [value.encoding, alias_text.encoding]

    value.freeze
    begin
      value.then { |s| s }.force_encoding("UTF-8")
    rescue FrozenError
      puts "frozen"
    end
    p [value.encoding, alias_text.encoding]
  end
end
EncodingStrings.new.run
