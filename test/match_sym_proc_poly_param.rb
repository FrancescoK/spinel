# `&:captures` on a match whose receiver is known only at run time: a program
# class's match taking &block receives it as a proc, so the block's parameter
# is a boxed slot, which the String arm's MatchData has to enter boxed.
class Mapper
  def match(path, options = nil, &block)
    "mapped #{path.inspect}"
  end
end

class Pat
  def match(other)
    "pat"
  end
end

def split_trace(trace)
  file, line = trace.match(/^(.+?):(\d+).*$/, &:captures) || trace
  [file, line]
end

traces = ["app/models/user.rb:12:in `foo'", "no colon here", Mapper.new, Pat.new]
traces.each do |t|
  p split_trace(t)
end
