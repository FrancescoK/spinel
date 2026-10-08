# A boxed argument into a parameter an --rbs seed pins to a Hash converts at
# the boundary, from a temp the statement's prelude declares. An argument
# that is itself a call whose own argument hoists a statement (the box
# `perm`'s untyped parameter takes) wrote that statement after the temp's
# `sp_RbVal _tN = `, in its initializer's place: the temp held the box, the
# call ran as a statement of its own and its result was dropped, so `upd`
# converted the caller's String-keyed input and read no :bio. Behind a
# receiver chain the C did not build.
# spinel: rbs-seed-run
class NestedArgProfile
  def initialize
    @bio = nil
  end

  def bio = @bio

  def upd(attrs)
    p attrs
    @bio = attrs[:bio] if attrs.key?(:bio)
    self
  end
end

class NestedArgForm
  def perm(input)
    out = {}
    out[:bio] = input["bio"]
    out
  end

  def run(profile, input)
    profile.upd(perm(input))
  end
end

profile = NestedArgProfile.new
NestedArgForm.new.run(profile, { "bio" => "updated" })
p profile.bio
p NestedArgProfile.new.upd(NestedArgForm.new.perm({ "bio" => "chained" })).bio
