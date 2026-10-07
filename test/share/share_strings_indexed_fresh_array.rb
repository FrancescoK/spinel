# Flag-only: an indexed iterator over a builtin's new String Array (a scan's
# or a split's answer) whose block changes each String and hands it on. The
# block parameter, the other holder and the iterator's answer name the same
# String, as they do over a local's Array: the fused each_with_index terminal
# and the materialized Enumerator (filter_map, with_object, a kept one) walk
# the Array as one of handles. They kept the bytes in two boxes and lost the
# later change (`[["r!", 0], ...]` or `[["r", 0], ...]`).
def go(name)
  kept = []
  b = yield kept
  kept[0] << "#"
  p [name, b, kept]
end
go(:select) { |k| "r3s4".scan(/[a-z]/).each_with_index.select { |e, i| e << "!"; k << e; true } }
go(:reject) { |k| "r3s4".scan(/[a-z]/).each_with_index.reject { |e, i| e << "!"; k << e; false } }
go(:map) { |k| "r3s4".scan(/[a-z]/).each_with_index.map { |e, i| e << "!"; k << e; [e, i] } }
go(:filter_map) { |k| "r3s4".scan(/[a-z]/).each_with_index.filter_map { |e, i| e << "!"; k << e; [e, i] } }
go(:with_index4) { |k| "r3s4".scan(/[a-z]/).each.with_index(4).select { |e, i| e << "!"; k << e; true } }
go(:with_object) { |k| "r3s4".scan(/[a-z]/).each_with_index.with_object([]) { |(e, i), m| e << "!"; k << e; m << [e, i] } }
go(:partition) { |k| "r3s4".scan(/[a-z]/).each_with_index.partition { |e, i| e << "!"; k << e; i == 0 } }
go(:count) { |k| "r3s4".scan(/[a-z]/).each_with_index.count { |e, i| e << "!"; k << e; true } }
go(:split) { |k| "r s".split(" ").each_with_index.select { |e, i| e << "!"; k << e; true } }
go(:kept_enum) { |k| en = "r3s4".scan(/[a-z]/).each_with_index; en.select { |e, i| e << "!"; k << e; true } }
b = "r3s4".scan(/[a-z]/).each_with_index.select { |e, i| e << "!"; true }
b[0][0] << "#"
p b
