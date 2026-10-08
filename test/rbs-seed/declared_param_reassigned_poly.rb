# A parameter an RBS declaration pins to its class, reassigned from a boxed
# value (`comment = subtree.shift` over a poly array read out of a group_by
# hash), took the raw sp_RbVal and the C did not compile (#4640). The write
# goes through the checked unbox: nil stays NULL, so the `if` test ends the
# walk, and the class is verified.
# spinel: rbs-seed-check
class Comment
  attr_reader :id, :parent_comment_id
  def initialize(id, parent)
    @id = id
    @parent_comment_id = parent
  end
end

def render(comment, comments)
  by_parent = comments.group_by { |x| x.parent_comment_id }
  subtree = by_parent[nil]
  out = +""
  while subtree
    if comment = subtree.shift
      out << "<li>#{comment.id}"
      children = by_parent[comment.id]
      subtree = children if children
    else
      subtree = nil
    end
  end
  out
end

puts render(Comment.new(0, nil), [Comment.new(1, nil), Comment.new(2, 1), Comment.new(3, nil)])
