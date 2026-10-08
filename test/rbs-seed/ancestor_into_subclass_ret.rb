# A seed declares a subclass return where the body returns its ancestor
# (#7278): the seed is trusted, so the function carried the subclass's C type
# and cc refused the ancestor's pointer. It is reported as a contradiction.
# spinel: rbs-seed-check
class AisBase
end

class AisUser < AisBase
end

class AisRepo
  def save_bang
    AisBase.new
  end

  def restore
    save_bang
  end

  def fresh
    AisUser.new
  end

  def plain
    fresh
  end
end

p AisRepo.new.restore.class
p AisRepo.new.plain.class
