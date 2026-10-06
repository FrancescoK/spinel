# --dump-repr prints one sorted line per slot with the representation the
# analysis chose for it: a String ivar mutated in place is the shared
# handle, a mixed Array's element is boxed, a Range is held by value, an
# Integer ivar carries the nil sentinel. The facts beside the type show
# too: an Integer Array a gap leaves nils in (elem_nil), a local only ever
# holding an Array or nil (arr_or_nil), a local a lambda captures in a
# heap cell (cell=heap), a class variable. tools/repr_diff.sh run with one
# compiler on both sides finds nothing to report.
puts `bash tools/cost_tools_test.sh dump`
