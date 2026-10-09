# spinel: share
# User singleton aliases and super keep resolving to compiled user methods.
class File
  class << self
    def basename(path) = "user:#{path}"
    alias saved_basename basename
    alias_method :other_basename, :saved_basename
  end
end
p File.saved_basename("a")
p File.other_basename("b")
class SingletonParent
  def self.read(value) = value + 1
end
class SingletonChild < SingletonParent
  def self.read(value) = super(value) + 2
end
p SingletonChild.read(3)
