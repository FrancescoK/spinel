# tools/alloc_diff.sh runs each program built by both compilers and flags
# the ones whose allocations or allocated bytes grew past the threshold. A
# program gets the words of its .args file; one whose two binaries print
# differently, or whose source reads the clock, is skipped and said to be.
puts `bash tools/cost_tools_test.sh alloc`
