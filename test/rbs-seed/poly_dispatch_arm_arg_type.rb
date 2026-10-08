# A poly dispatch handing the call site's argument to every arm.
#
# Each arm's declared parameter type is accurate and the arm that runs is
# correct; the arms that do not run still got the C emitted for them, with a
# pointer of one class passed where an unrelated class is declared. An arm
# whose parameter class is unrelated to the argument cannot be this call's
# target -- a receiver of that class would raise in CRuby rather than
# reinterpret the argument -- so it is not emitted, and the NoMethodError
# default covers it.
#
# A subclass in an ancestor-typed slot is a different matter: the layouts
# coincide and it gets a cast, so those arms stay.
# spinel: rbs-seed-run
class UserParams
  def initialize(n)
    @n = n
  end

  def n
    @n
  end
end

class TagParams
  def initialize(t)
    @t = t
  end

  def t
    @t
  end
end

class AdminParams < UserParams
end

class User
  def update(p)
    p.n
  end
end

class Tag
  def update(p)
    p.t
  end
end

class Admin
  def update(p)
    p.n * 10
  end
end

def pick(flag)
  flag ? User.new : Tag.new
end

def pick2(flag)
  flag ? User.new : Admin.new
end

record = pick(true)
p record.update(UserParams.new(7))

# the same call with the other receiver, and its own argument type
other = pick(false)
p other.update(TagParams.new("t"))

# a subclass argument into an ancestor-typed parameter: both arms survive,
# because the layouts coincide and the cast is a no-op
p pick2(true).update(AdminParams.new(3))
p pick2(false).update(AdminParams.new(3))
