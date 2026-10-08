# The literal splat is expanded before emission. Its old Array node must
# not be sealed as a typed container; the actual rest arguments carry it.
class ExpandedShareSplat
  def first(*xs) = xs[0]

  def parameter(s)
    t = first(*[s])
    s << "+"
    p [s, t, t.frozen?]
  end

  def run
    @@s = +"class"
    a = first(*[@@s])
    @@s.gsub!("a", "o")
    p [@@s, a]

    $expanded_share_splat = +"global"
    b = first(*[$expanded_share_splat])
    b << "+"
    p [$expanded_share_splat, b]

    parameter(+"parameter")
    frozen = first(*["frozen"])
    p [frozen, frozen.frozen?]
  end
end
ExpandedShareSplat.new.run
