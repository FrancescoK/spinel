# A user object reaching a String / Integer argument slot converts through
# CRuby's implicit conversion protocol (#to_str / #to_int). This class defines
# neither, and its class is STATIC at the call, so the call could only ever
# raise: spinel must refuse it at compile time and name what is missing,
# rather than emit a run-time raise (or, before the protocol existed, put the
# object pointer in the C slot and stop the generated-C build with a message
# about sp_str_index_opt). The run-time half of the protocol -- the same class
# reached through a poly slot, where it IS a run-time question -- is pinned by
# test/implicit_conversion_args.rb.
# spinel: rbs-seed-check
class Inert
end

p "abcd".index(Inert.new)
