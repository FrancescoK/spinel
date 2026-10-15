# PERMUTE (the default), REQUIRE_ORDER and RETURN_IN_ORDER, the `--`
# terminator under each, and POSIXLY_CORRECT turning the default into
# REQUIRE_ORDER, as ruby/getoptlong documents them.
require "getoptlong"

def opts_for(argv)
  ARGV.replace(argv)
  opts = GetoptLong.new(
    ["--verbose", "-v", GetoptLong::NO_ARGUMENT],
    ["--name", "-n", GetoptLong::REQUIRED_ARGUMENT]
  )
  opts.quiet = true
  opts
end

def run(argv, ordering)
  opts = opts_for(argv)
  opts.ordering = ordering if ordering
  seen = []
  opts.each { |opt, arg| seen << [opt, arg] }
  p [opts.ordering, seen, ARGV]
end

argv = %w[a -v b --name n c -- -v d]
p GetoptLong::PERMUTE, GetoptLong::REQUIRE_ORDER, GetoptLong::RETURN_IN_ORDER
p GetoptLong::ORDERINGS
run(argv, nil)
run(argv, GetoptLong::PERMUTE)
run(argv, GetoptLong::REQUIRE_ORDER)
run(argv, GetoptLong::RETURN_IN_ORDER)
run(%w[-v a b], GetoptLong::REQUIRE_ORDER)
run(%w[a b], GetoptLong::RETURN_IN_ORDER)

ENV["POSIXLY_CORRECT"] = "1"
run(argv, nil)
run(argv, GetoptLong::PERMUTE)
ENV.delete("POSIXLY_CORRECT")
run(argv, nil)

begin
  opts_for([]).ordering = 99
rescue ArgumentError => e
  p e.class, e.message
end

opts = opts_for(%w[-v x])
opts.get
begin
  opts.ordering = GetoptLong::PERMUTE
rescue ArgumentError => e
  p e.class, e.message, opts.error?, opts.error_message
end
