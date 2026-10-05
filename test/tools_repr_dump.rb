# --dump-repr prints one sorted line per slot with the representation the
# analysis chose for it: a String ivar mutated in place is the shared
# handle, a mixed Array's element is boxed, a Range is held by value, an
# Integer ivar carries the nil sentinel. tools/repr_diff.sh run with one
# compiler on both sides finds nothing to report.
puts `bash tools/cost_tools_test.sh dump`
