# Statement bangs use the same handle and String view as value-form bangs.
class BangReaderStrings
  attr_accessor :text
  Pair = Struct.new(:text)

  def run
    self.text = +"aabc"
    copy = catch(:text) { throw :text, self.text }
    self.text.sub!("b", "d")
    p [self.text, copy, self.text.equal?(copy)]
    self.text.gsub!("a", "o")
    p [self.text, copy]
    self.text.tr!("o", "x")
    p [self.text, copy]
    self.text.delete!("x")
    p [self.text, copy]

    pair = Pair.new("aabc")
    copy, unused = pair.text, 1
    begin
      pair.text.gsub!("a", "o")
    rescue FrozenError
      puts "frozen"
    end
    p [pair.text, copy, pair.text.equal?(copy), copy.frozen?]

    pair = Pair.new("aab#{ARGV.size}")
    copy = loop { break pair.text }
    pair.text.sub!("b", "d")
    p [pair.text, copy, pair.text.equal?(copy)]
  end
end
BangReaderStrings.new.run
