# any?/all?/none?/one? with no block on a String array holding nil. A nil
# element is a NULL slot, so the answer reads the elements, not the length.
none = ["a", "b"].map { |s| s == "z" ? s : nil }
p [none.any?, none.all?, none.none?, none.one?]
some = ["a", "b", "c"].map { |s| s == "b" ? s : nil }
p [some.any?, some.all?, some.none?, some.one?]
two = ["a", "b", "c"].map { |s| s == "c" ? nil : s }
p [two.any?, two.all?, two.none?, two.one?]
full = ["a", "b"].map { |s| s + "!" }
p [full.any?, full.all?, full.none?, full.one?]
args = ["x"]
deleted = ["-l", "--long"].map { |name| args.delete(name) }
p deleted.any?
gap = ["a"]
gap[2] = "c"
p [gap.all?, gap.any?, gap.one?]
