# Flag-only: freshness follows the argument actually bound to a returned parameter.
# Fresh and nil arms can accompany that parameter, including through calls.
def pass_text(text = +"default", which = 0)
  return "literal" if which == 1
  return nil if which == 2
  text << "!"
  text
end

def pass_forward(text, which = 0)
  pass_text(text, which)
end

def pass_keyword(text: +"keyword")
  pass_forward(text)
end

def pass_post(*rest, text)
  pass_forward(text)
end

[0, 1, 2].each do |which|
  a = which < 3 ? pass_forward(+"fresh", which) : nil
  p a
end
a = pass_text rescue nil
p a
a = pass_keyword rescue nil
p a
a = pass_keyword(text: +"given") rescue nil
p a
a = pass_post(1, 2, +"post") rescue nil
p a
a = pass_post(*[1, +"splat"]) rescue nil
p a

# The same method's borrowed call must keep the caller's handle.
shared = +"shared"
held = shared
answer = pass_forward(shared)
answer << "?"
p [held, answer, held.equal?(answer)]

# A parameter rebound to another name, or two possible return parameters,
# cannot be summarized as the first parameter. Their existing handles carry.
$kept = +"start"
def keep_text(text)
  $kept = text
  text
end
a = ARGV.empty? ? keep_text(+"kept") : nil
a << "!"
p [$kept, a, $kept.equal?(a)]

def rebound_text(text)
  text = $kept
  text
end
b = ARGV.empty? ? rebound_text(+"unused") : nil
b << "?"
p [$kept, b, $kept.equal?(b)]

def choose_text(left, right, flag)
  flag ? left : right
end
c = ARGV.empty? ? choose_text(+"unused", $kept, false) : nil
c << "."
p [$kept, c, $kept.equal?(c)]

# A recursive default is never evaluated here; freshness must still terminate.
def recursive_default(text = recursive_default)
  text
end
def uses_recursive_default
  recursive_default
end
p recursive_default(+"explicit")

class PassParent
  def text(value)
    value
  end
end
class PassChild < PassParent
  def text(value)
    super(value)
  end
end
p PassChild.new.text(+"super")

require "cgi"
p CGI.unescapeHTML("&#65; &amp; &#x1f600;")
