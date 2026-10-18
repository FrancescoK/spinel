# A safe-navigation call on a String-or-nil receiver held boxed, in a
# program that defines a method of the same name itself: the value arm
# reads the receiver through its box, so `match?` takes the String out of
# it rather than handing the box over as the String's bytes.
RE = Regexp.new("#\\s*lint:(\\w+)")

class Text
  def initialize(t) = @t = t
  def text = @t
end

class Holder
  attr_reader :match
  def initialize(m) = @match = m
end

class Pat
  def match?(s) = s == "x"
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
p Pat.new.match?("x")
