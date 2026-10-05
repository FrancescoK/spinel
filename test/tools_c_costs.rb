# tools/c_costs.sh counts the constructs of generated C that cost at run
# time, everywhere and inside loops: a snapshot copy in a loop body and one
# in a function only a loop calls count as in a loop, one after the loop
# does not, and neither do a prototype, a string literal or a `while (0)`.
# A new copy inside a loop is listed with its function.
puts `bash tools/cost_tools_test.sh costs`
