# tools/repr_diff.sh pairs two compilers' slots by name and sorts each
# change: a slot that became the shared String handle, became boxed or left
# its by-value layout, and any other change, a slot only one side has
# included. Against a compiler without --dump-repr both sides compare the
# slot declarations of their C instead.
puts `bash tools/cost_tools_test.sh repr`
