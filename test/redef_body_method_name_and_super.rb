# A reopening's redefinition keeps the earlier body under a hidden name
# (`get#redef1`), its def renamed too: __method__ in it answers get, and its
# super looks up get, as CRuby's do.
class B
  def get = "#{__method__} #{super rescue 'nosuper'}"
  alias old get
end
class B
  def get = 2
end
p B.new.old
