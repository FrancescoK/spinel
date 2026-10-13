# A builder local whose String the rule shares only once the storage phase
# re-infers what its late widenings moved (an ivar's String Array boxed
# late, then the reads over it) is decided over those types: the phase runs
# its promotions again while the refresh moves a type (#8328, a Rails
# application's sanitizer output under --share-strings).
class Domain
  def initialize(name) = @name = name
  def qualify = (@name << " is blank"; nil)
end

class Column
  def initialize(name) = @name = name
  def to_s = @name
end

class Article
  def initialize
    @errors = []
  end

  def errors
    @errors
  end

  def validate(title)
    errors << "Title can't be blank" if title.empty?
    m = +"Body"
    Domain.new(m).qualify
    errors << m
    self
  end

  def summary
    out = +""
    i = 0
    while i < errors.length
      out = out + errors[i].to_s + "; "
      i += 1
    end
    out
  end
end

a = Article.new.validate("")
p a.summary, Column.new(1).to_s
