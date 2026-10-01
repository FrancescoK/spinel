# `members` on a boxed receiver whose class answers it through an alias of
# an attr_reader: the reader's value, not the Struct member names. The alias
# is the only `members` in the program: a direct reader or a method of that
# name would take the dispatch on its own. Beside it, a Struct instance and
# a Struct class answer their member names, so the call's answer is boxed.
class Lobby
  attr_reader :payload
  alias members payload
  def initialize(v) = (@payload = v)
end

Plain = Struct.new(:a, :b)

p [Lobby.new(42), nil][0].members
[Lobby.new(7), Plain.new(1, 2), Plain].each { |o| p o.members }
