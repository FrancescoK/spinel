# Prepend returns the handle captured by its receiver, at every arity.
class PrependChainResult
  def run
    @text = +"a"
    other = @text
    other << "!"
    zero = (@text << "x").prepend
    one = (@text << "y").prepend("p")
    many = (@text << "z").prepend("q", "r", "s")
    p zero.equal?(@text), one.equal?(@text), many.equal?(@text)
    many << "?"
    p @text, other, zero

    # Evaluation of an argument may replace the variable, not the receiver.
    old = @text
    result = (@text << "u").prepend(rebind, "v")
    p result.equal?(old), result.equal?(@text)
    p old, result, @text
  end

  def rebind
    @text = +"new"
    "w"
  end
end
PrependChainResult.new.run

text = +"local"
other = text
other << "!"
result = (text << "x").prepend("p", "q")
result << "?"
p text, other, result, result.equal?(text)

text.freeze
begin
  text.prepend
rescue FrozenError
  puts "frozen"
end

nested = +"a"
alias_nested = nested
alias_nested << "!"
result = (nested << "x").prepend("p", "q").prepend("r", "s")
result << "?"
p nested, alias_nested, result, result.equal?(nested)

local = +"old"
alias_local = local
alias_local << "!"
result = local.prepend((local = +"new"; "p"), "q")
p result, alias_local, local, result.equal?(alias_local)
