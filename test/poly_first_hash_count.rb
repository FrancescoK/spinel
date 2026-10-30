# A count-taking first/last on a value known only at run time, handed a
# count of another known type (a Hash, as a computed public_send(*args,
# **kwargs) passes every one-argument name): the runtime conversion decides,
# a TypeError for the Hash, as for an Integer-looking Float it truncates.
class Box
  def first(opts)
    "box first #{opts.inspect}"
  end
  def last(opts)
    "box last #{opts.inspect}"
  end
end

objs = [Box.new, [1, 2, 3]]
objs.each do |o|
  h = {a: 1}
  begin
    puts o.first(h)
  rescue TypeError => e
    puts "TypeError: #{e.message}"
  end
  begin
    puts o.last(h)
  rescue TypeError => e
    puts "TypeError: #{e.message}"
  end
  f = 2.0
  p o.first(f) rescue puts "TypeError"
end
