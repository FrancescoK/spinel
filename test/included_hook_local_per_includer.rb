# A local of an included hook is the hook call's own: each include runs
# the hook afresh, so `n ||= 0` starts from nil for every includer.
module Hook
  def self.included(base)
    n ||= 0
    n += 1
    p n
  end
end

class A
  include Hook
end

class B
  include Hook
end
