# chr with an encoding argument (Encoding::UTF_8) on a value typed poly (a
# block param over an array that mixes kinds) encodes the codepoint, as it
# does on a typed Integer; it raised NoMethodError. clip-rb's CLIP tokenizer
# builds its byte-to-unicode table this way.
bs = (33..126).to_a
cs = bs.dup
n = 0
(0...256).each do |b|
  unless bs.include?(b)
    bs << b
    cs << (256 + n)
    n += 1
  end
end
cs = cs.map { |n| n.chr(Encoding::UTF_8) }
p cs.size, cs[0], cs[-1], cs[-1].bytesize
x = [300, "a"].first
p x.chr(Encoding::UTF_8)
p [65, "a"].first.chr(Encoding::US_ASCII)
