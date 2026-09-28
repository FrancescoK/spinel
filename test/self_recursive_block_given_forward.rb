# A self-recursive method that forwards its block (`&` or `&blk`) and asks
# block_given? is a real function taking the block as a proc, the recursion
# forwarding it: no inlining can terminate on it (#5377, Phlex's render).
class T
  def yc(&b) = b ? b.call : :nb

  def render(r = nil, &)
    case r
    when Array
      render(r[0], &)
    when nil
      p yc(&) if block_given?
      p :no_block unless block_given?
    else
      p r
    end
    nil
  end

  def depth(n, acc = [], &blk)
    return acc.map { |x| blk ? blk.call(x) : x } if n == 0
    acc << n
    depth(n - 1, acc, &blk)
  end
end

T.new.render([[5]]) { :hi }
T.new.render([[nil]]) { :hi }
T.new.render([[nil]])
p T.new.depth(3) { |x| x * 10 }
p T.new.depth(2)
