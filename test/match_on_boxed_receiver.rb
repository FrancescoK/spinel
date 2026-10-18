# `match` and `match?` on a value the analysis holds boxed: a call's
# MatchData kept in a boxed slot, and a safe-navigation chain whose String
# (or nil) is read through its box.
RE = Regexp.new("#\\s*lint:(\\w+)")

class Text
  def initialize(t) = @t = t
  def text = @t
end

# a class that reads a `match`: the match on a boxed receiver answers boxed
class Holder
  attr_reader :match
  def initialize(m) = @match = m
end

class Directive
  def initialize(comment)
    match_data = comment.text.match(RE)
    @match_data = match_data&.pre_match&.match?(/\A\s*\z/) ? match_data : nil
  end

  def mode = @match_data && @match_data[1]
end

p Directive.new(Text.new("# lint:disable Foo")).mode
p Directive.new(Text.new("x # lint:enable Bar")).mode
p Directive.new(Text.new("plain")).mode
p Directive.new(Text.new(ARGV.size > 3 ? :sym : "  # lint:todo Baz")).mode
p Holder.new(3).match
