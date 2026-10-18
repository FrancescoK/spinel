# A program that defines const_missing still lists only the constants
# assigned so far: `constants` called while a module's body runs leaves out
# the ones assigned after it, the constant being assigned among them. The
# const_missing hook is in another module (never called here). The listings
# are sorted: CRuby does not list constants in the order they were assigned.

module Props
  def self.all(name)
    constants.grep(/#{name}/).flat_map(&method(:const_get))
  end

  def self.names
    constants.sort
  end

  Age_V1 = %i[a b].freeze
  Age_V2 = %i[c].freeze
  Age = all(:Age_V).sort
  SEEN = names
  COUNT = 3
  LABEL = "props"
  V1 = all(:V1)
end

module Lookup
  def self.const_missing(name)
    name.to_s.start_with?("V") ? :fallback : super
  end
end

p Props::Age
p Props::SEEN
p Props::V1
p Props.constants.sort
p Props::COUNT
p Props::LABEL
p Lookup.singleton_methods
