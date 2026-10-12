# Marshal.load gives a String the encoding the stream records: a bare String
# record is ASCII-8BIT, and an `I` record's `:E` ivar makes it UTF-8.

x = Marshal.load(Marshal.dump(["\x12a".b, "u"]))
p x
p x[0].encoding
p x[1].encoding
p x[0] == "\x12a".b
p x[0].length

b = Marshal.load(Marshal.dump("\xff\x00ab".b))
p b
p b.encoding
p b.length
p b.bytes
p b[0]

h = Marshal.load(Marshal.dump({ "k".b => "\xc3\xa9".b, "t" => "é" }))
h.each { |k, v| p [k, v, k.encoding, v.encoding, v.length] }

# a dumped binary String loads back to the same bytes and dumps the same way
d = Marshal.dump(["\x01\x02\xff".b, "é", "plain"])
p Marshal.dump(Marshal.load(d)) == d

# streams CRuby wrote: a binary String linked twice, a binary String with an
# ivar but no encoding ivar, and text Strings marked by :E and :encoding
s = Marshal.load("\x04\b[\a\"\a\x01\x02@\x06".b)
p s
p s[0].encoding
p s[1].encoding
p s[0].equal?(s[1])
t = Marshal.load("\x04\bI\"\x06x\x06:\a@qi\x06".b)
p t
p t.encoding
u = Marshal.load("\x04\b[\aI\"\x06a\x06:\x06EFI\"\a\xC3\xA9\x06:\rencoding\"\nUTF-8".b)
p u
p u[1].encoding
p u[1].length
p u[0] == "a"

class Packet
  attr_reader :body, :name
  def initialize(body, name)
    @body = body
    @name = name
  end
end
pk = Marshal.load(Marshal.dump(Packet.new("\x80\x81".b, "né")))
p pk.body
p pk.body.encoding
p pk.body.length
p pk.name
p pk.name.encoding
p pk.name.length
