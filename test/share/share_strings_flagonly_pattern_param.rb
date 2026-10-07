# Flag-only: a pattern binds the String a parameter supplies, including a
# trailing element, a hash value and one-line matches.
class PatternParam
  def array(s)
    case [s]
    in [t]
    end
    s.setbyte(0, 65)
    p [s, t]
  end

  def post(s)
    case ["prefix", s]
    in [*rest, t]
    end
    s.prepend("x")
    p [rest, s, t]
  end

  def hash(s)
    case {text: s}
    in {text: t}
    end
    t.setbyte(0, 65)
    p [s, t]
  end

  def required(s)
    [s] => [t]
    s << "!"
    p [s, t]
  end

  def predicate(s)
    p(([s] in [t]))
    t << "!"
    p [s, t]
  end
end
x = PatternParam.new
x.array(+"abc")
x.post(+"abc")
x.hash(+"abc")
x.required(+"abc")
x.predicate(+"abc")
