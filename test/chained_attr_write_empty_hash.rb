# `adj = ctx.adjacent = {}` (json_schemer's validate_instance): the attribute
# write answers its argument, so the local and the attribute hold the same
# hash, and the literal takes the variant the local's key writes choose.

class Ctx
  attr_accessor :adjacent
end

def run(ctx)
  orig = ctx.adjacent
  adj = ctx.adjacent = {}
  adj["k"] = 1
  r = [adj.size, ctx.adjacent.equal?(adj)]
  ctx.adjacent = orig
  r
end

c = Ctx.new
c.adjacent = {"a" => 2}
p run(c)
p c.adjacent
