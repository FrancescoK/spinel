# frozen_string_literal: true
# A method answers a String literal where every way out does: through a
# return, a conditional, a call of a method that answers one, and a `||`
# whose left side answers only nil or raises. The literal, written to a
# variable and held by a Hash, is the literal itself (#9258).
class Picker
  def initialize(table) = @table = table
  def kind_word(n) = looked_up_kind(n) || guessed_kind(n)
  def looked_up_kind(n)
    return nil unless @table
    raise NotImplementedError, "no table"
  end
  def guessed_kind(n)
    return "box" unless n
    n > 1 ? "crate" : "box"
  end
  def pick(n, log)
    word = kind_word(n)
    held = { k: word }
    x = n > 5 ? word : +"mutable"
    x << "!" unless x.frozen?
    log << word
    [held[:k], x, word.frozen?, held[:k].equal?(word)]
  end
end
log = []
p Picker.new(false).pick(2, log), Picker.new(false).pick(7, log), log
