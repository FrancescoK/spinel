# A required file carrying `# spinel: defer-refusals`: the unsupported
# statements of its create_aggregate would raise NotImplementedError where
# they run (so it is not called here), and the rest of the file compiles
# and runs as written; without the pragma the program would not build.
require_relative "defer_refusals_pragma/aggregates"

r = Aggregates::Registry.new
r.define("plus_one") { |x| x + 1 }
r.define("join") { |*xs| xs.join("-") }
p r.call("plus_one", 41)
p r.call("join", 1, 2, 3)
p r.names
p r.respond_to?(:create_aggregate)
p r.names.size >= 2
