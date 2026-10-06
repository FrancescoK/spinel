# tools/c_costs.sh counts only code the program can run, and counts
# recursion as a loop: a runtime helper nothing calls is left out, boxing
# in a loop of its own though it does; a callback main only names counts;
# a function calling itself, two calling each other and the leaf they call
# count as in a loop.
puts `bash tools/cost_tools_test.sh costs-live`
