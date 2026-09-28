# An Enumerator owns its method label, including the heap Strings used for
# each_slice(n) and each_cons(n). Allocate after construction so collection
# must find the label through the Enumerator, not a constructor temporary.
# GC.start is currently a no-op in Spinel; the churn triggers real collections.
def check_label(en)
  10000.times { |i| "churn#{i}" }
  puts en.inspect
end

check_label((1..4).each_slice(2))
check_label([1, 2, 3, 4, 5].each_slice(3))
check_label((1..4).each_cons(2))
check_label([1, 2, 3, 4, 5].each_cons(3))

# A shallow copy keeps the same label alive after its source goes away.
def copied_slices
  (1..4).each_slice(2).dup
end
check_label(copied_slices)

# Repeated collections must preserve both the label and the iteration state.
en = (1..4).each_slice(2)
p en.next
check_label(en)
p en.next
en.rewind
check_label(en)
p en.to_a

# Static labels need the same marker-byte representation as heap labels.
# These cover runtime constructors, direct emitted stores and source stamping.
check_label([1, 2, 3].each)
check_label([1, 2, 3].reverse_each)
check_label([1, 2, 3].each_with_index)
check_label([1, 2, 3].each_index)
check_label([1, 2, 3].map)
check_label([1, 2, 3].cycle)
check_label("ab".each_char)
check_label("ab".each_byte)
check_label("ab".each_codepoint)
check_label("a\nb\n".each_line)
check_label("a\nb\n".each_line(chomp: true))
check_label("a\nb\n".each_line(chomp: false))
check_label(5.then)
check_label(5.yield_self)

# These labels have pre-existing formatting differences from CRuby. Exercise
# their stores and inspect readers for sanitizer coverage without pinning that
# unrelated formatting (separator/regexp arguments).
def check_static_label(en)
  10000.times { |i| "churn#{i}" }
  p en.inspect.start_with?("#<Enumerator:")
end
check_static_label("a:b:".each_line(":"))
check_static_label("aba".gsub(/a/))
# The endless-range arm builds a generator-backed Enumerator: its inspect shows
# the Generator wrapper where CRuby shows the range, and embeds a process
# address, so assert only that its label survives collection to be read.
check_static_label((1..).each)

# Generator labels are static too; their inspect embeds a process address.
gen = Enumerator.new { |y| y << 7 }
loop_enum = loop
10000.times { |i| "churn#{i}" }
p gen.next
p loop_enum.next
