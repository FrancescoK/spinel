# frozen_string_literal: true
# A require used as a value keeps its caller's line in the spliced program.
p [__LINE__, require_relative("require_expression_lines/relative")]
p __LINE__
p require_relative("require_expression_lines/relative")
p __LINE__

loaded = require "stringio"
p [loaded, __LINE__]
p require("stringio")
p __LINE__

# Hoisting out of a method must not advance any line in that method either.
def load_again
  loaded = require_relative "require_expression_lines/relative"
  [loaded, __LINE__]
end
p load_again
p __LINE__

require_relative "require_expression_lines/relative" if true
p __LINE__
p "caller".frozen?
