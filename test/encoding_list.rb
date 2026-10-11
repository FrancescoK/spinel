# Encoding.list: every encoding, in CRuby's order, as Encoding values that
# compare with the constants and answer their names.
names = ::Encoding.list.map { |e| e.name }
p names.size, names.first(3), names.include?("Shift_JIS")
p Encoding.list.include?(Encoding::UTF_8)
p Encoding.list.first == Encoding::BINARY
p Encoding.list.map(&:to_s).last(2)
p Encoding.list.count { |e| Encoding.find(e.name) == e }

# a fresh Array each call
l = Encoding.list
l << Encoding::UTF_8
p l.size, Encoding.list.size
